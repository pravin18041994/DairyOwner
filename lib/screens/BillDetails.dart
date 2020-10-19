import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'DayWiseBillDetails.dart';

class BillDetails extends StatefulWidget {
  var id;
  var name;
  BillDetails(this.id, this.name);

  @override
  _BillDetailsState createState() => _BillDetailsState();
}

class _BillDetailsState extends State<BillDetails> {
  TextEditingController yearController = new TextEditingController();
  var selectedYear;
  var lst = [];
  var currentYear;
  var token;
  var storage;
  var billDetailsUrl;
  List detailsList;
  var userAddress;
  var year;
  List totalAmt;
  var final_total = 0;
  var urlUser;
  var connectivityResult;
  var isConnectionActive = true;
  int now;
  int lastday;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    detailsList = [];

    currentYear = DateTime.now().toLocal().toString().split('-')[0];
    yearController.text = currentYear;
    urlUser = Constants.base_url + 'users/get_single_user';
    billDetailsUrl = Constants.base_url + 'users/get_user_wiz_bill_details';
    totalAmt = [];
    lst = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    checkInternetConnection();
    getUserAddress();
    getBillDetails();
  }

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        isConnectionActive = true;
        // getUserAddress();
        // getBillDetails();
      } else {
        isConnectionActive = false;
      }
    });
  }

  Future<Null> showDateTimePicker(BuildContext context2) async {
    DateTime newDateTime = await showRoundedDatePicker(
      context: context,
      initialDatePickerMode: DatePickerMode.year,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
    setState(() {
      yearController.text = newDateTime.toLocal().toString().split('-')[0];
    });
  }

  Future<void> getUserAddress() async {
    try {
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http.post(urlUser,
          body: {'id': widget.id},
          headers: {'Authorization': 'Bearer ' + token});
      var decodedResponse = json.decode(response.body);
      print('yes' + response.body);
      if (decodedResponse['state'] == 'success') {
        setState(() {
          userAddress = decodedResponse['msg'][0]['address'];
        });
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<void> getBillDetails() async {
    try {
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http.post(billDetailsUrl,
          body: {'id': widget.id},
          headers: {"Authorization": 'Bearer ' + token});
      print(response.body);
      var jsonDecoded = json.decode(response.body);
      print("RRRRR" + jsonDecoded['data'].toString());

      setState(() {
        for (int i = 0; i < 12; i++) {
          List ll = [];
          for (var j in jsonDecoded['data']) {
            if ((i + 1) == int.parse(j['_id']['month'])) {
              var obj = {
                'user_address': j['_id']['user_id']['address'],
                'productid': j['_id']['productid'],
                'total': j['total'],
                'qty': j['qty'],
              };
              final_total += j['total'];
              ll.add(obj);
              print(final_total);
            } else {
              continue;
            }
          }
          totalAmt.add(final_total);
          final_total = 0;
          if (ll.isEmpty) {
            List ll2 = [];
            ll2.add(null);
            detailsList.add(ll2);
          } else {
            detailsList.add(ll);
          }
        }
      });
      print(detailsList);
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
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.blue,
              centerTitle: true,
              title: Text(
                widget.name,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
            ),
            body: detailsList.length == 0
                ? Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                  ))
                : Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Container(
                              height: 35.0,
                              child: SizedBox(
                                width: 125.0,
                                child: TextField(
                                  readOnly: true,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                  controller: yearController,
                                  decoration: InputDecoration(
                                    hintText: "Select Year",
                                    hintStyle: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue)),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.date_range,
                                size: 40.0,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                checkInternetConnection();
                                showDateTimePicker(context);
                              },
                            ),
                          ],
                        ),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 24.0),
                          height: MediaQuery.of(context).size.height * 0.75,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: lst.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.67,
                                      width: MediaQuery.of(context).size.width *
                                          0.91,
                                      child: Card(
                                        color: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            side: BorderSide(
                                                color: Colors.white,
                                                width: 4.0)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.1,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Transform.rotate(
                                                    angle: -(3.42) / 4,
                                                    child: Container(
                                                        color: Colors.white,
                                                        height: 30,
                                                        width: 65,
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                0, 20, 10, 10),
                                                        child: Center(
                                                          child: Text(
                                                            lst[index]
                                                                .toString(),
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 12.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        )),
                                                  ),
                                                  detailsList[index][0] == null
                                                      ? Container()
                                                      : Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  right: 10.0),
                                                          child: InkWell(
                                                            onTap: () {
                                                              checkInternetConnection();
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (_) {
                                                                return DayWiseBillDetails(
                                                                    index + 1,
                                                                    int.parse(
                                                                        yearController
                                                                            .text),
                                                                    widget.id);
                                                              }));
                                                            },
                                                            child: Text(
                                                              "See Full Details",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  userAddress.toString(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Divider(
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                            detailsList[index][0] == null
                                                ? Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                    child: Center(
                                                      child: Text(
                                                        "No Bill Generated !",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  )
                                                : Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: <Widget>[
                                                      Column(
                                                        children: [
                                                          Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.3,
                                                            child: ListView
                                                                .builder(
                                                                    shrinkWrap:
                                                                        true,
                                                                    itemCount: detailsList[
                                                                            index]
                                                                        .length,
                                                                    itemBuilder:
                                                                        (BuildContext
                                                                                context,
                                                                            int index2) {
                                                                      return Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        children: <
                                                                            Widget>[
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: <Widget>[
                                                                              Container(
                                                                                margin: EdgeInsets.only(left: 10.0),
                                                                                child: Text(
                                                                                  detailsList[index][index2] == null ? "" : detailsList[index][index2]['productid']['name'].toString() + " ( " + detailsList[index][index2]['qty'].toString() + detailsList[index][index2]['productid']['measurement_unit'].toString() + " )",
                                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                margin: EdgeInsets.only(right: 10.0),
                                                                                child: Text(
                                                                                  detailsList[index][index2] == null ? "" : detailsList[index][index2]['total'].toString() + " Rs",
                                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Divider(
                                                                            color:
                                                                                Colors.white,
                                                                          )
                                                                        ],
                                                                      );
                                                                    }),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.08,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          10.0),
                                                              child: Text(
                                                                "Total",
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
                                                                          10.0),
                                                              child: Text(
                                                                totalAmt[index]
                                                                        .toString() +
                                                                    " Rs",
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
                                                      ),
                                                    ],
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
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
