import 'package:flutter/material.dart';
import 'package:jatvfinancetracker/view/loginPage.dart';
import 'PasswordResetPage.dart';
import '../viewModel/ForgotPasswordViewModel.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ForgotPasswordCard();
  }
}

class ForgotPasswordCard extends StatefulWidget {
  const ForgotPasswordCard({super.key});

  @override
  State<ForgotPasswordCard> createState() => _ForgotPasswordCardState();
}

class _ForgotPasswordCardState extends State<ForgotPasswordCard> {
  final TextEditingController emailController = TextEditingController();
  final ForgotPasswordViewModel _vm = ForgotPasswordViewModel();

  @override
  void dispose() {
    emailController.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await _vm.sendResetEmail();
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PasswordResetPage(email: _vm.email),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      body: Center(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) => _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      height: 440,
      width: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.mail_outlined, color: Colors.white, size: 50),
          ),
          SizedBox(height: 15),
          Text(
            'RESET PASSWORD',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
          ),
          Text("Enter your email address and we'll send you "),
          Text("instructions to reset your password"),
          SizedBox(height: 20),
          SizedBox(
            width: 300,
            child: TextField(
              showCursor: true,
              controller: emailController,
              onChanged: _vm.setEmail,
              decoration: InputDecoration(
                hintText: 'Enter Email',
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_vm.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                _vm.error!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _vm.isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.blue,
              minimumSize: Size(300, 50),
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
                    'Send Reset Link',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }
}

class successPage extends StatelessWidget {
  final String email;

  const successPage(this.email, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 65,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Check Your Email',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 3),
              Text("We've sent password reset instructions to "),
              Text(email, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => loginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Container(
                  height: 50,
                  width: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      'Back to login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                height: 50,
                width: 300,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Resend Email',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
