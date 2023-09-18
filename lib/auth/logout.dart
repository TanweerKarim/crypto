
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/auth/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: InkWell(
            onTap: () async {
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .update({"online": false});
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            child: ListTile(
              title: Text("Logout"),
            ),
          ),
        ),
      ),
    );
  }
}
