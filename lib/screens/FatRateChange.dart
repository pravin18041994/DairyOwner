import 'package:flutter/material.dart';

class FatrateChage extends StatefulWidget {
  @override
  _FatrateChageState createState() => _FatrateChageState();
}

class _FatrateChageState extends State<FatrateChage> {
  var dropdownValue;
  TextEditingController fatstepController = TextEditingController();
  TextEditingController fatRateController = TextEditingController();
  final _dialogKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  fatRateDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: _dialogKey,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              content: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextFormField(
                      cursorColor: Colors.blue,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter step';
                        }
                        return null;
                      },
                      controller: fatstepController,
                      decoration: InputDecoration(
                        labelText: "Enter Step",
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                      ),
                    ),
                    TextFormField(
                      cursorColor: Colors.blue,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter rate';
                        }
                        return null;
                      },
                      controller: fatRateController,
                      decoration: InputDecoration(
                        labelText: "Enter Rate",
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RaisedButton(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          onPressed: () {
                            if (_dialogKey.currentState.validate()) {
                              
                            }
                          },
                          child: Text("Add"),
                        ),
                        RaisedButton(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fat Rate"),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  color: Colors.blue[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.all(5),
                        child: Text(
                          "Per Fat Rate",
                          style: TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DropdownButton<String>(
                        underline: Container(
                          height: 2,
                          color: Colors.white,
                        ),
                        hint: Text(
                          "Per Fat Rate / SNF point",
                          style: TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.bold),
                        ),
                        value: dropdownValue,
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue = newValue;
                          });
                        },
                        items: <String>['One', 'Two', 'Free', 'Four']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                  fontSize: 12.0, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  color: Colors.white70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          "Fat rate",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                          child: IconButton(
                              icon: Icon(
                                Icons.add,
                                size: 25.0,
                              ),
                              onPressed: () {
                                fatRateDialog(context);
                              }))
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: ListView.builder(
                      itemCount: 3,
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) => Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    margin: EdgeInsets.all(10),
                                    child: Text("30")),
                                Container(
                                    margin: EdgeInsets.all(10),
                                    child: Text("30"))
                              ],
                            ),
                          )),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
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
        ],
      ),
    );
  }
}
