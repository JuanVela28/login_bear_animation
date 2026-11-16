import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login_bear_animation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint('ÉXITO: Firebase inicializado correctamente.');
  } catch (e) {
    debugPrint('ERROR al inicializar Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LoginScreen(),
    );
  }
}
