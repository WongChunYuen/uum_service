import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homestay Raya',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme.apply(),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
