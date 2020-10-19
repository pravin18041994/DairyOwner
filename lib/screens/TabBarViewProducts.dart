import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/database/DatabaseOperations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import '../utilities/Constants.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TabBarViewProducts extends StatefulWidget {
  @override
  _TabBarViewProducts createState() => _TabBarViewProducts();
}

class _TabBarViewProducts extends State<TabBarViewProducts> {
  var isSearching = false;
  List searchResult = [];
  List duplicateProducts = [];
  final ScrollController _scrollController = ScrollController();

  var isSearchingForDeletion = false;
  List searchResultForDeletion = [];
  List duplicateProductsForDeletion = [];

  List variantListUpdate;
  String dropdownValueUpdate;
  String dropdownValueMeasurement;
  var variantError;
  var variantsJsonObject;

  var addUrl;
  var productidupdate;
  var token;
  var updateUrl;
  var getProductsUrl;
  List productList;
  List variantsList;
  var deleteUrl;
  List<String> dropdownValueUpdateProduct;
  var productVariants;
  var errorProductName = false;
  var errorProductRate = false;
  var errorProductMeasurementUnit = false;
  var deleteProductListForConfirmation;
  var dropdownValueUpdateUnit;
  final _addFormKey = GlobalKey<FormState>();
  final _updateFormKey = GlobalKey<FormState>();
  final FocusNode nodeProductName = FocusNode();
  final FocusNode nodeProductRate = FocusNode();
  final FocusNode nodeAddButton = FocusNode();
  final FocusNode nodeUnitDropdown = FocusNode();

  final FocusNode nodeUpdateDropdownProducts = FocusNode();
  final FocusNode nodeUpdateProductsName = FocusNode();
  final FocusNode nodeUpdateRate = FocusNode();
  final FocusNode nodeUpdateUnit = FocusNode();
  TextEditingController searchController = TextEditingController();
  TextEditingController searchDeleteController = TextEditingController();
  final FocusNode nodeUpdateButton = FocusNode();
  var storage;
  TextEditingController productNameAddController = new TextEditingController();
  TextEditingController productRateAddController = new TextEditingController();
  TextEditingController productMeasurementUnitAddController =
      new TextEditingController();
  TextEditingController variantAddController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var beforeExpansionChanged = Icons.arrow_downward;
  var afterExpansionChanged = Icons.arrow_upward;
  var expIcon;
  List iconList;

  //  Update Controllers

  TextEditingController productNameUpdateController =
      new TextEditingController();
  TextEditingController productRateUpdateController =
      new TextEditingController();
  TextEditingController productMeasurementUnitUpdateController =
      new TextEditingController();

  //AddVariantController
  TextEditingController addVariantRateController = new TextEditingController();
  TextEditingController updateVariantRateController =
      new TextEditingController();
  var connectivityResult;
  var isConnectionActive = true;
  var isLoading = true;
  List<String> qtyVariantsAdd;
  var dropdownValueQtyVariant;
  var dropdownValueQtyVariantUpdate;
  var dialogUnit;
  var decodedResponse;
  DatabaseOperations databaseOperations;

