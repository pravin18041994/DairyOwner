import 'package:flutter/material.dart';

class Slide {
  final String imageUrl;
  final String description;
  final String title;

  Slide(
      {@required this.imageUrl,
      @required this.description,
      @required this.title});
}

final slideList = [
  Slide(
    imageUrl: 'Images/milkimage.jpg',
    title: "Drink milk anytime",
    description:
"Most parents make their children drink at least a glass of milk a day and why not? Milk is an important source of calcium, protein and other nutrients and benefits a child’s health."  ),
  Slide(
    imageUrl: 'Images/dairyman.jpg',
    title: "MIlk Delivery Boy",
    description:
    ' A milkman is a delivery person who delivers milk, often directly to customers houses in bottles or cartons',
  ),
  Slide(
    imageUrl: 'Images/milkman.jpg',
    title: "Pure milk directly at Home",
    description:
   ' Milk was delivered to houses daily in some countries when a lack of good refrigeration meant milk would quickly spoil'  )
];
