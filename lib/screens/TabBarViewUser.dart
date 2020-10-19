import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/database/DatabaseOperations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../utilities/Constants.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TabBarViewUser extends StatefulWidget {
  @override
  _TabBarViewUser createState() => _TabBarViewUser();
}

class _TabBarViewUser extends State<TabBarViewUser> {
  var isSearching = false;
  List searchResult = [];
  List duplicateUsers = [];

  var isSearchingForDeletion = false;
  List searchResultForDeletion = [];
  List duplicateUsersForDeletion = [];

  List<String> productNames;
  List productList;
  List productListUpdate;
  List tempProductList;
  TextEditingController searchController = TextEditingController();
  TextEditingController searchDeleteController = TextEditingController();
  var productVariants;
  var dropdownValueAreasUpdate;
  var dropdownValueProductsUpdate;
  final _addFormKey = GlobalKey<FormState>();
  final _updateFormKey = GlobalKey<FormState>();
  final _alertDialogFormKey = GlobalKey<FormState>();
  final _alertDialogUpdateFormKey = GlobalKey<FormState>();

  var dropdownValueUser;
  String dropdownValue;
  var dropdownValueProducts;
  List<String> areaNames;
  List<String> userNames;
  var dropdownValueUnit;
  var getAreaUrl;
  var areaList;
  List iconsList;
  var dropdownValueAreas;
  var userid_update;
  var getUserUrl;
  var addUrl;
  var updateUrl;
  var isLoading = true;
  var token;
  var errorFirstName = false;
  var errorLastName = false;
  var errorMobileNumber = false;
  var errorEmail = false;
  var storage;
  var errorAddress = false;
  List userList;
  List<String> userUpdate;
  var getProductsUrl;
  List productList1, productList2;
  var beforeExpansionChanged = Icons.arrow_downward;
  var afterExpansionChanged = Icons.arrow_upward;
  var expIcon;

  TextEditingController fullNameAddController = new TextEditingController();
  TextEditingController mobileNumberAddController = new TextEditingController();
  TextEditingController addressAddController = new TextEditingController();
  TextEditingController userCodeAddController = TextEditingController();
  TextEditingController emailAddController = new TextEditingController();

  TextEditingController fullNameUpdateController = new TextEditingController();
  TextEditingController mobileNumberUpdateController =
      new TextEditingController();
  TextEditingController addressUpdateController = new TextEditingController();
  TextEditingController emailUpdateController = new TextEditingController();
  TextEditingController addUnitController = new TextEditingController();
  TextEditingController userCodeUpdateController = TextEditingController();
  TextEditingController updateUnitController = new TextEditingController();

  var getDeleteUrl;
  var deleteUserId;
  var userListForDeletion;
  var dropdownUserUpdate;
  var userNamesUpdate;
  var dropdownValueUnitUpdate;
  var arrowDownwardButton = Icon(Icons.arrow_downward);

  final FocusNode addButton = FocusNode();
  final FocusNode nodeFn = FocusNode();
  final FocusNode nodeAddress = FocusNode();
  final FocusNode nodeMn = FocusNode();
  final FocusNode nodeEmail = FocusNode();
  final FocusNode nodeDropdownArea = FocusNode();
  final FocusNode nodeUserCodeAdd = FocusNode();
  final FocusNode nodeDropdownProducts = FocusNode();

  final FocusNode nodeUpdateButton = FocusNode();
  final FocusNode nodeUFn = FocusNode();
  final FocusNode nodeUAddress = FocusNode();
  final FocusNode nodeUMn = FocusNode();
  final FocusNode nodeUEmail = FocusNode();
  final FocusNode nodeUserCodeUpdate = FocusNode();
  final FocusNode nodeDropdownUpdateProducts = FocusNode();
  final FocusNode nodeDropdownUpdateUser = FocusNode();
  var connectivityResult;
  var isConnectionActive = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var decodedResponse;
  DatabaseOperations databaseOperations;

