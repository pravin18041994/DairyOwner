import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/LoginButtons.dart';
import 'package:dairy_app_owner/screens/MilkmanLogin.dart';
import 'package:dairy_app_owner/screens/MilkmanPastTransactions.dart';
import 'package:dairy_app_owner/screens/TransactionDetailsMilkman.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'MilkmanProfilePage.dart';

class MilkmanDrawer extends StatefulWidget {
  @override
  _MilkmanDrawerState createState() => _MilkmanDrawerState();
}

class _MilkmanDrawerState extends State<MilkmanDrawer> {
  var connectivityResult;
  var isConnectionActive = true;
  var storage;
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    storage = FlutterSecureStorage();
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
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            child: Drawer(
              child: ListView(
                children: <Widget>[
                  new DrawerHeader(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) {
                            return MilkmanProfilePage();
                          }));
                        },
                        child: CircleAvatar(
                          maxRadius: 50.0,
                          backgroundImage: AssetImage("Images/1.png"),
                        ),
                      ),
                    ],
                  )),
                  new ListTile(
                    onTap: () async {

                      Navigator.pop(context);
                      var resp = await Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return TransactionDetailsMilkman();
                      }));
                      if(resp == "from here"){
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please Try Again Later !',
            style: TextStyle(fontFamily: 'Muli'),
          ),
          duration: Duration(seconds: 5),
        ));
                      }
                    },
                    title: new Text(
                      "Transaction Details",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 15.0),
                    ),
                    leading: Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                  ),
                  new ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return MilkmanPastTransactions();
                      }));
                    },
                    title: new Text(
                      "Past Transactions",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 15.0),
                    ),
                    leading: Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                  ),
                  new ListTile(
                    onTap: () async {
                      await storage.delete(key: "milkman_token");
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return LoginButtons();
                      }));
                    },
                    title: new Text(
                      "Logout",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 15.0),
                    ),
                    leading: Icon(
                      Icons.lock,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
