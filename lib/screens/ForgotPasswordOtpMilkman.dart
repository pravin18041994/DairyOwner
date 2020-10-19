import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ForgotPasswordConfirmationMilkman.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ForgotPasswordOtpMilkman extends StatefulWidget {
  var contact;

  ForgotPasswordOtpMilkman({this.contact});

  @override
  _ForgotPasswordOtpMilkmanState createState() =>
      _ForgotPasswordOtpMilkmanState();
}

class _ForgotPasswordOtpMilkmanState extends State<ForgotPasswordOtpMilkman> {
  TextEditingController otpControllerMilkman = new TextEditingController();
  var urlMilkman;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  var connectivityResult;
  var isConnectionActive = true;
  var mtext = 1;
  var stext = 59;

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
    urlMilkman = Constants.base_url + 'milkmen/verify_otp_forgot_password';
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

  void verifyOtp() async {
    openDialog();
    var contact = widget.contact;
    var otp = otpControllerMilkman.text;
    print(contact);
    print(otp);
    http.Response response =
        await http.post(urlMilkman, body: {'contact': contact, 'otp': otp});
    print(response.body);
    var decoded = json.decode(response.body);
    if (response.statusCode == 200) {
      Navigator.pop(context);
      if (decoded['state'] == 'success') {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ForgotPasswordConfirmationMilkman(contact: contact);
        }));
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Invalid OTP !'),
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
                backgroundColor: Colors.blue,
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: Colors.blue,
                    )),
                content: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextFormField(
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please Enter OTP';
                          }
                          if (value.length < 4) {
                            return 'Please Enter Valid OTP';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4)
                        ],
                        decoration: InputDecoration(
                            labelText: "Enter OTP",
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            labelStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        controller: otpControllerMilkman,
                      ),
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(
                              color: Colors.blue,
                            )),
                        color: Colors.white,
                        elevation: 5.0,
                        child: Text(
                          "Submit",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
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
