import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExtraItemPageOwner extends StatefulWidget {
  @override
  _ExtraItemPageOwnerState createState() => _ExtraItemPageOwnerState();
}

class _ExtraItemPageOwnerState extends State<ExtraItemPageOwner> {
  var url;
  bool isloading = true;
  var storage;
  var token;
  List requests;
  var flag = 1;
  var confirmurl;
  var listExtra;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var connectivityResult;
  var isConnectionActive = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requests = [];
    url = Constants.base_url + 'transactions/get_pending_requests';
    confirmurl =
        Constants.base_url + 'transactions/change_status_pending_request';
    extraItemRequest();
    checkInternetConnection();
  }

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        isConnectionActive = true;
        // extraItemRequest();
      } else {
        isConnectionActive = false;
      }
    });
  }

  Future<void> confirmStatus(var status, var id) async {
    try {
      openDialog();
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      var requestId;
      for (var i in listExtra) {
        if (id == i['_id']) {
          for (var j in i['extra_item_requests']) {
            requestId = j['_id'];
            print("Req Id" + requestId);
          }
        }
      }
      http.Response response = await http.post(confirmurl,
          body: {'user_id': id, 'flag': status, 'subdoc_id': requestId},
          headers: {"Authorization": 'Bearer ' + token});
      print(response.body);
      var decodedResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        if (decodedResponse['state'] == 'success') {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Status Updated Successfully !',
                style: TextStyle(fontFamily: 'Muli')),
            duration: Duration(seconds: 5),
          ));
          setState(() {
            requests.clear();
          });
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Can\'t Update Status !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 5),
          ));
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please Try Again Later !',
            style: TextStyle(fontFamily: 'Muli'),
          ),
          duration: Duration(seconds: 5),
        ));
      }
    } catch (e) {
      Navigator.pop(context);
      checkInternetConnection();
    }
  }

  Future<void> extraItemRequest() async {
    try {
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response =
          await http.get(url, headers: {'Authorization': 'Bearer ' + token});
      print(response.body);
      var decodedResponse = json.decode(response.body);
      listExtra = decodedResponse['data'];
      if (response.statusCode == 200) {
        if (decodedResponse['state'] == 'success') {
          setState(() {
            isloading = false;
            List products = [];
            for (var i in decodedResponse['data']) {
              var dat = "";
              if (i['extra_item_requests'].length == 0) {
                continue;
              } else {
                for (var j in i['extra_item_requests']) {
                  if (j.length == 0) {
                    continue;
                  } else {
                    for (var k in j['requests']) {
                      if (j['req_status'] == 'pending') {
                        for (var kl in j['dates']) {
                          dat = dat + kl.toString();
                          if (j['dates'].indexOf(kl) == j['dates'].length - 1) {
                            break;
                          }
                          dat = dat + ",";
                        }
                        flag = 0;
                        var obj2 = {
                          '_id': k['_id'],
                          'name': k['product_id']['name'],
                          'qty': k['qty'],
                          'total': k['total'],
                          'unit': k['unit']
                        };
                        products.add(obj2);
                      }
                    }
                  }
                }
              }
              if (flag == 0) {
                var obj = {
                  'id': i['_id'],
                  'name': i['name'],
                  'address': i['address'],
                  'dates': dat.toString(),
                  'products': products,
                };
                requests.add(obj);
              } else {
                continue;
              }

              products = [];
            }
          });

          print(requests);
        } else {}
      } else {}
    } catch (e) {
      checkInternetConnection();
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
            key: _scaffoldKey,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Colors.blue,
              elevation: 0.0,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "Extra Item Requests ",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: isloading == true
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ),
                  )
                : requests.length == 0
                    ? Center(
                        child: Text(
                          'No Data Present !',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0),
                        ),
                      )
                    : ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.blue,
                            margin: EdgeInsets.all(15.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side: BorderSide(color: Colors.white)),
                            child: Container(
                              margin: EdgeInsets.all(10.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    requests[index]['name'],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0),
                                  ),
                                  Divider(
                                    color: Colors.white,
                                  ),
                                  Text(
                                    requests[index]['address'],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20.0),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "Dates : ",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0),
                                      ),
                                      Text(
                                        requests[index]['dates'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.0),
                                      ),
                                    ],
                                  ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                          requests[index]['products'].length,
                                      itemBuilder:
                                          (BuildContext context, int index2) {
                                        return Row(
                                          children: <Widget>[
                                            Flexible(
                                              child: ListTile(
                                                title: Text(
                                                  requests[index]['products']
                                                              [index2]['name']
                                                          .toString() +
                                                      '(' +
                                                      requests[index]
                                                                  ['products']
                                                              [index2]['qty']
                                                          .toString() +
                                                      " " +
                                                      requests[index]
                                                              ['products']
                                                          [index2]['unit'] +
                                                      ')',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(right: 10.0),
                                              child: Text(
                                                requests[index]['products']
                                                            [index2]['total']
                                                        .toString() +
                                                    " Rs",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        );
                                      }),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      RaisedButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            side: BorderSide(
                                                color: Colors.white)),
                                        color: Colors.white,
                                        onPressed: () {
                                          checkInternetConnection();
                                          setState(() {
                                            confirmStatus('accept',
                                                requests[index]['id']);
                                          });
                                        },
                                        child: Text(
                                          "Accept",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      RaisedButton(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18.0),
                                            side: BorderSide(
                                                color: Colors.white)),
                                        onPressed: () {
                                          checkInternetConnection();
                                          setState(() {
                                            confirmStatus('declined',
                                                requests[index]['id']);
                                          });
                                        },
                                        child: Text(
                                          "Decline",
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
          );
  }
}
