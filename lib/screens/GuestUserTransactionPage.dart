import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GuestUserTransactionPage extends StatefulWidget {
  @override
  _GuestUserTransactionPageState createState() =>
      _GuestUserTransactionPageState();
}

class _GuestUserTransactionPageState extends State<GuestUserTransactionPage> {
  var token;
  var dropdownValueProducts;
  var storage;
  var dropdownValueUnit;
  var getProductsUrl;
  var guestUserUrl;
  List productList;
  List<String> productNames;
  List productsItems;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController addQuantityController = new TextEditingController();
  TextEditingController addUnitController = new TextEditingController();
  final FocusNode nodeDropdownProduct = FocusNode();
  final FocusNode nodeDropdownUnit = FocusNode();
  final FocusNode nodeQuantity = FocusNode();
  final FocusNode nodeAddTransactionButton = FocusNode();
  var connectivityResult;
  var isConnectionActive = true;
  var unit;

  Future<void> getProducts() async {
    try {
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'milkman_token');
      print(token);
      http.Response response = await http.get(getProductsUrl, headers: {
        'Authorization': 'Bearer ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        setState(() {
          productList = decodedResponse['data'].toList();
          for (var p in productList) {
            productNames.add(p['name']);
          }
        });
        if (decodedResponse['state'] == 'success') {
        } else {}
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productList = [];
    productNames = [];
    productsItems = [];
    unit = "";
    guestUserUrl =
        Constants.base_url + 'transactions/add_guest_user_transaction';
    getProductsUrl = Constants.base_url + 'products/get_all_products_milkman';
    getProducts();
    checkInternetConnection();
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

  addToList(product, qty, unit) {
    setState(() {
      dropdownValueUnit = null;
      dropdownValueProducts = null;
      addQuantityController.clear();
      var obj = {'product': product, 'qty': qty, 'unit': unit};
      productsItems.add(obj);
    });
  }

  Future<void> guestUserTransaction() async {
    try {
      List finalProducts = [];
      for (var i in productList) {
        for (var j in productsItems) {
          if (j['product'] == i['name']) {
            var total = int.parse(j['qty']) * int.parse(i['rate']);
            var obj = {
              'product_id': i['_id'],
              'qty': j['qty'],
              'unit': j['unit'],
              'total': total
            };
            finalProducts.add(obj);
          }
        }
      }
      var encList = json.encode(finalProducts);
      openDialog();
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'milkman_token');
      http.Response response = await http.post(guestUserUrl,
          body: {'guest_user_details': encList.toString()},
          headers: {'Authorization': 'Bearer ' + token});
      print(response.body);
      var decodedResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        FocusScope.of(context).requestFocus(nodeAddTransactionButton);
        Navigator.pop(context);
        if (decodedResponse['state'] == 'success') {
          setState(() {
            productsItems.clear();
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Transaction Added Successfully!',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 3),
          ));
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Cannot Add Transaction!',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 3),
          ));
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please Try Again Later !',
            style: TextStyle(fontFamily: 'Muli'),
          ),
          duration: Duration(seconds: 3),
        ));
      }
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
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Colors.blue,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "Guest User Transaction ",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Card(
                    color: Colors.blue,
                    margin: EdgeInsets.all(10.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: Colors.black)),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.35,
                            child: ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    ListTile(
                                      title: DropdownButton<String>(
                                        dropdownColor: Colors.blue,
                                        focusNode: nodeDropdownProduct,
                                        value: dropdownValueProducts,
                                        icon: Icon(
                                          Icons.arrow_downward,
                                          color: Colors.white,
                                        ),
                                        iconSize: 0.0,
                                        elevation: 16,
                                        hint: Text(
                                          "Select Product",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Muli',
                                              fontSize: 15.0),
                                        ),
                                        style: TextStyle(color: Colors.white),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.white,
                                        ),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            dropdownValueProducts = newValue;

                                            for (var i in productList) {
                                              if (i['name'] == newValue) {
                                                unit = i['measurement_unit'];
                                              }
                                            }
                                          });
                                        },
                                        items: productNames
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Muli',
                                                  fontSize: 15.0),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: TextField(
                                            cursorColor: Colors.white,
                                            style:
                                                TextStyle(color: Colors.white),
                                            focusNode: nodeQuantity,
                                            controller: addQuantityController,
                                            decoration: InputDecoration(
                                                labelText: "Add Quantity",
                                                labelStyle: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .white)),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color:
                                                                Colors.white))),
                                          ),
                                        ),
                                        Text(
                                          unit.toString(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Muli',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        RaisedButton(
                                            focusNode: nodeAddTransactionButton,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18.0),
                                                side: BorderSide(
                                                    color: Colors.black)),
                                            color: Colors.white,
                                            elevation: 5.0,
                                            child: Text(
                                              "+",
                                              style: TextStyle(
                                                fontSize: 25.0,
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () {
                                              addToList(
                                                  dropdownValueProducts,
                                                  addQuantityController.text,
                                                  unit.toString());
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      nodeAddTransactionButton);
                                            }),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                    thickness: 2.0,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.42,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: productsItems.length == 0
                                  ? 0
                                  : productsItems.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Card(
                                  color: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      side: BorderSide(color: Colors.black)),
                                  child: ListTile(
                                    trailing: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.delete_forever,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      productsItems[index]
                                                  ['product']
                                              .toString() +
                                          " ( " +
                                          productsItems[index]['qty']
                                              .toString() +
                                          " " +
                                          productsItems[index]['unit']
                                              .toString() +
                                          " ) ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: RaisedButton(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(
                                    color: Colors.black, width: 2.0)),
                            onPressed: () {
                              checkInternetConnection();
                              guestUserTransaction();
                            },
                            child: Text(
                              "Add Transaction",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}
