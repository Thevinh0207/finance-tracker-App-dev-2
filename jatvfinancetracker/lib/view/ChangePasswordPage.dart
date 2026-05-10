import 'package:flutter/material.dart';

import '../viewModel/PasswordResetViewModel.dart';

/// Lets a signed-in user trigger a password reset email to their own address.
///
/// We reuse [PasswordResetViewModel] which wraps `sendPasswordResetEmail` —
/// that's the safest path: Firebase verifies the user via the link, no need
/// to handle the current password ourselves.
class ChangePasswordPage extends StatefulWidget {
  final String email;
  const ChangePasswordPage({super.key, required this.email});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final PasswordResetViewModel _vm = PasswordResetViewModel();
  bool _justSent = false;

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final ok = await _vm.sendResetEmail(widget.email, true);
    if (!mounted) return;
    if (ok) {
      setState(() => _justSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) => SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A90D9), Color(0xFF1A56C4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      _justSent
                          ? Icons.mark_email_read_outlined
                          : Icons.lock_reset_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  _justSent ? 'Email Sent' : 'Reset Your Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  _justSent
                      ? 'A password reset link has been sent to ${widget.email}. Click the link in your inbox to choose a new password.'
                      : "We'll email a secure link to ${widget.email} so you can set a new password.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32),
                if (_vm.error != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 14),
                    child: Text(
                      _vm.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _vm.isLoading ? null : _sendResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A90D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: _vm.isLoading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _justSent ? 'Resend Email' : 'Send Reset Link',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (_justSent) ...[
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Back to Settings',
                      style: TextStyle(
                        color: Color(0xFF4A90D9),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
