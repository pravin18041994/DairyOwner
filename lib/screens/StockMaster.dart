import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StockMaster extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(color: Colors.green)),
            child: ListTile(
              title: Text(
                "You have scanned 1 lit of milk",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Toatal number of 1 lit milk scanned",
                  style: TextStyle(color: Colors.green)),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(color: Colors.green)),
            child: ListTile(
              title: Text(
                "You have scanned 1 lit of milk",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Toatal number of 1 lit milk scanned",
                  style: TextStyle(color: Colors.green)),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(color: Colors.green)),
            child: ListTile(
              title: Text(
                "You have scanned 1 lit of milk",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Toatal number of 1 lit milk scanned",
                  style: TextStyle(color: Colors.green)),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(color: Colors.green)),
            child: ListTile(
              title: Text(
                "You have scanned 1 lit of milk",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Toatal number of 1 lit milk scanned",
                  style: TextStyle(color: Colors.green)),
            ),
          ),
        ],
      ),
    );
  }
}
