import 'package:action_slider/action_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class BuyCoins extends StatefulWidget {
  double funds;
  double currentPrice;
  String coinId;

  BuyCoins({
    super.key,
    required this.funds,
    required this.currentPrice,
    required this.coinId,
  });

  @override
  State<BuyCoins> createState() => _BuyCoinsState();
}

class _BuyCoinsState extends State<BuyCoins> {
  TextEditingController controllerText = new TextEditingController();
  String fundValue = '0';
  bool haveValue = false;
  double numberOfCoins = 0.0;
  double userFunds = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      userFunds = widget.funds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buy"),
        backgroundColor: Color.fromARGB(226, 104, 102, 102),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Your Balance : ",
                    style: TextStyle(fontSize: 25),
                  ),
                  Text(
                    userFunds.toString(),
                    style: TextStyle(fontSize: 25),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
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
                    numberOfCoins =
                        double.parse(controllerText.text) / widget.currentPrice;
                  });
                  setState(() {
                    fundValue = value;
                  });
                },
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    hintText: 'Enter amount',
                    suffixIconColor: Colors.black),
              ),
              SizedBox(
                height: 10,
              ),
              if (haveValue) ...[
                Text(
                  "Buy : " + numberOfCoins.toString() + " coins",
                ),
                Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ActionSlider.standard(
                    sliderBehavior: SliderBehavior.stretch,
                    width: 300.0,
                    backgroundColor: Colors.white,
                    toggleColor: Colors.lightGreenAccent,
                    action: (controller) async {
                      controller.loading(); //starts loading animation
                      await Future.delayed(const Duration(seconds: 3));
                      double coinRate = widget.currentPrice;
                      double shares =
                          double.parse(controllerText.text) / coinRate;
                      double bal = 0.0;
                      if (widget.funds >= double.parse(controllerText.text)) {
                        bal = widget.funds - double.parse(controllerText.text);
                        var timeSent = DateTime.now();
                        var shareid = const Uuid().v1();
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({"totalFunds": bal.toString()});
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection("coins")
                            .doc(widget.coinId)
                            .collection("shares")
                            .doc(shareid)
                            .set({
                          "id": shareid,
                          "rate": widget.currentPrice.toString(),
                          "shares": shares.toString(),
                          "timestamp": timeSent,
                        });
                        controller.success(); //starts success animation
                        await Future.delayed(const Duration(seconds: 1));
                        print(bal);
                        setState(() {
                          userFunds = bal;
                        });
                        controllerText.clear();
                        setState(() {
                          fundValue = '';
                          haveValue = false;
                        });
                        controller.reset();
                      } else {
                        showSnackBar(
                            context: context, content: "Insufficient funds");
                        setState(() {
                          fundValue = '';
                          haveValue = false;
                        });
                      }
                      controller.reset(); //resets the slider
                    },
                    child: const Text('Slide to confirm'),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
