import 'package:flutter/material.dart';

void main() => runApp(loginPage());

class loginPage extends StatelessWidget {
  const loginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loginCard(),
    );
  }
}

class loginCard extends StatefulWidget {
  const loginCard({super.key});

  @override
  State<loginCard> createState() => _loginCardState();
}

class _loginCardState extends State<loginCard> {



  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

