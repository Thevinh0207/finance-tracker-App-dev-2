import 'package:flutter/material.dart';

void main() => runApp(loginPage());

class loginPage extends StatelessWidget {
  const loginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: loginCard());
  }
}

class loginCard extends StatefulWidget {
  const loginCard({super.key});

  @override
  State<loginCard> createState() => _loginCardState();
}

class _loginCardState extends State<loginCard> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            loginInputCard(
              context,
              emailController,
              passwordController,
              message,
            ),
          ],
        ),
      ),
    );
  }
}

Widget loginInputCard(
  BuildContext context,
  TextEditingController emailController,
  TextEditingController passwordController,
  String message,
) {
  return Card(
    margin: EdgeInsets.all(16),
    shadowColor: Colors.black12,
    child: Container(
      height: 400,
      width: 400,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 5),
          Text('Login'),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 3),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        textAlign: TextAlign.left,
                        'Enter Email:',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
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
                      controller: passwordController,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 3),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        textAlign: TextAlign.left,
                        'Enter Password:',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      controller: passwordController,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(message),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            child: Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              backgroundColor: Colors.blue,
              minimumSize: Size(300, 50),
            ),
          ),
        ],
      ),
    ),
  );
}
