import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/database/DatabaseOperations.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class PastTransactionDetailsPage extends StatefulWidget {
  List transactionDataList;
  String date;
  PastTransactionDetailsPage(this.transactionDataList, this.date);

  @override
  _PastTransactionDetailsPageState createState() =>
      _PastTransactionDetailsPageState();
}

class _PastTransactionDetailsPageState
    extends State<PastTransactionDetailsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var isLoading;
  var guestUserIndex;
  List finalList;
  var updateUrl;
  var storage;
  var token;
  var productDropdown;
  var trId;
  var updateUnit;
  var getProductsUrl;
  List<String> productList;
  TextEditingController qtyController = TextEditingController();
  TextEditingController updateQtyController = TextEditingController();
  var unit;
  var connectivityResult;
  var isConnectionActive = true;
  List guestUserList;
  var getUsersMilkman;
  DatabaseOperations databaseOperations;
  List<String> userNames;
  List userList;
  var decodedResponse;
  var userDropdown;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    finalList = [];
    userNames = [];
    guestUserList = [];
    pstDetails();
    unit = "";
    print("final List" + finalList.toString());
    getProductsUrl = Constants.base_url + "products/get_all_products_milkman";
    updateUrl = Constants.base_url + 'transactions/update_transaction';
    getUsersMilkman = Constants.base_url + "users/get_users_milkmen";
    getProducts();
    getUser();
  }

  pstDetails() async {
    setState(() {
      print(widget.transactionDataList.toString());
      for (var i in widget.transactionDataList) {
        if (i['full_date'] == widget.date) {
          trId = i['_id'];
          finalList = i['product_attendance'];
          guestUserList = i['guest_user_details'];
          print('ggg' + guestUserList.toString());
        }
      }
      for (var j in finalList) {
        for (var k in j['items_bought']) {
          if (k['status'] == "Delivered") {
            k['del_status'] = true;
          } else {
            k['del_status'] = false;
          }
        }
      }
    });
  }

  void changeQuantityDialog(var amt, var unt, var index, var index2) {
    setState(() {
      updateQtyController.text = amt;
    });
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.blue)),
          title: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextField(
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      controller: updateQtyController,
                      decoration: InputDecoration(
                          hintText: "Add Quantity",
                          hintStyle: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))),
                    ),
                  ),
                  Text(
                    unt.toString(),
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.white)),
                      color: Colors.white,
                      elevation: 5.0,
                      child: Text(
                        "Update",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          finalList[index]['items_bought'][index2]['qty'] =
                              updateQtyController.text;
                          finalList[index]['items_bought'][index2]['total'] =
                              finalList[index]['items_bought'][index2]
                                      ['total'] *
                                  int.parse(updateQtyController.text);
                        });
                        Navigator.pop(context);
                      }),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                    color: Colors.white,
                    elevation: 5.0,
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> getProducts() async {
    try {
      productList = [];
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'milkman_token');
      print(token);
      http.Response response = await http.get(getProductsUrl, headers: {
        'Authorization': 'Bearer' + ' ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);

        if (decodedResponse['state'] == 'success') {
          setState(() {
            for (var i in decodedResponse['data']) {
              var obj = {
                'name': i['name'],
                'unit': i['measurement_unit'],
                'id': i['_id'],
                'rate': i['rate']
              };
              productList.add(json.encode(obj));
            }
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
          getProducts();
          pstDetails();
        } else {
          isConnectionActive = false;
        }
      });
    }
  }

  void dialogBoxConfirmation(var index) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.blue)),
          title: Column(
            children: <Widget>[
              new Text(
                "Are You Sure ?",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.white,
                      elevation: 5.0,
                      child: Text(
                        "Yes",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          guestUserList.removeAt(index);
                        });
                        Navigator.pop(context);
                      }),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                    color: Colors.white,
                    elevation: 5.0,
                    child: Text(
                      "No",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> getUser() async {
    try {
      userNames = [];
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'milkman_token');
      print("token");
      print(token);

      http.Response response = await http.get(getUsersMilkman, headers: {
        'Authorization': 'Bearer' + ' ' + token,
        "Accept": "application/json"
      });
      print("users" + response.body.toString());
      if (response.statusCode == 200) {
        var responseBody = response.body;
        decodedResponse = jsonDecode(responseBody);

        setState(() {
          isLoading = false;
          userList = decodedResponse['data'];
          for (var i in userList) {
            var obj = {'id': i['_id'], 'name': i['name']};
            userNames.add(json.encode(obj));
          }
        });
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

  void dialogBoxAddUser() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.blue)),
          content: StatefulBuilder(
            builder: (ctx, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.2,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ListTile(
                          title: DropdownButton<String>(
                            dropdownColor: Colors.blue,
                            value: userDropdown,
                            icon: Icon(
                              Icons.arrow_downward,
                              color: Colors.blue,
                            ),
                            iconSize: 0.0,
                            elevation: 16,
                            hint: Text(
                              "Select User",
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: TextStyle(color: Colors.white),
                            underline: Container(
                              height: 2,
                              color: Colors.white,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                userDropdown = newValue;
                              });
                            },
                            items: userNames
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: json.decode(value)['id'].toString(),
                                child: Text(
                                  json.decode(value)['name'].toString(),
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontFamily: 'Muli',
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.white)),
                                color: Colors.white,
                                elevation: 5.0,
                                child: Text(
                                  "Add",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  setState(() {
                                    for (var ii in finalList) {
                                      print(ii['user_id']);
                                      if (ii['user_id']['_id'].toString() ==
                                          userDropdown) {
                                        print("InHere1212121");

                                        Fluttertoast.showToast(
                                            msg: "User already exists",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        Navigator.pop(context);
                                        userDropdown = null;
                                        return;
                                      }
                                    }
                                    for (var i in userList) {
                                      if (i['_id'] == userDropdown) {
                                        var obj = {
                                          'user_id': i,
                                          'items_bought': []
                                        };
                                        finalList.add(obj);
                                        Navigator.pop(context);
                                      }
                                    }
                                    userDropdown = null;
                                  });
                                }),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.white)),
                              color: Colors.white,
                              elevation: 5.0,
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).then((value) => setState(() {}));
  }

  void dialogBoxAddGuestUserProducts() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.blue)),
          content: StatefulBuilder(
            builder: (ctx, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ListTile(
                          title: DropdownButton<String>(
                            dropdownColor: Colors.blue,
                            value: productDropdown,
                            icon: Icon(
                              Icons.arrow_downward,
                              color: Colors.blue,
                            ),
                            iconSize: 0.0,
                            elevation: 16,
                            hint: Text(
                              "Select Products",
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: TextStyle(color: Colors.white),
                            underline: Container(
                              height: 2,
                              color: Colors.white,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                productDropdown = newValue;
                                for (var ii in productList) {
                                  if (newValue == json.decode(ii)['name']) {
                                    unit = json.decode(ii)['unit'];
                                  }
                                }
                              });
                            },
                            items: productList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: json.decode(value)['name'].toString(),
                                child: Text(
                                  json.decode(value)['name'].toString(),
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontFamily: 'Muli',
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: TextField(
                                cursorColor: Colors.white,
                                style: TextStyle(color: Colors.white),
                                controller: qtyController,
                                keyboardType: TextInputType.numberWithOptions(),
                                decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    hintText: "Enter Quantity",
                                    hintStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Text(
                              unit.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.white)),
                                color: Colors.white,
                                elevation: 5.0,
                                child: Text(
                                  "Add",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  setState(() {
                                    for (var j in guestUserList) {
                                      if (j['product_id']['name'] ==
                                          productDropdown.toString()) {
                                        print("inhere");
                                        Navigator.pop(context);
                                        _scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            'Item Already Present !',
                                            style:
                                                TextStyle(fontFamily: 'Muli'),
                                          ),
                                          duration: Duration(seconds: 3),
                                        ));
                                        return;
                                      }
                                    }
                                    for (var i in productList) {
                                      if (productDropdown.toString() ==
                                          json.decode(i)['name']) {
                                        var obj = {
                                          '_id': json.decode(i)['id'],
                                          'name': productDropdown.toString()
                                        };
                                        var obj2 = {
                                          'product_id': obj,
                                          'qty': qtyController.text,
                                          'unit': unit.toString(),
                                          'total': int.parse(
                                                  json.decode(i)['rate']) *
                                              int.parse(qtyController.text)
                                        };
                                        guestUserList.add(obj2);
                                      }
                                    }
                                    Navigator.pop(context);
                                    qtyController.clear();
                                    unit = "";
                                    productDropdown = null;

                                    // finalList[index]['items_bought'].add({});
                                  });
                                }),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.white)),
                              color: Colors.white,
                              elevation: 5.0,
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).then((value) => setState(() {}));
  }

  void dialogBoxAddProducts(var index) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.blue)),
          content: StatefulBuilder(
            builder: (ctx, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ListTile(
                          title: DropdownButton<String>(
                            dropdownColor: Colors.blue,
                            value: productDropdown,
                            icon: Icon(
                              Icons.arrow_downward,
                              color: Colors.blue,
                            ),
                            iconSize: 0.0,
                            elevation: 16,
                            hint: Text(
                              "Select Products",
                              style: TextStyle(
                                  fontFamily: 'Muli',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: TextStyle(color: Colors.white),
                            underline: Container(
                              height: 2,
                              color: Colors.white,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                productDropdown = newValue;

                                for (var ii in productList) {
                                  if (newValue == json.decode(ii)['name']) {
                                    unit = json.decode(ii)['unit'];
                                  }
                                }
                              });
                            },
                            items: productList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: json.decode(value)['name'].toString(),
                                child: Text(
                                  json.decode(value)['name'].toString(),
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontFamily: 'Muli',
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: TextField(
                                cursorColor: Colors.white,
                                style: TextStyle(color: Colors.white),
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                controller: qtyController,
                                decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    hintText: "Enter Quantity",
                                    hintStyle: TextStyle(
                                        fontFamily: 'Muli',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Text(
                              unit.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.white)),
                                color: Colors.white,
                                elevation: 5.0,
                                child: Text(
                                  "Add",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  setState(() {
                                    for (var j in finalList[index]
                                        ['items_bought']) {
                                      if (j['product_id']['name'] ==
                                          productDropdown.toString()) {
                                        Navigator.pop(context);
                                        _scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            'Item Already Present !',
                                            style:
                                                TextStyle(fontFamily: 'Muli'),
                                          ),
                                          duration: Duration(seconds: 3),
                                        ));
                                        Navigator.pop(context);
                                        qtyController.clear();
                                        unit = "";
                                        productDropdown = null;
                                        return;
                                      }
                                    }
                                    for (var p in productList) {
                                      if (productDropdown.toString() ==
                                          json.decode(p)['name']) {
                                        var obj = {
                                          '_id': json.decode(p)['id'],
                                          'name': productDropdown.toString()
                                        };

                                        var obj2 = {
                                          'qty': qtyController.text,
                                          'unit': unit.toString(),
                                          'product_id': obj,
                                          'del_status': true,
                                          'status': "Delivered",
                                          'total': int.parse(
                                                  qtyController.text) *
                                              int.parse(json.decode(p)['rate']),
                                          'description': qtyController.text +
                                              " " +
                                              unit.toString() +
                                              " " +
                                              productDropdown.toString()
                                        };
                                        finalList[index]['items_bought']
                                            .add(obj2);
                                      }
                                    }
                                    Navigator.pop(context);
                                    qtyController.clear();
                                    unit = "";
                                    productDropdown = null;
                                  });
                                }),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.blue)),
                              color: Colors.white,
                              elevation: 5.0,
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).then((value) => setState(() {}));
  }

  Future<void> updateTransaction() async {
    try {
      print("In Update");
      openDialog();
      storage = FlutterSecureStorage();
      token = await storage.read(key: 'milkman_token');
      var fl = json.encode(finalList);
      var gl = json.encode(guestUserList);
      http.Response response = await http.post(updateUrl, body: {
        'id': trId,
        'product_attendance': fl.toString(),
        'guest_user_details': gl.toString()
      }, headers: {
        "Authorization": 'Bearer ' + token
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        var decRes = json.decode(response.body);
        if (decRes['state'] == 'success') {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Updated Successfully !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 5),
          ));
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Cannot Update !',
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
          duration: Duration(seconds: 2),
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
                      side: BorderSide(color: Colors.white)),
                  onPressed: () {
                    checkInternetConnection();
                  },
                  child: Text('Refresh'),
                )
              ],
            )),
          )
        : DefaultTabController(
            length: 2,
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                backgroundColor: Colors.blue,
                centerTitle: true,
                actions: [
                  IconButton(
                    onPressed: () {
                      checkInternetConnection();
                      updateTransaction();
                      print(finalList.toString());
                      print(guestUserList.toString());
                    },
                    icon: Icon(Icons.edit),
                  )
                ],
                bottom: TabBar(
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.directions_car),
                      text: "Regular Users",
                    ),
                    Tab(
                      icon: Icon(Icons.directions_transit),
                      text: "Guest Users",
                    ),
                  ],
                ),
                title: Text('Past Transaction Details',
                    style: TextStyle(fontSize: 18.0)),
              ),
              body: TabBarView(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.88,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: finalList.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  color: Colors.blue,
                                  margin: EdgeInsets.all(10.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                      side: BorderSide(color: Colors.blue)),
                                  child: ExpansionTile(
                                      trailing: IconButton(
                                        onPressed: () {
                                          dialogBoxAddProducts(index);
                                        },
                                        icon: Icon(
                                          Icons.add_box,
                                          size: 35.0,
                                          color: Colors.white,
                                        ),
                                        color: Colors.blue,
                                      ),
                                      backgroundColor: Colors.blue,
                                      children: [
                                        Container(
                                          child: finalList[index]
                                                          ['items_bought']
                                                      .length ==
                                                  0
                                              ? ListTile(
                                                  title: Text(
                                                    "No items purchased !",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: finalList[index]
                                                          ['items_bought']
                                                      .length,
                                                  itemBuilder: (ctx, index2) {
                                                    return ListTile(
                                                        trailing: Switch(
                                                          activeColor:
                                                              Colors.green,
                                                          inactiveThumbColor:
                                                              Colors.red,
                                                          value: finalList[
                                                                          index]
                                                                      [
                                                                      'items_bought']
                                                                  [index2]
                                                              ['del_status'],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              if (value ==
                                                                  true) {
                                                                finalList[index]
                                                                            [
                                                                            'items_bought']
                                                                        [index2]
                                                                    [
                                                                    'del_status'] = true;
                                                                finalList[index]['items_bought']
                                                                            [
                                                                            index2]
                                                                        [
                                                                        'status'] =
                                                                    "Delivered";
                                                              } else {
                                                                finalList[index]
                                                                            [
                                                                            'items_bought']
                                                                        [index2]
                                                                    [
                                                                    'del_status'] = false;
                                                                finalList[index]['items_bought']
                                                                            [
                                                                            index2]
                                                                        [
                                                                        'status'] =
                                                                    "Not Delivered";
                                                              }
                                                            });
                                                          },
                                                        ),
                                                        leading: IconButton(
                                                            tooltip:
                                                                "Change Quantity",
                                                            icon: Icon(
                                                              Icons.cached,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              changeQuantityDialog(
                                                                  finalList[index]['items_bought']
                                                                              [
                                                                              index2]
                                                                          [
                                                                          'qty']
                                                                      .toString(),
                                                                  finalList[index]
                                                                              [
                                                                              'items_bought'][index2]
                                                                          [
                                                                          'unit']
                                                                      .toString(),
                                                                  index,
                                                                  index2);
                                                            }),
                                                        title: Text(
                                                          finalList[index]['items_bought']
                                                                              [index2]
                                                                          ['product_id']
                                                                      ['name']
                                                                  .toString() +
                                                              " ( " +
                                                              finalList[index]['items_bought']
                                                                          [index2]
                                                                      ['qty']
                                                                  .toString() +
                                                              " " +
                                                              finalList[index][
                                                                          'items_bought']
                                                                      [
                                                                      index2]['unit']
                                                                  .toString() +
                                                              " ) ",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ));
                                                  }),
                                        )
                                      ],
                                      title: Text(
                                        finalList[index]['user_id']['name']
                                            .toString(),
                                        style: TextStyle(color: Colors.white),
                                      )),
                                );
                              }),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin:
                                  EdgeInsets.only(bottom: 10.0, right: 10.0),
                              child: ClipOval(
                                child: Material(
                                  color: Colors.blue, // button color
                                  child: InkWell(
                                    splashColor: Colors.red, // inkwell color
                                    child: SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        )),
                                    onTap: () {
                                      dialogBoxAddUser();
                                      // dialogBoxAddGuestUserProducts();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  //Guest User Transaction Details
                  Container(
                    height: MediaQuery.of(context).size.height * 0.88,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Expanded(
                          child: guestUserList.length == 0
                              ? Center(
                                  child: Text(
                                    "No Guest User Transactions !",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: guestUserList.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      color: Colors.blue,
                                      margin: EdgeInsets.all(10.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          side: BorderSide(color: Colors.blue)),
                                      child: Column(
                                        children: [
                                          ExpansionTile(
                                              backgroundColor: Colors.blue,
                                              trailing: IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    dialogBoxConfirmation(
                                                        index);
                                                  }),
                                              children: [
                                                Container(
                                                    child: ListTile(
                                                  leading: Text(
                                                    guestUserList[index]
                                                                ['product_id']
                                                            ['name'] +
                                                        " ( " +
                                                        guestUserList[index]
                                                                ['qty']
                                                            .toString() +
                                                        " " +
                                                        guestUserList[index]
                                                            ['unit'] +
                                                        " ) ".toString(),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ))
                                              ],
                                              title: Text(
                                                widget.date.toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          ListTile(
                                            trailing: Text(
                                              guestUserList[index]['total']
                                                      .toString() +
                                                  " Rs",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            title: Text(
                                              "Total Amount",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin:
                                  EdgeInsets.only(bottom: 10.0, right: 10.0),
                              child: ClipOval(
                                child: Material(
                                  color: Colors.blue, // button color
                                  child: InkWell(
                                    splashColor: Colors.red, // inkwell color
                                    child: SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        )),
                                    onTap: () {
                                      dialogBoxAddGuestUserProducts();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
