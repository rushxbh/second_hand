import 'package:flutter/material.dart';
import 'package:traderhub/main_screen.dart';
import 'package:traderhub/profile_page.dart';
import 'home_page.dart';
import 'auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// import 'package:flutter/material.dart';
void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use the generated options
  );
  runApp(const BarterApp());
}

class BarterApp extends StatelessWidget {
  const BarterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barter System App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green[50],
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthPage(),
       '/main': (context) => const MainScreen(), // Wrapper with bottom nav
      },
    );
  }
}
