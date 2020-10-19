import '../Widgets/Slide.dart';
import 'package:flutter/material.dart';

class SlideItem extends StatelessWidget {
  final int index;

  SlideItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius:BorderRadius.circular(20.0),
            image: DecorationImage(
                image: AssetImage(slideList[index].imageUrl),
                fit: BoxFit.fill),
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Text(
          slideList[index].title,
          style: TextStyle(
              color: Colors.green,
              fontSize: 20.0,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 50.0,
        ),
        Text(
          slideList[index].description,
          style: TextStyle(
              color: Colors.green,
              fontSize: 20.0,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
