import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/ForgotPasswordConfirmation.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordOtp extends StatefulWidget {
  var contact;

  ForgotPasswordOtp({this.contact});

  @override
  _ForgotPasswordOtpState createState() => _ForgotPasswordOtpState();
}

class _ForgotPasswordOtpState extends State<ForgotPasswordOtp> {
  var url;
  TextEditingController otpController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final FocusNode nodeOtp = FocusNode();
  final FocusNode submitButton = FocusNode();
  var connectivityResult;
  var isConnectionActive = true;
  var mtext = 1;
  var stext = 59;

  void verifyOtp() async {
    try {
      openDialog();
      var contact = widget.contact;
      var otp = otpController.text;
      print(contact);
      print(otp);
      http.Response response =
          await http.post(url, body: {'contact': contact, 'otp': otp});
      print(response.body);
      var decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        if (decoded['state'] == 'success') {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return ForgotPasswordConfirmation(contact: contact);
          }));
        } else {
          FocusScope.of(context).requestFocus(submitButton);
          Navigator.pop(context);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Invalid OTP !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 2),
          ));
          otpController.clear();
        }
      } else {}
    } catch (e) {
      Navigator.pop(context);
      checkInternetConnection();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          stext = stext - 1;
          if (stext < 0) {
            mtext = mtext - 1;
            stext = 59;
          }
          if (stext == 0 && mtext == 0) {
            timer.cancel();
          }
        });
      }
    });
    url = Constants.base_url + 'admins/verify_otp_forgot_password';
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
                backgroundColor: Colors.blue,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.blue)),
                content: Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextFormField(
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            hintText: "Enter Otp",
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        focusNode: nodeOtp,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        controller: otpController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter OTP';
                          }
                          if (value.length < 4) {
                            return 'Please enter valid OTP';
                          }
                          return null;
                        },
                      ),
                   
                      RaisedButton(
                        focusNode: submitButton,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.black)),
                        child: Text(
                          "Submit",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          checkInternetConnection();
                          if (_formKey.currentState.validate()) {
                            verifyOtp();
                          }
                        },
                      ),
                     
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Text(
                              "Resend OTP",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Text(
                            mtext.toString() + " : " + stext.toString(),
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
