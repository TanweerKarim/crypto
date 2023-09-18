import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:crypto_app/screens/View/selectCoin.dart';
import 'package:flutter/material.dart';

class Item extends StatelessWidget {
  var item;
  Item({required this.item});

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: myWidth * 0.06, vertical: myHeight * 0.02),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (contest) => SelectCoin(
                        selectItem: item,
                      )));
        },
        child: Container(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                    height: myHeight * 0.05, child: Image.network(item.image)),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.id,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '0.4 ' + item.symbol,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$ ' + item.currentPrice.toString(),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
