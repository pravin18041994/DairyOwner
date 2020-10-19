import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/LoginButtons.dart';
import 'package:dairy_app_owner/screens/MilkmanDashboard.dart';
import '../screens/OwnerDashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/animation.dart';

import 'WalkthroughPage.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Animation animation, delayedAnimation, muchDelayedAnimation;
  AnimationController animationController;
  var screenName;
  var storage;
  String token, token2;
  var connectivityResult;
  var isConnectionActive = true;
  var milkman_token;
  Future<String> getToken() async {
    storage = new FlutterSecureStorage();
    token = await storage.read(key: "token") ?? null;
    milkman_token = await storage.read(key: "milkman_token") ?? null;
    if (token != null ) {   
      screenName = OwnerDashboard();
    } else if(milkman_token !=null) {
        screenName = MilkmanDashboard();
    }
    else 
    {
      if(await storage.read(key:'first_time') == '1')
      {
        screenName = LoginButtons();
      }
      else 
      {
        screenName = Walkthrough();  
      }
      
    }
  }

  @override
  void initState() {
    getToken();
    // TODO: implement initState
    Timer(
        Duration(seconds: 4),
        () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => screenName)));

    animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);

    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));

    delayedAnimation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    ));

    muchDelayedAnimation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: Interval(0.8, 1.0, curve: Curves.fastOutSlowIn)));
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
  dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    animationController.forward();
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
        : AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return new Scaffold(
                body: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                   Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("Images/AppBg.png"),
                          fit: BoxFit.fitHeight),
                      color: Colors.white),
                ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: new Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                // CircleAvatar(
                                //   radius: 60.0,
                                //   backgroundColor: Colors.green,
                                //   child: Icon(
                                //     Icons.shutter_speed,
                                //     size: 80.0,
                                //     color: Colors.white,
                                //   ),
                                // ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 10.0,
                                  ),
                                ),
                                // Text(
                                //   "DoodhWala",
                                //   style: TextStyle(
                                //       color: Colors.green,
                                //       fontSize: 24.0,
                                //       fontWeight: FontWeight.bold),
                                // )
                              ],
                            ),
                          ),
                        ),
                        // Expanded(
                        //   flex: 1,
                        //   child: Column(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: <Widget>[
                        //       Padding(
                        //         padding: EdgeInsets.only(top: 20.0),
                        //       ),
                        //       Transform(
                        //         transform: Matrix4.translationValues(
                        //             animation.value * width, 0.0, 0.0),
                        //         child: Text(
                        //           "Powered By",
                        //           style: TextStyle(
                        //               color: Colors.green,
                        //               fontFamily: 'Muli',
                        //               fontSize: 10.0,
                        //               fontStyle: FontStyle.italic),
                        //         ),
                        //       ),
                        //       Transform(
                        //         transform: Matrix4.translationValues(
                        //             delayedAnimation.value * width, 0.0, 0.0),
                        //         child: Text(
                        //           "ARKININDIA",
                        //           style: TextStyle(
                        //               color: Colors.green,
                        //               fontSize: 18.0,
                        //               fontFamily: 'Muli',
                        //               fontStyle: FontStyle.italic,
                        //               fontWeight: FontWeight.bold),
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // )
                      ],
                    )
                  ],
                ),
              );
            });
  }
}
