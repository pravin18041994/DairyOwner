import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ForgotPasswordOtpMilkman.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordMobileNumberMilkman extends StatefulWidget {
  @override
  _ForgotPasswordMobileNumberMilkmanState createState() =>
      _ForgotPasswordMobileNumberMilkmanState();
}

class _ForgotPasswordMobileNumberMilkmanState
    extends State<ForgotPasswordMobileNumberMilkman> {
  TextEditingController mobileNumberControllerMilkman =
      new TextEditingController();
  var url;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var connectivityResult;
  var isConnectionActive = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    url = Constants.base_url + 'milkmen/get_contact_change_password';
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

  void getContactMilkman() async {
    try {
      openDialog();
      var contact = mobileNumberControllerMilkman.text;
      print(contact);
      http.Response response = await http.post(url, body: {'contact': contact});
      print(response.body);
      var decoded = json.decode(response.body);
      if (response.statusCode == 200) {
        if (decoded['state'] == 'success') {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return ForgotPasswordOtpMilkman(contact: contact);
          }));
        } else {
          Navigator.pop(context);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Mobile Number Is Not Registered !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 2),
          ));
        }
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
            body: Form(
              key: _formKey,
              child: AlertDialog(
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.blue)),
                backgroundColor: Colors.blue,
                content: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please Enter Mobile Number';
                          }
                          if (value.length < 10) {
                            return 'Please Enter Valid Mobile Number';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            labelText: "Enter Mobile Number",
                            labelStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10)
                        ],
                        controller: mobileNumberControllerMilkman,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          RaisedButton(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.black)),
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                getContactMilkman();
                              }
                            },
                          ),
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.black)),
                            color: Colors.white,
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
              ),
            ),
          );
  }
}
