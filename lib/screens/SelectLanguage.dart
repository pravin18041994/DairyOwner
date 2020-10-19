import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'OwnerDashboard.dart';

class SelectLanguage extends StatefulWidget {
  @override
  _SelectLanguageState createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences sharedPreferences;
  var connectivityResult;
  var isConnectionActive = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSharedPreferences();
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

  checkSharedPreferences() async {
    sharedPreferences = await _prefs;
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
      body: AlertDialog(
        elevation: 0.0,
        
        content: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.3,
          child: Card(
            color: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: Colors.blue)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Select Language",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Muli',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
                RaisedButton(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.blue)),
                  onPressed: () {
                    sharedPreferences.setString("lang", "English");
                    CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    );
                    Future.delayed(Duration(seconds: 3));
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_){
                      return OwnerDashboard();
                    }));
                  },
                  child: Text(
                    "English",
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),
                  ),
                ),
                RaisedButton(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.blue)),
                  onPressed: () {
                    sharedPreferences.setString("lang", "Marathi");
                    CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    );
                    Future.delayed(Duration(seconds: 3));
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_){
                      return OwnerDashboard();
                    }));
                  },
                  child: Text(
                    "मराठी",
                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
