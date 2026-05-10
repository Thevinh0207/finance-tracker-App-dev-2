import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/FirebaseConfig.dart';
import 'util/AppRouteObserver.dart';
import 'util/AppTheme.dart';
import 'util/ThemeController.dart';
import 'view/SplashScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: FirebaseConfig.getOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeController.instance.isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        navigatorObservers: [appRouteObserver],
        home: const SplashScreen(),
      ),
    );
  }
}
