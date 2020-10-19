import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';


class SelectUserDialogBox extends StatefulWidget {
  @override
  _SelectUserDialogBoxState createState() => _SelectUserDialogBoxState();
}

class _SelectUserDialogBoxState extends State<SelectUserDialogBox> {
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
      backgroundColor: Colors.white,
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.green),
      centerTitle: true,
      title: Text(
        "Select User",
        style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold),
      ),
    ),
    );
  }
}
