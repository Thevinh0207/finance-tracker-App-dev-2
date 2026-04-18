import 'package:flutter/material.dart';


void main() => runApp(signUpPage());

class signUpPage extends StatelessWidget {
  const signUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: signUpCard());
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

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  String message = '';

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
            colors: [
              Colors.blueAccent,
              Colors.lightBlueAccent,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
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
                                      decoration: InputDecoration(
                                        hintText: 'First name',
                                        fillColor: Colors.white,
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
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
                                      decoration: InputDecoration(
                                        hintText: 'Last name',
                                        fillColor: Colors.white,
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        _buildField(
                          label: 'Enter Email:',
                          hint: 'Enter Email',
                          controller: emailController,
                        ),

                        SizedBox(height: 20),

                        _buildField(
                          label: 'Enter Password:',
                          hint: 'Enter password',
                          controller: passwordController,
                          obscure: hidePassword,
                          suffixIcon: IconButton(
                            icon: Icon(hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => hidePassword = !hidePassword),
                          ),
                        ),

                        SizedBox(height: 20),

                        _buildField(
                          label: 'Confirm Password:',
                          hint: 'Re-enter password',
                          controller: confirmPasswordController,
                          obscure: hideConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(hideConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                    () => hideConfirmPassword = !hideConfirmPassword),
                          ),
                        ),

                        SizedBox(height: 16),

                        if (message.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              message,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),

                        SizedBox(height: 4),

                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (firstNameController.text.isEmpty ||
                                  lastNameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  passwordController.text.isEmpty) {
                                message = 'Please fill in all fields.';
                              } else if (passwordController.text !=
                                  confirmPasswordController.text) {
                                message = 'Passwords do not match.';
                              } else {
                                message = '';
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.blue,
                            minimumSize: Size(300, 50),
                          ),
                          child: Text(
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
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
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