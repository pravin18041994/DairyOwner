import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/OwnerLogin.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordConfirmation extends StatefulWidget {
  var contact;

  ForgotPasswordConfirmation({this.contact});

  @override
  _ForgotPasswordConfirmationState createState() =>
      _ForgotPasswordConfirmationState();
}

class _ForgotPasswordConfirmationState
    extends State<ForgotPasswordConfirmation> {
  TextEditingController newPasswordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FocusNode password = FocusNode();
  final FocusNode submitButton = FocusNode();
  final FocusNode confirmPassword = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var url;
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
    url = Constants.base_url + 'admins/change_password';
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

  void changePassword() async {
    try {
      if (newPasswordController.text != confirmPasswordController.text) {
        FocusScope.of(context).requestFocus(submitButton);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Passwords Doesn\'t Match !'),
          duration: Duration(seconds: 2),
        ));
        return;
      }
      openDialog();
      http.Response response = await http.post(url, body: {
        'contact': widget.contact,
        'password': confirmPasswordController.text
      });
      print(response.body);
      var decoded = json.decode(response.body);
      if (response.statusCode == 200) {
        if (decoded['state'] == 'success') {
          Navigator.pop(context);
          for (int i = 0; i < 3; i++) {
            Navigator.pop(context, 'from change password');
          }
        } else {
          Navigator.pop(context);
          FocusScope.of(context).requestFocus(submitButton);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Please Try Again Later !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 2),
          ));
        }
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
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
        : Form(
            key: _formKey,
            child: Scaffold(
              key: _scaffoldKey,
              body: AlertDialog(
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.black)),
                backgroundColor: Colors.blue,
                content: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextFormField(
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          focusNode: password,
                          controller: newPasswordController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Please enter valid password';
                            }
                            return null;
                          },
                          obscureText: newPasswordObscureText,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  if (newPasswordEye == Icons.visibility_off) {
                                    newPasswordObscureText = false;
                                    newPasswordEye = Icons.visibility;
                                  } else {
                                    newPasswordEye = Icons.visibility_off;
                                    newPasswordObscureText = true;
                                  }
                                });
                              },
                              icon: Icon(
                                newPasswordEye,
                              ),
                              color: Colors.white,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            labelText: 'New Password',
                            labelStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                      TextFormField(
                          cursorColor: Colors.white,
                          style: TextStyle(color: Colors.white),
                          focusNode: confirmPassword,
                          controller: confirmPasswordController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Please enter valid password';
                            }
                            return null;
                          },
                          obscureText: confirmPasswordObscureText,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              color: Colors.white,
                              icon: Icon(confirmPasswordEye),
                              onPressed: () {
                                setState(() {
                                  if (confirmPasswordEye ==
                                      Icons.visibility_off) {
                                    confirmPasswordObscureText = false;
                                    confirmPasswordEye = Icons.visibility;
                                  } else {
                                    confirmPasswordEye = Icons.visibility_off;
                                    confirmPasswordObscureText = true;
                                  }
                                });
                              },
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                      RaisedButton(
                        focusNode: submitButton,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue, width: 2.0)),
                        child: Text(
                          "Submit",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          checkInternetConnection();
                          if (_formKey.currentState.validate()) {
                            changePassword();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
