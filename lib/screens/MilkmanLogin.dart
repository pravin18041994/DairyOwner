import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/ForgotPasswordMobileNumberMilkman.dart';
import 'package:dairy_app_owner/screens/MilkmanDashboard.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../animations/BounceAnimation.dart';
import '../screens/ForgotPasswordMobileNumber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MilkManLogin extends StatefulWidget {
  @override
  _MilkManLoginState createState() => _MilkManLoginState();
}

class _MilkManLoginState extends State<MilkManLogin> {
  var connectivityResult;
  var isConnectionActive = true;
  ForgotPasswordMobileNumber _forgotPasswordMobileNumber;
  var url;
  var storage;
  TextEditingController contactControllerMilkman = new TextEditingController();
  TextEditingController passwordControllerMilkman = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Icon i;
  var passwordVisible;
  final FocusNode nodeMobileNumber = FocusNode();
  final FocusNode nodePassword = FocusNode();
  final FocusNode nodeLoginButton = FocusNode();

  @override
  void initState() {
    // TODO: implement initState

    _forgotPasswordMobileNumber = new ForgotPasswordMobileNumber();
    url = Constants.base_url + "/milkmen/login_milkman";

    super.initState();
    checkInternetConnection();
    i = Icon(Icons.visibility_off);
    passwordVisible = true;
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

  checkRoute(String info) {
    if (info == "from forgot password") {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          'Password Updated Successfully !',
          style: TextStyle(fontFamily: 'Muli'),
        ),
        duration: Duration(seconds: 5),
      ));
    }
  }

  checkLoginMillkman() async {
    try {
      openDialog();
      storage = FlutterSecureStorage();
      var contact = contactControllerMilkman.text;
      var password = passwordControllerMilkman.text;

      http.Response response = await http
          .post(url, body: {'contactno': contact, 'password': password});
      print(response.body);

      var jsonDecode = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        if (jsonDecode['state'] == 'success') {
          FocusScope.of(context).requestFocus(nodeLoginButton);
          await storage.write(key: "milkman_token", value: jsonDecode['token']);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => MilkmanDashboard()));
          contactControllerMilkman.clear();
          passwordControllerMilkman.clear();
        } else {
          FocusScope.of(context).requestFocus(nodeLoginButton);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Invalid Credentials !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 5),
          ));
          passwordControllerMilkman.clear();
          contactControllerMilkman.clear();
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please Try Again Later !',
            style: TextStyle(fontFamily: 'Muli'),
          ),
          duration: Duration(seconds: 5),
        ));
        passwordControllerMilkman.clear();
        contactControllerMilkman.clear();
      }
    } catch (e) {
      Navigator.pop(context);
      checkInternetConnection();
    }
  }

  openDialog() {
    Dialog dialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        height: 100.0,
        width: 100.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
              backgroundColor: Colors.blue,
            )
          ],
        ),
      ),
    );
    showDialog(context: context, barrierDismissible: false, child: dialog);
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
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Image.asset("Images/MilkmanLogo.png"),
                      ),
                    ),
                    BounceAnimation("Milkman", "  Login"),
                    Container(
                      padding: EdgeInsets.only(
                          top: 0.0, left: 20.0, right: 20.0),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            cursorColor: Colors.blue,
                            focusNode: nodeMobileNumber,
                            
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter Mobile Number';
                              }
                              return null;
                            },
                            controller: contactControllerMilkman,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: "Mobile No",
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.blue)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.blue)),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            cursorColor: Colors.blue,
                            focusNode: nodePassword,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter Password';
                              }
                              return null;
                            },
                            controller: passwordControllerMilkman,
                            obscureText: passwordVisible,
                            decoration: InputDecoration(
                              labelText: "Password",
                              suffixIcon: IconButton(
                                color: Colors.blue,
                                onPressed: () {
                                  setState(() {
                                    if (i.toString() ==
                                        Icon(Icons.visibility_off)
                                            .toString()) {
                                      print("inhere");
                                      i = Icon(Icons.visibility);
                                    } else {
                                      i = Icon(Icons.visibility_off);
                                    }
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                                icon: i,
                              ),
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.blue)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.blue)),
                            ),
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          Container(
                            child: RaisedButton(
                              focusNode: nodeLoginButton,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(18.0),
                                  side: BorderSide(
                                      color: Colors.black, width: 2.0)),
                              onPressed: () {
                                checkInternetConnection();
                                if (_formKey.currentState.validate()) {
                                  checkLoginMillkman();
                                } else {}
                              },
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 5.0,
                        ),
                        InkWell(
                          onTap: () async {
                            checkInternetConnection();
                            var fp = await Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return ForgotPasswordMobileNumberMilkman();
                            }));
                            checkRoute(fp);
                          },
                          child: Text(
                            "Forgot Password ?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
