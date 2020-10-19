import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class TabBarViewMilkDistributor extends StatefulWidget {
  @override
  _TabBarViewMilkDistributorState createState() =>
      _TabBarViewMilkDistributorState();
}

class _TabBarViewMilkDistributorState extends State<TabBarViewMilkDistributor> {
  var token;
  final storage = FlutterSecureStorage();
  var getUrl, addUrl, deleteUrl, updateUrl;
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController nameUpdateController = TextEditingController();
  TextEditingController contactUpdateController = TextEditingController();
  TextEditingController addressUpdateController = TextEditingController();

  final _addFormKey = GlobalKey<FormState>();
  final _updateFormKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FocusNode nameNode = FocusNode();
  final FocusNode contactNode = FocusNode();
  final FocusNode addressNode = FocusNode();
  final FocusNode addButtonNode = FocusNode();
  final FocusNode nameUpdateNode = FocusNode();
  final FocusNode contactUpdateNode = FocusNode();
  final FocusNode addressUpdateNode = FocusNode();
  final FocusNode updateButtonNode = FocusNode();
  var dropdownVlueDistributor;

  var connectivityResult;
  var isConnectionActive = true;
  var isLoading = true;
  var dropdownValueDistributor;
  var distributorId;
  List distributorList, updateDistList, deleteDistributorList;
  var distributorNames;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    distributorList = [];
    distributorNames = [];
    updateDistList = [];
    distributorNames = [];
    deleteDistributorList = [];
    addUrl = Constants.base_url + "distributors/add_distributor";
    getUrl = Constants.base_url + "distributors/get_distributors";
    deleteUrl = Constants.base_url + "distributors/delete_distributor";
    updateUrl = Constants.base_url + "distributors/update_distributor";
    getMilkDistributors();
  }

  void callUser(contactno) async {
    var url = "tel:+91 " + contactno;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
                          side: BorderSide(color: Colors.black)),
                      color: Colors.white,
                      elevation: 5.0,
                      child: Text(
                        "Yes",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        print(id);

                        deleteDistributor(id, index);
                      }),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.black)),
                    color: Colors.white,
                    elevation: 5.0,
                    child: Text(
                      "No",
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

  addMilkDistributors() async {
    openDialog();
    token = await storage.read(key: 'token');
    http.Response response = await http.post(addUrl, body: {
      "name": nameController.text,
      "contact": contactController.text,
      "address": addressController.text
    }, headers: {
      "Authorization": "Bearer " + token
    });
    print(response.body);

    if (response.statusCode == 200) {
      Navigator.pop(context);
      var decRes = json.decode(response.body);
      if (decRes['state'] == 'success') {
        FocusScope.of(context).requestFocus(addButtonNode);
        final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
            content: Text(
              " Added Successfully !",
              style: TextStyle(fontFamily: 'Muli'),
            ));
        nameController.clear();
        contactController.clear();
        addressController.clear();
        Scaffold.of(context).showSnackBar(snackBar);
      } else {
        FocusScope.of(context).requestFocus(addButtonNode);
        final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
            content: Text(
              " Cannot add now !",
              style: TextStyle(fontFamily: 'Muli'),
            ));
        Scaffold.of(context).showSnackBar(snackBar);
        nameController.clear();
        contactController.clear();
        addressController.clear();
      }
    } else {
      FocusScope.of(context).requestFocus(addButtonNode);
      final snackBar = SnackBar(
          behavior: SnackBarBehavior.fixed,
          duration: Duration(seconds: 2),
          content: Text(
            " Please try again later !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
      Scaffold.of(context).showSnackBar(snackBar);
      nameController.clear();
      contactController.clear();
      addressController.clear();
    }
  }

  updateMilkDistributors() async {
    openDialog();
     final storage = new FlutterSecureStorage();
    token = await storage.read(key: 'token');
    http.Response response = await http.post(addUrl, body: {
      "name": nameUpdateController.text,
      "contact": contactUpdateController.text,
      "address": addressUpdateController.text,
      'id': distributorId
    }, headers: {
      "Authorization": "Bearer " + token
    });
    print(response.body);
    if (response.statusCode == 200) {
      Navigator.pop(context);
      var decRes = json.decode(response.body);
      if (decRes['state'] == 'success') {
        print(nameUpdateController.text);
        FocusScope.of(context).requestFocus(addButtonNode);
        final snackBar = SnackBar(
            duration: Duration(seconds: 2),
            content: Text(
              " Updated Successfully !",
              style: TextStyle(fontFamily: 'Muli'),
            ));
        Scaffold.of(context).showSnackBar(snackBar);
        nameUpdateController.clear();
        contactUpdateController.clear();
        addressUpdateController.clear();
      } else {
        FocusScope.of(context).requestFocus(updateButtonNode);
        final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
            content: Text(
              " Cannot add now !",
              style: TextStyle(fontFamily: 'Muli'),
            ));
        Scaffold.of(context).showSnackBar(snackBar);
        nameUpdateController.clear();
        contactUpdateController.clear();
        addressUpdateController.clear();
      }
    } else {
      FocusScope.of(context).requestFocus(updateButtonNode);
      final snackBar = SnackBar(
          behavior: SnackBarBehavior.fixed,
          duration: Duration(seconds: 2),
          content: Text(
            " Please try again later !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  getMilkDistributors() async {
    token = await storage.read(key: 'token');
    http.Response response = await http.get(getUrl, headers: {
      "Authorization": "Bearer " + token,
      "Accept": "application/json"
    });
    print(response.body);
    if (response.statusCode == 200) {
      var decRes = json.decode(response.body);
      if (decRes['state'] == 'success') {
        if (mounted) {
          setState(() {
            isLoading = false;
            distributorList = decRes['data'];
            for (var i in distributorList) {
              var obj = {"id": i['_id'], "name": i['name'], "code": i['code']};
              deleteDistributorList.add(obj);
              var obj2 = {'id': i['_id'], 'name': i['name']};
              distributorNames.add(obj2);
            }
          });
        }
        print(distributorList);
      } else {}
    } else {}
  }

  void deleteDistributor(var id, var index) async {
    try {
      openDialog();
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      setState(() {});
      http.Response response = await http.post(deleteUrl, body: {
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
            deleteDistributorList.removeAt(index);
            distributorList.removeAt(index);
            distributorNames.removeAt(index);
          });
          Navigator.pop(context);
          Navigator.pop(context);
          final snackBar = SnackBar(
              content: Text(
            " Deleted Successfully !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
        } else {
          Navigator.pop(context);
          Navigator.pop(context);
          final snackBar = SnackBar(
              content: Text(
            " Cannot delete now !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
        }
      } else {
        Navigator.pop(context);
        Navigator.pop(context);
        final snackBar = SnackBar(
            content: Text(
          " Please try again later !",
          style: TextStyle(fontFamily: 'Muli'),
        ));
        Scaffold.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      Navigator.pop(context);
      checkInternetConnection();
    }
  }

  Future<Null> getRefresh() async {
    try {
      await Future.delayed(Duration(seconds: 2));
      getMilkDistributors();
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: <Widget>[
        Container(
            child: RefreshIndicator(
          onRefresh: getRefresh,
          child: isLoading == true
              ? Center(
                  child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ))
              : distributorList.length == 0
                  ? Center(
                      child: Text(
                        "No Data Found",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )
                  : AnimationLimiter(
                      child: ListView.builder(
                        itemCount: distributorList.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return AnimationConfiguration.staggeredList(
                            duration: const Duration(milliseconds: 600),
                            position: index,
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Card(
                                  color: Colors.blue,
                                  margin: EdgeInsets.fromLTRB(
                                      10.0, 10.0, 10.0, 10.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      ExpansionTile(
                                        leading: CircleAvatar(
                                          child: Text(distributorList[index]
                                                  ['code']
                                              .toString()),
                                        ),
                                        title: Text(
                                          distributorList[index]['name'],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        children: <Widget>[
                                          Divider(
                                            color: Colors.white,
                                          ),
                                          Container(
                                              child: ListTile(
                                            leading: IconButton(
                                              onPressed: () {
                                                callUser(distributorList[index]
                                                    ['contact']);
                                              },
                                              icon: Icon(Icons.call),
                                              color: Colors.white,
                                            ),
                                            title: Text(
                                              distributorList[index]['contact'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                          Container(
                                              child: ListTile(
                                            leading: IconButton(
                                              onPressed: () {},
                                              icon: Icon(Icons.location_on),
                                              color: Colors.white,
                                            ),
                                            title: Text(
                                              distributorList[index]['address'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ))
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        )),
        Form(
          key: _addFormKey,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Card(
              color: Colors.blue,
              margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ListTile(
                          title: TextFormField(
                            focusNode: nameNode,
                            controller: nameController,
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter Full Name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            keyboardType: TextInputType.phone,
                            focusNode: contactNode,
                            controller: contactController,
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter Contact';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Contact",
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            controller: addressController,
                            focusNode: addressNode,
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter Address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Address",
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: RaisedButton(
                                focusNode: addButtonNode,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(18.0)),
                                color: Colors.white,
                                child: Text(
                                  "Add",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  checkInternetConnection();
                                  if (_addFormKey.currentState.validate()) {
                                    addMilkDistributors();
                                  } else {}
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Form(
          key: _updateFormKey,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Card(
              color: Colors.blue,
              margin: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 10.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ListTile(
                          title: DropdownButton<String>(
                            dropdownColor: Colors.blue,
                            value: dropdownValueDistributor,
                            icon: Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                            ),
                            iconSize: 0.0,
                            elevation: 16,
                            hint: Text(
                              "Select Distributor",
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
                                for (var p in distributorList) {

                                  print(distributorList.toString()+ "hhh");
                                  dropdownValueDistributor = newValue;
                                  if (dropdownValueDistributor == p['_id']) {
                                    distributorId = p['_id'];
                                    print(distributorId+"jjj");
                                    nameUpdateController.text = p['name'];
                                    contactUpdateController.text = p['contact'];
                                    addressUpdateController.text = p['address'];
                                  }
                                }
                              });
                            },
                            items: distributorNames
                                .map<DropdownMenuItem<String>>((var value) {
                              return DropdownMenuItem<String>(
                                value: value['id'].toString(),
                                child: Text(
                                  value['name'].toString(),
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontFamily: 'Muli',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            focusNode: nameUpdateNode,
                            controller: nameUpdateController,
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter Full Name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            keyboardType: TextInputType.phone,
                            focusNode: contactUpdateNode,
                            controller: contactUpdateController,
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter Contact';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Contact",
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                            ),
                          ),
                        ),
                        ListTile(
                          title: TextFormField(
                            controller: addressUpdateController,
                            focusNode: addressUpdateNode,
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter Address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Address",
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: RaisedButton(
                                focusNode: updateButtonNode,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(18.0)),
                                color: Colors.white,
                                child: Text(
                                  "Update",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  checkInternetConnection();
                                  if (_updateFormKey.currentState.validate()) {
                                    updateMilkDistributors();
                                  } else {}
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
            child: deleteDistributorList == null
                ? Container()
                : AnimationLimiter(
                    child: new ListView.builder(
                        itemCount: deleteDistributorList.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          return AnimationConfiguration.staggeredList(
                            duration: const Duration(milliseconds: 600),
                            position: index,
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Card(
                                  color: Colors.blue,
                                  margin: EdgeInsets.fromLTRB(
                                      10.0, 10.0, 10.0, 10.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
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
                                                  deleteDistributorList[index]
                                                      ['id'],
                                                  index);
                                            });
                                          },
                                        ),
                                        leading: CircleAvatar(
                                          child: Text(
                                              deleteDistributorList[index]
                                                      ['code']
                                                  .toString()),
                                        ),
                                        title: Text(
                                          deleteDistributorList[index]
                                                      ['name'] !=
                                                  null
                                              ? deleteDistributorList[index]
                                                  ['name']
                                              : '',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  )),
      ],
    );
  }
}
