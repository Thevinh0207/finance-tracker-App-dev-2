import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:qr_flutter/qr_flutter.dart';

import '../Repository/UserSettingsRepository.dart';

class TotpSetupPage extends StatefulWidget {
  final String userID;
  final String email;

  const TotpSetupPage({
    super.key,
    required this.userID,
    required this.email,
  });

  @override
  State<TotpSetupPage> createState() => _TotpSetupPageState();
}

class _TotpSetupPageState extends State<TotpSetupPage> {
  final UserSettingsRepository _settingsRepo = UserSettingsRepository();
  final TextEditingController _codeCtrl = TextEditingController();

  fb.TotpSecret? _secret;
  String? _qrUri;
  bool _isLoading = true;
  bool _isVerifying = false;
  bool _enrolled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateSecret();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateSecret() async {
    try {
      final user = fb.FirebaseAuth.instance.currentUser!;
      final session = await user.multiFactor.getSession();
      final secret = await fb.TotpMultiFactorGenerator.generateSecret(session);
      final qrUri = secret.generateQrCodeUrl(
        accountName: widget.email,
        issuer: 'JATVFinance',
      );
      if (!mounted) return;
      setState(() {
        _secret = secret;
        _qrUri = qrUri;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to generate secret: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _enroll() async {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code from your authenticator app.');
      return;
    }
    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final user = fb.FirebaseAuth.instance.currentUser!;
      final assertion = fb.TotpMultiFactorGenerator.getAssertionForEnrollment(
        _secret!,
        code,
      );
      await user.multiFactor.enroll(assertion, displayName: 'Authenticator App');

      // Mirror the flag in Firestore so ProfileSettingsPage can show the right state.
      final settings = await _settingsRepo.getOrCreate(widget.userID);
      await _settingsRepo.save(settings.copyWith(twoFactorEnabled: true));

      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _enrolled = true;
      });
    } on fb.FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _error = e.message ?? 'Verification failed. Check the code and try again.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _error = 'Enrollment failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Set Up Authenticator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFF4A90D9)))
            : _enrolled
                ? _buildSuccess()
                : _buildSetupBody(theme),
      ),
    );
  }

  Widget _buildSetupBody(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A90D9), Color(0xFF1A56C4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 36),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Link Your Authenticator App',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Scan the QR code below with Google Authenticator, Authy,\nor any TOTP-compatible app.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
          ),
          SizedBox(height: 28),

          // QR Code
          if (_qrUri != null && _error == null) ...[
            Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _qrUri!,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Manual secret key (tap to copy)
            Text(
              'Or enter this key manually in your app:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: _secret!.secretKey));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Secret key copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(0xFF4A90D9).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _secret!.secretKey,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          letterSpacing: 1.5,
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.copy, size: 18, color: Color(0xFF4A90D9)),
                  ],
                ),
              ),
            ),
          ],

          if (_error != null && _secret == null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),

          SizedBox(height: 28),

          // Step 2 label
          Text(
            'Step 2 — Enter the 6-digit code from your app:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 10),

          // Code input
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '000000',
              hintStyle: TextStyle(
                letterSpacing: 8,
                color: Colors.grey.shade400,
                fontSize: 24,
              ),
              filled: true,
              fillColor: theme.cardColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFDDE1EA), width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF4A90D9), width: 2),
              ),
            ),
          ),
          SizedBox(height: 16),

          if (_error != null && _secret != null)
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (_isVerifying || _secret == null) ? null : _enroll,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A90D9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: Color(0xFF4A90D9).withOpacity(0.4),
              ),
              child: _isVerifying
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Verify & Enable 2FA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green, size: 52),
            ),
            SizedBox(height: 24),
            Text(
              'Two-Factor Authentication Enabled!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "Your account is now secured with your authenticator app. "
              "You'll be asked for a code each time you sign in.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4A90D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
