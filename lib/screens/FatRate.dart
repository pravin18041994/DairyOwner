import 'package:dairy_app_owner/screens/FatRateChange.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FatRate extends StatefulWidget {
  @override
  _FatRateState createState() => _FatRateState();
}

class _FatRateState extends State<FatRate> {
  bool _selected = false;

  List categoryNames = ["Cow", "Buffalo"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fat Rate"),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.55,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 5),
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryNames.length,
                            shrinkWrap: true,
                            itemBuilder: (ctx, index) => InputChip(
                                selected: _selected,
                                label: Text(categoryNames[index]),
                                labelStyle: TextStyle(color: Colors.white),
                                backgroundColor: Colors.grey,
                                selectedColor: Colors.blue,
                                onPressed: () {
                                  setState(() {
                                    _selected = !_selected;
                                  });
                                }),),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => FatrateChage()));
                    },
                    child: Text(
                      "Change",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Fat'))),
                      TableCell(
                        child: Center(child: Text('Rate')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                    TableRow(children: [
                      TableCell(child: Center(child: Text('Value 1'))),
                      TableCell(
                        child: Center(child: Text('Value 2')),
                      ),
                    ]),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
