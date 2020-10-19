import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/TabBarViewPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MilkmanDetailsPage extends StatefulWidget {
  @override
  _MilkmanDetailsPageState createState() => _MilkmanDetailsPageState();
}

class _MilkmanDetailsPageState extends State<MilkmanDetailsPage> {
  TabController controller;
  var connectivityResult;
  var isConnectionActive = true;

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
                "Milkman Details",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 0.0,
              backgroundColor: Colors.blue,
              iconTheme: new IconThemeData(color: Colors.white),
            ),
            body: TabBarViewPage(context));
  }
}
