import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/database/DatabaseOperations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dairy_app_owner/utilities/Constants.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool upiAddressCrossFadeState;
  bool deliveryChargesCrossFadeState;
  bool minimumOrderCrossFadeState;
  bool selectLanguageCroosFadeState;
  bool paymentReminderCroosFadeState;
  var storage;
  var token;
  var url;
  var valUpiAddress;
  var valPaymentRemainder;
  var valMinimumOrder;
  var valLangauge;
  var valDeliveryCharges;
  var connectivityResult;
  var isConnectionActive = true;
  TextEditingController upiController = TextEditingController();
  TextEditingController deliveryChargeController = TextEditingController();
  TextEditingController mimimumOrderController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var paymentRemindeDropdown;
  var selectLanguageDropdown;
  var settingsUrl;
  var updateUrl;
  var isLoading = false;

  DatabaseOperations databaseOperations;
  var decodedresponse;
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    upiAddressCrossFadeState = false;
    deliveryChargesCrossFadeState = false;
    selectLanguageCroosFadeState = false;
    minimumOrderCrossFadeState = false;
    paymentReminderCroosFadeState = false;
    settingsUrl = Constants.base_url + "admins/get_settings";
    updateUrl = Constants.base_url + "admins/update_settings";
    setState(() {
      getSettings();
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

  Future<void> updateDetails() async {
    try {
      openDialog();
      storage = FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http.post(updateUrl, body: {
        'upi_address': upiController.text,
        'language': selectLanguageDropdown.toString(),
        'delivery_charges': deliveryChargeController.text,
        'minimum_order': mimimumOrderController.text,
        'payment_remainder': paymentRemindeDropdown.toString(),
      }, headers: {
        "Authorization": 'Bearer ' + token
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        var decRes = json.decode(response.body);
        if (decRes['state'] == 'success') {
          int len = await databaseOperations.updateSettingsData(
              json.encode(decRes['data']), "settings");
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Updated Successfully!',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 2),
          ));
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Cannot Update Now!',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 5),
          ));
        }
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please Try Again Later!',
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

  Future<void> getSettings() async {
    try {
      storage = FlutterSecureStorage();
      token = await storage.read(key: 'token');

      databaseOperations = DatabaseOperations();
      int len = await databaseOperations.checkSettings("settings");
      if (len == 0) {
        http.Response response = await http
            .get(settingsUrl, headers: {"Authorization": 'Bearer ' + token});
        print(response.body);
        if (response.statusCode == 200) {
          decodedresponse = json.decode(response.body);
          if (decodedresponse['state'] == 'success') {
            setState(() {
              isLoading = true;
              valUpiAddress =
                  decodedresponse['data'][0]['upi_address'].toString();
              valPaymentRemainder =
                  decodedresponse['data'][0]['payment_remainder'].toString();
              valMinimumOrder =
                  decodedresponse['data'][0]['minimum_order'].toString();
              valDeliveryCharges =
                  decodedresponse['data'][0]['delivery_charges'].toString();
              valLangauge = decodedresponse['data'][0]['language'].toString();

              upiController.text =
                  decodedresponse['data'][0]['upi_address'].toString();
              paymentRemindeDropdown =
                  decodedresponse['data'][0]['payment_remainder'].toString();
              mimimumOrderController.text =
                  decodedresponse['data'][0]['minimum_order'].toString();
              deliveryChargeController.text =
                  decodedresponse['data'][0]['delivery_charges'].toString();
              selectLanguageDropdown =
                  decodedresponse['data'][0]['language'].toString();
            });
          } else {}
        } else {}

        databaseOperations.insertSettings(
            json.encode(decodedresponse['data']), "settings");
      } else {
        print("inHere");
        List<Map> list = [];
        list = await databaseOperations.getSettings();
        print(list[0]);
        List ss = list.toList();
        var qq = json.decode(ss[0]['data']);
        setState(() {
          isLoading = true;
          valUpiAddress = qq[0]['upi_address'].toString();
          valPaymentRemainder = qq[0]['payment_remainder'].toString();
          valMinimumOrder = qq[0]['minimum_order'].toString();
          valDeliveryCharges = qq[0]['delivery_charges'].toString();
          valLangauge = qq[0]['language'].toString();

          upiController.text = qq[0]['upi_address'].toString();
          paymentRemindeDropdown = qq[0]['payment_remainder'].toString();
          mimimumOrderController.text = qq[0]['minimum_order'].toString();
          deliveryChargeController.text = qq[0]['delivery_charges'].toString();
          selectLanguageDropdown = qq[0]['language'].toString();
        });
      }
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<Null> getRefresh() async {
    try {
      getSettings();
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
            backgroundColor: Colors.blue,
            appBar: AppBar(
              actions: [
                IconButton(
                  tooltip: "Save All",
                  splashColor: Colors.white,
                  onPressed: () {
                    checkInternetConnection();
                    updateDetails();
                  },
                  icon: Icon(Icons.save),
                )
              ],
              elevation: 0.0,
              centerTitle: true,
              backgroundColor: Colors.blue,
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "Settings",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            body: isLoading == false
                ? Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ))
                : ListView(
                    shrinkWrap: true,
                    children: [
                      RefreshIndicator(
                        onRefresh: getRefresh,
                        child: Container(
                            height: MediaQuery.of(context).size.height * 0.88,
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              elevation: 0.0,
                              color: Colors.blue,
                              margin: EdgeInsets.only(left: 5.0, right: 5.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.93,
                                                  margin: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.settings,
                                                      color: Colors.white,
                                                    ),
                                                    title: Text("UPI Address",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14.0)),
                                                    trailing: IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            upiAddressCrossFadeState =
                                                                upiAddressCrossFadeState ==
                                                                        false
                                                                    ? true
                                                                    : false;
                                                          });
                                                        }),
                                                  )),
                                            ],
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.90,
                                            child: Row(
                                              children: [
                                                AnimatedCrossFade(
                                                  duration: const Duration(
                                                      milliseconds: 1500),
                                                  crossFadeState:
                                                      upiAddressCrossFadeState ==
                                                              false
                                                          ? CrossFadeState
                                                              .showFirst
                                                          : CrossFadeState
                                                              .showSecond,
                                                  firstChild: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.90,
                                                    child: ListTile(
                                                      leading: Icon(
                                                        Icons.input,
                                                        color: Colors.white,
                                                      ),
                                                      title: Text(
                                                        valUpiAddress
                                                                    .toString() ==
                                                                "null"
                                                            ? " - "
                                                            : valUpiAddress,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  secondChild: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 0.0),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.90,
                                                          child: ListTile(
                                                            leading: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0),
                                                                child: Icon(
                                                                  Icons.input,
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                            title:
                                                                TextFormField(
                                                              controller:
                                                                  upiController,
                                                              cursorColor:
                                                                  Colors.white,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                              decoration: InputDecoration(
                                                                  enabledBorder: UnderlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .white)),
                                                                  focusedBorder: UnderlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .white)),
                                                                  labelText:
                                                                      "Upi Address",
                                                                  labelStyle: TextStyle(
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                        child: Divider(
                                          thickness: 2.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.93,
                                                  margin: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.settings,
                                                      color: Colors.white,
                                                    ),
                                                    title: Text(
                                                        "Select Language",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14.0)),
                                                    trailing: IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            selectLanguageCroosFadeState =
                                                                selectLanguageCroosFadeState ==
                                                                        false
                                                                    ? true
                                                                    : false;
                                                          });
                                                        }),
                                                  )),
                                            ],
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.90,
                                            child: Row(
                                              children: [
                                                AnimatedCrossFade(
                                                  duration: const Duration(
                                                      milliseconds: 1500),
                                                  crossFadeState:
                                                      selectLanguageCroosFadeState ==
                                                              false
                                                          ? CrossFadeState
                                                              .showFirst
                                                          : CrossFadeState
                                                              .showSecond,
                                                  firstChild: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.90,
                                                    child: ListTile(
                                                      leading: Icon(
                                                        Icons.input,
                                                        color: Colors.white,
                                                      ),
                                                      title: Text(
                                                        valLangauge.toString() ==
                                                                "null"
                                                            ? '-'
                                                            : valLangauge,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  secondChild: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 0.0),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.90,
                                                          child: ListTile(
                                                            leading: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0),
                                                                child: Icon(
                                                                  Icons.input,
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                            title:
                                                                DropdownButton<
                                                                    String>(
                                                              dropdownColor:
                                                                  Colors.blue,
                                                              value:
                                                                  selectLanguageDropdown,
                                                              icon: Icon(
                                                                Icons
                                                                    .arrow_downward,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              iconSize: 0.0,
                                                              elevation: 16,
                                                              hint: Text(
                                                                "Select Launguage",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        'Muli',
                                                                    fontSize:
                                                                        15.0),
                                                              ),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                              underline:
                                                                  Container(
                                                                height: 2,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onChanged: (String
                                                                  newValue) {
                                                                setState(() {
                                                                  selectLanguageDropdown =
                                                                      newValue;
                                                                });
                                                              },
                                                              items: <String>[
                                                                "Hindi",
                                                                "Marathi",
                                                                "Telugu"
                                                              ].map<
                                                                  DropdownMenuItem<
                                                                      String>>((String
                                                                  value) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: value,
                                                                  child: Text(
                                                                    value,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        decoration:
                                                                            TextDecoration
                                                                                .none,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            'Muli',
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                        child: Divider(
                                          thickness: 2.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.93,
                                                  margin: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.settings,
                                                      color: Colors.white,
                                                    ),
                                                    title: Text(
                                                        "Delivery Charges",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14.0)),
                                                    trailing: IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            deliveryChargesCrossFadeState =
                                                                deliveryChargesCrossFadeState ==
                                                                        false
                                                                    ? true
                                                                    : false;
                                                          });
                                                        }),
                                                  )),
                                            ],
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.90,
                                            child: Row(
                                              children: [
                                                AnimatedCrossFade(
                                                  duration: const Duration(
                                                      milliseconds: 1500),
                                                  crossFadeState:
                                                      deliveryChargesCrossFadeState ==
                                                              false
                                                          ? CrossFadeState
                                                              .showFirst
                                                          : CrossFadeState
                                                              .showSecond,
                                                  firstChild: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.90,
                                                    child: ListTile(
                                                      leading: Icon(
                                                        Icons.input,
                                                        color: Colors.white,
                                                      ),
                                                      title: Text(
                                                        valDeliveryCharges
                                                                    .toString() ==
                                                                "null"
                                                            ? '-'
                                                            : valDeliveryCharges,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  secondChild: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 0.0),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.90,
                                                          child: ListTile(
                                                            leading: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0),
                                                                child: Icon(Icons
                                                                    .input)),
                                                            title:
                                                                TextFormField(
                                                              controller:
                                                                  deliveryChargeController,
                                                              cursorColor:
                                                                  Colors.white,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                              decoration: InputDecoration(
                                                                  enabledBorder: UnderlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .white)),
                                                                  focusedBorder: UnderlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .white)),
                                                                  labelText:
                                                                      "Delivery Charges",
                                                                  labelStyle: TextStyle(
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                        child: Divider(
                                          thickness: 2.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.93,
                                                  margin: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.settings,
                                                      color: Colors.white,
                                                    ),
                                                    title: Text("Minimum Order",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14.0)),
                                                    trailing: IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            minimumOrderCrossFadeState =
                                                                minimumOrderCrossFadeState ==
                                                                        false
                                                                    ? true
                                                                    : false;
                                                          });
                                                        }),
                                                  )),
                                            ],
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.90,
                                            child: Row(
                                              children: [
                                                AnimatedCrossFade(
                                                  duration: const Duration(
                                                      milliseconds: 1500),
                                                  crossFadeState:
                                                      minimumOrderCrossFadeState ==
                                                              false
                                                          ? CrossFadeState
                                                              .showFirst
                                                          : CrossFadeState
                                                              .showSecond,
                                                  firstChild: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.90,
                                                    child: ListTile(
                                                      leading: Icon(
                                                        Icons.input,
                                                        color: Colors.white,
                                                      ),
                                                      title: Text(
                                                        valMinimumOrder
                                                                    .toString() ==
                                                                'null'
                                                            ? '-'
                                                            : valMinimumOrder,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  secondChild: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 0.0),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.90,
                                                          child: ListTile(
                                                            leading: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0),
                                                                child: Icon(
                                                                  Icons.input,
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                            title:
                                                                TextFormField(
                                                              controller:
                                                                  mimimumOrderController,
                                                              cursorColor:
                                                                  Colors.white,
                                                              style: new TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                              decoration: InputDecoration(
                                                                  enabledBorder: UnderlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .white)),
                                                                  focusedBorder: UnderlineInputBorder(
                                                                      borderSide: BorderSide(
                                                                          color: Colors
                                                                              .white)),
                                                                  labelText:
                                                                      "Minimum Order",
                                                                  labelStyle: TextStyle(
                                                                      fontSize:
                                                                          14.0,
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                        child: Divider(
                                          thickness: 2.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.93,
                                                  margin: EdgeInsets.only(
                                                      left: 15.0),
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.settings,
                                                      color: Colors.white,
                                                    ),
                                                    title: Text(
                                                        "Payment Reminder",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16.0)),
                                                    trailing: IconButton(
                                                        icon: Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            paymentReminderCroosFadeState =
                                                                paymentReminderCroosFadeState ==
                                                                        false
                                                                    ? true
                                                                    : false;
                                                          });
                                                        }),
                                                  )),
                                            ],
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.90,
                                            child: Row(
                                              children: [
                                                AnimatedCrossFade(
                                                  duration: const Duration(
                                                      milliseconds: 1500),
                                                  crossFadeState:
                                                      paymentReminderCroosFadeState ==
                                                              false
                                                          ? CrossFadeState
                                                              .showFirst
                                                          : CrossFadeState
                                                              .showSecond,
                                                  firstChild: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.90,
                                                    child: ListTile(
                                                      leading: Icon(
                                                        Icons.input,
                                                        color: Colors.white,
                                                      ),
                                                      title: Text(
                                                        valPaymentRemainder
                                                                    .toString() ==
                                                                'null'
                                                            ? '-'
                                                            : valPaymentRemainder,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                  ),
                                                  secondChild: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 0.0),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.90,
                                                          child: ListTile(
                                                            leading: Container(
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        top:
                                                                            10.0),
                                                                child: Icon(
                                                                  Icons.input,
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                            title:
                                                                DropdownButton<
                                                                    String>(
                                                              dropdownColor:
                                                                  Colors.blue,
                                                              value:
                                                                  paymentRemindeDropdown,
                                                              icon: Icon(
                                                                Icons
                                                                    .arrow_downward,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              iconSize: 0.0,
                                                              elevation: 16,
                                                              hint: Text(
                                                                "Payment Reminder",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        'Muli',
                                                                    fontSize:
                                                                        15.0),
                                                              ),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                              underline:
                                                                  Container(
                                                                height: 2,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onChanged: (String
                                                                  newValue) {
                                                                setState(() {
                                                                  paymentRemindeDropdown =
                                                                      newValue;
                                                                });
                                                              },
                                                              items: <String>[
                                                                "First Day Of Month",
                                                                "Last  Day Of Month",
                                                              ].map<
                                                                  DropdownMenuItem<
                                                                      String>>((String
                                                                  value) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: value,
                                                                  child: Text(
                                                                    value,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        decoration:
                                                                            TextDecoration
                                                                                .none,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            'Muli',
                                                                        fontSize:
                                                                            15.0),
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ),
                            )),
                      ),
                    ],
                  ));
  }
}
