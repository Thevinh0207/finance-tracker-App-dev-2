import 'package:flutter/material.dart';

import 'EmailVerificationPage.dart';
import '/viewModel/SignUpViewModel.dart';
import 'loginPage.dart';

class signUpPage extends StatelessWidget {
  const signUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return signUpCard();
  }
}

class signUpCard extends StatefulWidget {
  const signUpCard({super.key});

  @override
  State<signUpCard> createState() => _signUpCardState();
}

class _signUpCardState extends State<signUpCard> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final SignUpViewModel _vm = SignUpViewModel();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await _vm.signUp();
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EmailVerificationPage(userID: _vm.user!.userID),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ListenableBuilder(
              listenable: _vm,
              builder: (context, _) => _buildCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Card(
      margin: EdgeInsets.all(16),
      shadowColor: Colors.black12,
      child: Container(
        width: 500,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'First Name:',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: firstNameController,
                          onChanged: _vm.setFirstName,
                          decoration: _inputDecoration('First name'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last Name:',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: lastNameController,
                          onChanged: _vm.setLastName,
                          decoration: _inputDecoration('Last name'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _field(
              label: 'Enter Email:',
              hint: 'Enter Email',
              controller: emailController,
              onChanged: _vm.setEmail,
            ),
            SizedBox(height: 20),
            _field(
              label: 'Enter Password:',
              hint: 'Enter password',
              controller: passwordController,
              onChanged: _vm.setPassword,
              obscure: _vm.hidePassword,
              suffixIcon: IconButton(
                icon: Icon(_vm.hidePassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: _vm.togglePasswordVisibility,
              ),
            ),
            SizedBox(height: 20),
            _field(
              label: 'Confirm Password:',
              hint: 'Re-enter password',
              controller: confirmPasswordController,
              onChanged: _vm.setConfirmPassword,
              obscure: _vm.hideConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(_vm.hideConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: _vm.toggleConfirmPasswordVisibility,
              ),
            ),
            SizedBox(height: 16),
            if (_vm.error != null)
              Padding(
                padding:  EdgeInsets.only(bottom: 8),
                child: Text(
                  _vm.error!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 4),
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
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => loginPage())
                );

              },
              child: Text(
                'Already have an account? Log in',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: onChanged,
            obscureText: obscure,
            showCursor: true,
            decoration: _inputDecoration(hint, suffixIcon: suffixIcon),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      fillColor: Colors.white,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }
}