  @override
  void initState() {
    // TODO: implement initState
    expIcon = beforeExpansionChanged;
    variantListUpdate = [];
    iconList = [];
    qtyVariantsAdd = [];
    for (double i = 0.25; i < 50; i = i + 0.25) {
      qtyVariantsAdd.add(i.toString());
    }
    variantError = false;
    dropdownValueUpdateProduct = [];
    addUrl = Constants.base_url + "products/add_product";
    updateUrl = Constants.base_url + "products/update_product";
    deleteUrl = Constants.base_url + "products/delete_product";
    getProductsUrl = Constants.base_url + "products/get_all_products";
    variantsList = [];
    productVariants = [];
    deleteProductListForConfirmation = [];
    variantsJsonObject = new List<dynamic>();
    super.initState();
    getProducts();
    checkInternetConnection();
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

  Future<void> getProducts() async {
    try {
      productList = [];
      deleteProductListForConfirmation = [];
      dropdownValueUpdateProduct = [];
      productVariants = [];
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      print(token);

      databaseOperations = DatabaseOperations();

      int len = await databaseOperations.checkProducts("products");
      if (len == 0) {
        http.Response response = await http.get(getProductsUrl, headers: {
          'Authorization': 'Bearer' + ' ' + token,
          "Accept": "application/json"
        });
        print(response.body);
        if (response.statusCode == 200) {
          var responseBody = response.body;
          decodedResponse = jsonDecode(responseBody);
          productList = decodedResponse['data'].toList();
          duplicateProducts = decodedResponse['data'].toList();
          print(productList);
          if (decodedResponse['state'] == 'success') {
            setState(() {
              isLoading = false;
              for (var i in productList) {
                iconList.add(Icons.arrow_downward);
                var obj1 = {'id': i['_id'], 'name': i['name']};
                deleteProductListForConfirmation.add(obj1);
                duplicateProductsForDeletion.add(obj1);
                var obj = {"name": i["variants"]};
                productVariants.add(obj);
                dropdownValueUpdateProduct.add(i['name']);
              }
              print(productVariants);
              print(productList.length);
              print("DUUU" + deleteProductListForConfirmation.length);
            });
          } else {
            isLoading = false;
          }
        } else {}
        databaseOperations.insertProducts(
            json.encode(decodedResponse['data']), "products");
      } else {
        print("inhere");
        List<Map> list = [];
        list = await databaseOperations.getProducts();
        print(list[0]);
        List ss = list.toList();
        var qq = json.decode(ss[0]['data']);
        productList = qq;
        duplicateProducts = qq;
        setState(() {
          isLoading = false;
          for (var i in productList) {
            iconList.add(Icons.arrow_downward);
            var obj1 = {'id': i['_id'], 'name': i['name']};
            deleteProductListForConfirmation.add(obj1);
            var obj = {"name": i["variants"]};
            productVariants.add(obj);
            dropdownValueUpdateProduct.add(i['name']);
            duplicateProductsForDeletion.add(obj1);
          }
          print(productVariants);
          print(productList.length);
        });
      }
    } catch (e) {
      checkInternetConnection();
    }
  }

  void filterSearchResults(String query) async {
    print("in search");

    if (query.isNotEmpty) {
      setState(() {
        searchResult.clear();
        isSearching = true;
      });
      print(duplicateProducts);
      duplicateProducts.forEach((item) {
        print(item['name']);
        if (item['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['cust_code']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase())) {
          setState(() {
            print("Itemsss" + item['name'].toString());
            searchResult.add(item);
            print(searchResult[0]['name'].toString());
          });
        }
      });
    } else {
      setState(() {
        isSearching = false;
      });
    }
  }

  void filterSearchResultsForDeletion(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        searchResultForDeletion.clear();
        isSearchingForDeletion = true;
      });

      duplicateProductsForDeletion.forEach((item) {
        if (item['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase())) {
          setState(() {
            searchResultForDeletion.add(item);
          });
        }
      });
    } else {
      setState(() {
        isSearchingForDeletion = false;
      });
    }
  }

