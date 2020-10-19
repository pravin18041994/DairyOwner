import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/PurchaseSalesList.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

class PurchaseSalesDetails extends StatefulWidget {
  @override
  _PurchaseSalesDetailsState createState() => _PurchaseSalesDetailsState();
}

class _PurchaseSalesDetailsState extends State<PurchaseSalesDetails> {
  var dropdownValueType;
  List productList;
  List finalProductList;
  var dropdownValueProducts;
  var dropdownValueUnit;
  List<String> productName;
  var unit = ' ';
  var storage;
  var token;
  var url;
  var url2;
  TextEditingController quantityController = new TextEditingController();
  TextEditingController vendorNameContrller = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController contactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var connectivityResult;
  var isConnectionActive = true;
  final FocusNode nodeSubmitButton = FocusNode();
  final FocusNode nodeTypeButton = FocusNode();

  final FocusNode nodeVendorName = FocusNode();
  var isLoading = true;
  var vendorNameUrl;
  List<String> vendorNames;
  @override
  void initState() {
    // TODO: implement initState
    getProducts();
    productList = [];
    vendorNames = [];
    productName = [];
    finalProductList = [];

    url = Constants.base_url + 'products/get_all_products';
    url2 = Constants.base_url + 'transactions/update_purchase_sale_transaction';
    vendorNameUrl = Constants.base_url + 'transactions/get_vendor_names';

    super.initState();
    getVendorNames();
    checkInternetConnection();
  }

