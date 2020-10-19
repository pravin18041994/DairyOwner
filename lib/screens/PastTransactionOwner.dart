import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/database/DatabaseOperations.dart';
import 'package:dairy_app_owner/screens/FullTransactionDetails.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PastTransactionOwner extends StatefulWidget {
  var milkmanId;
  PastTransactionOwner(this.milkmanId);
  @override
  _PastTransactionOwnerState createState() => _PastTransactionOwnerState();
}

class _PastTransactionOwnerState extends State<PastTransactionOwner> {
  List<String> month;
  List<String> year;
  var monthDropdown;
  var yearDropdown;
  var storage;
  var token;
  var url;
  var isLoading = true;
  List transactionDataList;
  var connectivityResult;
  var isConnectionActive = true;
  DateFormat format = DateFormat('DD/M/yyyy');
  Map groupedItems;
  var decRes;
  DatabaseOperations databaseOperations;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    month = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
    ];
    year = [];

    for (int i = 2020; i < 2100; i++) {
      year.add(i.toString());
    }

    monthDropdown = DateTime.now().month.toString();
    print(monthDropdown.toString());
    yearDropdown = DateTime.now().year.toString();
    url = Constants.base_url +
        'transactions/get_short_details_update_transactions_owner';
    Future.delayed(Duration.zero, () async {
      getPastTransactionDetails();
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

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        isConnectionActive = true;
        getPastTransactionDetails();
      } else {
        isConnectionActive = false;
      }
    });
  }

  Future<void> getPastTransactionDetails() async {
    try {
      // openDialog();
      storage = FlutterSecureStorage();
      token = await storage.read(key: 'token');
      databaseOperations = DatabaseOperations();
      // int len =
      //     await databaseOperations.checkPastTransaction("past_transaction");
      // if (len == 0) {
      http.Response response = await http.post(url, body: {
        'milkman_id': widget.milkmanId,
        'month': monthDropdown.toString(),
        'year': yearDropdown.toString()
      }, headers: {
        "Authorization": 'Bearer ' + token
      });
      print(response.body);
      if (response.statusCode == 200) {
        // Navigator.pop(context);
        decRes = json.decode(response.body);
        if (decRes['state'] == 'success') {
          setState(() {
            isLoading = false;
            transactionDataList = decRes['data'];
            Iterable inReverse = transactionDataList.reversed;
            var reversedList = inReverse.toList();
            transactionDataList = reversedList;
          });
        } else {
          // Navigator.pop(context);
        }
      }

      // databaseOperations.insertPastTransaction(
      //     json.encode(decRes['data']), "past_transaction");
      // }

      // else {
      //   print("incache");
      //   List<Map> list = [];
      //   list = await databaseOperations.getPastTransaction();
      //   print(list[0]);
      //   List ss = list.toList();
      //   var qq = json.decode(ss[0]['data']);
      //   setState(() {
      //     Navigator.pop(context);
      //     isLoading = false;
      //     transactionDataList = qq;
      //     Iterable inReverse = transactionDataList.reversed;
      //     var reversedList = inReverse.toList();
      //     transactionDataList = reversedList;
      //   });
      // }
    } catch (e) {
      // Navigator.pop(context);
      checkInternetConnection();
    }
  }

  Future<void> getPastTransactionDetailsChangeMonth() async {
    try {
      openDialog();
      storage = FlutterSecureStorage();
      token = await storage.read(key: 'token');
      databaseOperations = DatabaseOperations();
      // int len =
      //     await databaseOperations.checkPastTransaction("past_transaction");
      // if (len == 0) {
      http.Response response = await http.post(url, body: {
        'milkman_id': widget.milkmanId,
        'month': monthDropdown.toString(),
        'year': yearDropdown.toString()
      }, headers: {
        "Authorization": 'Bearer ' + token
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        decRes = json.decode(response.body);
        if (decRes['state'] == 'success') {
          setState(() {
            isLoading = false;
            transactionDataList = decRes['data'];
            Iterable inReverse = transactionDataList.reversed;
            var reversedList = inReverse.toList();
            transactionDataList = reversedList;
          });
        } else {
          Navigator.pop(context);
        }
      }

      // databaseOperations.insertPastTransaction(
      //     json.encode(decRes['data']), "past_transaction");
      // }

      // else {
      //   print("incache");
      //   List<Map> list = [];
      //   list = await databaseOperations.getPastTransaction();
      //   print(list[0]);
      //   List ss = list.toList();
      //   var qq = json.decode(ss[0]['data']);
      //   setState(() {
      //     Navigator.pop(context);
      //     isLoading = false;
      //     transactionDataList = qq;
      //     Iterable inReverse = transactionDataList.reversed;
      //     var reversedList = inReverse.toList();
      //     transactionDataList = reversedList;
      //   });
      // }
    } catch (e) {
      Navigator.pop(context);
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
                      side: BorderSide(color: Colors.white)),
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
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "Transaction Details",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: isLoading == true
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              DropdownButton<String>(
                                value: monthDropdown,
                                icon: Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                ),
                                iconSize: 0.0,
                                elevation: 16,
                                hint: Text(
                                  " Select Month",
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: TextStyle(color: Colors.white),
                                underline: Container(
                                  height: 2,
                                  color: Colors.blue,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    monthDropdown = newValue;
                                  });
                                },
                                items: month.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                            fontFamily: 'Muli',
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                            fontSize: 15.0),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              DropdownButton<String>(
                                value: yearDropdown,
                                icon: Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                ),
                                iconSize: 0.0,
                                elevation: 16,
                                hint: Text(
                                  " Select Year",
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                style: TextStyle(color: Colors.blue),
                                underline: Container(
                                  height: 2,
                                  color: Colors.blue,
                                ),
                                onChanged: (String newValue) {
                                  setState(() {
                                    yearDropdown = newValue;
                                  });
                                },
                                items: year.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          fontFamily: 'Muli',
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.none,
                                          fontSize: 15.0),
                                    ),
                                  );
                                }).toList(),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: RaisedButton(
                                  color: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  onPressed: () {
                                    getPastTransactionDetailsChangeMonth();
                                  },
                                  child: Text("Go",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: isLoading == true
                              ? Center(
                                  child: CircularProgressIndicator(
                                  backgroundColor: Colors.blue,
                                ))
                              : transactionDataList.length == 0
                                  ? Center(
                                      child: Text(
                                        "No Data Present !",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: transactionDataList.length == 0
                                          ? 0
                                          : transactionDataList.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          children: [
                                            Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.2,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.95,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                      return FullTransactionDetails(
                                                        widget.milkmanId,
                                                        transactionDataList,
                                                        transactionDataList[
                                                                    index]
                                                                ['full_date']
                                                            .toString(),
                                                      );
                                                    }));
                                                  },
                                                  child: Card(
                                                    color: Colors.blue,
                                                    elevation: 0.0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            side: BorderSide(
                                                              width: 2.0,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18.0)),
                                                    child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20.0),
                                                                child: Text(
                                                                  "Date : ",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            20.0),
                                                                child: Text(
                                                                  transactionDataList[
                                                                              index]
                                                                          [
                                                                          'full_date']
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20.0),
                                                                child: Text(
                                                                  "Total Users Delivered : ",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            20.0),
                                                                child: Text(
                                                                  transactionDataList[
                                                                              index]
                                                                          [
                                                                          'product_attendance']
                                                                      .length
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            20.0),
                                                                child: Text(
                                                                  "Total Guest Users : ",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        right:
                                                                            20.0),
                                                                child: Text(
                                                                  transactionDataList[
                                                                              index]
                                                                          [
                                                                          'guest_user_details']
                                                                      .length
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15.0),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ]),
                                                  ),
                                                )),
                                          ],
                                        );
                                      }),
                        ),
                      ],
                    ),
                  ),
          );
  }
}
