import 'dart:collection';

import 'package:action_slider/action_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/screens/view/home.dart';
import 'package:crypto_app/screens/view/navBar.dart';
import 'package:crypto_app/utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SellCoins extends StatefulWidget {
  double funds;
  double currentPrice;
  String coinId;
  var selectItem;
  int numberOfTrades;

  SellCoins({
    super.key,
    required this.funds,
    required this.currentPrice,
    required this.coinId,
    required this.selectItem,
    required this.numberOfTrades,
  });

  @override
  State<SellCoins> createState() => _SellCoinsState();
}

class _SellCoinsState extends State<SellCoins> {
  TextEditingController controllerText = TextEditingController();
  String fundValue = '0';
  bool haveValue = false;
  double numberOfCoins = 0.0;
  double userFunds = 0.0;
  double totalAmt2 = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      userFunds = widget.funds;
    });
    setBoolVal();
  }

  List<bool> checked = [];
  List<double> totalAmt = [];
  HashSet<String> ids = HashSet();

  setBoolVal() {
    for (int i = 0; i < widget.numberOfTrades; i++) {
      checked.add(false);
      totalAmt.add(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sell"),
        backgroundColor: Color.fromARGB(226, 104, 102, 102),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                "Trades",
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Container(
                  height: 250,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("coins")
                        .doc(widget.selectItem.id)
                        .collection('shares')
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final List storedocs = [];
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map a = document.data() as Map<String, dynamic>;
                        storedocs.add(a);
                      }).toList();
                      List<double> actualValue = [];
                      List<bool> profit = [];
                      double totalCoins = 0.0;
                      for (int i = 0; i < storedocs.length; i++) {
                        double totalShares =
                            double.parse(storedocs[i]['shares']);
                        double cp =
                            totalShares * double.parse(storedocs[i]['rate']);
                        double sp =
                            totalShares * widget.selectItem.currentPrice;
                        double profitOrLoss = 0.0;
                        double actualValue1 = 0.0;
                        if (cp > sp) {
                          profitOrLoss = cp - sp;
                          actualValue1 = cp - profitOrLoss;
                          profit.add(false);
                        } else {
                          profitOrLoss = sp - cp;
                          actualValue1 = cp + profitOrLoss;
                          profit.add(true);
                        }
                        actualValue.add(actualValue1);
                        totalCoins =
                            totalCoins + double.parse(storedocs[i]['shares']);
                      }
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 18),
                                child: Row(
                                  children: [
                                    const Text(
                                      "Your coins : ",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(
                                      "${totalCoins.toStringAsFixed(5)}...",
                                      style: TextStyle(fontSize: 20),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: ListView(
                                  children: [
                                    for (int i = 0;
                                        i < storedocs.length;
                                        i++) ...[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CheckboxListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Image.network(
                                                widget.selectItem.image,
                                                scale: 5,
                                              ),
                                              SizedBox(
                                                width: 20,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Text("Coins"),
                                                    Text(
                                                        "${double.parse(storedocs[i]['shares']).toStringAsFixed(4)}..."),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Text("Value"),
                                                    Text(
                                                      "${actualValue[i].toStringAsFixed(4)}...",
                                                      style: TextStyle(
                                                        color: profit[i]
                                                            ? Colors.greenAccent
                                                            : Colors.redAccent,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          value: checked[i],
                                          onChanged: (bool? value) {
                                            if (value!) {
                                              setState(() {
                                                checked[i] = true;
                                                totalAmt[i] = actualValue[i];
                                                ids.add(storedocs[i]['id']);
                                              });
                                            } else {
                                              setState(() {
                                                checked[i] = false;
                                                totalAmt[i] = 0.0;
                                                ids.remove(storedocs[i]['id']);
                                              });
                                            }
                                            double tmt = 0.0;
                                            for (int i = 0;
                                                i < widget.numberOfTrades;
                                                i++) {
                                              setState(() {
                                                tmt = tmt + totalAmt[i];
                                              });
                                            }
                                            for (int i = 0;
                                                i < widget.numberOfTrades;
                                                i++) {
                                              if (checked[i] == true) {
                                                setState(() {
                                                  haveValue = true;
                                                });
                                                break;
                                              } else {
                                                setState(() {
                                                  haveValue = false;
                                                });
                                              }
                                            }
                                            setState(() {
                                              totalAmt2 = tmt;
                                            });
                                            print(ids);
                                          },
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ));
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              if (haveValue) ...[
                Row(
                  children: [
                    Text("Total Amount : "),
                    Text(totalAmt2.toString()),
                  ],
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
                      double bal = widget.funds;
                      print(ids.elementAt(0));
                      for (int i = 0; i < ids.length; i++) {
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection("coins")
                            .doc(widget.coinId)
                            .collection("shares")
                            .doc(ids.elementAt(i))
                            .delete();
                      }
                      bal = bal + totalAmt2;
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({"totalFunds": bal.toString()});
                      controller.success(); //starts success animation
                      await Future.delayed(const Duration(seconds: 1));
                      print(bal);
                      setState(() {
                        totalAmt2 = 0.0;
                      });
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NavBar(),
                        ),
                        (route) => false,
                      );
                      showSnackBar(
                          context: context,
                          content:
                              "Trade successfully sold"); //resets the slider
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
