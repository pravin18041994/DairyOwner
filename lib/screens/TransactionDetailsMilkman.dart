import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/GuestUserTransactionPage.dart';
import 'package:dairy_app_owner/screens/MilkmanDashboard.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TransactionDetailsMilkman extends StatefulWidget {
  @override
  _TransactionDetailsMilkmanState createState() =>
      _TransactionDetailsMilkmanState();
}

class _TransactionDetailsMilkmanState extends State<TransactionDetailsMilkman> {
  var urlMilkmanJourney;
  List transactionItems;
  var isLoading = true;
  TextEditingController qtyUpdateController = TextEditingController();
  var unit = "";

  var productUpdateDropdown;

  var storage;
  List areaWithUserList;
  var expansionIcon = Icons.arrow_downward;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> choices;
  List<Text> t;
  List userList;
  List<String> productNames;
  var token;
  var getProductsUrl;
  List productList;
  List finalTransactionList;
  var transactionUrl;
  var checkTransactionUrl;
  var endTransactionUrl;
  var st = false;
  TextEditingController updateQtyController = TextEditingController();
  bool isTransactionComplete;
  final _formKey = GlobalKey<FormState>();
  var pendingUrl;
  TextEditingController addQuantityController = new TextEditingController();
  TextEditingController addUnitController = new TextEditingController();
  var guestUserUrl;
  var connectivityResult;
  var isConnectionActive = true;

  @override
  void initState() {
    productList = [];
    transactionItems = [];
    finalTransactionList = [];
    areaWithUserList = [];
    productNames = [];
    choices = ["Guest User Transaction"];
    userList = [];
    urlMilkmanJourney = Constants.base_url + 'areas/get_areas';
    getProductsUrl = Constants.base_url + 'products/get_all_products_milkman';
    pendingUrl = Constants.base_url + 'transactions/remove_pending_requests';
    checkTransactionUrl =
        Constants.base_url + 'transactions/check_end_transaction';
    transactionUrl = Constants.base_url + 'transactions/add_transaction';
    endTransactionUrl = Constants.base_url + 'transactions/end_transaction';
    // TODO: implement initState
    checkTransactionComplete();
    super.initState();
    getProducts();
    storage = new FlutterSecureStorage();
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

  Future<void> checkTransactionComplete() async {
    try {
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'milkman_token');
      http.Response response = await http.post(checkTransactionUrl,
          headers: {"Authorization": 'Bearer ' + token});
      print(response.body);
      var decodeResponse = json.decode(response.body);
      setState(() {
        var x = decodeResponse['data'];
        print(x.length);
        if (x.length == 0) {
          dialogBoxTransactionConfirmation();
        } else {
          dialogBoxTransactionComplete();
        }
      });
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<void> endTransactionComplete() async {
    try {
      openDialog();
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'milkman_token');
      http.Response response = await http.post(endTransactionUrl,
          headers: {"Authorization": 'Bearer ' + token});
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        var decRes = json.decode(response.body);
        if (decRes['state'] == 'success') {
          endJourneyDialogBox();
        } else {}
      } else {
        Navigator.pop(context);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please Try Again Later !',
            style: TextStyle(fontFamily: "Muli"),
          ),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      Navigator.pop(context);
      checkInternetConnection();
    }
  }

