import 'package:flutter/material.dart';

import 'HomePage.dart';
import '../viewModel/EmailVerificationViewModel.dart';

class EmailVerificationPage extends StatefulWidget {
  final String userID;
  const EmailVerificationPage({super.key, required this.userID});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final EmailVerificationViewModel _vm = EmailVerificationViewModel();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _vm.sendVerificationEmail();
    _vm.startAutoCheck();
    _vm.addListener(_onChanged);
  }

  void _onChanged() {
    if (_vm.isVerified && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => homePage(userID: widget.userID),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _resend() async {
    await _vm.sendVerificationEmail(force: true);
  }

  Future<void> _checkNow() async {
    await _vm.checkVerified();
    if (!mounted) return;
    if (!_vm.isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email not verified yet. Click the link in your inbox.')),
      );
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _vm.dispose();
    super.dispose();
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
              child: Icon(Icons.mark_email_read_outlined,
                  color: Colors.white, size: 40),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Verify Your Email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 12),
          Text(
            _vm.email.isEmpty
                ? 'A verification link has been sent to your email.'
                : 'A verification link has been sent to ${_vm.email}.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          SizedBox(height: 8),
          Text(
            'Click the link in your inbox to continue.',
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
              onPressed: _vm.isLoading ? null : _checkNow,
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
                      "I've Verified",
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
