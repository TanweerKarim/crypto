import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/auth/register.dart';
import 'package:crypto_app/screens/View/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/view/navBar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  String deviceToken = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Crypto App",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
                  child: TextFormField(
                    onChanged: (value) => setState(() {
                      email = value;
                    }),
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.black),
                      ),
                      hintText: 'Username',
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: const EdgeInsets.only(
                    top: 10,
                  ),
                  child: TextFormField(
                    obscureText: true,
                    onChanged: (value) => setState(() {
                      password = value;
                    }),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.black),
                      ),
                      hintText: 'Password',
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: email, password: password)
                          .then((currentUser) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NavBar(),
                          ),
                          (route) => false,
                        );
                      }).onError((error, stackTrace) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.toString()),
                          ),
                        );
                      });
                    },
                    child: Text("Log in"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blueAccent //elevated btton background color
                        ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Text("Register"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.redAccent //elevated btton background color
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
