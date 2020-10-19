import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/Messages.dart';
// import 'package:dairy_app_owner/screens/SelectLanguage.dart';
import 'package:dairy_app_owner/utilities/AppTranslations.dart';
import 'package:dairy_app_owner/utilities/Application.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../screens/OwnerDashboardDrawer.dart';
import 'package:flutter/material.dart';
import 'OwnerDashboardDrawer.dart';
import 'StockUpdatePage.dart';

class OwnerDashboard extends StatefulWidget {
  @override
  _OwnerDashboardState createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard>
    with SingleTickerProviderStateMixin {
  static final List<String> languagesList = application.supportedLanguages;
  static final List<String> languageCodesList =
      application.supportedLanguagesCodes;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var connectivityResult;
  AnimationController controller;
  Animation<double> scaleAnimation;
  var isConnectionActive = true;
  var isLoading = true;
  List productList = [];
  List<String> productsName = [];
  var deleteProductListForConfirmation = [];
  var dropdownValueUpdateProduct = [];
  var productVariants = [];
  var lang;
  var dropdownValueMeasurement;
  var stockUrl;
  var addStockUrl;
  String unit = '';

  List stockList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var getProductsUrl = Constants.base_url + "products/get_all_products";
  var dropdownValueProduct;

  List<String> unitQuantity = [];
  TextEditingController quantityController = TextEditingController();
  TextEditingController deliveredController = TextEditingController();
  TextEditingController lostController = TextEditingController();
  TextEditingController leftController2 = TextEditingController();
  SharedPreferences prefs;
  final Map<dynamic, dynamic> languagesMap = {
    languagesList[0]: languageCodesList[0],
    languagesList[1]: languageCodesList[1],
  };

  // checkSelectionValue() async {
  //   prefs = await _prefs;

  //   if (prefs.getString("lang") == null) {
  //     Navigator.push(context, MaterialPageRoute(builder: (_) {
  //       return SelectLanguage();
  //     }));
  //   } else {
  //     setState(() {
  //       lang = prefs.getString(lang);
  //       print(prefs.getString("lang"));
  //       onLocaleChange(Locale(languagesMap[prefs.getString("lang")]));
  //     });
  //   }
  // }

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

  Future<void> getStockDetails() async {
    try {
      var date = DateTime.now();
      print(date.day);
      print(date.month);
      print(date.year);
      final storage = new FlutterSecureStorage();
      var token = await storage.read(key: 'token');
      print(token);
      http.Response response = await http.post(stockUrl, body: {
        'month': date.month.toString(),
        'year': date.year.toString(),
        'date': date.day.toString(),
      }, headers: {
        'Authorization': 'Bearer' + ' ' + token,
      });
      print(response.body);
      if (response.statusCode == 200) {
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);

        if (decodedResponse['state'] == 'success') {
          setState(() {
            isLoading = false;
            stockList = decodedResponse['data'];
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<Null> getRefresh() async {
    try {
      getStockDetails();
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<void> addStockDetails(
      flag, qty, unit2, pid, delivered2, left2, lost2) async {
    openDialog();
    try {
      final storage = FlutterSecureStorage();
      var token = await storage.read(key: 'token');

      http.Response response = await http.post(addStockUrl, body: {
        'qty': qty,
        'unit': unit2,
        'delivered': delivered2.toString(),
        'lost': lost2.toString(),
        'left': left2.toString(),
        'product_id': pid
      }, headers: {
        'Authorization': 'Bearer' + ' ' + token,
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        Navigator.pop(context);
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);

        if (decodedResponse['state'] == 'success') {
          setState(() {
            dropdownValueProduct = null;
            dropdownValueMeasurement = null;
            unit = "";
            unit2 = "";
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Added Successfully !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 3),
          ));
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Cannot Add !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 3),
          ));
        }
      } else {
        Navigator.pop(context);
        Navigator.pop(context);
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

  Future<void> getProducts() async {
    try {
      final storage = new FlutterSecureStorage();
      var token = await storage.read(key: 'token');
      print(token);
      http.Response response = await http.get(getProductsUrl, headers: {
        'Authorization': 'Bearer' + ' ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);

        productList = decodedResponse['data'].toList();
        print(productList);
        if (decodedResponse['state'] == 'success') {
          setState(() {
            for (var i in productList) {
              productsName
                  .add(json.encode({'name': i['name'], 'id': i['_id']}));
            }
            print(productVariants);
            print(productList.length);
          });
        } else {}
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  void stockUpdateDialog(var pname, var delivered, var left1, var lost, var qty,
      var unit, var pid) {
    setState(() {
      deliveredController.text = delivered.toString();
      lostController.text = lost.toString();
      leftController2.text = left1.toString();
    });

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (ctx, setState) {
          return Container(
            color: Colors.transparent,
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.42,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: ShapeDecoration(
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0))),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Center(
                      child: Text(
                        pname.toString(),
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.30,
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: ListTile(
                              leading: Container(
                                  child: Text(
                                "Delivered : ",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                              trailing: Container(
                                margin: EdgeInsets.only(right: 10),
                                width: MediaQuery.of(context).size.width * 0.3,
                                height:
                                    MediaQuery.of(context).size.height * 0.03,
                                child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  controller: deliveredController,
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white))),
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Lost : ",
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                            trailing: Container(
                              margin: EdgeInsets.only(right: 10),
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                controller: lostController,
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white))),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Left : ",
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                            trailing: Container(
                              margin: EdgeInsets.only(right: 10),
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                controller: leftController2,
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white))),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              addStockDetails(
                                  "from update dialog",
                                  qty,
                                  unit,
                                  pid,
                                  deliveredController.text,
                                  leftController2.text,
                                  lostController.text);
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
              ),
            ),
          );
        });
      },
    );
  }

  void confirmationDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(color: Colors.black)),
          title: Column(
            children: <Widget>[
              new Text(
                "Are You Sure ?",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
                      color: Colors.white,
                      elevation: 5.0,
                      child: Text(
                        "Exit",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            SystemChannels.platform
                                .invokeMethod('SystemNavigator.pop');
                          });
                        }
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
                          color: Colors.black, fontWeight: FontWeight.bold),
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

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if (mounted) {
      setState(() {
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          isConnectionActive = true;
          // getStockDetails();
        } else {
          isConnectionActive = false;

          return;
        }
      });
    }
  }

