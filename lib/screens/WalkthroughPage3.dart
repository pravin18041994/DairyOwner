import 'package:dairy_app_owner/screens/LoginButtons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'WalkthroughPage2.dart';

class WalkthroughPage3 extends StatefulWidget {
  @override
  _WalkthroughPage3State createState() => _WalkthroughPage3State();
}

class _WalkthroughPage3State extends State<WalkthroughPage3> {
  final storage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.7,
                child: Image.asset("Images/3.png"),
              ),
            ),
            Container(
              color: Colors.amber,
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Center(child: Text("Descriptions")),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: RaisedButton(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return WalkthroughPage2();
                      }));
                    },
                    child: Text("Previous"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 20),
                  child: RaisedButton(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    onPressed: () async {
                      await storage.write(key: 'first_time',value:'1');
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return LoginButtons();
                      }));
                    },
                    child: Text("Done"),
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