  Future<void> getVendorNames() async {
    try {
      storage = FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http
          .get(vendorNameUrl, headers: {"Authorization": 'Bearer ' + token});
      print(response.body);
      if (response.statusCode == 200) {
        var decRes = json.decode(response.body);
        if (decRes['state'] == 'success') {
          setState(() {
            for (var i in decRes['data']) {
              vendorNames.add(i);
            }
            print(vendorNames.toString());
          });
        } else {}
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  void _select(String value) async {
    if (value == "Show Details") {
      Navigator.push(context, MaterialPageRoute(builder: (_) {
        return PurchaseSalesList();
      }));
    }
  }

  var choice = ['Show Details'];

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

  Future<void> addTransaction() async {
    try {
      openDialog();
      List fp = [];
      for (var ii in finalProductList) {
        for (var jj in productList) {
          if (ii['product'] == jj['name']) {
            var obj = {
              'id': jj['_id'],
              'unit': ii['qty'],
              'rate': jj['rate'],
            };
            fp.add(obj);
          }
        }
      }
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http.post(url2, body: {
        'name': vendorNameContrller.text,
        'type': dropdownValueType,
        'products': json.encode(fp),
        'contact': contactController.text
      }, headers: {
        "Authorization": 'Bearer ' + token
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        var decodedResponse = json.decode(response.body);
        if (decodedResponse['state'] == 'success') {
          FocusScope.of(context).requestFocus(nodeSubmitButton);
          setState(() {
            vendorNameContrller.clear();
            dropdownValueType = null;
            finalProductList = [];
            contactController.clear();
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(
                'Submitted Successfully !',
                style: TextStyle(fontFamily: 'Muli'),
              ),
              duration: Duration(seconds: 3),
            ));
          });
        } else {
          FocusScope.of(context).requestFocus(nodeSubmitButton);
          vendorNameContrller.clear();
          dropdownValueType = null;
          finalProductList = [];
          contactController.clear();
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Please Add Stock First !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 3),
          ));
        }
      } else {
        Navigator.pop(context);
        vendorNameContrller.clear();
        dropdownValueType = null;
        contactController.clear();
        finalProductList = [];
        contactController.clear();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please Try Again Later !',
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

  Future<void> getProducts() async {
    try {
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response =
          await http.get(url, headers: {"Authorization": 'Bearer ' + token});

      setState(() {
        var decodedResponse = json.decode(response.body);
        if (decodedResponse['state'] == 'success') {
          productList = decodedResponse['data'].toList();
          for (var t in productList) {
            productName.add(t['name']);
          }
          vendorNameContrller.clear();
        } else {}
      });
    } catch (e) {
      checkInternetConnection();
    }
  }

  getRefreshedNames(String query) {
    List<String> matches = List();
    matches.addAll(vendorNames);

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
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

  void dialogBoxProduct() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.30,
                width: MediaQuery.of(context).size.width * 0.70,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ListTile(
                          title: DropdownButton<String>(
                            dropdownColor: Colors.blue,
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
                                print(newValue);
                                dropdownValueProducts = newValue;
                                for (var i in productList) {
                                  if (i['name'] == dropdownValueProducts) {
                                    unit = i['measurement_unit'];
                                  }
                                }
                              });
                            },
                            items: productName
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                      fontFamily: 'Muli',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: TextField(
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  controller: quantityController,
                                  decoration: InputDecoration(
                                    labelText: "Enter quantity",
                                    labelStyle: TextStyle(
                                        fontFamily: 'Muli',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              unit.toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
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
                                  side: BorderSide(color: Colors.black)),
                              onPressed: () {
                                setState(() {
                                  for (var i in finalProductList) {
                                    if (i['name'] == dropdownValueProducts) {
                                      Navigator.pop(context);
                                    }
                                  }
                                  var obj = {
                                    "product": dropdownValueProducts,
                                    "qty": quantityController.text,
                                    "unit": unit
                                  };
                                  print(obj);
                                  finalProductList.add(obj);
                                  Navigator.pop(context);
                                  dropdownValueProducts = null;
                                  quantityController.clear();
                                  unit = "";
                                });
                              },
                              color: Colors.white,
                              elevation: 5.0,
                              child: Text(
                                "Add",
                                style: TextStyle(
                                    fontFamily: 'Muli',
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(color: Colors.black)),
                              color: Colors.white,
                              elevation: 5.0,
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
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

  @protected
  void didChangeDependencies() {
    super.didChangeDependencies();
    // FocusScope.of(context).requestFocus(nodeSubmitButton);
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
              centerTitle: true,
              elevation: 0.0,
              title: Text(
                "Purchase / Sale Details",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              iconTheme: IconThemeData(color: Colors.white),
              actions: [
                PopupMenuButton<String>(
                  color: Colors.blue,
                  onSelected: _select,
                  itemBuilder: (BuildContext context) {
                    return choice.map((String choice) {
                      return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )));
                    }).toList();
                  },
                ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: Container(
                child: ListView(
                  padding: EdgeInsets.all(10.0),
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.20,
                      child: Icon(
                        Icons.developer_board,
                        color: Colors.blue,
                        size: 75.0,
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.60,
                      child: Card(
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(color: Colors.white, width: 2.0)),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.85,
                                        child: TypeAheadFormField(
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please Enter Vendor Name';
                                            }
                                            return null;
                                          },
                                          hideOnEmpty: true,
                                          textFieldConfiguration: TextFieldConfiguration(
                                              focusNode: nodeVendorName,
                                              controller: vendorNameContrller,
                                              cursorColor: Colors.white,
                                              decoration: InputDecoration(
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white)),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white)),
                                                  hintText: "Vendor name",
                                                  hintStyle: TextStyle(
                                                      color: Colors.white)),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          suggestionsCallback: (pattern) async {
                                            return getRefreshedNames(pattern);
                                          },
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              leading:
                                                  Icon(Icons.shopping_cart),
                                              title: Text(suggestion),
                                            );
                                          },
                                          onSuggestionSelected: (suggestion) {
                                            vendorNameContrller.text =
                                                suggestion
                                                    .toString()
                                                    .split("(")[0];
                                            print(suggestion
                                                .toString()
                                                .split("(")
                                                .toString());
                                            contactController.text = suggestion
                                                .toString()
                                                .split("(")[1]
                                                .replaceAll(')', '')
                                                .trim();
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: TextFormField(
                                          cursorColor: Colors.white,
                                          style: TextStyle(color: Colors.white),
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please Enter Contact Number';
                                            }
                                            return null;
                                          },
                                          keyboardType: TextInputType.phone,
                                          controller: contactController,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                10),
                                            WhitelistingTextInputFormatter
                                                .digitsOnly
                                          ],
                                          decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white)),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white)),
                                            labelText: "Contact Number",
                                            labelStyle: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: DropdownButton<String>(
                                          dropdownColor: Colors.blue,
                                          focusNode: nodeTypeButton,
                                          value: dropdownValueType,
                                          icon: Icon(
                                            Icons.arrow_downward,
                                            color: Colors.white,
                                          ),
                                          iconSize: 0.0,
                                          elevation: 16,
                                          hint: Text(
                                            "Type",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Muli'),
                                          ),
                                          style: TextStyle(color: Colors.white),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.white,
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              dropdownValueType = newValue;
                                            });
                                          },
                                          items: <String>["Sale", "Purchase"]
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                    fontFamily: 'Muli',
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.white,
                                        thickness: 1.0,
                                        height: 2.0,
                                      ),
                                      ListTile(
                                        trailing: IconButton(
                                          onPressed: dialogBoxProduct,
                                          icon: Icon(
                                            Icons.plus_one,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(
                                          "Products",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.white,
                                        thickness: 1.0,
                                        height: 2.0,
                                      ),
                                      Container(
                                        child: finalProductList == null
                                            ? Container()
                                            : Container(
                                              
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.17,
                                                child: ListView.builder(
                                                  itemCount:
                                                      finalProductList.length,
                                                  key: new ObjectKey(
                                                      finalProductList.length),
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (BuildContext ctx,
                                                          int index) {
                                                    return SingleChildScrollView(
                                                      child: Column(
                                                        children: <Widget>[
                                                          Card(
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(20.0),
                                                              side: BorderSide(
                                                                color: Colors.white
                                                              )
                                                            ),
                                                            color: Colors.blue,
                                                            child: ListTile(
                                                                trailing:
                                                                    IconButton(
                                                                  color: Colors
                                                                      .white,
                                                                  icon: Icon(Icons
                                                                      .close),
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      finalProductList
                                                                          .removeAt(
                                                                              index);
                                                                      print(
                                                                          finalProductList);
                                                                    });
                                                                  },
                                                                ),
                                                                title: Text(
                                                                  finalProductList[index]['product'] +
                                                                      " ( " +
                                                                      finalProductList[
                                                                              index]
                                                                          [
                                                                          'qty'] +" "+
                                                                      finalProductList[
                                                                              index]
                                                                          [
                                                                          'unit'] +
                                                                      " ) ",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )),
                                                          ),
                                                          Divider(
                                                            color: Colors.white,
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(10.0),
                              child: RaisedButton(
                                focusNode: nodeSubmitButton,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                      color: Colors.black,
                                    )),
                                color: Colors.white,
                                elevation: 5.0,
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  checkInternetConnection();
                                  if (_formKey.currentState.validate()) {
                                    addTransaction();
                                  } else {}
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