  Future<void> removePendingRequest(id) async {
    try {
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http.post(pendingUrl, body: {
        'user_id': id,
      }, headers: {
        "Authorization": 'Bearer ' + token
      });
      print(response.body);
      var decodedReponse = json.decode(response.body);
      if (decodedReponse['state'] == 'success') {
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<void> addTransaction(var tItems, var userId) async {
    try {
      openDialog();
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'milkman_token');
      var final_tItems = json.encode(tItems);
      http.Response response = await http.post(transactionUrl, body: {
        'user_id': userId,
        'items_bought': final_tItems.toString(),
      }, headers: {
        'Authorization': 'Bearer ' + token
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Entry Added Successfully !',
            style: TextStyle(fontFamily: "Muli"),
          ),
          duration: Duration(seconds: 2),
        ));
        for (var i in areaWithUserList) {
          for (var j in i['users']) {
            if (j['_id'] == userId) {
              List eir = [];
              String json1 = json.encode(j['extra_item_requests']);
              eir = json.decode(json1);
              print(eir);
              if (eir.length > 0) {
                for (var iii in eir) {
                  var currentDate = DateTime.now();
                  if (iii['dates'].contains(currentDate.day)) {
                    print('yopoooo');
                    var index = iii['dates'].indexOf(currentDate.day);
                    print(index);
                    if (iii['dates'].length - 1 == index) {
                      removePendingRequest(userId);
                    }
                  }
                }
              }
            }
          }
        }
        var responseBody = response.body;
        var decodeResponse = jsonDecode(responseBody);
      } else {
        Navigator.pop(context);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please Try Again Later !',
            style: TextStyle(fontFamily: "Muli"),
          ),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      Navigator.pop(context);
      checkInternetConnection();
    }
  }

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
          for (var i in productList) {
            var obj = {
              'name': i['name'],
              'unit': i['measurement_unit'],
              'id': i['_id'],
              'rate': i['rate']
            };
            productNames.add(json.encode(obj));
          }
        });
        if (decodedResponse['state'] == 'success') {
        } else {}
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<void> getAreaswithUser() async {
    try {
      var token = await storage.read(key: 'milkman_token');
      print(token);
      http.Response response = await http.get(urlMilkmanJourney, headers: {
        'accept': 'application/json',
        'Authorization': "Bearer " + token
      });
      print("rr" + response.body);

      var decodedResponse = json.decode(response.body);
      if (decodedResponse['state'] == 'success') {
        setState(() {
          isLoading = false;
          areaWithUserList = decodedResponse['data'];
          for (var i in areaWithUserList) {
            userList.add(i['users']);
            for (var j in i['users']) {
              for (var k in productList) {
                List eir = [];
                String json1 = json.encode(j['extra_item_requests']);
                eir = json.decode(json1);
                print("eir" + eir.toString());
                for (var iii in eir) {
                  var currentDate = DateTime.now();
                  if (iii['dates'].contains(currentDate.day)) {
                    if (iii['req_status'] == "pending") {
                      continue;
                    } else {
                      for (var l in iii['requests']) {
                        if (k['_id'] == l['product_id']) {
                          var obj = {
                            '_id': l['product_id'],
                            'name': k['name'] + '( Extra )',
                            'rate': k['rate'],
                          };
                          var prod_obj = {
                            'productid': obj,
                            'qty': int.parse(l['qty']),
                            'unit': l['unit'],
                            'delivery_status': false
                          };
                          j['regular_items'].add(prod_obj);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          print(areaWithUserList);
        });
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  void dialogBoxTransactionConfirmation() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.black, width: 2.0)),
          title: new Text(
            "DoodhWala",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Do You Want To Start Journey?",
                  style: TextStyle(
                      fontFamily: "Muli",
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.black)),
                        color: Colors.white,
                        elevation: 5.0,
                        child: Text(
                          "Start",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          getAreaswithUser();
                          Navigator.pop(context);
                        }),
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.black)),
                      color: Colors.white,
                      elevation: 5.0,
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MilkmanDashboard()));
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void endJourneyDialogBox() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.black)),
          title: new Text(
            "DoodhWala",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "All Transactions Are Completed !",
                  style: TextStyle(
                      fontFamily: "Muli",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black)),
                  color: Colors.white,
                  elevation: 0.0,
                  child: Text(
                    "Continue",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MilkmanDashboard()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void dialogBoxTransactionComplete() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(color: Colors.black)),
          title: new Text(
            "DoodhWala",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "All Transactions Are Completed For Today...",
                  style: TextStyle(
                      fontFamily: "Muli",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                      side: BorderSide(color: Colors.black)),
                  color: Colors.white,
                  elevation: 0.0,
                  child: Text(
                    "Go Back",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MilkmanDashboard()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void updateProductsDialog(var index, var index2) {
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
                            value: productUpdateDropdown,
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
                                print("nnnnn" + newValue);

                                productUpdateDropdown = newValue.toString();

                                for (var ii in productNames) {
                                  if (newValue == json.decode(ii)['name']) {
                                    unit = json.decode(ii)['unit'];
                                  }
                                }
                              });
                            },
                            items: productNames
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
                                controller: qtyUpdateController,
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
                                    for (var i in productList) {
                                      if (productUpdateDropdown == i['name']) {
                                        var obj = {
                                          'productid': i,
                                          'qty': int.parse(
                                              qtyUpdateController.text),
                                          'unit': unit,
                                          'delivery_status': false
                                        };
                                        areaWithUserList[index]['users'][index2]
                                                ['regular_items']
                                            .add(obj);
                                      }
                                    }

                                    Navigator.pop(context);
                                    qtyUpdateController.clear();
                                    unit = "";
                                    productUpdateDropdown = null;

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


  void changeQuantityDialog(var amt, var unt, var index, var index2,var index3) {
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
                          areaWithUserList[index]['users'][index2]['regular_items'][index3]['qty'] =
                              updateQtyController.text;
                          // areaWithUserList[index]['items_bought'][index2]['total'] =
                          //     areaWithUserList[index]['items_bought'][index2]
                          //             ['total'] *
                          //         int.parse(updateQtyController.text);
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
              elevation: 0.0,
              iconTheme: IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Text(
                "Transaction Details",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: <Widget>[
                PopupMenuButton<String>(
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onSelected: (String value) {
                    if (value == "Guest User Transaction") {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return GuestUserTransactionPage();
                      }));
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return choices.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(
                          choice,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            body: Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                        child: isLoading == true
                            ? Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.blue,
                                ),
                              )
                            : areaWithUserList.length == 0
                                ? Center(
                                    child: Text(
                                      "No Area Assigned",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 25.0,
                                      ),
                                    ),
                                  )
                                : new ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: areaWithUserList.length,
                                    itemBuilder: (BuildContext ctx, int index) {
                                      return Card(
                                        color: Colors.blue,
                                        margin: EdgeInsets.fromLTRB(
                                            10.0, 10.0, 10.0, 10.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            side: BorderSide(
                                                color: Colors.black)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            SingleChildScrollView(
                                              child: ExpansionTile(
                                                backgroundColor: Colors.blue,
                                                title: Text(
                                                  areaWithUserList[index]
                                                      ['area_name'],
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                children: <Widget>[
                                                  areaWithUserList[index]
                                                                  ['users']
                                                              .length ==
                                                          0
                                                      ? ListTile(
                                                          title: Text(
                                                            "No user available",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        )
                                                      : ListView.builder(
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              areaWithUserList[
                                                                          index]
                                                                      ['users']
                                                                  .length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index2) {
                                                            return Card(
                                                              color:
                                                                  Colors.blue,
                                                              margin: EdgeInsets
                                                                  .all(10.0),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                  side: BorderSide(
                                                                      color: Colors
                                                                          .black)),
                                                              child: Column(
                                                                children: <
                                                                    Widget>[
                                                                  ExpansionTile(
                                                                    title: Text(
                                                                      areaWithUserList[index]['users']
                                                                              [
                                                                              index2]
                                                                          [
                                                                          'name'],
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              18.0,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    leading:
                                                                        IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        updateProductsDialog(
                                                                            index,
                                                                            index2);
                                                                      },
                                                                      icon: Icon(
                                                                          Icons
                                                                              .add),
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    children: <
                                                                        Widget>[
                                                                      ListView.builder(
                                                                          shrinkWrap: true,
                                                                          itemCount: areaWithUserList[index]['users'][index2]['regular_items'].length,
                                                                          itemBuilder: (BuildContext ctx, int index3) {
                                                                            return Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                IconButton(
                                                                                  onPressed: () {
                                                                                      changeQuantityDialog(
                                                                                        areaWithUserList[index]['users'][index2]['regular_items'][index3]['qty']
                                                                                            .toString(),
                                                                                        areaWithUserList[index]['users'][index2]['regular_items'][index3]['unit']
                                                                                            .toString(),
                                                                                        index,
                                                                                        index2,index3);
                                                                                  },
                                                                                  tooltip:
                                                                                      "Change Quantity",
                                                                                  icon: Icon(
                                                                                    Icons.cached,
                                                                                    color:
                                                                                        Colors.white,
                                                                                  )),
                                                                                Container(
                                                                                  margin: EdgeInsets.only(left: 10),
                                                                                  child: Text(
                                                                                    areaWithUserList[index]['users'][index2]['regular_items'][index3]['productid']['name'].toString() + " ( " + areaWithUserList[index]['users'][index2]['regular_items'][index3]['qty'].toString() + areaWithUserList[index]['users'][index2]['regular_items'][index3]['unit'].toString() + " ) ",
                                                                                    style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  child: Switch(
                                                                                    activeColor: Colors.white,
                                                                                    inactiveThumbColor: Colors.red,
                                                                                    value: areaWithUserList[index]['users'][index2]['regular_items'][index3]['delivery_status'],
                                                                                    onChanged: (value) {
                                                                                      var status;

                                                                                      setState(() {
                                                                                        if (value == true) {
                                                                                          areaWithUserList[index]['users'][index2]['regular_items'][index3]['delivery_status'] = true;
                                                                                          status = "Delivered";
                                                                                        } else {
                                                                                          areaWithUserList[index]['users'][index2]['regular_items'][index3]['delivery_status'] = false;
                                                                                          status = "Not Delivered";
                                                                                        }
                                                                                      });
                                                                                      transactionItems = [];

                                                                                      var obj = {
                                                                                        "status": status,
                                                                                        'product_id': areaWithUserList[index]['users'][index2]['regular_items'][index3]['productid']['_id'],
                                                                                        'qty': areaWithUserList[index]['users'][index2]['regular_items'][index3]['qty'],
                                                                                        'unit': areaWithUserList[index]['users'][index2]['regular_items'][index3]['unit'],
                                                                                        'total': int.parse(areaWithUserList[index]['users'][index2]['regular_items'][index3]['productid']['rate']) * (areaWithUserList[index]['users'][index2]['regular_items'][index3]['qty']),
                                                                                      };
                                                                                      print(obj);
                                                                                      transactionItems.add(obj);
                                                                                      addTransaction(transactionItems, areaWithUserList[index]['users'][index2]['_id']);
                                                                                    },
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            );
                                                                          })
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            );
                                                          })
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    })),
                  ),
                  Visibility(
                    visible: areaWithUserList.length == 0 ? false : true,
                    child: SizedBox(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side:
                                  BorderSide(color: Colors.black, width: 2.0)),
                          color: Colors.white,
                          elevation: 0.0,
                          child: Text(
                            "End Journey",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            checkInternetConnection();
                            endTransactionComplete();
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ));
  }
}
