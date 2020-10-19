import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class DayWiseStockDetails extends StatefulWidget {
  @override
  _DayWiseStockDetailsState createState() => _DayWiseStockDetailsState();
}

class _DayWiseStockDetailsState extends State<DayWiseStockDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> month;
  List<String> year;
  var monthDropdown;
  var yearDropdown;
  DateFormat format = DateFormat('DD/M/yyyy');
  var connectivityResult;
  var isConnectionActive = true;
  List stockDetails = [];
  var isLoading = false;

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
    getDayWiseStockDetails();
  }

  Future<void> getDayWiseStockDetails() async {
    try {
      final storage = new FlutterSecureStorage();
      var token = await storage.read(key: 'token');
      print("inhere");
      print(monthDropdown);
      print(yearDropdown);
      http.Response response = await http.post(
          Constants.base_url + "stocks/get_day_wise_stock_details",
          body: {
            'month': monthDropdown,
            'year': yearDropdown,
          },
          headers: {
            'Authorization': 'Bearer' + ' ' + token,
            "Accept": "application/json"
          });
      print(response.body);
      if (response.statusCode == 200) {
        var decRes = json.decode(response.body);
        if (decRes['state'] == 'success') {
          setState(() {
            isLoading = true;
            stockDetails = decRes['msg'];
          });
        } else {}
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());

    if (mounted) {
      setState(() {
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          isConnectionActive = true;
        } else {
          isConnectionActive = false;
        }
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return isConnectionActive == false
        ? Scaffold(
            key: _scaffoldKey,
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Card(
                  child: Text(
                    'No Internet Connection !',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                RaisedButton(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.black)),
                  onPressed: () {
                    checkInternetConnection();
                  },
                  child: Text(
                    'Refresh',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              centerTitle: true,
              title: Text(
                "Day Wise Stocks",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: Container(
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
                          items: month
                              .map<DropdownMenuItem<String>>((String value) {
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
                          items: year
                              .map<DropdownMenuItem<String>>((String value) {
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
                                borderRadius: BorderRadius.circular(20.0)),
                            onPressed: () {
                              setState(() {
                                isLoading = false;
                              });
                              getDayWiseStockDetails();
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
                  Divider(
                    color: Colors.black,
                    height: 5.0,
                    thickness: 2.0,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.77,
                    width: MediaQuery.of(context).size.width,
                    child: AnimationLimiter(
                      child: isLoading == false
                          ? Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.blue,
                              ),
                            )
                          : stockDetails.length == 0
                              ? Center(
                                  child: Text(
                                    "No Data",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: stockDetails.length,
                                  itemBuilder: (ctx, index) =>
                                      AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration:
                                            const Duration(milliseconds: 600),
                                        child: SlideAnimation(
                                          verticalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: Card(
                                              color: Colors.blue,
                                              child: ExpansionTile(
                                                backgroundColor: Colors.blue,
                                                title: Center(
                                                  child: Text(
                                                    stockDetails[index]
                                                            ['full_date']
                                                        .toString()
                                                        .split(",")[0]
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                children: [
                                                  ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        stockDetails[index]
                                                                ['products']
                                                            .length,
                                                    itemBuilder:
                                                        (ctx, index2) =>
                                                            ExpansionTile(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      title: Text(
                                                        stockDetails[index]['products']
                                                                        [index2]
                                                                    [
                                                                    'product_id']
                                                                ['name']
                                                            .toString(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      children: [
                                                        ListTile(
                                                          leading: Text(
                                                            "Delivered",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          trailing: Text(
                                                            stockDetails[index][
                                                                            'products']
                                                                        [index2]
                                                                    [
                                                                    'delivered']
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        ListTile(
                                                          leading: Text(
                                                            "Left",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          trailing: Text(
                                                            stockDetails[index][
                                                                        'products']
                                                                    [
                                                                    index2]['left']
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        ListTile(
                                                          leading: Text(
                                                            "Lost",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          trailing: Text(
                                                            stockDetails[index][
                                                                        'products']
                                                                    [
                                                                    index2]['lost']
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
