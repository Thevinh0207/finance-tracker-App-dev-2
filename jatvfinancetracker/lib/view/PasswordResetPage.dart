import 'package:flutter/material.dart';

import 'loginPage.dart';
import '../viewModel/PasswordResetViewModel.dart';

class PasswordResetPage extends StatefulWidget {
  final String email;
  const PasswordResetPage({super.key, required this.email});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final PasswordResetViewModel _vm = PasswordResetViewModel();

  @override
  void initState() {
    super.initState();
    // Email was already sent by ForgotPasswordPage. Only Resend re-triggers.
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    await _vm.sendResetEmail(widget.email, true);
  }

  void _backToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => loginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Color(0xFFF4F6FA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) => _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 40),
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
              child: Icon(Icons.lock_reset_outlined,
                  color: Colors.white, size: 40),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Reset Your Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 12),
          Text(
            widget.email.isEmpty
                ? 'A password reset link has been sent to your email.'
                : 'A password reset link has been sent to ${widget.email}.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          SizedBox(height: 8),
          Text(
            'Click the link in your inbox to choose a new password.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          SizedBox(height: 36),
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
              onPressed: _vm.isLoading ? null : _backToLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A90D9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              child: _vm.isLoading
                  ? SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(
                      'Back to Login',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: _vm.isLoading ? null : _resend,
            child: Text(
              'Resend Email',
              style: TextStyle(
                color: Color(0xFF4A90D9),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
