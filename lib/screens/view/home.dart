import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto_app/screens/Model/coinModel.dart';
import 'package:crypto_app/screens/Model/singleCoinData.dart';
import 'package:crypto_app/screens/Model/usermodels.dart';
import 'package:crypto_app/screens/View/Components/item.dart';
import 'package:crypto_app/screens/View/Components/item2.dart';
import 'package:crypto_app/screens/view/Components/item3.dart';
import 'package:crypto_app/screens/view/addfunds.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String fund = '0';

  @override
  void initState() {
    getCoinMarket();
    getChart();
    super.initState();
  }

  late Stream<DocumentSnapshot<Map<String, dynamic>>> personnalData =
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();
  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
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
            Padding(
              padding: EdgeInsets.symmetric(vertical: myHeight * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: myWidth * 0.02, vertical: myHeight * 0.005),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      'Main portfolio',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: myWidth * 0.07),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<UserModel>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .snapshots()
                          .map(
                            (event) => UserModel.fromMap(event.data()!),
                          ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (contest) => AddFunds()));
                          },
                          child: Text(
                            "\$ " +
                                double.parse(snapshot.data!.totalFunds)
                                    .toStringAsFixed(2) +
                                "..",
                            style: TextStyle(fontSize: 35, color: Colors.white),
                          ),
                        );
                      }),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: myWidth * 0.07),
              child: Row(
                children: [
                  Text(
                    '+0% all time',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
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
                children: [
                  SizedBox(
                    height: myHeight * 0.03,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: myWidth * 0.08),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Assets',
                          style: TextStyle(fontSize: 20),
                        ),
                        Icon(Icons.add)
                      ],
                    ),
                  ),
                  SizedBox(
                    height: myHeight * 0.02,
                  ),
                  Container(
                    height: myHeight * 0.29,
                    child: isRefreshing == true
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Color(0xffFBC700),
                            ),
                          )
                        : coinMarket == null || coinMarket!.length == 0
                            ? Padding(
                                padding: EdgeInsets.all(myHeight * 0.06),
                                child: Center(
                                  child: Text(
                                    'Attention this Api is free, so you cannot send multiple requests per second, please wait and try again later.',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              )
                            : Container(
                                height: 500,
                                child: StreamBuilder<DocumentSnapshot>(
                                    stream: personnalData,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox();
                                      }
                                      return ListView(
                                        children: [
                                          for (int i = 0;
                                              i <
                                                  snapshot
                                                      .data!['itemId'].length;
                                              i++) ...[
                                            Item3(
                                              item: addedToPortFolio![i],
                                            ),
                                          ]
                                          // Container(),
                                        ],
                                      );
                                    }),
                              ),
                    // : ListView.builder(
                    //     itemCount: 4,
                    //     shrinkWrap: true,
                    //     itemBuilder: (context, index) {
                    // return Item(
                    //   item: coinMarket![index],
                    // );
                    //     },
                    //   ),
                  ),
                  SizedBox(
                    height: myHeight * 0.02,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: myWidth * 0.05),
                    child: Row(
                      children: [
                        Text(
                          'Recommend to Buy',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: myHeight * 0.01,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: myWidth * 0.03),
                      child: isRefreshing == true
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color(0xffFBC700),
                              ),
                            )
                          : coinMarket == null || coinMarket!.length == 0
                              ? Padding(
                                  padding: EdgeInsets.all(myHeight * 0.06),
                                  child: Center(
                                    child: Text(
                                      'Attention this Api is free, so you cannot send multiple requests per second, please wait and try again later.',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Container(
                                    height: 200,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: coinMarket!.length,
                                      itemBuilder: (context, index) {
                                        return Item2(
                                          item: coinMarket![index],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                    ),
                  ),
                  SizedBox(
                    height: myHeight * 0.01,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  bool isRefreshing = true;

  List? coinMarket = [];
  var coinMarketList;
  Future<List<CoinModel>?> getCoinMarket() async {
    const url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&sparkline=true';

    setState(() {
      isRefreshing = true;
    });
    var response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });
    setState(() {
      isRefreshing = false;
    });
    if (response.statusCode == 200) {
      var x = response.body;
      coinMarketList = coinModelFromJson(x);
      setState(() {
        coinMarket = coinMarketList;
      });
    } else {
      print(response.statusCode);
    }
  }

  List? addedToPortFolio = [];
  var addedToPortFolioList;

  bool isRefresh = true;

  Future<void> getChart() async {
    var collection = FirebaseFirestore.instance.collection('users');
    var docSnapshot =
        await collection.doc(FirebaseAuth.instance.currentUser!.uid).get();
    List funds = [];
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      funds = data?['itemId']; // <-- The value you want to retrieve.
      // Call setState if needed.
    }
    print(funds[0]);
    String url =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=';
    for (int i = 0; i < funds.length; i++) {
      if (i != 0) {
        url = url + "%2C" + funds[i];
      } else {
        url = url + funds[i];
      }
    }
    print(url);
    setState(() {
      isRefresh = true;
    });

    var response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    });

    if (response.statusCode == 200) {
      var x = response.body;
      addedToPortFolioList = singleCoinDataFromJson(x);
      setState(() {
        addedToPortFolio = addedToPortFolioList;
        isRefresh = false;
      });
      print(addedToPortFolio);
    } else {
      print(response.statusCode);
    }
  }
}
