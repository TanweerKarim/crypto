import 'package:crypto_app/auth/loginscreen.dart';
import 'package:crypto_app/firebase_options.dart';
import 'package:crypto_app/screens/View/home.dart';
import 'package:crypto_app/screens/view/navBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  User? firebaseUser = FirebaseAuth.instance.currentUser;
  late Widget firstWidget;
  if (firebaseUser != null) {
    debugPrint(firebaseUser.uid);
    firstWidget = NavBar();
  } else {
    firstWidget = LoginScreen();
  }
  runApp(MyApp(
    page: firstWidget,
  ));
}

class MyApp extends StatefulWidget {
  Widget page;
  MyApp({super.key, required this.page});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: widget.page,
    );
  }
}
