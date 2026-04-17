import 'package:flutter/material.dart';


void main() => runApp(signUpPage());

class signUpPage extends StatelessWidget {
  const signUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: signUpCard()
    );
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}

