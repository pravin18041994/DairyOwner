import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/FirebaseMessagingService.dart';

import '../animations/BounceAnimation.dart';
import '../models/LoginData.dart';
import '../screens/ForgotPasswordMobileNumber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../utilities/Constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OwnerLogin extends StatefulWidget {
  @override
  _OwnerLoginState createState() => _OwnerLoginState();
}

class _OwnerLoginState extends State<OwnerLogin>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Icon i;
  var storage;
  ForgotPasswordMobileNumber _forgotPasswordMobileNumber;
  TextEditingController contactController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  var url;
  var errorContact = false;
  var errorPassword = false;
  bool passwordVisible;
  Future<LoginData> loginData;
  final FocusNode nodeContact = FocusNode();
  final FocusNode loginButton = FocusNode();
  final FocusNode nodePassword = FocusNode();
  final _formKey = GlobalKey<FormState>();
  FirebaseMessagingService fms;
  var connectivityResult;
  var isConnectionActive = true;

  @override
  void initState() {
    // TODO: implement initState
    storage = new FlutterSecureStorage();
    _forgotPasswordMobileNumber = new ForgotPasswordMobileNumber();
    url = Constants.base_url + "/admins/login";
    super.initState();
    i = Icon(Icons.visibility_off);
    passwordVisible = true;
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

  void checkRoute(String info) {
    print('inhere');
    if (info == 'from change password') {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          'Password Updated Successfully!',
          style: TextStyle(fontFamily: 'Muli'),
        ),
        duration: Duration(seconds: 5),
      ));
    }
  }

  void checkLogin() async {
    try {
      print(contactController.text);
      setState(() {
        if (contactController.text == "") {
          this.errorContact = true;
          return;
        }
        if (passwordController.text == "") {
          this.errorPassword = true;
          return;
        }
      });
      openDialog();
      http.Response response = await http.post(url, body: {
        'contact': contactController.text,
        'password': passwordController.text
      }, headers: {
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context); //this statement closes the dialog
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse['state'] == 'success') {
          await storage.write(key: "token", value: decodedResponse['token']);

          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  FirebaseMessagingService(contactController.text)));
        } else {
          FocusScope.of(context).requestFocus(loginButton);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Invalid Credentials !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 5),
          ));

          contactController.clear();
          passwordController.clear();
        }
      } else {
        Navigator.pop(context);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please Try Again Later!',
            style: TextStyle(fontFamily: 'Muli'),
          ),
          duration: Duration(seconds: 5),
        ));
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
                    BounceAnimation("Owner", "  Login"),
                    Container(
                      padding: EdgeInsets.only(
                          top: 0.0, left: 20.0, right: 20.0),
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            onTap: () {
                              setState(() {
                                if (contactController.text.length == 0) {
                                  this.errorContact = false;
                                  return;
                                } else {
                                  this.errorContact = true;
                                  return;
                                }
                              });
                            },
                            onChanged: (val) {
                              if (val.length == 10) {
                                FocusScope.of(context)
                                    .requestFocus(nodePassword);
                              }
                            },
                            controller: contactController,
                            cursorColor: Colors.blue,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              WhitelistingTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
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
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter mobile number';
                              }
                              if (value.length < 10) {
                                return 'Please enter valid mobile number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter password';
                              }
                              if (value.length < 6) {
                                return 'Please enter valid password';
                              }

                              return null;
                            },
                            onTap: () {
                              checkInternetConnection();
                              if (passwordController.text.length == 0) {
                                this.errorPassword = false;
                                return;
                              } else {
                                this.errorPassword = true;
                                return;
                              }
                            },
                            focusNode: nodePassword,
                            cursorColor: Colors.blue,
                            controller: passwordController,
                            obscureText: passwordVisible,
                            decoration: InputDecoration(
                              labelText: "Password",
                              suffixIcon: IconButton(
                                icon: i,
                                color: Colors.blue,
                                onPressed: () {
                                  setState(() {
                                    if (i.toString() ==
                                        Icon(Icons.visibility_off)
                                            .toString()) {
                                      i = Icon(Icons.visibility);
                                    } else {
                                      i = Icon(Icons.visibility_off);
                                    }
                                    passwordVisible = !passwordVisible;
                                  });
                                },
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
                            height: 50.0,
                          ),
                          RaisedButton(
                            focusNode: loginButton,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                    color: Colors.black, width: 2.0)),
                            onPressed: () {
                              checkInternetConnection();

                              if (_formKey.currentState.validate()) {
                                checkLogin();
                              } else {}
                            },
                            child: Center(
                              child: Text(
                                "Log In",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  checkInternetConnection();
                                  var fp = await Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return ForgotPasswordMobileNumber();
                                  }));
                                  checkRoute(fp);
                                },
                                child: Text(
                                  "Forgot Password ?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
