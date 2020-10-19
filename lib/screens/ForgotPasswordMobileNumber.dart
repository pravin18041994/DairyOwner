import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/ForgotPasswordOtp.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordMobileNumber extends StatefulWidget {
  @override
  _ForgotPasswordMobileNumberState createState() =>
      _ForgotPasswordMobileNumberState();
}

class _ForgotPasswordMobileNumberState
    extends State<ForgotPasswordMobileNumber> {
  TextEditingController mobileNumberController = new TextEditingController();
  var url;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FocusNode nodeContact = FocusNode();
  final FocusNode submitButton = FocusNode();
  final FocusNode cancelButton = FocusNode();
  var connectivityResult;
  var isConnectionActive = true;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    url = Constants.base_url + 'admins/get_contact_change_password';
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

  void getContact() async {
    try {
      openDialog();
      var contact = mobileNumberController.text;
      http.Response response = await http.post(url, body: {'contact': contact});
      print(response.body);
      var decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        if (decoded['state'] == 'success') {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return ForgotPasswordOtp(contact: contact);
          }));
        } else {
          Navigator.pop(context);
          FocusScope.of(context).requestFocus(submitButton);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Mobile Number Not Registered !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 2),
          ));
          mobileNumberController.clear();
        }
      }
    } catch (e) {
      Navigator.pop(context);
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
        : Scaffold(
            key: _scaffoldKey,
            body: Form(
              key: _formKey,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.blue)),
                elevation: 0.0,
                backgroundColor: Colors.blue,
                content: Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                     
                      TextFormField(
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            hintText: "Enter Mobile Number",
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10)
                        ],
                        controller: mobileNumberController,
                        focusNode: nodeContact,
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
                    SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          RaisedButton(
                            focusNode: submitButton,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                    color: Colors.blue, width: 2.0)),
                            elevation: 5.0,
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                getContact();
                              }
                            },
                          ),
                          RaisedButton(
                            focusNode: cancelButton,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                    color: Colors.blue, width: 2.0)),
                            elevation: 5.0,
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                actions: <Widget>[],
              ),
            ),
          );
  }
}
