import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class ForgotPasswordConfirmationMilkman extends StatefulWidget {
  var contact;

  ForgotPasswordConfirmationMilkman({this.contact});

  @override
  _ForgotPasswordConfirmationMilkmanState createState() =>
      _ForgotPasswordConfirmationMilkmanState();
}

class _ForgotPasswordConfirmationMilkmanState
    extends State<ForgotPasswordConfirmationMilkman> {
  TextEditingController newPasswordControllerMilkman =
      new TextEditingController();
  TextEditingController confirmPasswordControllerMilkman =
      new TextEditingController();
  var url;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var connectivityResult;
  var isConnectionActive = true;
  var newPasswordEye = Icons.visibility_off;
  var confirmPasswordEye = Icons.visibility_off;

  var newPasswordObscureText = true;
  var confirmPasswordObscureText = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkInternetConnection();
    url = Constants.base_url + 'milkmen/change_password_milkman';
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

  void changePasswordMilkman() async {
    try {
      if (newPasswordControllerMilkman.text !=
          confirmPasswordControllerMilkman.text) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            "Password Doesn't Match !",
            style: TextStyle(fontFamily: 'Muli'),
          ),
          duration: Duration(seconds: 2),
        ));
        return;
      }
      openDialog();
      http.Response response = await http.post(url, body: {
        'contact': widget.contact,
        'password': confirmPasswordControllerMilkman.text
      });
      print(response.body);
      var decoded = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        if (decoded['state'] == 'success') {
          for (int i = 0; i < 3; i++) {
            Navigator.pop(context, "from forgot password");
          }
        } else {}
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please Try Again Later !',
            style: TextStyle(fontFamily: 'Muli'),
          ),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
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
            body: Form(
              key: _formKey,
              child: AlertDialog(
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(color: Colors.black)),
                  backgroundColor: Colors.blue,
                  title: new Text(
                    "Set Password",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  content: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: ListView(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            TextFormField(
                                obscureText: newPasswordObscureText,
                                cursorColor: Colors.white,
                                style: TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please Enter Password';
                                  }
                                  return null;
                                },
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10)
                                ],
                                controller: newPasswordControllerMilkman,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      setState(() {
                                        if (newPasswordEye ==
                                            Icons.visibility_off) {
                                          newPasswordEye = Icons.visibility;
                                          newPasswordObscureText = false;
                                        } else {
                                          newPasswordEye = Icons.visibility_off;
                                          newPasswordObscureText = true;
                                        }
                                      });
                                    },
                                    icon: Icon(newPasswordEye),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  labelText: 'New Password',
                                  labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                            TextFormField(
                                obscureText: confirmPasswordObscureText,
                                cursorColor: Colors.white,
                                style: TextStyle(color: Colors.white),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please Enter Password';
                                  }
                                  return null;
                                },
                                controller: confirmPasswordControllerMilkman,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                      color: Colors.white,
                                      icon: Icon(confirmPasswordEye),
                                      onPressed: () {
                                        setState(() {
                                          if (confirmPasswordEye ==
                                              Icons.visibility_off) {
                                            confirmPasswordObscureText = false;
                                            confirmPasswordEye =
                                                Icons.visibility;
                                          } else {
                                            confirmPasswordEye =
                                                Icons.visibility_off;
                                            confirmPasswordObscureText = true;
                                          }
                                        });
                                      }),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  labelText: 'Confirm Password',
                                  labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                            SizedBox(
                              height: 20.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                RaisedButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.black),
                                      borderRadius:
                                          BorderRadius.circular(18.0)),
                                  elevation: 5.0,
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                      changePasswordMilkman();
                                    }
                                  },
                                ),
                                RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Colors.black),
                                      borderRadius:
                                          BorderRadius.circular(18.0)),
                                  color: Colors.white,
                                  elevation: 5.0,
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    for (int i = 0; i < 3; i++) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
          );
  }
}