  @override
  void initState() {
    productNames = [];

    tempProductList = [];
    productList2 = [];
    userListForDeletion = [];
    productList = [];
    productList1 = [];
    areaNames = [];
    userList = [];
    userNames = [];
    userNamesUpdate = [];
    productListUpdate = [];
    expIcon = beforeExpansionChanged;

    // TODO: implement initState
    checkInternetConnection();

    addUrl = Constants.base_url + "users/add_user";
    updateUrl = Constants.base_url + "users/update_user_admin";
    getUserUrl = Constants.base_url + "users/get_all_users";
    getAreaUrl = Constants.base_url + "areas/get_areas_user";
    getProductsUrl = Constants.base_url + "products/get_all_products";
    getDeleteUrl = Constants.base_url + "users/delete_user";
    super.initState();
    final storage = new FlutterSecureStorage();
    iconsList = [];
    getUser();
    getAreas();
    getProducts();
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
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      print(token);
      http.Response response = await http.get(getProductsUrl, headers: {
        'Authorization': 'Bearer' + ' ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        setState(() {
          productList1 = decodedResponse['data'].toList();
          print("ds" + productList1.toString());
          for (var i in productList1) {
            productNames.add(i['name']);
          }
        });
        if (decodedResponse['state'] == 'success') {
        } else {}
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<void> getAreas() async {
    try {
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      print("token");
      print(token);
      http.Response response = await http.get(getAreaUrl, headers: {
        'Authorization': 'Bearer' + ' ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        setState(() {
          areaList = decodedResponse['data'].toList();
          for (var kk in areaList) {
            areaNames.add(kk['area_name']);
          }
          print(areaList.length);
        });
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<void> getUser() async {
    try {
      userNamesUpdate = [];
      userNames = [];
      userListForDeletion = [];
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      print("token");
      print(token);

      databaseOperations = DatabaseOperations();
      int len = await databaseOperations.checkProducts("user");
      if (len == 0) {
        http.Response response = await http.get(getUserUrl, headers: {
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
            duplicateUsers = decodedResponse['data'];
            print("dup users" + duplicateUsers.toString());
            for (var jj in userList) {
              print(jj['_id']);
              var obj = {
                "id": jj['_id'],
                "name": jj['name'],
                'contact': jj['contactno']
              };
              userListForDeletion.add(obj);
              duplicateUsersForDeletion.add(obj);
            }
            for (var i in userList) {
              iconsList.add(Icon(Icons.arrow_downward));
              userNames.add(i['name']);
              var obj2 = {
                'id': i['_id'],
                'name': i['name'],
                'contact': i['contactno']
              };
              userNamesUpdate.add(obj2);
              print(i['name']);
            }
          });
        } else {}
        databaseOperations.insertUser(
            json.encode(decodedResponse['data']), "user");
      } else {
        print("inhere2323");
        List<Map> list = [];
        list = await databaseOperations.getUser();
        print(list[0]);
        List ss = list.toList();
        var qq = json.decode(ss[0]['data']);
        setState(() {
          userList = qq;
          duplicateUsers = qq;
          isLoading = false;
          for (var jj in userList) {
            print(jj['_id']);
            var obj = {
              "id": jj['_id'],
              "name": jj['name'],
              'contact': jj['contactno']
            };
            userListForDeletion.add(obj);
          }
          for (var i in userList) {
            iconsList.add(Icon(Icons.arrow_downward));
            userNames.add(i['name']);
            var obj2 = {
              'id': i['_id'],
              'name': i['name'],
              'contact': i['contactno']
            };
            userNamesUpdate.add(obj2);
            duplicateUsersForDeletion.add(obj2);
            print(i['name']);
          }
        });
      }
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<void> dialogBoxProducts(String newValue) async {
    var unit;
    setState(() {
      for (var i in productList1) {
        if (i['name'] == newValue) {
          unit = i['measurement_unit'];
        }
      }
    });

    showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return Form(
                key: _alertDialogFormKey,
                child: AlertDialog(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(color: Colors.black)),
                    content: Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: TextFormField(
                                    cursorColor: Colors.white,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                        hintText: "Add Quantity",
                                        hintStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: "Muli")),
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please Enter Quantity';
                                      }
                                      return null;
                                    },
                                    controller: addUnitController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[0-9.]")),
                                      LengthLimitingTextInputFormatter(4)
                                    ],
                                    keyboardType: TextInputType.phone,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                RaisedButton(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(color: Colors.black)),
                                    child: Text(
                                      "Add",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      if (_alertDialogFormKey.currentState
                                          .validate()) {
                                        setState(() {
                                          for (var i in productList) {
                                            if (i['name'] == newValue) {
                                              Navigator.pop(context);
                                              _scaffoldKey.currentState
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                  'Item already present!',
                                                  style: TextStyle(
                                                      fontFamily: 'Muli'),
                                                ),
                                                duration: Duration(seconds: 2),
                                              ));

                                              addUnitController.clear();

                                              return;
                                            }
                                          }
                                          productList.add({
                                            "name": newValue,
                                            "qty": addUnitController.text,
                                            "unit": unit.toString()
                                          });
                                          addUnitController.clear();
                                          Navigator.pop(context);
                                        });
                                      }
                                    }),
                                RaisedButton(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                        side: BorderSide(color: Colors.black)),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }),
                              ],
                            )
                          ],
                        );
                      }),
                    )),
              );
            })
        .whenComplete(() => {(context as Element).reassemble()})
        .then((value) => unit = null);
  }

  Future<void> dialogBoxProductsUpdate(String newValue, var idd) async {
    var unit;
    print(idd);
    print(productList1.toString());
    setState(() {
      for (var i in productList1) {
        if (i['_id'] == idd) {
          //     print('uu' + i['measurement_unit']);
          unit = i['measurement_unit'];
        }
      }
    });
    showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(color: Colors.black)),
                  content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  cursorColor: Colors.white,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9.]")),
                                    LengthLimitingTextInputFormatter(4)
                                  ],
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      hintText: "Add Quantity",
                                      hintStyle: TextStyle(
                                          fontFamily: "Muli",
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  controller: updateUnitController,
                                ),
                              ),
                              Text(
                                unit.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              RaisedButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.black)),
                                  child: Text(
                                    "Add",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      var obj = {
                                        "unit": unit.toString(),
                                        'qty': updateUnitController.text,
                                        "name": newValue,
                                        "id": idd
                                      };
                                      productListUpdate.add(obj);
                                      print(productListUpdate);
                                    });
                                    setState(() {
                                      updateUnitController.clear();
                                      Navigator.pop(context);
                                      dropdownValueProductsUpdate = null;
                                    });
                                  }),
                              RaisedButton(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.black)),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  })
                            ],
                          )
                        ],
                      ),
                    );
                  }));
            })
        .whenComplete(() => {(context as Element).reassemble()})
        .then((value) => {dropdownValueUnitUpdate = null});
  }

  void checkAddDetails(flag) async {
    try {
      openDialog();
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');

      var area_id;
      List regular_items = [];
      for (var i in areaList) {
        print(i['area_name']);
        if (dropdownValueAreas == i['area_name']) {
          print(i);
          area_id = i['_id'];
        }
      }
      for (var j in productList1) {
        for (var k in productList) {
          if (k['name'] == j['name']) {
            var obj = {
              "product_id": j['_id'],
              "qty": k['qty'],
              "unit": k['unit'],
              "name": k['name']
            };
            regular_items.add(obj);
          }
        }
      }
      var x = json.encode(regular_items);

      setState(() {
        if (fullNameAddController.text == "") {
          this.errorFirstName = true;
          return;
        }
        if (mobileNumberAddController.text == "") {
          this.errorMobileNumber = true;
          return;
        }
        if (addressAddController.text == "") {
          this.errorAddress = true;
          return;
        }
        if (emailAddController.text == "") {
          this.errorEmail = true;
          return;
        }
      });

      print(token);
      print(mobileNumberAddController.text);
      print(addressAddController.text);
      print(emailAddController.text);
      print(fullNameAddController.text);
      print(area_id);
      print(regular_items.toString());
      http.Response response = await http.post(addUrl, body: {
        'name': fullNameAddController.text,
        'contactno': mobileNumberAddController.text,
        'address': addressAddController.text,
        'email': emailAddController.text,
        'area_id': area_id,
        'user_code':userCodeAddController.text,
        'regular_items': x.toString(),
        'flag': flag
      }, headers: {
        'Authorization': 'Bearer' + ' ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse['state'] == 'success') {
          FocusScope.of(context).requestFocus(addButton);
          Navigator.pop(context);
          if (flag == "fresh") {
            Navigator.pop(context);
          }
          setState(() {
            getUser();
            productList = [];
            dropdownValueAreas = null;
            dropdownValueProducts = null;
          });
          int len = await databaseOperations.updateUserData(
              json.encode(decodedResponse['data']), "user");
          final snackBar = SnackBar(
              content: Text(
            " Added Successfully !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
          fullNameAddController.clear();
          mobileNumberAddController.clear();
          userCodeAddController.clear();
          addressAddController.clear();
          emailAddController.clear();
        } else {
          Navigator.pop(context);
          userAlreadyExistDialog();
          // fullNameAddController.clear();
          // mobileNumberAddController.clear();
          // addressAddController.clear();
          // emailAddController.clear();
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      checkInternetConnection();
    }
  }

  void filterSearchResults(String query) async {
    print("in search");

    if (query.isNotEmpty) {
      setState(() {
        searchResult = [];
        isSearching = true;
      });
      print(duplicateUsers);
      duplicateUsers.forEach((item) {
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
        searchResult = [];
      });
    }
  }

  void filterSearchResultsForDeletion(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        searchResultForDeletion = [];
        isSearchingForDeletion = true;
      });

      duplicateUsersForDeletion.forEach((item) {
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
        searchResultForDeletion = [];
      });
    }
  }

  void deleteUser(var id, var index) async {
    try {
      openDialog();
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      setState(() {});
      http.Response response = await http.post(getDeleteUrl, body: {
        'id': id
      }, headers: {
        "Authorization": 'Bearer ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        if (decodedResponse['state'] == 'success') {
          setState(() {
            userListForDeletion.removeAt(index);
            userList.removeAt(index);
            
            userNamesUpdate.removeAt(index);
          });

          Navigator.pop(context);
          Navigator.pop(context);
          int len = await databaseOperations.updateUserData(
              json.encode(decodedResponse['data']), "user");
          final snackBar = SnackBar(
              content: Text(
            " Deleted Successfully !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
        } else {
          Navigator.pop(context);
          Navigator.pop(context);
          // setState(() {
          //   userListForDeletion.removeAt(index);
          // });
          final snackBar = SnackBar(
              content: Text(
            " Please try again later !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
        }
      } else {}
    } catch (e) {
      Navigator.pop(context);
      checkInternetConnection();
    }
  }

  void checkUpdateDetails() async {
    try {
      openDialog();
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      setState(() {
        if (fullNameUpdateController.text == "") {
          this.errorFirstName = true;
          return;
        }
        if (mobileNumberUpdateController.text == "") {
          this.errorMobileNumber = true;
          return;
        }
        if (addressUpdateController.text == "") {
          this.errorAddress = true;
          return;
        }
        if (emailUpdateController.text == "") {
          this.errorEmail = true;
          return;
        }
      });
      var reg_items = [];
      var final_reg_items;
      for (var v in productListUpdate) {
        var obj = {
          'product_id': v['id'],
          'unit': v['unit'],
          'qty': v['qty'],
          "name": v['name']
        };
        reg_items.add(obj);
      }
      final_reg_items = json.encode(reg_items);
      http.Response response = await http.post(updateUrl, body: {
        'name': fullNameUpdateController.text,
        'contactno': mobileNumberUpdateController.text,
        'address': addressUpdateController.text,
        'email': emailUpdateController.text,
        'id': userid_update,
        'user_code':userCodeUpdateController.text,
        'regular_items': final_reg_items
      }, headers: {
        "Authorization": 'Bearer ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse['state'] == 'success') {
          FocusScope.of(context).requestFocus(nodeUpdateButton);
          setState(() {
            productListUpdate.clear();
            dropdownUserUpdate = null;
            dropdownValueProductsUpdate = null;
            searchResult = [];
            searchResultForDeletion = [];
          });
          Navigator.pop(context);
          fullNameUpdateController.clear();
          mobileNumberUpdateController.clear();
          addressUpdateController.clear();
          emailUpdateController.clear();
          int len = await databaseOperations.updateUserData(
              json.encode(decodedResponse['data']), "user");

          final snackBar = SnackBar(
              content: Text(
            " Updated Successfully !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
        } else {
          Navigator.pop(context);
          final snackbar = SnackBar(
              content: Text(
            "Please Try Again Later !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackbar);
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

  void dialogBoxConfirmation(var id, var index) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
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
                          side: BorderSide(color: Colors.blue)),
                      color: Colors.white,
                      elevation: 5.0,
                      child: Text(
                        "Yes",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        print(id);
                        deleteUser(id, index);
                      }),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.blue)),
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

  void userAlreadyExistDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.black)),
          title: Column(
            children: <Widget>[
              new Text(
                "User already exists !",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0),
              ),
              new Text(
                "Do you want to continue ?",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0),
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
                        checkAddDetails("fresh");
                      }),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.blue)),
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

  Future<Null> getRefresh() async {
    try {
      getUser();
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      checkInternetConnection();
    }
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
            body: TabBarView(
              children: <Widget>[
                isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(
                        backgroundColor: Colors.blue,
                      ))
                    : userList.length == 0
                        ? Center(
                            child: Text(
                            "No Data Found !",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ))
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
                                    controller: searchController,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide:
                                              BorderSide(color: Colors.black)),
                                      enabledBorder: UnderlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                            duration: const Duration(
                                                milliseconds: 600),
                                            child: SlideAnimation(
                                              verticalOffset: 50.0,
                                              child: FadeInAnimation(
                                                child: Card(
                                                  color: Colors.blue,
                                                  margin: EdgeInsets.fromLTRB(
                                                      10.0, 10.0, 10.0, 10.0),
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      ExpansionTile(
                                                        onExpansionChanged:
                                                            (val) {
                                                          setState(() {
                                                            if (val == true) {
                                                              iconsList[index] =
                                                                  Icon(Icons
                                                                      .arrow_upward);
                                                            } else {
                                                              iconsList[index] =
                                                                  Icon(Icons
                                                                      .arrow_downward);
                                                            }
                                                          });
                                                        },
                                                        backgroundColor:
                                                            Colors.blue,
                                                        trailing: IconButton(
                                                          icon:
                                                              iconsList[index],
                                                          onPressed: () {},
                                                          color: Colors.white,
                                                        ),
                                                        leading: CircleAvatar(
                                                          child: Text(
                                                            searchResult[index][
                                                                    'cust_code']
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 10.0),
                                                          ),
                                                        ),
                                                        title: Text(
                                                          searchResult[index][
                                                                      'name'] !=
                                                                  null
                                                              ? searchResult[
                                                                  index]['name']
                                                              : '',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        children: <Widget>[
                                                          Divider(
                                                            color: Colors.white,
                                                          ),
                                                          ListTile(
                                                            leading: Icon(
                                                              Icons
                                                                  .mobile_screen_share,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            title: Text(
                                                              searchResult[
                                                                      index]
                                                                  ['contactno'],
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
                                                            leading: Icon(
                                                              Icons.location_on,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            title: Text(
                                                              searchResult[
                                                                      index]
                                                                  ['address'],
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            color: Colors.white,
                                                          ),
                                                          ListTile(
                                                            leading: Icon(
                                                              Icons.monetization_on,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            title: Text(
                                                             "Balance : "+ searchResult[
                                                                      index]
                                                                  ['balance'].toString(),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                          Divider(
                                                            color: Colors.white,
                                                          ),
                                                          ListTile(
                                                            leading: Icon(
                                                              Icons
                                                                  .mobile_screen_share,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            title: Text(
                                                              searchResult[
                                                                          index]
                                                                      ['email']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
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
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              title: Text(
                                                                "Regular Items",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                    child: ListView.builder(
                                                                        shrinkWrap: true,
                                                                        itemCount: searchResult[index]['regular_items'].length,
                                                                        itemBuilder: (BuildContext ctx, int index2) {
                                                                          return ListTile(
                                                                            leading:
                                                                                Icon(
                                                                              Icons.mobile_screen_share,
                                                                              color: Colors.white,
                                                                            ),
                                                                            title:
                                                                                Text(
                                                                              searchResult[index]['regular_items'][index2]['description'],
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
                                        color: Colors.blue,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.65,
                                          child: AnimationLimiter(
                                            child: new ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: userList.length,
                                                itemBuilder: (BuildContext ctx,
                                                    int index) {
                                                  return AnimationConfiguration
                                                      .staggeredList(
                                                    position: index,
                                                    duration: const Duration(
                                                        milliseconds: 600),
                                                    child: SlideAnimation(
                                                      verticalOffset: 50.0,
                                                      child: FadeInAnimation(
                                                        child: Card(
                                                          color: Colors.blue,
                                                          margin:
                                                              EdgeInsets.all(
                                                                  10),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .black),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0),
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              ExpansionTile(
                                                                onExpansionChanged:
                                                                    (val) {
                                                                  setState(() {
                                                                    if (val ==
                                                                        true) {
                                                                      iconsList[
                                                                              index] =
                                                                          Icon(Icons
                                                                              .arrow_upward);
                                                                    } else {
                                                                      iconsList[
                                                                              index] =
                                                                          Icon(Icons
                                                                              .arrow_downward);
                                                                    }
                                                                  });
                                                                },
                                                                backgroundColor:
                                                                    Colors.blue,
                                                                trailing:
                                                                    IconButton(
                                                                  icon:
                                                                      iconsList[
                                                                          index],
                                                                  onPressed:
                                                                      () {},
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                leading:
                                                                    CircleAvatar(
                                                                  child: Text(
                                                                    userList[index]
                                                                            [
                                                                            'cust_code']
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            10.0),
                                                                  ),
                                                                ),
                                                                title: Text(
                                                                  userList[index]
                                                                              [
                                                                              'name'] !=
                                                                          null
                                                                      ? userList[
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
                                                                children: <
                                                                    Widget>[
                                                                  Divider(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  ListTile(
                                                                    leading:
                                                                        Icon(
                                                                      Icons
                                                                          .mobile_screen_share,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    title: Text(
                                                                      userList[
                                                                              index]
                                                                          [
                                                                          'contactno'],
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
                                                                        Icon(
                                                                      Icons
                                                                          .location_on,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    title: Text(
                                                                      userList[
                                                                              index]
                                                                          [
                                                                          'address'],
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                            color: Colors.white,
                                                          ),
                                                          ListTile(
                                                            leading: Icon(
                                                              Icons.monetization_on,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            title: Text(
                                                              "Balance : "+userList[
                                                                      index]
                                                                  ['balance'].toString(),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                                  Divider(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  ListTile(
                                                                    leading:
                                                                        Icon(
                                                                      Icons
                                                                          .mobile_screen_share,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    title: Text(
                                                                      userList[index]
                                                                              [
                                                                              'email']
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
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
                                                                            FontAwesomeIcons.listAlt),
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
                                                                      title:
                                                                          Text(
                                                                        "Regular Items",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                      children: <
                                                                          Widget>[
                                                                        Container(
                                                                            child: ListView.builder(
                                                                                shrinkWrap: true,
                                                                                itemCount: userList[index]['regular_items'].length,
                                                                                itemBuilder: (BuildContext ctx, int index2) {
                                                                                  return ListTile(
                                                                                    leading: Icon(
                                                                                      Icons.mobile_screen_share,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    title: Text(
                                                                                      userList[index]['regular_items'][index2]['description'],
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
                  child: Container(
                    child: Center(
                      child: Card(
                        color: Colors.blue,
                        margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  Column(
                                    children: <Widget>[
                                      ListTile(
                                        title: TextFormField(
                                          style: TextStyle(color: Colors.white),
                                          cursorColor: Colors.white,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please Enter Name';
                                            }
                                            return null;
                                          },
                                          controller: fullNameAddController,
                                          focusNode: nodeFn,
                                          decoration: InputDecoration(
                                              labelText: "Full Name",
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              labelStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.white))),
                                        ),
                                      ),
                                      ListTile(
                                        title: TextFormField(
                                          style: TextStyle(color: Colors.white),
                                          cursorColor: Colors.white,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please Enter Code';
                                            }
                                            return null;
                                          },
                                          controller: userCodeAddController,
                                          focusNode: nodeUserCodeAdd,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              labelText: "User Code",
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              labelStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.white))),
                                        ),
                                      ),
                                      ListTile(
                                        title: TextFormField(
                                          style: TextStyle(color: Colors.white),
                                          cursorColor: Colors.white,
                                          keyboardType: TextInputType.phone,
                                          focusNode: nodeMn,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please Enter Mobile Number';
                                            }
                                            return null;
                                          },
                                          controller: mobileNumberAddController,
                                          inputFormatters: [
                                            WhitelistingTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(10)
                                          ],
                                          decoration: InputDecoration(
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              labelText: "Mobile Number",
                                              labelStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.white))),
                                        ),
                                      ),
                                      ListTile(
                                        title: TextFormField(
                                          style: TextStyle(color: Colors.white),
                                          cursorColor: Colors.white,
                                          focusNode: nodeAddress,
                                          keyboardType:
                                              TextInputType.streetAddress,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please Enter Address';
                                            }
                                            return null;
                                          },
                                          controller: addressAddController,
                                          decoration: InputDecoration(
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              labelText: "Address",
                                              labelStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.white))),
                                        ),
                                      ),
                                      ListTile(
                                        title: TextFormField(
                                          style: TextStyle(color: Colors.white),
                                          cursorColor: Colors.white,
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Please Enter Email';
                                            }
                                            return null;
                                          },
                                          controller: emailAddController,
                                          focusNode: nodeEmail,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white),
                                              ),
                                              labelText: "Email",
                                              labelStyle: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                              focusedBorder:
                                                  UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.white))),
                                        ),
                                      ),
                                      ListTile(
                                        title: DropdownButton<String>(
                                          dropdownColor: Colors.blue,
                                          focusNode: nodeDropdownArea,
                                          value: dropdownValueAreas,
                                          icon: Icon(
                                            Icons.arrow_downward,
                                            color: Colors.white,
                                          ),
                                          iconSize: 0.0,
                                          elevation: 16,
                                          hint: Text(
                                            "Select Area",
                                            style: TextStyle(
                                                fontFamily: 'Muli',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          style: TextStyle(color: Colors.white),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.white,
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              dropdownValueAreas = newValue;
                                            });
                                          },
                                          items: areaNames
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
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      ListTile(
                                        title: DropdownButton<String>(
                                          dropdownColor: Colors.blue,
                                          focusNode: nodeDropdownProducts,
                                          value: dropdownValueProducts,
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
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          style: TextStyle(color: Colors.white),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.white,
                                          ),
                                          onChanged: (String newValue) {
                                            setState(() {
                                              dropdownValueProducts = newValue;
                                              dialogBoxProducts(newValue);
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
                                                    decoration:
                                                        TextDecoration.none,
                                                    color: Colors.white,
                                                    fontFamily: 'Muli',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15.0),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      Container(
                                        child: productList == null
                                            ? Container()
                                            : Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.15,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    border: Border.all(
                                                        width: 2.0,
                                                        color: Colors.white)),
                                                child: ListView.builder(
                                                  itemCount: productList.length,
                                                  key: new ObjectKey(
                                                      productList.length),
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (BuildContext ctx,
                                                          int index) {
                                                    return SingleChildScrollView(
                                                      child: Column(
                                                        children: <Widget>[
                                                          ListTile(
                                                              trailing:
                                                                  IconButton(
                                                                color: Colors
                                                                    .white,
                                                                icon: Icon(Icons
                                                                    .close),
                                                                onPressed: () {
                                                                  setState(() {
                                                                    productList
                                                                        .removeAt(
                                                                            index);
                                                                    print(
                                                                        productList);
                                                                  });
                                                                },
                                                              ),
                                                              title: Text(
                                                                productList[index]
                                                                        [
                                                                        'name'] +
                                                                    " ( " +
                                                                    productList[index]
                                                                            [
                                                                            'qty']
                                                                        .toString() +
                                                                    " " +
                                                                    productList[
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10.0, bottom: 10.0),
                                  child: RaisedButton(
                                    focusNode: addButton,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(18.0),
                                        side: BorderSide(
                                            color: Colors.blue, width: 2.0)),
                                    color: Colors.white,
                                    child: Text(
                                      "Add",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    onPressed: () {
                                      checkInternetConnection();
                                      if (_addFormKey.currentState.validate()) {
                                        checkAddDetails("not fresh");
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
                  ),
                ),

                //Update
                Form(
                  key: _updateFormKey,
                  child: Container(
                    child: Card(
                      color: Colors.blue,
                      margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white, width: 3.0),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: DropdownButton<String>(
                                        dropdownColor: Colors.blue,
                                        focusNode: nodeDropdownUpdateUser,
                                        hint: Text(
                                          "Select User",
                                          style: TextStyle(
                                              fontFamily: 'Muli',
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        value: dropdownUserUpdate,
                                        icon: Icon(
                                          Icons.arrow_downward,
                                          color: Colors.white,
                                        ),
                                        iconSize: 0.0,
                                        elevation: 16,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                            fontSize: 15.0),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.white,
                                        ),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            productListUpdate = [];
                                            dropdownUserUpdate = newValue;
                                            print(dropdownUserUpdate);
                                            for (var i in userList) {
                                              if (dropdownUserUpdate ==
                                                  i['_id']) {
                                                userid_update = i['_id'];
                                                fullNameUpdateController.text =
                                                    i['name'];
                                                mobileNumberUpdateController
                                                    .text = i['contactno'];
                                                emailUpdateController.text =
                                                    i['email'];
                                                addressUpdateController.text =
                                                    i['address'];
                                                    userCodeUpdateController.text = i['cust_code'];
                                                for (var j
                                                    in i['regular_items']) {
                                                  print(j['qty']);
                                                  var obj = {
                                                    'unit': j['unit'],
                                                    'qty': j['qty'],
                                                    'id': j['productid']['_id'],
                                                    'name': j['productid']
                                                        ['name']
                                                  };
                                                  productListUpdate.add(obj);
                                                }
                                              }
                                            }
                                          });
                                        },
                                        items: userNamesUpdate
                                            .map<DropdownMenuItem<String>>(
                                                (var value) {
                                          return DropdownMenuItem<String>(
                                            value: value['id'].toString(),
                                            child: Text(
                                              value['name'].toString() +
                                                  " ( " +
                                                  value['contact'].toString() +
                                                  " ) ",
                                              style: TextStyle(
                                                decoration: TextDecoration.none,
                                                fontFamily: 'Muli',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    ListTile(
                                      title: TextFormField(
                                        cursorColor: Colors.white,
                                        style: TextStyle(color: Colors.white),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please Enter Name';
                                          }
                                          return null;
                                        },
                                        controller: fullNameUpdateController,
                                        focusNode: nodeUserCodeUpdate,
                                        decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white)),
                                            labelText: "Full Name",
                                            labelStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white))),
                                      ),
                                    ),
                                    ListTile(
                                      title: TextFormField(
                                        cursorColor: Colors.white,
                                        style: TextStyle(color: Colors.white),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please Enter Code';
                                          }
                                          return null;
                                        },
                                        controller: userCodeUpdateController,
                                        focusNode: nodeUFn,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white)),
                                            labelText: "User Code",
                                            labelStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white))),
                                      ),
                                    ),
                                    ListTile(
                                      title: TextFormField(
                                        keyboardType: TextInputType.number,
                                        cursorColor: Colors.white,
                                        style: TextStyle(color: Colors.white),
                                        focusNode: nodeUMn,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter mobile number';
                                          }
                                          return null;
                                        },
                                        controller:
                                            mobileNumberUpdateController,
                                        inputFormatters: [
                                          WhitelistingTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(10)
                                        ],
                                        decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white)),
                                            labelText: "Mobile Number",
                                            labelStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white))),
                                      ),
                                    ),
                                    ListTile(
                                      title: TextFormField(
                                        cursorColor: Colors.white,
                                        style: TextStyle(color: Colors.white),
                                        focusNode: nodeUAddress,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter address';
                                          }
                                          return null;
                                        },
                                        controller: addressUpdateController,
                                        decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white)),
                                            labelText: "Address",
                                            labelStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white))),
                                      ),
                                    ),
                                    ListTile(
                                      title: TextFormField(
                                        cursorColor: Colors.white,
                                        style: TextStyle(color: Colors.white),
                                        focusNode: nodeUEmail,
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter email';
                                          }
                                          return null;
                                        },
                                        controller: emailUpdateController,
                                        decoration: InputDecoration(
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white)),
                                            labelText: "Email",
                                            labelStyle: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white))),
                                      ),
                                    ),
                                    ListTile(
                                      title: DropdownButton<String>(
                                        dropdownColor: Colors.blue,
                                        focusNode: nodeDropdownUpdateProducts,
                                        value: dropdownValueProductsUpdate,
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
                                        style: TextStyle(color: Colors.white),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.white,
                                        ),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            for (var i in productListUpdate) {
                                              if (i['name'] == newValue) {
                                                final snackBar = SnackBar(
                                                    content: Text(
                                                  " Already Exists !",
                                                  style: TextStyle(
                                                      fontFamily: 'Muli'),
                                                ));
                                                Scaffold.of(context)
                                                    .showSnackBar(snackBar);
                                                return;
                                              }
                                            }
                                            dropdownValueProductsUpdate =
                                                newValue;
                                            print(dropdownValueProductsUpdate);

                                            for (var i in productList1) {
                                              if (i['name'] ==
                                                  dropdownValueProductsUpdate) {
                                                dialogBoxProductsUpdate(
                                                    newValue, i['_id']);
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
                                                  fontFamily: 'Muli',
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: 15.0),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    Container(
                                      child: productListUpdate == null
                                          ? Container()
                                          : Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.2,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 2.0,
                                                      color: Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0)),
                                              child: ListView.builder(
                                                itemCount:
                                                    productListUpdate.length,
                                                key: new ObjectKey(
                                                    productListUpdate.length),
                                                shrinkWrap: true,
                                                itemBuilder: (BuildContext ctx,
                                                    int index) {
                                                  return SingleChildScrollView(
                                                    child: Column(
                                                      children: <Widget>[
                                                        ListTile(
                                                            trailing:
                                                                IconButton(
                                                              color:
                                                                  Colors.white,
                                                              icon: Icon(
                                                                  Icons.close),
                                                              onPressed: () {
                                                                setState(() {
                                                                  productListUpdate
                                                                      .removeAt(
                                                                          index);
                                                                  print(
                                                                      productList);
                                                                });
                                                              },
                                                            ),
                                                            title: Text(
                                                              productListUpdate[
                                                                          index]
                                                                      ['name'] +
                                                                  " ( " +
                                                                  productListUpdate[
                                                                              index]
                                                                          [
                                                                          'qty']
                                                                      .toString() +
                                                                  " " +
                                                                  productListUpdate[
                                                                          index]
                                                                      ['unit'] +
                                                                  " ) ",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Muli',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                            )),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 10.0, bottom: 10.0),
                                child: RaisedButton(
                                  focusNode: nodeUpdateButton,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(18.0),
                                      side: BorderSide(
                                          color: Colors.blue, width: 2.0)),
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
                  ),
                ),

                //delete
                Container(
                    child: userListForDeletion == null
                        ? Container(
                            child: Center(
                              child: Text(
                                "No users available",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0),
                              ),
                            ),
                          )
                        : ListView(
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
                                      filterSearchResultsForDeletion(val);
                                    });
                                  },
                                  cursorColor: Colors.black,
                                  controller: searchDeleteController,
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
                                          isSearchingForDeletion = false;
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
                                      itemBuilder:
                                          (BuildContext ctx, int index) {
                                        return AnimationConfiguration
                                            .staggeredList(
                                          duration:
                                              const Duration(milliseconds: 600),
                                          position: index,
                                          child: SlideAnimation(
                                            verticalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: Card(
                                                color: Colors.blue,
                                                margin: EdgeInsets.fromLTRB(
                                                    10.0, 10.0, 10.0, 10.0),
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    ListTile(
                                                      trailing: IconButton(
                                                        icon: Icon(
                                                          Icons.close,
                                                          color: Colors.white,
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
                                                                    ['name'] !=
                                                                null
                                                            ? searchResultForDeletion[
                                                                index]['name']
                                                            : '',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      })
                                  : Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.65,
                                      child: AnimationLimiter(
                                        child: new ListView.builder(
                                            shrinkWrap: true,
                                            itemCount:
                                                userListForDeletion.length,
                                            itemBuilder:
                                                (BuildContext ctx, int index) {
                                              return AnimationConfiguration
                                                  .staggeredList(
                                                duration: const Duration(
                                                    milliseconds: 600),
                                                position: index,
                                                child: SlideAnimation(
                                                  verticalOffset: 50.0,
                                                  child: FadeInAnimation(
                                                    child: Card(
                                                      color: Colors.blue,
                                                      margin:
                                                          EdgeInsets.fromLTRB(
                                                              10.0,
                                                              10.0,
                                                              10.0,
                                                              10.0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .black),
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
                                                              onPressed: () {
                                                                setState(() {
                                                                  dialogBoxConfirmation(
                                                                      userListForDeletion[
                                                                              index]
                                                                          [
                                                                          'id'],
                                                                      index);
                                                                });
                                                              },
                                                            ),
                                                            title: Text(
                                                              userListForDeletion[
                                                                              index]
                                                                          [
                                                                          'name'] !=
                                                                      null
                                                                  ? userListForDeletion[
                                                                              index]
                                                                          [
                                                                          'name'] +
                                                                      " ( " +
                                                                      userListForDeletion[
                                                                              index]
                                                                          [
                                                                          'contact'] +
                                                                      " ) "
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
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                                    ),
                            ],
                          )),
              ],
            ),
          );
  }
}
