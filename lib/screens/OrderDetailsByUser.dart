import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class OrderDetailsByUSer extends StatefulWidget {
  @override
  _OrderDetailsByUSerState createState() => _OrderDetailsByUSerState();
}

class _OrderDetailsByUSerState extends State<OrderDetailsByUSer> {
  var selectedDate;
  var sdo;
  var storage;
  final dateFocusNode = FocusNode();
  var connectivityResult;
  var isConnectionActive = true;
  var timestamp_order;

  var token;
  var ordersUrl;
  List ordersList;
  var finishUrl;
  TextEditingController dateController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FocusNode nodeTodayButton = FocusNode();

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    ordersUrl = Constants.base_url + 'orders/get_orders_admin';
    finishUrl = Constants.base_url + 'orders/finish_order';
    ordersList = [];
  }

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        isConnectionActive = true;
        getOrders(dateController.text);
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

  Future<Null> showDateTimePicker(BuildContext context2) async {
    DateTime d = await showDatePicker(
      context: context2,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if (d != null && d != selectedDate) {
      openDialog();
      setState(() {
        print(d);
        var finalDate = d.toLocal().toString().split(' ');
        sdo = finalDate[0];
        dateController.text = finalDate[0];
        getOrders(finalDate[0]);
        Navigator.pop(context);
      });
    }
  }

  Future<void> getOrders(d) async {
    try {
      openDialog();
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http.post(ordersUrl,
          body: {'order_date': d},
          headers: {"Authorization": 'Bearer ' + token});
      print(response.body);
      print(d);

      var jsonDecoded = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        if (jsonDecoded['state'] == 'success') {
          setState(() {
            FocusScope.of(context).requestFocus(nodeTodayButton);
            ordersList = jsonDecoded['data'];
            for (var i in ordersList) {
              timestamp_order = i['timestamp_added'];
              timestamp_order = timestamp_order.toString().split("T");
              i['timestamp_added'] = timestamp_order[1]
                  .toString()
                  .substring(0, timestamp_order[1].toString().length - 5);
              if (int.parse(i['timestamp_added'].toString().split(':')[0]) <
                  12) {
                i['timestamp_added'] = i['timestamp_added'] + " AM";
              } else {
                i['timestamp_added'] = i['timestamp_added'] + " PM";
              }
            }
          });
        } else {}
      } else {}
    } on NoSuchMethodError {}
  }

  Future<void> finishOrder(id) async {
    try {
      openDialog();
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http.post(finishUrl,
          body: {'order_id': id},
          headers: {'Authorization': 'Bearer ' + token});
      print(response.body);

      if (response.statusCode == 200) {
        Navigator.pop(context);
        var decodedResponse = json.decode(response.body);
        if (decodedResponse['state'] == 'success') {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Status Updated... !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 5),
          ));

          if (mounted) {
            setState(() {
              getOrders(dateController.text);
            });
          }
          FocusScope.of(context).requestFocus(nodeTodayButton);
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Cannot Update  !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 3),
          ));
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please try again later  !',
            style: TextStyle(fontFamily: 'Muli'),
          ),
          duration: Duration(seconds: 3),
        ));
      }
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
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.blue,
              centerTitle: true,
              title: Text(
                "Order Details",
                style: TextStyle(
                  color: Colors.white,
                   fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
            ),
            body: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                 
                  child: Column(
                    children: <Widget>[
                      Container(
                       
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              width: 125.0,
                              child: TextField(
                                cursorColor: Colors.blue,
                                style: TextStyle(
                                  color: Colors.blue
                                ),
                                focusNode: dateFocusNode,
                                controller: dateController,
                                onTap: () {
                                  showDateTimePicker(context);
                                },
                                decoration: InputDecoration(
                                    hintText: "Select Date",
                                    hintStyle: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue)),
                                            enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue)),
                                            ),
                              ),
                            ),
                            Container(
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.white
                                  )
                                ),
                                focusNode: nodeTodayButton,
                                color: Colors.blue,
                                child: Text(
                                  "Today",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  print(DateTime.now());
                                  dateController.text =
                                      DateTime.now().toString().split(' ')[0];
                                  getOrders(
                                      DateTime.now().toString().split(' ')[0]);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.blue,
                        thickness: 2.0,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 24.0),
                        height: MediaQuery.of(context).size.height * 0.80,
                        child: ordersList.length == 0
                            ? Center(
                                child: Text(
                                  'No orders present !',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24.0),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: ordersList.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.91,
                                    child: Card(
                                      color: ordersList[index]
                                                  ['order_status'] ==
                                              "Completed"
                                          ? Colors.green[200]
                                          : Colors.orange[200],
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          side: BorderSide(
                                              color: Colors.black, width: 2.0)),
                                      child: Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  ordersList[index]['user_id']
                                                      ['name'],
                                                  style: TextStyle(
                                                     fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                    fontSize: 20.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  ordersList[index]
                                                          ['order_date']
                                                      .toString(),style: TextStyle(
                                                         fontWeight: FontWeight.bold,
                                                      ),
                                                ),
                                                Text(
                                                  ordersList[index]
                                                          ['timestamp_added']
                                                      .toString(),style: TextStyle(
                                                         fontWeight: FontWeight.bold,
                                                      ),
                                                )
                                              ],
                                            ),
                                            Text(
                                              ordersList[index]['user_id']
                                                  ['address'],
                                              style: TextStyle(
                                                 fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text("Transaction Id : ",style: TextStyle(
                                                   fontWeight: FontWeight.bold,
                                                ),),
                                                Text("#" +
                                                    ordersList[index]
                                                            ['transaction_id']
                                                        .toString(),style: TextStyle(
                                                           fontWeight: FontWeight.bold,
                                                        ),)
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text("Order Id : ",style: TextStyle(
                                                   fontWeight: FontWeight.bold,
                                                ),),
                                                Text("#" +
                                                    ordersList[index]['orderid']
                                                        .toString(),style: TextStyle(
                                                           fontWeight: FontWeight.bold,
                                                        ),)
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text("Payment Mode : ",style: TextStyle(
                                                   fontWeight: FontWeight.bold,
                                                ),),
                                                Text(ordersList[index]
                                                        ['payment_mode']
                                                    .toString(),style: TextStyle(
                                                       fontWeight: FontWeight.bold,
                                                    ),)
                                              ],
                                            ),
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.3,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: ordersList[index]
                                                        ['items']
                                                    .length,
                                                itemBuilder: (BuildContext ctx,
                                                    int index2) {
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 20.0),
                                                        child: Text(
                                                          ordersList[index][
                                                                          'items']
                                                                      [index2][
                                                                  'description'] +
                                                              " X " +
                                                              ordersList[index][
                                                                          'items']
                                                                      [
                                                                      index2]['qty']
                                                                  .toString(),
                                                          style: TextStyle(
                                                            color: Colors.black,
                                                             fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            right: 20.0),
                                                        child: Text(
                                                          (ordersList[index]['items']
                                                                              [
                                                                              index2]
                                                                          [
                                                                          'qty'] *
                                                                      ordersList[index]
                                                                              [
                                                                              'items'][index2]
                                                                          [
                                                                          'rate'])
                                                                  .toString() +
                                                              " Rs",
                                                          style: TextStyle(
                                                             fontWeight: FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                            Divider(
                                              height: 2.0,
                                              thickness: 1.0,
                                              color: Colors.black,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        left: 20.0),
                                                    child: Text(
                                                      "Total",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                         fontWeight: FontWeight.bold,
                                                      ),
                                                    )),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 20.0),
                                                  child: Text(
                                                    ordersList[index]['total']
                                                            .toString() +
                                                        " Rs",
                                                    style: TextStyle(
                                                       fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Divider(
                                              height: 2.0,
                                              thickness: 1.0,
                                              color: Colors.black,
                                            ),
                                            Container(
                                              child: ordersList[index]
                                                          ['order_status'] ==
                                                      'Completed'
                                                  ? Container(
                                                      child: Text(
                                                        'Completed !',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 20.0),
                                                      ),
                                                    )
                                                  : RaisedButton(
                                                      color: Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          18.0),
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .black)),
                                                      onPressed: () {
                                                        finishOrder(
                                                            ordersList[index]
                                                                ['_id']);
                                                      },
                                                      child: Text(
                                                        "Finish Order",
                                                        style: TextStyle(
                                                            color: Colors.blue,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
