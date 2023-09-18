import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/screens/view/navBar.dart';
import 'package:crypto_app/utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late String uname;
  late String email;
  late String password;
  late String password1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png'),
                radius: 64),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 8.0, left: 12, right: 12),
                child: TextField(
                  onChanged: (value) => setState(() {
                    uname = value;
                  }),
                  enableSuggestions: true,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 10.0, left: 12, right: 12),
                child: TextField(
                  onChanged: (value) => setState(() {
                    email = value.toLowerCase();
                  }),
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 8.0, left: 12, right: 12),
                child: TextField(
                  onChanged: (value) => setState(() {
                    password = value;
                  }),
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Enter your password',
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 8.0, left: 12, right: 12),
                child: TextField(
                  onChanged: (value) => setState(() {
                    password1 = value;
                  }),
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'Re-enter your password',
                  ),
                  onEditingComplete: () {
                    if (password != password1) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text(""),
                                content: const Text(
                                    "Password you have entered is not matched"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ));
                    }
                  },
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 20.0, bottom: 20.0, left: 12, right: 12),
                child: SizedBox(
                  height: 50, //height of button
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () async {
                      try {
                        String userName =
                            email.substring(0, email.indexOf('@'));
                        String searchkey = email.substring(0, 1);
                        await _auth
                            .createUserWithEmailAndPassword(
                                email: email, password: password)
                            .then((signedUser) async {});

                        String uid = _auth.currentUser!.uid;
                        String photoUrl =
                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png';
                        // if (image != null) {
                        //   try {
                        //     UploadTask uploadTask = FirebaseStorage.instance
                        //         .ref()
                        //         .child('profilePic/$uid')
                        //         .putFile(image!);
                        //     TaskSnapshot snap = await uploadTask;
                        //     String downloadUrl =
                        //         await snap.ref.getDownloadURL();
                        //     photoUrl = downloadUrl;
                        //   } catch (e) {
                        //     showSnackBar(
                        //         context: context, content: e.toString());
                        //   }
                        // }
                        // await _auth.currentUser!.updatePhotoURL(photoUrl);
                        await _auth.currentUser!.updateDisplayName(uname);
                        await _firestore.collection('users').doc(uid).set({
                          'name': uname,
                          'uid': uid,
                          'profilePic': photoUrl,
                          'emailId': email,
                          'userName': userName,
                          'isVerified': false,
                          'totalFunds': 0,
                          'itemId': ['1'],
                          'profit': 0,
                          'loss': 0,
                        });
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NavBar(),
                          ),
                          (route) => false,
                        );
                      } catch (e) {
                        showSnackBar(context: context, content: e.toString());
                      }
                    },
                    child: const Text('Register'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showAlert(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => NavBar(),
      ),
      (route) => false,
    );
  }
}
