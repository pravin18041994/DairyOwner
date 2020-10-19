import 'package:connectivity/connectivity.dart';

import '../screens/TabBarViewPage.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
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
                "User Details",
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
