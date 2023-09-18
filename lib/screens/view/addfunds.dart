import 'dart:io';

import 'package:action_slider/action_slider.dart';
import 'package:checkout_screen_ui/checkout_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/screens/Model/usermodels.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFunds extends StatefulWidget {
  const AddFunds({super.key});

  @override
  State<AddFunds> createState() => _AddFundsState();
}

class _AddFundsState extends State<AddFunds> {
  String fundValue = '0';
  bool haveValue = false;

  TextEditingController controllerText = new TextEditingController();

  haveValueInTextField(String value) {
    if (value != '0')
      setState(() {
        haveValue = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Funds"),
        backgroundColor: Color.fromARGB(226, 104, 102, 102),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: myHeight,
          width: myWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 106, 104, 104),
                  Color.fromARGB(255, 7, 7, 7),
                ]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: myWidth * 0.07),
                child: StreamBuilder<UserModel>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots()
                        .map(
                          (event) => UserModel.fromMap(event.data()!),
                        ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Funds: \$ " +
                                snapshot.data!.totalFunds.toString(),
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                    }),
              ),
              SizedBox(
                height: myHeight * 0.02,
              ),
              Container(
                height: myHeight * 0.7,
                width: myWidth,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 5,
                          color: Colors.grey.shade300,
                          spreadRadius: 3,
                          offset: Offset(0, 3))
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 10),
                      child: Text(
                        "Add Funds",
                        style: TextStyle(fontSize: 35),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: controllerText,
                        onChanged: (value) {
                          debugPrint(value);
                          if (value != '' && value != '0') {
                            setState(() {
                              haveValue = true;
                            });
                          } else {
                            setState(() {
                              haveValue = false;
                            });
                          }
                          setState(() {
                            fundValue = value;
                          });
                        },
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0)),
                            ),
                            hintText: 'Add Funds',
                            suffixIconColor: Colors.black),
                      ),
                    ),
                    if (haveValue) ...[
                      SizedBox(height: 230),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ActionSlider.standard(
                            sliderBehavior: SliderBehavior.stretch,
                            width: 300.0,
                            backgroundColor: Colors.white,
                            toggleColor: Colors.lightGreenAccent,
                            action: (controller) async {
                              controller.loading(); //starts loading animation
                              await Future.delayed(const Duration(seconds: 3));

                              controller.success(); //starts success animation
                              await Future.delayed(const Duration(seconds: 1));
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({'totalFunds': controllerText.text});
                              print(controllerText.text);
                              controllerText.clear();
                              setState(() {
                                fundValue = '';
                                haveValue = false;
                              });
                              print(controllerText.text);
                              print(fundValue);
                              controller.reset(); //resets the slider
                            },
                            child: const Text('Slide to confirm'),
                          ),
                        ),
                      )
                    ]
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
