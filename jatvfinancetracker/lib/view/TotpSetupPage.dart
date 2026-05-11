import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';
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

  late final String _secret;
  late final String _qrUri;

  bool _isVerifying = false;
  bool _enrolled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _secret = _generateBase32Secret();
    _qrUri = _buildOtpAuthUri(_secret);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Generates a cryptographically random 20-byte secret encoded as base32.
  /// This is the standard length used by Google Authenticator.
  String _generateBase32Secret() {
    final rng = Random.secure();
    final bytes = List<int>.generate(20, (_) => rng.nextInt(256));
    return _base32Encode(bytes);
  }

  String _base32Encode(List<int> bytes) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    var result = StringBuffer();
    var buffer = 0;
    var bitsLeft = 0;
    for (final byte in bytes) {
      buffer = (buffer << 8) | (byte & 0xff);
      bitsLeft += 8;
      while (bitsLeft >= 5) {
        bitsLeft -= 5;
        result.write(alphabet[(buffer >> bitsLeft) & 0x1f]);
      }
    }
    if (bitsLeft > 0) {
      result.write(alphabet[(buffer << (5 - bitsLeft)) & 0x1f]);
    }
    return result.toString();
  }

  String _buildOtpAuthUri(String secret) {
    final issuer = Uri.encodeComponent('JATVFinance');
    final account = Uri.encodeComponent(widget.email);
    return 'otpauth://totp/$issuer:$account'
        '?secret=$secret'
        '&issuer=$issuer'
        '&algorithm=SHA1'
        '&digits=6'
        '&period=30';
  }

  /// Checks the code against the current 30-second window AND the previous one
  /// to handle slight clock differences between the phone and the server.
  bool _verifyCode(String code) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final current = OTP.generateTOTPCodeString(
      _secret,
      now,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );
    final previous = OTP.generateTOTPCodeString(
      _secret,
      now - 30000,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );
    return code == current || code == previous;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

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

    if (!_verifyCode(code)) {
      setState(() {
        _isVerifying = false;
        _error = 'Incorrect code. Make sure you scanned the right QR code and try again.';
      });
      return;
    }

    try {
      // Store the secret and enable 2FA in Firestore.
      final settings = await _settingsRepo.getOrCreate(widget.userID);
      await _settingsRepo.save(
        settings.copyWith(twoFactorEnabled: true, totpSecret: _secret),
      );

      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _enrolled = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _error = 'Failed to save 2FA settings: $e';
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
        child: _enrolled ? _buildSuccess() : _buildSetupBody(theme),
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
            'Step 1 — Scan this QR code',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Open Google Authenticator or Authy and scan the code below.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
          ),
          SizedBox(height: 24),

          // QR Code
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
                data: _qrUri,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20),

          // Manual secret key
          Text(
            "Can't scan? Enter this key manually:",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _secret));
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
                      _secret,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
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

          SizedBox(height: 28),
          Divider(),
          SizedBox(height: 20),

          // Step 2
          Text(
            'Step 2 — Enter the 6-digit code from your app',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 10),

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

          if (_error != null)
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
              onPressed: _isVerifying ? null : _enroll,
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "Your account is now secured. You'll be asked for a "
              "6-digit code from your authenticator app each time you sign in.",
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
