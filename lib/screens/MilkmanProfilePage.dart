import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class MilkmanProfilePage extends StatefulWidget {
  @override
  _MilkmanProfilePageState createState() => _MilkmanProfilePageState();
}

class _MilkmanProfilePageState extends State<MilkmanProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var token;
  var storage;
  var milkmanProfileDataUrl;
  var connectivityResult;
  var isConnectionActive = true;
  var isLoading = true;

  TextEditingController milkmanFullNameController = new TextEditingController();
  TextEditingController milkmanMobileNumberController =
      new TextEditingController();
  TextEditingController milkmanPersonalAddressController =
      new TextEditingController();
  var updateMilkmanUrl;
  final _formKey = GlobalKey<FormState>();
  final FocusNode updateButtonNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    checkInternetConnection();
    storage = new FlutterSecureStorage();
    milkmanProfileDataUrl = Constants.base_url + "milkmen/get_profile_data";
    updateMilkmanUrl = Constants.base_url + "milkmen/update_milkman";
    getProfileMilkmanData();
  }

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        isConnectionActive = true;
        // getProfileMilkmanData();
      } else {
        isConnectionActive = false;
      }
    });
  }

  void getProfileMilkmanData() async {
    try {
      token = await storage.read(key: 'milkman_token');
      http.Response response = await http.get(milkmanProfileDataUrl,
          headers: {'Authorization': 'Bearer ' + token});
      print(response.body);
      if (json.decode(response.body)['state'] == 'success') {
        setState(() {
          isLoading = false;
        });
        milkmanFullNameController.text = json.decode(response.body)['name'];
        milkmanMobileNumberController.text =
            json.decode(response.body)['contact'];
        milkmanPersonalAddressController.text =
            json.decode(response.body)['address'];
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  void updateMilkmanDetails() async {
    try {
      openDialog();
      token = await storage.read(key: 'milkman_token');
      http.Response response = await http.post(updateMilkmanUrl, body: {
        'name': milkmanFullNameController.text,
        'contact': milkmanMobileNumberController.text,
        'residential_address': milkmanPersonalAddressController.text
      }, headers: {
        'Authorization': 'Bearer ' + token
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        if (json.decode(response.body)['state'] == 'success') {
            FocusScope.of(context).requestFocus(updateButtonNode);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Updated Successfully !',
              style: TextStyle(fontFamily: "Muli"),
            ),
            duration: Duration(seconds: 2),
          ));
        
        } else {
          Navigator.pop(context);
          Focus.of(context).requestFocus(updateButtonNode);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Cannot update now !',
              style: TextStyle(fontFamily: "Muli"),
            ),
            duration: Duration(seconds: 2),
          ));
        }
      } else {
        Navigator.pop(context);
        Focus.of(context).requestFocus(updateButtonNode);
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            'Please try again later !',
            style: TextStyle(fontFamily: "Muli"),
          ),
          duration: Duration(seconds: 2),
        ));
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
            appBar: AppBar(
              backgroundColor: Colors.blue,
              elevation: 0.0,
              iconTheme: IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Text(
                "Profile Page",
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
                      child: ListView(
                        children: <Widget>[
                          Container(
                            height: MediaQuery.of(context).size.height * 0.85,
                            child: Card(
                              margin:
                                  EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  CircleAvatar(
                                    maxRadius: 80.0,
                                    backgroundImage: AssetImage("Images/1.png"),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                      controller: milkmanFullNameController,
                                      decoration: InputDecoration(
                                          labelText: "Full Name",
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue))),
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        WhitelistingTextInputFormatter
                                            .digitsOnly,
                                        LengthLimitingTextInputFormatter(10)
                                      ],
                                      controller: milkmanMobileNumberController,
                                      decoration: InputDecoration(
                                          labelText: "Mobile Number",
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue))),
                                    ),
                                  ),
                                  ListTile(
                                    title: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter some text';
                                        }
                                        return null;
                                      },
                                      controller:
                                          milkmanPersonalAddressController,
                                      decoration: InputDecoration(
                                          labelText: "Personal Address",
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.blue))),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  RaisedButton(
                                    focusNode: updateButtonNode,
                                    elevation: 0.0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(10.0),
                                        side: BorderSide(color: Colors.black)),
                                    color: Colors.white60,
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        updateMilkmanDetails();
                                      } else {}
                                    },
                                    child: Text(
                                      "Update ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
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
