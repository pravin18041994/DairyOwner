import 'package:flutter/material.dart';

class TermsAndCondition extends StatefulWidget {
  @override
  _TermsAndConditionState createState() => _TermsAndConditionState();
}

class _TermsAndConditionState extends State<TermsAndCondition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "Terms & Conditions",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
    );  
  }
}
