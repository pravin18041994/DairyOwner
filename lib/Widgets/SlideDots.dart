import 'package:flutter/material.dart';

class SlideDots extends StatelessWidget {
  bool isActive;

  SlideDots(this.isActive);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: EdgeInsets.symmetric(horizontal: 10),
      height: isActive?12:8,
      width: isActive?12:8,
      duration: Duration(microseconds: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        color: Colors.green
      ),
    );
  }
}