  checkInternetConnection2() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if (mounted) {
      setState(() {
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          isConnectionActive = true;
          // getStockDetails();
        } else {
          print("inhere");
          Navigator.pop(context);
          Navigator.pop(context);
          isConnectionActive = false;
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'No Internet Connection !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 3),
          ));
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    application.onLocaleChanged = onLocaleChange;

    checkInternetConnection();
    for (double i = 1; i <= 50; i = i + 0.5) {
      unitQuantity.add(i.toString());
    }

    getProducts();
    addStockUrl = Constants.base_url + 'stocks/add_stock_entry';
    stockUrl = Constants.base_url + 'stocks/get_stock_for_a_particular_dairy';
    getStockDetails();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  void onLocaleChange(Locale locale) async {
    setState(() {
      AppTranslations.load(locale);
    });
  }

  void _select(String language) async {
    await prefs.setString("lang", language);
    print("dd " + language);

    setState(() {
      onLocaleChange(Locale(languagesMap[language]));
      if (language == "Marathi") {
        label = "मराठी";
      } else {
        label = language;
      }
    });
  }

  String label = languagesList[0];
  var choice = ['English', 'Marathi'];

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
        : WillPopScope(
            onWillPop: () {
              confirmationDialog();
              return Future<bool>.value(true);
            },
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                elevation: 0.0,
                actions: <Widget>[
                  // IconButton(
                  //   icon: Icon(Icons.notification_important),
                  //   tooltip: 'Messages',
                  //   onPressed: () {
                  //     Navigator.push(context, MaterialPageRoute(builder: (_) {
                  //       return Messages();
                  //     }));
                  //   },
                  // ),
                  IconButton(
                      tooltip: "Add Stock",
                      icon: Icon(
                        Icons.add_circle_outline,
                      ),
                      onPressed: () {
                        checkInternetConnection();
                        showModalBottomSheet(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0)),
                            ),
                            context: context,
                            builder: (builder) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        top: 5, left: 15, right: 15),
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          child: DropdownButton<String>(
                                            dropdownColor: Colors.blue,
                                            underline: Container(
                                              height: 2.0,
                                              color: Colors.white,
                                            ),
                                            value: dropdownValueProduct,
                                            icon: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.white,
                                            ),
                                            iconSize: 0.0,
                                            hint: Text(
                                              "Select Product",
                                              style: TextStyle(
                                                  fontFamily: 'Muli',
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            style:
                                                TextStyle(color: Colors.white),
                                            onChanged: (String newValue) {
                                              setState(() {
                                                dropdownValueProduct = newValue;
                                                print(dropdownValueProduct);
                                                print(dropdownValueProduct
                                                    .runtimeType);
                                                for (var i in productList) {
                                                  print(i['_id'].runtimeType);
                                                  if (i['_id'] ==
                                                      dropdownValueProduct) {
                                                    print("InHere");
                                                    setState(() {
                                                      unit =
                                                          i['measurement_unit'];
                                                    });
                                                  }
                                                }
                                              });
                                            },
                                            items: productsName
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: json
                                                    .decode(value)['id']
                                                    .toString(),
                                                child: Text(
                                                  json
                                                      .decode(value)['name']
                                                      .toString(),
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5,
                                              child: DropdownButton<String>(
                                                dropdownColor: Colors.blue,
                                                underline: Container(
                                                  height: 2,
                                                  color: Colors.white,
                                                ),
                                                value: dropdownValueMeasurement,
                                                icon: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.blue,
                                                ),
                                                iconSize: 0.0,
                                                hint: Text(
                                                  "Select Quantity",
                                                  style: TextStyle(
                                                      fontFamily: 'Muli',
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                style: TextStyle(
                                                    color: Colors.blue),
                                                onChanged: (String newValue) {
                                                  setState(() {
                                                    dropdownValueMeasurement =
                                                        newValue;
                                                  });
                                                },
                                                items: unitQuantity.map<
                                                        DropdownMenuItem<
                                                            String>>(
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
                                            Container(
                                              child: Text(
                                                unit.toString(),
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    color: Colors.white,
                                                    fontFamily: "Muli"),
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              child: RaisedButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                    side: BorderSide(
                                                        color: Colors.white)),
                                                color: Colors.white,
                                                child: Text(
                                                  "Add",
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onPressed: () {
                                                  checkInternetConnection2();
                                                  openDialog();
                                                  addStockDetails(
                                                      "from bottom sheet",
                                                      dropdownValueMeasurement,
                                                      unit,
                                                      dropdownValueProduct,
                                                      0,
                                                      0,
                                                      0);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                            Container(
                                              child: RaisedButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                    side: BorderSide(
                                                        color: Colors.white)),
                                                color: Colors.white,
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).then((value) => setState(() {
                              getStockDetails();
                            }));
                      }),
                  // PopupMenuButton<String>(
                  //   onSelected: _select,
                  //   itemBuilder: (BuildContext context) {
                  //     return choice.map((String choice) {
                  //       return PopupMenuItem<String>(
                  //         value: choice,
                  //         child: Text(
                  //           choice,
                  //           style: TextStyle(fontWeight: FontWeight.bold),
                  //         ),
                  //       );
                  //     }).toList();
                  //   },
                  // ),
                ],
                backgroundColor: Colors.white,
                iconTheme: new IconThemeData(color: Colors.blue),
                centerTitle: true,
                title: Text(
                  "Dashboard",
                  // AppTranslations.of(context).text("key_first_name"),
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              drawer: OwnerDrawer(),
              body: RefreshIndicator(
                onRefresh: getRefresh,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.95,
                      child: Column(
                        children: [
                          Flexible(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.2,
                              margin: EdgeInsets.only(top: 10.0),
                              child: isLoading == true
                                  ? Center(
                                      child: CircularProgressIndicator(
                                          backgroundColor: Colors.blue))
                                  : stockList.length == 0
                                      ? Container(
                                          decoration: BoxDecoration(),
                                          child: Card(
                                            color: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                side: BorderSide(
                                                    color: Colors.black
                                                        .withOpacity(0.25))),
                                            child: Center(
                                              child: Text(
                                                  "No Stock For Today !",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ))
                                      : ListView.builder(
                                          itemCount: stockList.length,
                                          itemBuilder:
                                              (BuildContext ctx, int index) {
                                            return Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.50,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                StockUpdatePage(
                                                                  stockList[
                                                                          index]
                                                                      ['qty'],
                                                                  stockList[index]
                                                                          [
                                                                          'product_id']
                                                                      ['name'],
                                                                  stockList[index]
                                                                          [
                                                                          'product_id']
                                                                      ['_id'],
                                                                  stockList[index]
                                                                          [
                                                                          'delivered']
                                                                      .toString(),
                                                                  stockList[index]
                                                                          [
                                                                          'left']
                                                                      .toString(),
                                                                  stockList[index]
                                                                          [
                                                                          'lost']
                                                                      .toString(),
                                                                  stockList[
                                                                          index]
                                                                      ['unit'],
                                                                )));
                                                    // stockUpdateDialog(
                                                    // stockList[index]
                                                    //         ['product_id']
                                                    //     ['name'],
                                                    //     stockList[index]
                                                    //             ['delivered']
                                                    //         .toString(),
                                                    //     stockList[index]['left']
                                                    //         .toString(),
                                                    //     stockList[index]['lost']
                                                    //         .toString(),
                                                    // stockList[index]['qty'],
                                                    // stockList[index]
                                                    //     ['unit'],
                                                    //     stockList[index]
                                                    //             ['product_id']
                                                    //         ['_id']);
                                                  },
                                                  child: Card(
                                                    color: Colors.blue,
                                                    elevation: 0.0,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            side: BorderSide(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.25),
                                                            )),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        Container(
                                                          child: Flexible(
                                                            child: Text(
                                                              stockList[index][
                                                                          'product_id']
                                                                      ['name'] +
                                                                  " " +
                                                                  " : " +
                                                                  " " +
                                                                  stockList[index]
                                                                          [
                                                                          'qty']
                                                                      .toString() +
                                                                  stockList[
                                                                          index]
                                                                      ['unit'],
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
                                                        ),
                                                        Divider(
                                                          thickness: 2.0,
                                                          height: 2.0,
                                                          color: Colors.white,
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            "Delivered :" +
                                                                stockList[index]
                                                                        [
                                                                        'delivered']
                                                                    .toString() +
                                                                " " +
                                                                stockList[index]
                                                                        ['unit']
                                                                    .toString(),
                                                            // stockList[index]
                                                            //         ['product_id']
                                                            //     ['name'],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15.0),
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            "Left : " +
                                                                stockList[index]
                                                                        ['left']
                                                                    .toString() +
                                                                " " +
                                                                stockList[index]
                                                                        ['unit']
                                                                    .toString(),
                                                            // stockList[index]
                                                            //         ['product_id']
                                                            //     ['name'],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15.0),
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Text(
                                                            "Lost : " +
                                                                stockList[index]
                                                                        ['lost']
                                                                    .toString() +
                                                                " " +
                                                                stockList[index]
                                                                        ['unit']
                                                                    .toString(),
                                                            // stockList[index]
                                                            //         ['product_id']
                                                            //     ['name'],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15.0),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                          },
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                        ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.7,
                            width: MediaQuery.of(context).size.width,
                            child: ListView(
                              shrinkWrap: true,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: Card(
                                            color: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: Card(
                                            color: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: Card(
                                            color: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: Card(
                                            color: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: Card(
                                            color: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: Colors.black),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)),
                                          ),
                                        ),
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.25,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          child: Card(
                                            color: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
