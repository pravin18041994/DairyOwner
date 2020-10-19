import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'OwnerLogin.dart';
import 'MilkmanLogin.dart';

class LoginButtons extends StatefulWidget {
  @override
  _LoginButtonsState createState() => _LoginButtonsState();
}

class _LoginButtonsState extends State<LoginButtons>
    with SingleTickerProviderStateMixin {
  Animation animation, delayedAnimation, muchDelayedAnimation;
  AnimationController animationController;
  var connectivityResult;
  var isConnectionActive = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkInternetConnection();
    animationController =
        AnimationController(duration: Duration(seconds: 2), vsync: this);

    animation = Tween(begin: -1.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.bounceOut));

    delayedAnimation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.5, 1.0, curve: Curves.bounceOut),
    ));

    muchDelayedAnimation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: Interval(0.8, 1.0, curve: Curves.fastOutSlowIn)));
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
        : WillPopScope(
            onWillPop: () {
              return null;
            },
            child: AnimatedBuilder(
                animation: animationController,
                builder: (BuildContext context, Widget child) {
                  return Scaffold(
                      backgroundColor: Colors.white,
                      body: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Transform(
                            transform: Matrix4.translationValues(
                                animation.value * width, 0.0, 0.0),
                            child: Container(
                              margin: EdgeInsets.all(20),
                              height: 200.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(30.0),
                                shadowColor: Colors.lightBlueAccent,
                                color: Colors.blue,
                                elevation: 7.0,
                                child: OutlineButton(
                                  highlightedBorderColor: Colors.green,
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                  onPressed: () {
                                    checkInternetConnection();
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (_) {
                                      return OwnerLogin();
                                    }));
                                  },
                                  child: Center(
                                    child: Text(
                                      "LOGIN AS OWNER",
                                      style: TextStyle(
                                        fontSize: 25.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 60.0,
                          ),
                          Transform(
                            transform: Matrix4.translationValues(
                                delayedAnimation.value * width, 0.0, 0.0),
                            child: Container(
                               margin: EdgeInsets.all(20),
                              height: 200.0,
                              child: Material(
                                borderRadius: BorderRadius.circular(30.0),
                                shadowColor: Colors.lightBlueAccent,
                                color: Colors.blue,
                                elevation: 7.0,
                                child: OutlineButton(
                                  highlightedBorderColor: Colors.green,
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(30.0)),
                                  onPressed: () {
                                    checkInternetConnection();
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (_) {
                                      return MilkManLogin();
                                    }));
                                  },
                                  child: Center(
                                    child: Text(
                                      "LOGIN AS MILKMAN",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      )));
                }),
          );
  }
}
