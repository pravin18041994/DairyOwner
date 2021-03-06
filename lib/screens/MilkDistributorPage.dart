import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

import 'TabBarViewPage.dart';


class MilkDistributorpage extends StatefulWidget {
  @override
  _MilkDistributorpageState createState() => _MilkDistributorpageState();
}

class _MilkDistributorpageState extends State<MilkDistributorpage> {
    TabController controller;
  var connectivityResult;
  var isConnectionActive = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      checkInternetConnection();
  }

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        isConnectionActive = true;
      } else {
        isConnectionActive = false;
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return isConnectionActive == false
        ? Scaffold(
            key: _scaffoldKey,
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('No Internet Connection !'),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.black)),
                  onPressed: () {
                    checkInternetConnection();
                  },
                  child: Text('Refresh'),
                )
              ],
            )),
          )
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                "Milk Distributor",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              elevation: 0.0,
              backgroundColor: Colors.blue,
              iconTheme: new IconThemeData(color: Colors.white),
            ),
            body: TabBarViewPage(context));
  }
}