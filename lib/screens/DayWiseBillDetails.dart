import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DayWiseBillDetails extends StatefulWidget {
  var index;
  var userId;

  var year;
  DayWiseBillDetails(this.index, this.year, this.userId);
  @override
  _DayWiseBillDetailsState createState() => _DayWiseBillDetailsState();
}

class _DayWiseBillDetailsState extends State<DayWiseBillDetails> {
  List days;
  int w = 5;
  var tempfin;
  int v = 7;
  int v2 = 1;
  var storage;
  var token;
  var x;
  List finalList;
  DateTime now;
  int lastday;
  List transactions;
  int fin;
  var url;
  var cond;
  var connectivityResult;
  var isConnectionActive = true;
  var isLoading = true;
  List dailyDetails;
  @override
  void initState() {
    //ss TODO: implement initState
    transactions = [];
    dailyDetails = [];
    finalList = [];
    final DateTime date = new DateTime(widget.year, widget.index);
    url = Constants.base_url + "transactions/get_transactions_specific_user";
    final DateTime lastDay = Utils.lastDayOfMonth(date);
    print(lastDay.day);
    print(widget.year);
    lastday = lastDay.day;
    print(widget.index);
    print(DateTime(widget.year, widget.index, 1).weekday);
    fin = DateTime(widget.year, widget.index, 1).weekday;
    if (fin == 1) {
      cond = lastday;
    } else {
      cond = lastday - 1;
    }
    print(fin);
    super.initState();
    storage = FlutterSecureStorage();
    getTransactions();
    x = [];
    x = new List.generate(6, (_) => new List(7));
    days = [];
    days = List.generate(7, (i) => List(6), growable: false);
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 7; j++) {
        x[i][j] = v2;
        v2 = v2 + 1;
      }
    }
    print(x.toString());
    int temp = 0;
    for (int ii = 0; ii < 6; ii++) {
      for (var jj = 0; jj < 7; jj++) {
        try {
          if (fin == 1) {
            fin = 0;
          }
          x[ii][jj] = x[ii][jj] - fin;
        } on RangeError {
          if (jj > 6) {
            ii = 0;
            jj = 0;
          }
        }
      }
    }
    print(x.toString());
  }

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        isConnectionActive = true;
        getTransactions();
      } else {
        isConnectionActive = false;
      }
    });
  }

  getTransactions() async {
    try {
      token = await storage.read(key: 'token');
      http.Response response = await http.post(url, body: {
        'id': widget.userId,
        'year': widget.year.toString(),
        'month': widget.index.toString()
      }, headers: {
        'Authorization': 'Bearer ' + token
      });
      print(response.body);

      var decodedResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        if (decodedResponse['state'] == 'success') {
          for (var i in decodedResponse['all_details']) {
            for (var j in i['product_attendance']) {
              if (j['user_id'] == widget.userId) {
                var obj = {
                  'date': i['date'],
                  'items': j['items_bought'],
                };
                dailyDetails.add(obj);
              }
            }
          }
          print(decodedResponse['all_details']);
          setState(() {
            isLoading = false;
            transactions = decodedResponse['data'];
            print(x.toString());
          });
        } else {}
      } else {}
    } catch (e) {
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
            appBar: AppBar(
              centerTitle: true,
              elevation: 0.0,
              backgroundColor: Colors.blue,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "Day Wise Bill Details",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: isLoading == true
                ? Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                  ))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                 
                                  height: 20,
                                  width: 45,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.white)),
                                    color: Colors.blue,
                                    child: Text(
                                      "Mon",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 5.5),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width: 45,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.white)),
                                    color: Colors.blue,
                                    child: Text(
                                      "Tue",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 7.0),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width: 45,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.white)),
                                    color: Colors.blue,
                                    child: Text(
                                      "Wed",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 5.5),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width: 45,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.white)),
                                    color: Colors.blue,
                                    child: Text(
                                      "Thu",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 7.0),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width: 45,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.white)),
                                    color: Colors.blue,
                                    child: Text(
                                      "Fri",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 7.0),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width: 45,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.white)),
                                    color: Colors.blue,
                                    child: Text(
                                      "Sat",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 7.0),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                                Container(
                                  height: 20,
                                  width: 45,
                                  child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Colors.white)),
                                    color: Colors.blue,
                                    child: Text(
                                      "Sun",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 7.0),
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (int i = 0; i < 6; i++) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        // this creates scat.length many elements inside the Column
                                        for (int j = 0; j < 7; j++) ...[
                                          // for (int k = 0;
                                          //     k < transactions.length;
                                          //     k++) ...[
                                          Container(
                                              height: 30,
                                              width: 45,
                                              child: x[i][j] > cond
                                                  ? Visibility(
                                                      visible: transactions
                                                              .contains(x[i][j]
                                                                  .toString())
                                                          ? true
                                                          : false,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          print("inhere");
                                                          setState(() {
                                                            finalList = [];
                                                            for (var i
                                                                in dailyDetails) {
                                                              if ((x[i][j])
                                                                      .toString() ==
                                                                  i['date']) {
                                                                finalList =
                                                                    i['items'];
                                                              }
                                                            }
                                                          });
                                                        },
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors.green,
                                                          child: Text((x[i][j])
                                                              .toString()),
                                                        ),
                                                      ),
                                                    )
                                                  : x[i][j] < 0
                                                      ? Visibility(
                                                          visible: false,
                                                          child: CircleAvatar(
                                                            backgroundColor:
                                                                Colors.white,
                                                            child: Text(((x[i]
                                                                    [j]))
                                                                .toString()),
                                                          ),
                                                        )
                                                      : cond == lastday
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                print(
                                                                    "inhere1");

                                                                setState(() {
                                                                  finalList =
                                                                      [];
                                                                  for (var xx
                                                                      in dailyDetails) {
                                                                    if ((x[i][j])
                                                                            .toString() ==
                                                                        xx['date']
                                                                            .toString()) {
                                                                      finalList =
                                                                          xx['items'];
                                                                    }
                                                                  }
                                                                });
                                                              },
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    transactions.contains(
                                                                            x[i][j]
                                                                                .toString())
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red,
                                                                child: Text(
                                                                  x[i][j]
                                                                      .toString(),
                                                                  // (x[i][j]).toString(),
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            )
                                                          : GestureDetector(
                                                              onTap: () {
                                                                print(
                                                                    "inhere2");
                                                                setState(() {
                                                                  finalList =
                                                                      [];
                                                                  for (var ii
                                                                      in dailyDetails) {                                                                        
                                                                    if ((x[i][j] +1)
                                                                            .toString() ==
                                                                        ii['date']) {
                                                                      finalList =
                                                                          ii['items'];
                                                                    }
                                                                  }
                                                                });
                                                              },
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    transactions.contains(
                                                                            (x[i][j] + 1)
                                                                                .toString())
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red,
                                                                child: Text(
                                                                  (x[i][j] +1)
                                                                      .toString(),
                                                                  // (x[i][j] + 1).toString(),
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          10.0),
                                                                ),
                                                              ),
                                                            )),
                                        ]
                                      ],
                                    )
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.black, thickness: 2.0),
                    
                      Container(
                       
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: MediaQuery.of(context).size.width,
                        child: finalList.length == 0
                            ? Center(
                                child: Text(
                                "No Items Purchased !",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ))
                            : ListView.builder(
                                itemCount: finalList.length,
                                itemBuilder: (ctx, index) {
                                  return Card(
                                    color: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(
                                            color: Colors.white, width: 2.0)),
                                    child: ListTile(
                                      leading: Text(
                                        finalList[index]['product_id']['name'] +
                                            " ( " +
                                            finalList[index]['qty'].toString() +
                                            " " +
                                            finalList[index]['unit']
                                                .toString() +
                                            " ) ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: Text(
                                        finalList[index]['total'].toString() +
                                            " Rs",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                }),
                      ),
                    ],
                  ),
          );
  }
}
