import 'dart:convert';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/screens/Model/chartModel.dart';
import 'package:crypto_app/screens/view/buycoins.dart';
import 'package:crypto_app/screens/view/sellcoins.dart';
import 'package:crypto_app/utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class SelectCoin2 extends StatefulWidget {
  var selectItem;

  SelectCoin2({this.selectItem});

  @override
  State<SelectCoin2> createState() => _SelectCoin2State();
}

class _SelectCoin2State extends State<SelectCoin2> {
  late TrackballBehavior trackballBehavior;

  @override
  void initState() {
    getChart();
    trackballBehavior = TrackballBehavior(
        enable: true, activationMode: ActivationMode.singleTap);
    super.initState();
    getLength();
  }

  int documents = 0;
  getLength() async {
    var collection = FirebaseFirestore.instance.collection('users');
    final QuerySnapshot qSnap = await collection
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("coins")
        .doc(widget.selectItem.id)
        .collection("shares")
        .get();
    documents = qSnap.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      body: Container(
        height: myHeight,
        width: myWidth,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: myWidth * 0.05, vertical: myHeight * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                          height: myHeight * 0.08,
                          child: Image.network(widget.selectItem.image)),
                      SizedBox(
                        width: myWidth * 0.03,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectItem.id,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: myHeight * 0.01,
                          ),
                          Text(
                            widget.selectItem.symbol,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${widget.selectItem.currentPrice}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: myHeight * 0.01,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
                child: Column(
              children: [
                SizedBox(
                  height: myHeight * 0.015,
                ),
                Container(
                  height: myHeight * 0.4,
                  width: myWidth,
                  // color: Colors.amber,
                  child: isRefresh == true
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xffFBC700),
                          ),
                        )
                      : itemChart == null
                          ? Padding(
                              padding: EdgeInsets.all(myHeight * 0.06),
                              child: const Center(
                                child: Text(
                                  'Attention this Api is free, so you cannot send multiple requests per second, please wait and try again later.',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            )
                          : SfCartesianChart(
                              trackballBehavior: trackballBehavior,
                              zoomPanBehavior: ZoomPanBehavior(
                                  enablePinching: true, zoomMode: ZoomMode.x),
                              series: <CandleSeries>[
                                CandleSeries<ChartModel, int>(
                                    enableSolidCandles: true,
                                    enableTooltip: true,
                                    bullColor: Colors.green,
                                    bearColor: Colors.red,
                                    dataSource: itemChart!,
                                    xValueMapper: (ChartModel sales, _) =>
                                        sales.time,
                                    lowValueMapper: (ChartModel sales, _) =>
                                        sales.low,
                                    highValueMapper: (ChartModel sales, _) =>
                                        sales.high,
                                    openValueMapper: (ChartModel sales, _) =>
                                        sales.open,
                                    closeValueMapper: (ChartModel sales, _) =>
                                        sales.close,
                                    animationDuration: 55)
                              ],
                            ),
                ),
                SizedBox(
                  height: myHeight * 0.01,
                ),
                Center(
                  child: Container(
                    height: myHeight * 0.03,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: text.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: myWidth * 0.02),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                textBool = [
                                  false,
                                  false,
                                  false,
                                  false,
                                  false,
                                  false
                                ];
                                textBool[index] = true;
                              });
                              setDays(text[index]);
                              getChart();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: myWidth * 0.03,
                                  vertical: myHeight * 0.005),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: textBool[index] == true
                                    ? const Color(0xffFBC700).withOpacity(0.3)
                                    : Colors.transparent,
                              ),
                              child: Text(
                                text[index],
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: myHeight * 0.04,
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                          child: ListTile(
                                            leading: Image.network(
                                                widget.selectItem.image),
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const Text("Value"),
                                                      Text(
                                                        "${actualValue[i].toStringAsFixed(4)}...",
                                                        style: TextStyle(
                                                          color: profit[i]
                                                              ? Colors
                                                                  .greenAccent
                                                              : Colors
                                                                  .redAccent,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
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
              ],
            )),
            Container(
              height: myHeight * 0.1,
              width: myWidth,
              // color: Colors.amber,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  var collection = FirebaseFirestore.instance
                                      .collection('users');
                                  var docSnapshot = await collection
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .get();

                                  double funds = 0.0;
                                  if (docSnapshot.exists) {
                                    Map<String, dynamic>? data =
                                        docSnapshot.data();
                                    funds = double.parse(data?[
                                        'totalFunds']); // <-- The value you want to retrieve.
                                    // Call setState if needed.
                                  }
                                  print(funds);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (contest) => BuyCoins(
                                                funds: funds,
                                                currentPrice: widget
                                                    .selectItem.currentPrice,
                                                coinId: widget.selectItem.id,
                                              )));
                                },
                                child: const Text("Buy"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.greenAccent, // Background color
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  var collection = FirebaseFirestore.instance
                                      .collection('users');
                                  var docSnapshot = await collection
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .get();

                                  double funds = 0.0;
                                  if (docSnapshot.exists) {
                                    Map<String, dynamic>? data =
                                        docSnapshot.data();
                                    funds = double.parse(data?[
                                        'totalFunds']); // <-- The value you want to retrieve.
                                    // Call setState if needed.
                                  }
                                  if (documents != 0) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (contest) => SellCoins(
                                                  funds: funds,
                                                  currentPrice: widget
                                                      .selectItem.currentPrice,
                                                  coinId: widget.selectItem.id,
                                                  selectItem: widget.selectItem,
                                                  numberOfTrades: documents,
                                                )));
                                  } else {
                                    showSnackBar(
                                        context: context,
                                        content: "You dont have coins to sell");
                                  }
                                },
                                child: const Text("Sell"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.redAccent, // Background color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  List<String> text = ['D', 'W', 'M', '3M', '6M', 'Y'];
  List<bool> textBool = [true, false, false, false, false, false];

  int days = 1;

  setDays(String txt) {
    if (txt == 'D') {
      setState(() {
        days = 1;
      });
    } else if (txt == 'W') {
      setState(() {
        days = 7;
      });
    } else if (txt == 'M') {
      setState(() {
        days = 30;
      });
    } else if (txt == '3M') {
      setState(() {
        days = 90;
      });
    } else if (txt == '6M') {
      setState(() {
        days = 180;
      });
    } else if (txt == 'Y') {
      setState(() {
        days = 365;
      });
    }
  }

  List<ChartModel>? itemChart;

  bool isRefresh = true;

  Future<void> getChart() async {
    String url =
        '${'https://api.coingecko.com/api/v3/coins/' + widget.selectItem.id}/ohlc?vs_currency=usd&days=$days';

    setState(() {
      isRefresh = true;
    });

    var response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });

    setState(() {
      isRefresh = false;
    });
    if (response.statusCode == 200) {
      Iterable x = json.decode(response.body);
      List<ChartModel> modelList =
          x.map((e) => ChartModel.fromJson(e)).toList();
      setState(() {
        itemChart = modelList;
      });
    } else {
      print(response.statusCode);
    }
  }
}
