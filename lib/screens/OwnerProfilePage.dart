import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/database/DatabaseOperations.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqlite_api.dart';

class OwnerProfilePage extends StatefulWidget {
  @override
  _OwnerProfilePageState createState() => _OwnerProfilePageState();
}

class _OwnerProfilePageState extends State<OwnerProfilePage> {
  TextEditingController ownerFullNameController = new TextEditingController();
  TextEditingController ownerMobileNumberController =
      new TextEditingController();
  TextEditingController ownerDairyNameController = new TextEditingController();
  TextEditingController ownerDairyAddressController =
      new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var url;
  var storage;
  var token;
  var updateUrl;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var connectivityResult;
  var isConnectionActive = true;
  final FocusNode nodeUpdateButton = FocusNode();
  final FocusNode nodeFullName = FocusNode();

  final FocusNode nodeMobileNumber = FocusNode();
  final FocusNode nodeDairyName = FocusNode();
  final FocusNode nodeDiryAddress = FocusNode();
  var isLoading = true;
  DatabaseOperations databaseOperations;

  var decodedResponse;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    url = Constants.base_url + 'admins/get_owner_profile';
    updateUrl = Constants.base_url + 'admins/update_owner_profile';
    ownerDetails();
    checkInternetConnection();
  }

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    if (mounted) {
      setState(() {
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          isConnectionActive = true;
          // ownerDetails();
        } else {
          isConnectionActive = false;
        }
      });
    }
  }

  Future<void> ownerDetails() async {
    try {
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      databaseOperations = DatabaseOperations();
      int len =
          await databaseOperations.checkProfileDataPresent("profile_data");
      if (len == 0) {
        http.Response response =
            await http.get(url, headers: {"Authorization": 'Bearer ' + token});
        print(response.body);
        decodedResponse = json.decode(response.body);
        if (decodedResponse['state'] == 'success') {
          print(decodedResponse['data']);
          setState(() {
            isLoading = false;
            ownerFullNameController.text =
                decodedResponse['data']['dairy_id']['owner_name'].toString();
            ownerMobileNumberController.text =
                decodedResponse['data']['contact'].toString();
            ownerDairyNameController.text =
                decodedResponse['data']['dairy_id']['dairy_name'].toString();
            ownerDairyAddressController.text =
                decodedResponse['data']['dairy_id']['dairy_address'].toString();
          });
          databaseOperations.insertProfileData(
              json.encode(decodedResponse['data']), "profile_data");
        }
      } else {
        print("inhere");
        List<Map> list = [];
        list = await databaseOperations.getProfileData();
        print(list[0]);
        List ss = list.toList();
        var qq = json.decode(ss[0]['data']);
        setState(() {
          isLoading = false;
          ownerFullNameController.text =
              qq['dairy_id']['owner_name'].toString();
          ownerMobileNumberController.text = qq['contact'].toString();
          ownerDairyNameController.text =
              qq['dairy_id']['dairy_name'].toString();
          ownerDairyAddressController.text =
              qq['dairy_id']['dairy_address'].toString();
        });
      }
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

  Future<void> updateDetails() async {
    try {
      openDialog();
      storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http.post(updateUrl, body: {
        'name': ownerFullNameController.text,
        'contact': ownerMobileNumberController.text
      }, headers: {
        "Authorization": 'Bearer ' + token,
      });
      print(response.body);

      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        if (decodedResponse['state'] == 'success') {
          FocusScope.of(context).requestFocus(nodeUpdateButton);
          Navigator.pop(context);
          print('updateCache');
          int len = await databaseOperations.updateProfileData(
              json.encode(decodedResponse['data']), "profile_data");
          print(len);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Updated Successfully ! ',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 3),
          ));
        } else {
          Navigator.pop(context);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Please Try Again Later !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 2),
          ));
        }
        print(decodedResponse['data']);
      }
    } catch (e) {
      print(e.toString());
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
                  color: Colors.white,
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
              backgroundColor: Colors.blue,
              elevation: 0.0,
              iconTheme: IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Text(
                "Profile ",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            body: isLoading == true
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.88,
                      child: ListView(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.88,
                            child: Card(
                              color: Colors.blue[400],
                              margin:
                                  EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.75,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 10.0),
                                                child: CircleAvatar(
                                                  maxRadius: 70.0,
                                                  child: FittedBox(
                                                    child: Container(
                                                      height: 100,
                                                      width: 100,
                                                      child: Image.asset(
                                                        'Images/1.png',
                                                      ),
                                                    ),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                title: TextFormField(
                                                  cursorColor: Colors.white,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  focusNode: nodeFullName,
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Please Enter Name';
                                                    }
                                                    return null;
                                                  },
                                                  controller:
                                                      ownerFullNameController,
                                                  decoration: InputDecoration(
                                                    labelText: "Full Name",
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
                                                title: TextFormField(
                                                  cursorColor: Colors.white,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  focusNode: nodeMobileNumber,
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Please Enter Mobile Number';
                                                    }
                                                    return null;
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller:
                                                      ownerMobileNumberController,
                                                  inputFormatters: [
                                                    WhitelistingTextInputFormatter
                                                        .digitsOnly,
                                                    LengthLimitingTextInputFormatter(
                                                        10)
                                                  ],
                                                  decoration: InputDecoration(
                                                    labelText: "Mobile Number",
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
                                                title: TextFormField(
                                                  cursorColor: Colors.white,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  focusNode: nodeDairyName,
                                                  readOnly: true,
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Please Enter Dairy Name';
                                                    }
                                                    return null;
                                                  },
                                                  controller:
                                                      ownerDairyNameController,
                                                  decoration: InputDecoration(
                                                    labelText: "Dairy Name",
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
                                                title: TextFormField(
                                                  cursorColor: Colors.white,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  focusNode: nodeDiryAddress,
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'Please Enter Dairy Address';
                                                    }
                                                    return null;
                                                  },
                                                  readOnly: true,
                                                  controller:
                                                      ownerDairyAddressController,
                                                  decoration: InputDecoration(
                                                    labelText: "Dairy Address",
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
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  RaisedButton(
                                    focusNode: nodeUpdateButton,
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(20.0),
                                    ),
                                    color: Colors.white,
                                    onPressed: () {
                                      checkInternetConnection();
                                      if (_formKey.currentState.validate()) {
                                        updateDetails();
                                      } else {}
                                    },
                                    child: Text(
                                      "Update",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
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
