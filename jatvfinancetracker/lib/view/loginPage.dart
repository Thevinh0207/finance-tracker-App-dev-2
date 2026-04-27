import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import 'ForgotPasswordPage.dart';
import 'signUpPage.dart';
import 'HomePage.dart';
import '2FAPage.dart';
import 'EmailVerificationPage.dart';
import '../viewModel/LoginViewModel.dart';
import '../Repository/UserSettingsRepository.dart';

class loginPage extends StatelessWidget {
  const loginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return loginCard();
  }
}

class loginCard extends StatefulWidget {
  const loginCard({super.key});

  @override
  State<loginCard> createState() => _loginCardState();
}

class _loginCardState extends State<loginCard> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LoginViewModel _vm = LoginViewModel();
  final UserSettingsRepository _settingsRepo = UserSettingsRepository();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await _vm.login();
    if (!mounted) return;
    if (success) {
      final userID = _vm.user!.userID;
      final authUser = fb.FirebaseAuth.instance.currentUser;

      if (authUser != null && !authUser.emailVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationPage(userID: userID),
          ),
        );
        return;
      }

      final settings = await _settingsRepo.getOrCreate(userID);
      if (!mounted) return;
      if (settings.twoFactorEnabled) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TwoFactorPage(
              userID: userID,
              email: _vm.user!.email,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => homePage(userID: userID),
          ),
        );
      }
    } else if (_vm.mfaRequired) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TwoFactorPage(resolver: _vm.mfaResolver!),
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
          child: ListenableBuilder(
            listenable: _vm,
            builder: (context, _) => _buildCard(),
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
        height: 500,
        width: 500,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            SizedBox(
              width: 300,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Login',
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
            SizedBox(height: 10),
            SizedBox(
              width: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _vm.rememberMe,
                        onChanged: (v) => _vm.setRememberMe(v ?? false),
                        activeColor: Colors.lightBlue,
                        checkColor: Colors.white,
                      ),
                      Text('Remember me'),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_vm.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Text(
                  _vm.error!,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 3),
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
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => signUpPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
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
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