  void deleteProducts(id, index) async {
    try {
      openDialog();
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http.post(deleteUrl, body: {
        'id': id,
      }, headers: {
        'Authorization': 'Bearer ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        if (decodedResponse['state'] == 'success') {
          setState(() {
            deleteProductListForConfirmation.removeAt(index);
            productList.removeAt(index);
            dropdownValueUpdateProduct.removeAt(index);
          });

          //  Future.delayed(Duration(seconds: 4));
          Navigator.pop(context);
          Navigator.pop(context);
          int len = await databaseOperations.updateProductData(
              json.encode(decodedResponse['data']), "products");
          Fluttertoast.showToast(
              msg: "Deleted successfully !",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          // final snackBar = SnackBar(
          //     content: Text(
          //   " Deleted Successfully !",
          //   style: TextStyle(fontFamily: 'Muli'),
          // ));
          // Scaffold.of(context).showSnackBar(snackBar);
        } else {
          Future.delayed(Duration(seconds: 4));
          Navigator.pop(context);
          Navigator.pop(context);
          Fluttertoast.showToast(
              msg: "Please try again later !",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);

          // final snackBar = SnackBar(
          //     content: Text(
          //   " Please try again later !",
          //   style: TextStyle(fontFamily: 'Muli'),
          // ));
          // Scaffold.of(context).showSnackBar(snackBar);
        }
      } else {}
    } catch (e) {
      Navigator.pop(context);
      checkInternetConnection();
    }
  }

  void dialogBoxConfirmation(var id, var index) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.black)),
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
                          side: BorderSide(color: Colors.white)),
                      color: Colors.white,
                      elevation: 5.0,
                      child: Text(
                        "Yes",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        print(id);
                        deleteProducts(id, index);
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

  void dialogBoxVariants() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(12.0)),
            content: StatefulBuilder(builder: (ctx, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DropdownButton<String>(
                          dropdownColor: Colors.blue,
                          focusNode: nodeUnitDropdown,
                          value: dropdownValueQtyVariant,
                          icon: Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                          ),
                          iconSize: 0.0,
                          elevation: 16,
                          hint: Text(
                            "Select Quantity",
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
                              dropdownValueQtyVariant = newValue;
                            });
                          },
                          items: qtyVariantsAdd
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
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
                        Text(
                          dropdownValueMeasurement == null
                              ? " "
                              : dropdownValueMeasurement.toString(),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextField(
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        controller: addVariantRateController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
                        ],
                        decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            hintText: "Enter Rate",
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.black)),
                            color: Colors.white,
                            elevation: 5.0,
                            child: Text(
                              "Add",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              if (addVariantRateController.text.isEmpty) {
                                variantError = true;
                                return;
                              } else {
                                setState(() {
                                  var isPresent = false;
                                  for (var i in variantsList) {
                                    if (i['qty'] == addVariantRateController) {
                                      isPresent = true;
                                    }
                                  }
                                  if (isPresent == true) {
                                     Fluttertoast.showToast(
              msg: "Already exists !",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
                                    
                                    // _scaffoldKey.currentState
                                    //     .showSnackBar(SnackBar(
                                    //   content: Text('Already Exists !'),
                                    //   duration: Duration(seconds: 3),
                                    // ));
                                    return;
                                  } else {
                                    var o = {
                                      'qty': dropdownValueQtyVariant.toString(),
                                      'rate': addVariantRateController.text
                                          .toString(),
                                      'unit':
                                          dropdownValueMeasurement.toString()
                                    };
                                    variantsList.add(o);
                                  }

                                  print(variantsList);
                                  Navigator.pop(context);
                                  addVariantRateController.clear();
                                  dropdownValueQtyVariant = null;
                                });
                              }
                            }),
                        RaisedButton(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.black)),
                          elevation: 5.0,
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }));
      },
    ).then((value) => setState(() {})).then((value) => setState(() {
          getProducts();
        }));
  }

  void dialogBoxVariantsUpdate() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(color: Colors.white)),
            content: StatefulBuilder(builder: (tx, setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DropdownButton<String>(
                          dropdownColor: Colors.blue,
                          focusNode: nodeUnitDropdown,
                          value: dropdownValueQtyVariantUpdate,
                          icon: Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                          ),
                          iconSize: 0.0,
                          elevation: 16,
                          hint: Text(
                            "Select Quantity",
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
                              dropdownValueQtyVariantUpdate = newValue;
                            });
                          },
                          items: qtyVariantsAdd
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
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
                        Text(
                          dropdownValueUpdateUnit == null
                              ? ""
                              : dropdownValueUpdateUnit.toString(),
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: TextField(
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        controller: updateVariantRateController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            hintText: "Enter Rate",
                            hintStyle: TextStyle(
                                fontFamily: 'Muli',
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.black)),
                            color: Colors.white,
                            elevation: 5.0,
                            child: Text(
                              "Add",
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              if (updateVariantRateController.text.isEmpty) {
                                variantError = true;
                                return;
                              } else {
                                setState(() {
                                  var isPresent = false;
                                  for (var i in variantListUpdate) {
                                    if (i['qty'] ==
                                        updateVariantRateController) {
                                      isPresent = true;
                                    }
                                  }
                                  if (isPresent == true) {
                                     Fluttertoast.showToast(
              msg: "Already exists !",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
                                    // _scaffoldKey.currentState
                                    //     .showSnackBar(SnackBar(
                                    //   content: Text('Already Exists !'),
                                    //   duration: Duration(seconds: 3),
                                    // ));
                                    return;
                                  } else {
                                    var o = {
                                      'qty': dropdownValueQtyVariantUpdate
                                          .toString(),
                                      'rate': updateVariantRateController.text
                                          .toString(),
                                      'unit': dropdownValueUpdateUnit.toString()
                                    };
                                    variantListUpdate.add(o);
                                  }

                                  Navigator.pop(context);
                                  updateVariantRateController.clear();
                                });
                              }
                            }),
                        RaisedButton(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.black)),
                          elevation: 5.0,
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                        ),
                      ],
                    )
                  ],
                ),
              );
            }));
      },
    ).then((value) => setState(() {})).then((value) => setState(() {
          getProducts();
        }));
  }

  void checkAddDetails() async {
    try {
      openDialog();
      setState(() {
        if (productNameAddController.text == "") {
          this.errorProductName = true;
          return;
        }
        if (productRateAddController.text == "") {
          this.errorProductRate = true;
          return;
        }
        if (productMeasurementUnitAddController.text == "") {
          this.errorProductMeasurementUnit = true;
          return;
        }
      });

      //print(variantsList.toString());
      var o = {
        'qty': '1',
        'rate': productRateAddController.text,
        'unit': dropdownValueMeasurement.toString()
      };
      variantsList.add(o);
      var x = json.encode(variantsList);
      print(x);
      print(token);

      http.Response response = await http.post(addUrl, body: {
        'name': productNameAddController.text,
        'rate': productRateAddController.text,
        'unit': dropdownValueMeasurement,
        'variants': x.toString(),
      }, headers: {
        'Authorization': 'Bearer' + ' ' + token,
      });
      print("token");
      print(token);
      print(response.body);
      if (response.statusCode == 200) {
        //this statement closes the dialog
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse['state'] == 'success') {
          FocusScope.of(context).requestFocus(nodeAddButton);
          Navigator.pop(context);
          setState(() {
            getProducts();

            variantsList = [];
          });
          int len = await databaseOperations.updateProductData(
              json.encode(decodedResponse['data']), "products");
               Fluttertoast.showToast(
              msg: "Added successfully !",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);

          // final snackBar = SnackBar(
          //     content: Text(
          //   " Added Successfully !",
          //   style: TextStyle(fontFamily: 'Muli'),
          // ));
          // Scaffold.of(context).showSnackBar(snackBar);
          dropdownValueMeasurement = null;
          productNameAddController.clear();
          productRateAddController.clear();
          productMeasurementUnitAddController.clear();
        } else if (decodedResponse['msg'] == "Already exists !") {
          FocusScope.of(context).requestFocus(nodeAddButton);
          Navigator.pop(context);
           Fluttertoast.showToast(
              msg: "Product already exists !",
              toastLength: Toast.LENGTH_SHORT,

              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          // final snackBar = SnackBar(
          //     content: Text(
          //   " Product already exist !",
          //   style: TextStyle(fontFamily: 'Muli'),
          // ));
          // Scaffold.of(context).showSnackBar(snackBar);
          productNameAddController.clear();
          productRateAddController.clear();
          productMeasurementUnitAddController.clear();
        } else {
          FocusScope.of(context).requestFocus(nodeAddButton);
          Navigator.pop(context);
           Fluttertoast.showToast(
              msg: "Please try again later !",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          // final snackBar = SnackBar(
          //     content: Text(
          //   " Please try again later !",
          //   style: TextStyle(fontFamily: 'Muli'),
          // ));
          // Scaffold.of(context).showSnackBar(snackBar);
          productNameAddController.clear();
          productRateAddController.clear();
          productMeasurementUnitAddController.clear();
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      checkInternetConnection();
    }
  }

  void checkUpdateDetails() async {
    try {
      openDialog();
      setState(() {
        if (productNameUpdateController.text == "") {
          this.errorProductName = true;
          return;
        }
        if (productRateAddController.text == "") {
          this.errorProductRate = true;
          return;
        }
        if (productMeasurementUnitUpdateController.text == "") {
          this.errorProductMeasurementUnit = true;
          return;
        }
      });
      print(token);

      var final_arr = json.encode(variantListUpdate);
      print(productNameUpdateController.text);
      print(productRateUpdateController.text);
      print(productMeasurementUnitUpdateController.text);
      http.Response response = await http.post(updateUrl, body: {
        'name': productNameUpdateController.text,
        'rate': productRateUpdateController.text,
        'unit': dropdownValueUpdateUnit,
        'variants': final_arr.toString(),
        'id': productidupdate
      }, headers: {
        "Authorization": 'Bearer ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse['state'] == 'success') {
          FocusScope.of(context).requestFocus(nodeUpdateButton);
          setState(() {
            variantListUpdate.clear();
            dropdownValueUpdate = null;
            dropdownValueUpdateProduct.clear();
            productNameUpdateController.clear();
            productRateUpdateController.clear();
            productMeasurementUnitUpdateController.clear();
          });
          // setState(() {
          //   dropdownValueUpdateProduct = [];
          //   // getProducts();
          // });
          int len = await databaseOperations.updateProductData(
              json.encode(decodedResponse['data']), "products");
               Fluttertoast.showToast(
              msg: "Updated successfully !",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);

          // final snackBar = SnackBar(
          //     content: Text(
          //   "Updated Successfully !",
          //   style: TextStyle(fontFamily: 'Muli'),
          // ));
          // Scaffold.of(context).showSnackBar(snackBar);
        } else {
          Navigator.pop(context);
          productNameUpdateController.clear();
          productRateUpdateController.clear();
          productMeasurementUnitUpdateController.clear();
           Fluttertoast.showToast(
              msg: "Please try again later !",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
          // final snackbar = SnackBar(
          //     content: Text(
          //   "Please try again later!",
          //   style: TextStyle(fontFamily: 'Muli'),
          // ));
          // Scaffold.of(context).showSnackBar(snackbar);
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
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

  Future<Null> getRefresh() async {
    try {
      getProducts();
      await Future.delayed(Duration(seconds: 2));
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
        : TabBarView(
            children: <Widget>[
              isLoading == true
                  ? Center(
                      child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ))
                  : productList.length == 0
                      ? Center(
                          child: Text("No Data Found !",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        )
                      : Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: MediaQuery.of(context).size.width,
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Container(
                                margin: EdgeInsets.all(10),
                                height:
                                    MediaQuery.of(context).size.height * 0.09,
                                width: MediaQuery.of(context).size.width,
                                child: TextField(
                                  onChanged: (val) {
                                    setState(() {
                                      filterSearchResults(val);
                                    });
                                  },
                                  cursorColor: Colors.black,
                                  
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 30.0,
                                      color: Colors.black,
                                    ),
                                    labelText: "Search ",
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: (){
                                        setState(() {
                                          isSearching = false;
                                          searchController.text = "";
                                        });
                                      },
                                    ),
                                    labelStyle: TextStyle(
                                        color: Colors.black, fontSize: 20.0),
                                    focusedBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: Colors.black)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: Colors.black)),
                                  ),
                                ),
                              ),
                              isSearching == true
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: searchResult.length,
                                      itemBuilder:
                                          (BuildContext ctx, int index) {
                                        return AnimationConfiguration
                                            .staggeredList(
                                          position: index,
                                          duration:
                                              const Duration(milliseconds: 600),
                                          child: SlideAnimation(
                                            verticalOffset: 40.0,
                                            child: FadeInAnimation(
                                              child: Card(
                                                color: Colors.blue,
                                                margin: EdgeInsets.all(10),
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: Colors.white),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    ExpansionTile(
                                                      onExpansionChanged: (x) {
                                                        setState(() {
                                                          if (x == true) {
                                                            iconList[index] =
                                                                Icons
                                                                    .arrow_upward;
                                                          } else {
                                                            iconList[index] = Icons
                                                                .arrow_downward;
                                                          }
                                                        });
                                                      },
                                                      backgroundColor:
                                                          Colors.blue,
                                                      trailing: Icon(
                                                        iconList[index],
                                                        color: Colors.white,
                                                      ),
                                                      title: Text(
                                                        searchResult[index]
                                                            ['name'],
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      children: <Widget>[
                                                        Divider(
                                                          color: Colors.white,
                                                        ),
                                                        ListTile(
                                                          leading: IconButton(
                                                            onPressed: () {},
                                                            icon: FaIcon(
                                                              FontAwesomeIcons
                                                                  .rupeeSign,
                                                              size: 20.0,
                                                            ),
                                                            color: Colors.white,
                                                          ),
                                                          title: Text(
                                                            searchResult[index]
                                                                ['rate'],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: Colors.white,
                                                        ),
                                                        ListTile(
                                                          leading: IconButton(
                                                            onPressed: () {},
                                                            icon: FaIcon(
                                                                FontAwesomeIcons
                                                                    .calculator),
                                                            color: Colors.white,
                                                          ),
                                                          title: Text(
                                                            searchResult[index][
                                                                'measurement_unit'],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: Colors.white,
                                                        ),
                                                        ExpansionTile(
                                                            onExpansionChanged:
                                                                (value) {
                                                              setState(() {
                                                                if (value ==
                                                                    true) {
                                                                  expIcon =
                                                                      afterExpansionChanged;
                                                                } else {
                                                                  expIcon =
                                                                      beforeExpansionChanged;
                                                                }
                                                              });
                                                            },
                                                            backgroundColor:
                                                                Colors.blue,
                                                            leading: IconButton(
                                                              onPressed: () {},
                                                              icon: FaIcon(
                                                                  FontAwesomeIcons
                                                                      .listAlt),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            trailing:
                                                                IconButton(
                                                              onPressed: () {},
                                                              icon: Icon(
                                                                  expIcon,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            title: Text(
                                                              "Variants",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            children: <Widget>[
                                                              Container(
                                                                  child: searchResult[index]['variants']
                                                                              .length ==
                                                                          0
                                                                      ? ListTile(
                                                                          title: Text(
                                                                              "No Variants For This Product",
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                                        )
                                                                      : new ListView
                                                                              .builder(
                                                                          shrinkWrap:
                                                                              true,
                                                                          itemCount: searchResult[index]['variants']
                                                                              .length,
                                                                          itemBuilder:
                                                                              (BuildContext ctx, int index2) {
                                                                            return ListTile(
                                                                              leading: Icon(
                                                                                Icons.mobile_screen_share,
                                                                                color: Colors.white,
                                                                              ),
                                                                              title: Text(
                                                                                searchResult[index]['variants'][index2]['qty'].toString() + " " + searchResult[index]['measurement_unit'] + " ( " + searchResult[index]['variants'][index2]['rate'].toString() + " Rs" + " ) ",
                                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                              ),
                                                                            );
                                                                          }))
                                                            ]),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                                  : RefreshIndicator(
                                      onRefresh: getRefresh,
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.65,
                                        child: AnimationLimiter(
                                          child: new ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: productList.length,
                                              itemBuilder: (BuildContext ctx,
                                                  int index) {
                                                return AnimationConfiguration
                                                    .staggeredList(
                                                  position: index,
                                                  duration: const Duration(
                                                      milliseconds: 600),
                                                  child: SlideAnimation(
                                                    verticalOffset: 40.0,
                                                    child: FadeInAnimation(
                                                      child: Card(
                                                        color: Colors.blue,
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                10.0,
                                                                10.0,
                                                                10.0,
                                                                10.0),
                                                        shape: RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .white),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0)),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            ExpansionTile(
                                                              onExpansionChanged:
                                                                  (x) {
                                                                setState(() {
                                                                  if (x ==
                                                                      true) {
                                                                    iconList[
                                                                            index] =
                                                                        Icons
                                                                            .arrow_upward;
                                                                  } else {
                                                                    iconList[
                                                                            index] =
                                                                        Icons
                                                                            .arrow_downward;
                                                                  }
                                                                });
                                                              },
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              trailing: Icon(
                                                                iconList[index],
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              title: Text(
                                                                productList[
                                                                        index]
                                                                    ['name'],
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              children: <
                                                                  Widget>[
                                                                Divider(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                ListTile(
                                                                  leading:
                                                                      IconButton(
                                                                    onPressed:
                                                                        () {},
                                                                    icon:
                                                                        FaIcon(
                                                                      FontAwesomeIcons
                                                                          .rupeeSign,
                                                                      size:
                                                                          20.0,
                                                                    ),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  title: Text(
                                                                    productList[
                                                                            index]
                                                                        [
                                                                        'rate'],
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                Divider(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                ListTile(
                                                                  leading:
                                                                      IconButton(
                                                                    onPressed:
                                                                        () {},
                                                                    icon: FaIcon(
                                                                        FontAwesomeIcons
                                                                            .calculator),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  title: Text(
                                                                    productList[
                                                                            index]
                                                                        [
                                                                        'measurement_unit'],
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                Divider(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                ExpansionTile(
                                                                    onExpansionChanged:
                                                                        (value) {
                                                                      setState(
                                                                          () {
                                                                        if (value ==
                                                                            true) {
                                                                          expIcon =
                                                                              afterExpansionChanged;
                                                                        } else {
                                                                          expIcon =
                                                                              beforeExpansionChanged;
                                                                        }
                                                                      });
                                                                    },
                                                                    backgroundColor:
                                                                        Colors
                                                                            .blue,
                                                                    leading:
                                                                        IconButton(
                                                                      onPressed:
                                                                          () {},
                                                                      icon: FaIcon(
                                                                          FontAwesomeIcons
                                                                              .listAlt),
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    trailing:
                                                                        IconButton(
                                                                      onPressed:
                                                                          () {},
                                                                      icon: Icon(
                                                                          expIcon,
                                                                          color:
                                                                              Colors.white),
                                                                    ),
                                                                    title: Text(
                                                                      "Variants",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                          child: productList[index]['variants'].length == 0
                                                                              ? ListTile(
                                                                                  title: Text("No Variants For This Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                                                )
                                                                              : new ListView.builder(
                                                                                  shrinkWrap: true,
                                                                                  itemCount: productList[index]['variants'].length,
                                                                                  itemBuilder: (BuildContext ctx, int index2) {
                                                                                    return ListTile(
                                                                                      leading: Icon(
                                                                                        Icons.mobile_screen_share,
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                      title: Text(
                                                                                        productList[index]['variants'][index2]['qty'].toString() + " " + productList[index]['measurement_unit'] + " ( " + productList[index]['variants'][index2]['rate'].toString() + " Rs" + " ) ",
                                                                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                    );
                                                                                  }))
                                                                    ]),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),

              //Add
              Form(
                key: _addFormKey,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: Card(
                              color: Colors.blue,
                              margin:
                                  EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
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
                                            ListTile(
                                              title: TextFormField(
                                                cursorColor: Colors.white,
                                                style: TextStyle(
                                                    color: Colors.white),
                                                focusNode: nodeProductName,
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return 'Please Enter Product Name';
                                                  }
                                                  return null;
                                                },
                                                controller:
                                                    productNameAddController,
                                                decoration: InputDecoration(
                                                    labelText: "Product Name",
                                                    labelStyle: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white)),
                                                    enabledBorder:
                                                        UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Colors
                                                                    .white))),
                                              ),
                                            ),
                                            ListTile(
                                              title: TextFormField(
                                                cursorColor: Colors.white,
                                                style: TextStyle(
                                                    color: Colors.white),
                                                focusNode: nodeProductRate,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(RegExp("[0-9.]")),
                                                ],
                                                keyboardType:
                                                    TextInputType.phone,
                                                onChanged: (val) {},
                                                validator: (value) {
                                                  if (value.isEmpty) {
                                                    return 'Please Enter Product Rate';
                                                  }
                                                  return null;
                                                },
                                                controller:
                                                    productRateAddController,
                                                decoration: InputDecoration(
                                                  labelText: "Rate",
                                                  labelStyle: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
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
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              title: DropdownButton<String>(
                                                dropdownColor: Colors.blue,
                                                focusNode: nodeUnitDropdown,
                                                value: dropdownValueMeasurement,
                                                icon: Icon(
                                                  Icons.arrow_downward,
                                                  color: Colors.white,
                                                ),
                                                iconSize: 0.0,
                                                elevation: 16,
                                                hint: Text(
                                                  "Select Measurement Unit",
                                                  style: TextStyle(
                                                      fontFamily: 'Muli',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                style: TextStyle(
                                                    color: Colors.white),
                                                underline: Container(
                                                  height: 2,
                                                  color: Colors.white,
                                                ),
                                                onChanged: (String newValue) {
                                                  setState(() {
                                                    dropdownValueMeasurement =
                                                        newValue;
                                                  });
                                                },
                                                items: <String>[
                                                  ' Litre',
                                                  'Ml',
                                                  'Kg',
                                                  'Mg'
                                                ].map<DropdownMenuItem<String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          fontFamily: 'Muli',
                                                          color: Colors.white,
                                                          fontSize: 15.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            Divider(
                                              height: 20.0,
                                              color: Colors.white,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Text(
                                                  "Add Variants",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Container(
                                                  child: IconButton(
                                                    color: Colors.white,
                                                    icon: Icon(Icons.plus_one),
                                                    onPressed:
                                                        dialogBoxVariants,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              height: 20.0,
                                              color: Colors.white,
                                            ),
                                            Container(
                                              child: variantsList == null
                                                  ? Container()
                                                  : Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.2,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        border: Border.all(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      child: ListView.builder(
                                                        itemCount:
                                                            variantsList.length,
                                                        key: new ObjectKey(
                                                            variantsList
                                                                .length),
                                                        shrinkWrap: true,
                                                        itemBuilder:
                                                            (BuildContext ctx,
                                                                int index) {
                                                          return SingleChildScrollView(
                                                            child: Column(
                                                              children: <
                                                                  Widget>[
                                                                ListTile(
                                                                    trailing:
                                                                        IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .close,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          variantsList
                                                                              .removeAt(index);
                                                                          print(
                                                                              variantsList);
                                                                        });
                                                                      },
                                                                    ),
                                                                    title: Text(
                                                                      variantsList[index]
                                                                              [
                                                                              'qty'] +
                                                                          " " +
                                                                          variantsList[index]
                                                                              [
                                                                              'unit'] +
                                                                          " ( " +
                                                                          variantsList[index]
                                                                              [
                                                                              'rate'] +
                                                                          " Rs"
                                                                              " ) ",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.white),
                                                                    )),
                                                                Divider(
                                                                  color: Colors
                                                                      .green,
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        child: RaisedButton(
                                          focusNode: nodeAddButton,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18.0),
                                              side: BorderSide(
                                                  color: Colors.white)),
                                          color: Colors.white,
                                          child: Text(
                                            "Add",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            checkInternetConnection();
                                            if (_addFormKey.currentState
                                                .validate()) {
                                              checkAddDetails();
                                            } else {}
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              //Update
              Form(
                key: _updateFormKey,
                child: Container(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: Card(
                          color: Colors.blue,
                          margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
                                        ListTile(
                                          title: DropdownButton<String>(
                                            dropdownColor: Colors.blue,
                                            value: dropdownValueUpdate,
                                            focusNode:
                                                nodeUpdateDropdownProducts,
                                            icon: Icon(
                                              Icons.arrow_downward,
                                              color: Colors.white,
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
                                            style:
                                                TextStyle(color: Colors.white),
                                            underline: Container(
                                              height: 2,
                                              color: Colors.white,
                                            ),
                                            onChanged: (String newValue) {
                                              setState(() {
                                                dropdownValueUpdate = newValue;
                                                for (var c in productList) {
                                                  if (c['name'] == newValue) {
                                                    productidupdate = c['_id'];
                                                    productNameUpdateController
                                                        .text = c['name'];
                                                    productRateUpdateController
                                                        .text = c['rate'];
                                                    dropdownValueUpdateUnit =
                                                        c['measurement_unit'];
                                                    variantListUpdate =
                                                        c['variants'];
                                                  }
                                                }
                                              });
                                            },
                                            items: dropdownValueUpdateProduct
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                      fontFamily: 'Muli',
                                                      decoration:
                                                          TextDecoration.none,
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        ListTile(
                                          title: TextFormField(
                                            cursorColor: Colors.white,
                                            style:
                                                TextStyle(color: Colors.white),
                                            focusNode: nodeUpdateProductsName,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please Enter Product Name';
                                              }
                                              return null;
                                            },
                                            controller:
                                                productNameUpdateController,
                                            decoration: InputDecoration(
                                              labelText: "Product Name",
                                              labelStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white)),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: TextFormField(
                                            cursorColor: Colors.white,
                                            style:
                                                TextStyle(color: Colors.white),
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Please Enter Product Rate';
                                              }
                                              return null;
                                            },
                                            controller:
                                                productRateUpdateController,
                                            focusNode: nodeUpdateRate,
                                            decoration: InputDecoration(
                                              labelText: "Rate",
                                              labelStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white)),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          title: DropdownButton<String>(
                                            dropdownColor: Colors.blue,
                                            value: dropdownValueUpdateUnit,
                                            focusNode: nodeUpdateUnit,
                                            icon: Icon(
                                              Icons.arrow_downward,
                                              color: Colors.white,
                                            ),
                                            iconSize: 0.0,
                                            elevation: 16,
                                            hint: Text(
                                              "Select Measurement Unit",
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontFamily: 'Muli',
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            style:
                                                TextStyle(color: Colors.white),
                                            underline: Container(
                                              height: 2,
                                              color: Colors.white,
                                            ),
                                            onChanged: (String newValue) {
                                              setState(() {
                                                dropdownValueUpdateUnit =
                                                    newValue;
                                              });
                                            },
                                            items: <String>[
                                              ' Litre',
                                              'Ml',
                                              'Kg',
                                            ].map<DropdownMenuItem<String>>(
                                                (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                      decoration:
                                                          TextDecoration.none,
                                                      fontFamily: 'Muli',
                                                      color: Colors.white,
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        ListTile(
                                            trailing: IconButton(
                                              icon: Icon(
                                                Icons.plus_one,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                dialogBoxVariantsUpdate();
                                              },
                                            ),
                                            leading: Text(
                                              "Variants List",
                                              style: TextStyle(
                                                  fontFamily: "Muli",
                                                  color: Colors.white,
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Divider(
                                          height: 10.0,
                                          color: Colors.white,
                                        ),
                                        Container(
                                            child: variantListUpdate == null
                                                ? Container()
                                                : Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.17,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.9,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        border: Border.all(
                                                            color:
                                                                Colors.white)),
                                                    child: new ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            variantListUpdate
                                                                .length,
                                                        itemBuilder:
                                                            (BuildContext ctx,
                                                                int index) {
                                                          return Card(
                                                            color: Colors.blue,
                                                            margin:
                                                                EdgeInsets.all(
                                                                    10.0),
                                                            shape: RoundedRectangleBorder(
                                                                side: BorderSide(
                                                                    color: Colors
                                                                        .white),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                ListTile(
                                                                  trailing:
                                                                      IconButton(
                                                                    color: Colors
                                                                        .white,
                                                                    icon: Icon(Icons
                                                                        .close),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        variantListUpdate
                                                                            .removeAt(index);
                                                                      });
                                                                    },
                                                                  ),
                                                                  title: Text(
                                                                    variantListUpdate[index] !=
                                                                            null
                                                                        ? variantListUpdate[index]['qty'].toString() +
                                                                            " " +
                                                                            variantListUpdate[index]['unit'].toString() +
                                                                            " ( " +
                                                                            variantListUpdate[index]['rate'].toString() +
                                                                            " Rs"
                                                                                " ) "
                                                                        : '',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }),
                                                  )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    child: RaisedButton(
                                      focusNode: nodeUpdateButton,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side:
                                              BorderSide(color: Colors.white)),
                                      color: Colors.white,
                                      child: Text(
                                        "Update",
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        checkInternetConnection();
                                        if (_updateFormKey.currentState
                                            .validate()) {
                                          checkUpdateDetails();
                                        } else {}
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              //delete
              Container(
                  child: deleteProductListForConfirmation == null
                      ? CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: [
                            Container(
                              margin: EdgeInsets.all(10),
                              height: MediaQuery.of(context).size.height * 0.09,
                              width: MediaQuery.of(context).size.width,
                              child: TextField(
                                onChanged: (val) {
                                  setState(() {
                                    filterSearchResultsForDeletion(val);
                                  });
                                },
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 30.0,
                                    color: Colors.black,
                                  ),
                                  labelText: "Search ",
                                  suffixIcon: IconButton(
                                      icon: Icon(Icons.close),
                                      onPressed: (){
                                        setState(() {
                                          isSearching = false;
                                          searchDeleteController.text = "";
                                        });
                                      },
                                    ),
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 20.0),
                                  focusedBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                  enabledBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.black)),
                                ),
                              ),
                            ),
                            isSearchingForDeletion == true
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: searchResultForDeletion.length,
                                    itemBuilder: (BuildContext ctx, int index) {
                                      return AnimationConfiguration
                                          .staggeredList(
                                              position: index,
                                              duration: const Duration(
                                                  milliseconds: 600),
                                              child: SlideAnimation(
                                                  verticalOffset: 40.0,
                                                  child: FadeInAnimation(
                                                      child: Card(
                                                    color: Colors.blue,
                                                    margin: EdgeInsets.fromLTRB(
                                                        10.0, 10.0, 10.0, 10.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color:
                                                                    Colors
                                                                        .white),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0)),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        ListTile(
                                                          trailing: IconButton(
                                                            icon: Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              setState(() {
                                                                dialogBoxConfirmation(
                                                                    searchResultForDeletion[
                                                                            index]
                                                                        ['id'],
                                                                    index);
                                                              });
                                                            },
                                                          ),
                                                          title: Text(
                                                            searchResultForDeletion[
                                                                            index]
                                                                        [
                                                                        'name'] !=
                                                                    null
                                                                ? searchResultForDeletion[
                                                                        index]
                                                                    ['name']
                                                                : '',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ))));
                                    })
                                : Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.65,
                                    child: AnimationLimiter(
                                      child: new ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              deleteProductListForConfirmation
                                                  .length,
                                          itemBuilder:
                                              (BuildContext ctx, int index) {
                                            return AnimationConfiguration
                                                .staggeredList(
                                                    position: index,
                                                    duration: const Duration(
                                                        milliseconds: 600),
                                                    child: SlideAnimation(
                                                        verticalOffset: 40.0,
                                                        child: FadeInAnimation(
                                                            child: Card(
                                                          color: Colors.blue,
                                                          margin:
                                                              EdgeInsets.all(
                                                                  10),
                                                          shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .white),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0)),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              ListTile(
                                                                trailing:
                                                                    IconButton(
                                                                  icon: Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      dialogBoxConfirmation(
                                                                          deleteProductListForConfirmation[index]
                                                                              [
                                                                              'id'],
                                                                          index);
                                                                    });
                                                                  },
                                                                ),
                                                                title: Text(
                                                                  deleteProductListForConfirmation[index]
                                                                              [
                                                                              'name'] !=
                                                                          null
                                                                      ? deleteProductListForConfirmation[
                                                                              index]
                                                                          [
                                                                          'name']
                                                                      : '',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ))));
                                          }),
                                    ),
                                  ),
                          ],
                        )),
            ],
          );
  }
}
