import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/database/DatabaseOperations.dart';
import 'package:intl/intl.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import "package:collection/collection.dart";
import 'package:http/http.dart' as http;

class PurchaseSalesList extends StatefulWidget {
  @override
  _PurchaseSalesListState createState() => _PurchaseSalesListState();
}

class _PurchaseSalesListState extends State<PurchaseSalesList> {
  List flagExpanded;
  var storage;
  var token;
  var url;
  Map groupedItems;
  List finalList;
  DateFormat format = DateFormat('DD-MM-yyyy');
  var isLoading = true;
  String key;
  var connectivityResult;
  var isConnectionActive = true;
  DatabaseOperations databaseOperations;
  var decodedresponse;

  @override
  void initState() {
    flagExpanded = [];
    finalList = [];
    super.initState();
    url = Constants.base_url + "transactions/get_purchase_sale_transactions";
    getPurchaseSaleDetails();
  }

  Future<void> getPurchaseSaleDetails() async {
    try {
      storage = FlutterSecureStorage();
      token = await storage.read(key: 'token');

      databaseOperations = DatabaseOperations();
      int len = await databaseOperations
          .checkPurchaseSaleDetailsPresent("purchaseSaleDetails");
      if (len == 0) {
        http.Response response =
          await http.get(url, headers: {"Authorization": 'Bearer ' + token});
      print(response.body);
      if (response.statusCode == 200) {
       decodedresponse = json.decode(response.body);
        if (decodedresponse['state'] == 'success') {
          setState(() {
            isLoading = false;
            finalList = decodedresponse['data'];

            groupedItems = groupBy(finalList, (obj) => obj['full_date']);
            var newMap = Map.fromEntries(groupedItems.entries.toList()
              ..sort((e1, e2) =>
                  (format.parse(e2.key)).compareTo(format.parse(e1.key))));
            groupedItems = newMap;
            groupedItems.forEach((key, value) {
              List aa = [];
              for (var i in value) {
                aa.add(false);
              }
              flagExpanded.add(aa);
            });
          });
        } else {}
      } else {}
        databaseOperations.insertPurchaseSaleDetails(json.encode(decodedresponse['data']), "purchaseSaleDetails");
      } else {
        print("inhere1212");
        List<Map> list = [];
        list = await databaseOperations.getPurchaseSaleDetails();
        print(list[0]);
        List ss = list.toList();
        var qq = json.decode(ss[0]['data']);
        setState(() {
            isLoading = false;
            finalList =qq;
            groupedItems = groupBy(finalList, (obj) => obj['full_date']);
            var newMap = Map.fromEntries(groupedItems.entries.toList()
              ..sort((e1, e2) =>
                  (format.parse(e2.key)).compareTo(format.parse(e1.key))));
            groupedItems = newMap;
            groupedItems.forEach((key, value) {
              List aa = [];
              for (var i in value) {
                aa.add(false);
              }
              flagExpanded.add(aa);
            });
          });


      }
      
    } catch (e) {
      checkInternetConnection();
    }
  }

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        isConnectionActive = true;
      } else {
        isConnectionActive = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.blue,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            "Purchase Sale List",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          child: isLoading == true
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                  ),
                )
              : finalList.length == 0
                  ? Center(
                      child: Text("No Data"),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: groupedItems.length,
                          itemBuilder: (context, index) {
                            key = groupedItems.keys.elementAt(index);
                            print(groupedItems[key].length);
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.30,
                                      child: Divider(
                                          thickness: 2.0,
                                          height: 2.0,
                                          color: Colors.black),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 15.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.20,
                                      child: Text(
                                        "$key",
                                        style: TextStyle(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.30,
                                      child: Divider(
                                          thickness: 2.0,
                                          height: 2.0,
                                          color: Colors.black),
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    )
                                  ],
                                ),
                                Container(
                                  child: ListView.builder(
                                      itemCount: groupedItems[key].length,
                                      shrinkWrap: true,
                                      itemBuilder: (ctx, index2) {
                                        return Column(
                                          children: [
                                            Container(
                                                color: Colors.blue,
                                                child: Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                          cardColor:
                                                              Colors.blue),
                                                  child: ExpansionPanelList(
                                                    expansionCallback:
                                                        (int index3,
                                                            var state) {
                                                      setState(() {
                                                        print("ind" +
                                                            index3.toString());
                                                        flagExpanded[index]
                                                                [index2] =
                                                            flagExpanded[index][
                                                                        index2] ==
                                                                    false
                                                                ? true
                                                                : false;
                                                      });
                                                    },
                                                    children: [
                                                      ExpansionPanel(
                                                          canTapOnHeader: true,
                                                          isExpanded:
                                                              flagExpanded[index]
                                                                  [index2],
                                                          headerBuilder: (BuildContext
                                                                  context,
                                                              bool isExpanded) {
                                                            return new ListTile(
                                                                title: new Text(
                                                              groupedItems[key][index2]['transactions']
                                                                              [0]
                                                                          [
                                                                          'name']
                                                                      .toString() +
                                                                  " ( " +
                                                                  groupedItems[key]
                                                                              [
                                                                              index2]['transactions'][0]
                                                                          [
                                                                          'type']
                                                                      .toString() +
                                                                  " )",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style:
                                                                  new TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ));
                                                          },
                                                          body: Container(
                                                              height: MediaQuery.of(context)
                                                                      .size
                                                                      .height *
                                                                  0.2,
                                                              width:
                                                                  MediaQuery.of(context)
                                                                      .size
                                                                      .width,
                                                              child: Card(
                                                                  elevation:
                                                                      0.0,
                                                                  color:
                                                                      Colors
                                                                          .blue,
                                                                  child: ListView
                                                                      .builder(
                                                                          itemCount: groupedItems[key][index2]['transactions'][0]['item_details']
                                                                              .length,
                                                                          itemBuilder:
                                                                              (context, index4) {
                                                                            return ListTile(
                                                                              leading: Text(
                                                                                groupedItems[key][index2]['transactions'][0]['item_details'][index4]['product_id']['name'] + " ( " + groupedItems[key][index2]['transactions'][0]['item_details'][index4]['unit'].toString() + " " + groupedItems[key][index2]['transactions'][0]['item_details'][index4]['product_id']['measurement_unit'] + " ) ",
                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                                              ),
                                                                              trailing: Text(
                                                                                groupedItems[key][index2]['transactions'][0]['item_details'][index4]['total'].toString() + " Rs",
                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                                              ),
                                                                            );
                                                                          })))),
                                                    ],
                                                  ),
                                                )),
                                            SizedBox(
                                              height: 10.0,
                                            )
                                          ],
                                        );
                                      }),
                                )
                              ],
                            );
                          }),
                    ),
        ));
  }
}
