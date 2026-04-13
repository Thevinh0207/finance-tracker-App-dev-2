import 'package:flutter/material.dart';

void main() => runApp(homePage());

class homePage extends StatelessWidget {
  const homePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: mainDashboard(),
    );
  }
}

class mainDashboard extends StatefulWidget {
  const mainDashboard({super.key});

  @override
  State<mainDashboard> createState() => _mainDashboardState();
}

class _mainDashboardState extends State<mainDashboard> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
