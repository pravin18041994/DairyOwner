import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/database/DatabaseOperations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../utilities/Constants.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TabBarViewMilkman extends StatefulWidget {
  @override
  _TabBarViewMilkman createState() => _TabBarViewMilkman();
}

class _TabBarViewMilkman extends State<TabBarViewMilkman> {
  var isSearching = false;
  List searchResult = [];
  List duplicateMilkman = [];

  var isSearchingForDeletion = false;
  List searchResultForDeletion = [];
  List duplicateMilkmanForDeletion = [];

  String dropdownValueUpdate;
  List<String> milkmenUpdate;
  var milkmanid_update;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  var addUrl;
  var updateReadOnlyName = true;
  var updateReadOnlyContact = true;
  var updateReadOnlyAddress = true;
  var token;
  var isLoading = true;
  var updateUrl;
  var getMilkmenUrl;
  var errorFirstName = false;
  List milkmanList;
  var errorLastName = false;
  var errorMobileNumber = false;
  var refreshIsRefreshing = false;
  var errorAddress = false;
  var storage;
  List listIcon;
  var deleteMilkmanUrl;
  final _addFormKey = GlobalKey<FormState>();
  final _updateFormKey = GlobalKey<FormState>();
  TextEditingController firstNameAddController = new TextEditingController();
  TextEditingController lastNameAddController = new TextEditingController();
  TextEditingController mobileNumberAddController = new TextEditingController();
  TextEditingController addressAddController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var connectivityResult;
  var isConnectionActive = true;

  //  Update Controllers
  var milkmanListForDeletion;

  TextEditingController fullNameUpdateController = new TextEditingController();
  TextEditingController mobileNumberUpdateController =
      new TextEditingController();
  TextEditingController addressUpdateController = new TextEditingController();
  final FocusNode nodeaddress = FocusNode();
  final FocusNode addButton = FocusNode();
  final FocusNode nodeFn = FocusNode();
  final FocusNode nodeLn = FocusNode();
  final FocusNode nodeMn = FocusNode();
  final FocusNode nodeUfn = FocusNode();
  final FocusNode nodeUmn = FocusNode();
  TextEditingController searchController = TextEditingController();
  TextEditingController searchDeleteController = TextEditingController();
  final FocusNode nodeUadd = FocusNode();
  final FocusNode nodeUdropdown = FocusNode();
  final FocusNode nodeUpdateButton = FocusNode();

  var decodedResponse;
  DatabaseOperations databaseOperations;

  @override
  void initState() {
    // TODO: implement initState

    addUrl = Constants.base_url + "/milkmen/add_milkman";
    milkmenUpdate = [];
    updateUrl = Constants.base_url + "/milkmen/update_milkman";
    milkmanListForDeletion = [];
    milkmanList = [];
    listIcon = [];
    getMilkmenUrl =
        Constants.base_url + "/milkmen/get_all_milkmen_with_dairy_details";
    deleteMilkmanUrl = Constants.base_url + "/milkmen/delete_milkman";
    super.initState();
    checkInternetConnection();

    getMilkmen();
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

  Future<Null> getRefresh() async {
    try {
      getMilkmen();
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      checkInternetConnection();
    }
  }

  void deleteMilkman(var id, var index) async {
    try {
      openDialog();
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');

      http.Response response = await http.post(deleteMilkmanUrl, body: {
        'id': id
      }, headers: {
        "Authorization": 'Bearer ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        if (decodedResponse['state'] == 'success') {
          Navigator.pop(context);
          Navigator.pop(context);
          setState(() {
            //    getMilkmen();
            milkmanListForDeletion.removeAt(index);
            milkmanList.removeAt(index);
            milkmenUpdate.removeAt(index);
          });
          int len = await databaseOperations.updateMilkmanData(
              json.encode(decodedResponse['data']), "milkman");
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
            " Please try again later !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
        }
      } else {}
    } catch (e) {
      print(e.toString());
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
                        deleteMilkman(id, index);
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

  Future<void> getMilkmen() async {
    try {
      milkmenUpdate = [];
      milkmanListForDeletion = [];
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      print("token");
      print(token);
      databaseOperations = DatabaseOperations();
      int len = await databaseOperations.checkMilkmanPresent("milkman");

      if (len == 0) {
        http.Response response = await http.get(getMilkmenUrl, headers: {
          'Authorization': 'Bearer' + ' ' + token,
          "Accept": "application/json"
        });
        print(response.body);
        if (response.statusCode == 200) {
          var responseBody = response.body;
          decodedResponse = jsonDecode(responseBody);
          setState(() {
            isLoading = false;
            milkmanList = decodedResponse['milkmen'];
            duplicateMilkman = decodedResponse['milkmen'];
            for (var i in milkmanList) {
              listIcon.add(Icons.arrow_downward);
              var obj = {
                "id": i['_id'],
                "name": i['name'],
                'contact': i['contact']
              };
              milkmanListForDeletion.add(obj);
              duplicateMilkmanForDeletion.add(obj);
              milkmenUpdate.add(json.encode(obj));
            }
            print(milkmenUpdate.runtimeType);
            print(milkmanList.length);
          });
        } else {}

        databaseOperations.insertMilkman(
            json.encode(decodedResponse['milkmen']), "milkman");
      } else {
        print("inhere");
        List<Map> list = [];
        list = await databaseOperations.getMilkman();
        print(list[0]);
        List ss = list.toList();
        var qq = json.decode(ss[0]['data']);
        setState(() {
          milkmanList = qq;
          duplicateMilkman = qq;
          isLoading = false;
          for (var i in milkmanList) {
            listIcon.add(Icons.arrow_downward);
            var obj = {
              "id": i['_id'],
              "name": i['name'],
              'contact': i['contact']
            };
            milkmanListForDeletion.add(obj);
            duplicateMilkmanForDeletion.add(obj);
            milkmenUpdate.add(json.encode(obj));
          }
          print(milkmenUpdate.runtimeType);
          print(milkmanList.length);
        });
      }
    } catch (e) {
      checkInternetConnection();
    }
  }

  void checkAddDetails() async {
    try {
      openDialog();
      setState(() {
        if (firstNameAddController.text == "") {
          this.errorFirstName = true;
          return;
        }
        if (lastNameAddController.text == "") {
          this.errorLastName = true;
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
      });

      print(token);
      print(firstNameAddController.text + ' ' + lastNameAddController.text);
      print(mobileNumberAddController.text);
      print(addressAddController.text);
      http.Response response = await http.post(addUrl, body: {
        'name': firstNameAddController.text + " " + lastNameAddController.text,
        'contact': mobileNumberAddController.text,
        'residential_address': addressAddController.text.trim(),        
        'password': '123456',
      }, headers: {
        'Authorization': 'Bearer' + ' ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context); //this statement closes the dialog
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse['state'] == 'success') {
          getMilkmen();
          FocusScope.of(context).requestFocus(addButton);

          firstNameAddController.clear();
          lastNameAddController.clear();
          mobileNumberAddController.clear();
          addressAddController.clear();
          int len = await databaseOperations.updateMilkmanData(
              json.encode(decodedResponse['data']), "milkman");
          final snackBar = SnackBar(
              content: Text(
            " Added Successfully !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
        } else {
          FocusScope.of(context).requestFocus(addButton);
          final snackBar = SnackBar(
              content: Text(
            "Milkman Already Exists !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
          firstNameAddController.clear();
          lastNameAddController.clear();
          mobileNumberAddController.clear();
          addressAddController.clear();
        }
      } else {
        Navigator.pop(context);
        final snackBar = SnackBar(
            content: Text(
          "Please Try Again Later !",
          style: TextStyle(fontFamily: 'Muli'),
        ));
        Scaffold.of(context).showSnackBar(snackBar);
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
        print(milkmanid_update);
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
      });

      print(token);
      print(mobileNumberUpdateController.text);
      print(addressUpdateController.text);
      print(milkmanid_update);
      http.Response response = await http.post(updateUrl, body: {
        'name': fullNameUpdateController.text,
        'contact': mobileNumberUpdateController.text,
        'residential_address': addressUpdateController.text,
        'id': milkmanid_update
      }, headers: {
        "Authorization": 'Bearer ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context); //this statement closes the dialog
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse['state'] == 'success') {
          setState(() {
            getMilkmen();
            dropdownValueUpdate = null;
          });
          FocusScope.of(context).requestFocus(nodeUpdateButton);
          int len = await databaseOperations.updateMilkmanData(
              json.encode(decodedResponse['data']), "milkman");
          final snackBar = SnackBar(
              content: Text(
            " Updated Successfully !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
          fullNameUpdateController.clear();
          mobileNumberUpdateController.clear();
          addressUpdateController.clear();
        } else {
          FocusScope.of(context).requestFocus(nodeUpdateButton);
          final snackbar = SnackBar(
              content: Text(
            "Please try  again later !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackbar);
          fullNameUpdateController.clear();
          mobileNumberUpdateController.clear();
          addressUpdateController.clear();
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

  void filterSearchResults(String query) async {
    print("in search");

    if (query.isNotEmpty) {
      setState(() {
        searchResult.clear();
        isSearching = true;
      });
      print(duplicateMilkman);
      duplicateMilkman.forEach((item) {
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

      duplicateMilkmanForDeletion.forEach((item) {
        if (item['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            item['cust_code']
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
                  : milkmanList.length == 0
                      ? Center(
                          child: Text(
                          "No Data Found",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ))
                      : Container(
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
                                            verticalOffset: 50.0,
                                            child: FadeInAnimation(
                                              child: Card(
                                                color: Colors.blue,
                                                margin: EdgeInsets.fromLTRB(
                                                    10.0, 10.0, 10.0, 10.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    ExpansionTile(
                                                      backgroundColor:
                                                          Colors.blue,
                                                      onExpansionChanged:
                                                          (value) {
                                                        setState(() {
                                                          if (value == true) {
                                                            listIcon[index] =
                                                                Icons
                                                                    .arrow_upward;
                                                          } else {
                                                            listIcon[index] = Icons
                                                                .arrow_downward;
                                                          }
                                                        });
                                                      },
                                                      trailing: Icon(
                                                        listIcon[index],
                                                        color: Colors.white,
                                                      ),
                                                      title: Text(
                                                        searchResult[index]
                                                            ['name'],
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      children: <Widget>[
                                                        Divider(
                                                          color: Colors.white,
                                                        ),
                                                        ListTile(
                                                          leading: Icon(
                                                            Icons
                                                                .mobile_screen_share,
                                                            color: Colors.white,
                                                          ),
                                                          title: Text(
                                                            searchResult[index]
                                                                ['contact'],
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        Divider(
                                                          color: Colors.white,
                                                        ),
                                                        ListTile(
                                                          leading: Icon(
                                                            Icons.location_on,
                                                            color: Colors.white,
                                                          ),
                                                          title: Text(
                                                            searchResult[index][
                                                                'residential_address'],
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
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
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.65,
                                        child: AnimationLimiter(
                                          child: new ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: milkmanList.length,
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
                                                        margin: EdgeInsets.all(
                                                            10.0),
                                                        shape: RoundedRectangleBorder(
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
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              onExpansionChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  if (value ==
                                                                      true) {
                                                                    listIcon[
                                                                            index] =
                                                                        Icons
                                                                            .arrow_upward;
                                                                  } else {
                                                                    listIcon[
                                                                            index] =
                                                                        Icons
                                                                            .arrow_downward;
                                                                  }
                                                                });
                                                              },
                                                              trailing: Icon(
                                                                listIcon[index],
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              title: Text(
                                                                milkmanList[
                                                                        index]
                                                                    ['name'],
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              children: <
                                                                  Widget>[
                                                                Divider(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                ListTile(
                                                                  leading: Icon(
                                                                    Icons
                                                                        .mobile_screen_share,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  title: Text(
                                                                    milkmanList[
                                                                            index]
                                                                        [
                                                                        'contact'],
                                                                    style:
                                                                        TextStyle(
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
                                                                  leading: Icon(
                                                                    Icons
                                                                        .location_on,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  title: Text(
                                                                    milkmanList[
                                                                            index]
                                                                        [
                                                                        'residential_address'],
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
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
                  child: ListView(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: Card(
                          color: Colors.blue,
                          margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ListTile(
                                title: TextFormField(
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter name';
                                    }
                                    return null;
                                  },
                                  controller: firstNameAddController,
                                  focusNode: nodeFn,
                                  decoration: InputDecoration(
                                      labelText: "First Name",
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white))),
                                ),
                              ),
                              ListTile(
                                title: TextFormField(
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter last name';
                                    }
                                    return null;
                                  },
                                  controller: lastNameAddController,
                                  focusNode: nodeLn,
                                  decoration: InputDecoration(
                                    labelText: "Last Name",
                                    labelStyle: TextStyle(
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
                              ListTile(
                                title: TextFormField(
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter mobile number';
                                    }
                                    return null;
                                  },
                                  controller: mobileNumberAddController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(10),
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  focusNode: nodeMn,
                                  decoration: InputDecoration(
                                    labelText: "Mobile Number",
                                    labelStyle: TextStyle(
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
                              ListTile(
                                title: TextFormField(
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  focusNode: nodeaddress,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter address';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.streetAddress,
                                  controller: addressAddController,
                                  decoration: InputDecoration(
                                    labelText: "Address",
                                    labelStyle: TextStyle(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
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
              ),

              //Update
              Form(
                key: _updateFormKey,
                child: Container(
                  child: ListView(
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: Card(
                          color: Colors.blue,
                          margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white, width: 2.0),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ListTile(
                                title: DropdownButton<String>(
                                  dropdownColor: Colors.blue,
                                  focusNode: nodeUdropdown,
                                  value: dropdownValueUpdate,
                                  icon: Icon(
                                    Icons.arrow_downward,
                                    color: Colors.white,
                                  ),
                                  iconSize: 0.0,
                                  elevation: 16,
                                  hint: Text(
                                    " Select Milkman",
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
                                      updateReadOnlyAddress = false;
                                      updateReadOnlyContact = false;
                                      updateReadOnlyName = false;
                                      dropdownValueUpdate = newValue;
                                      print(dropdownValueUpdate);
                                      for (var i in milkmanList) {
                                        if (i['_id'] == dropdownValueUpdate) {
                                          milkmanid_update = i['_id'];
                                          fullNameUpdateController.text =
                                              i['name'];
                                          mobileNumberUpdateController.text =
                                              i['contact'];
                                          addressUpdateController.text =
                                              i['residential_address'];
                                        }
                                      }
                                    });
                                  },
                                  items: milkmenUpdate
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: json.decode(value)['id'],
                                      child: Text(
                                        json.decode(value)['name'] +
                                            " ( " +
                                            json.decode(value)['contact'] +
                                            " ) ",
                                        style: TextStyle(
                                            fontFamily: 'Muli',
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                            fontSize: 15.0),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              ListTile(
                                title: TextFormField(
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  readOnly: updateReadOnlyName,
                                  focusNode: nodeUfn,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please Enter Full Name';
                                    }
                                    return null;
                                  },
                                  controller: fullNameUpdateController,
                                  decoration: InputDecoration(
                                    labelText: "Full Name",
                                    labelStyle: TextStyle(
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
                              ListTile(
                                title: TextFormField(
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  readOnly: updateReadOnlyContact,
                                  focusNode: nodeUmn,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please Enter Mobile Number';
                                    }
                                    return null;
                                  },
                                  controller: mobileNumberUpdateController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Mobile Number",
                                    labelStyle: TextStyle(
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
                              ListTile(
                                title: TextFormField(
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  readOnly: updateReadOnlyAddress,
                                  focusNode: nodeUadd,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please Enter Address';
                                    }
                                    return null;
                                  },
                                  controller: addressUpdateController,
                                  decoration: InputDecoration(
                                    labelText: "Address",
                                    labelStyle: TextStyle(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    child: RaisedButton(
                                      focusNode: nodeUpdateButton,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(18.0)),
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
                  child: milkmanListForDeletion == null
                      ? Container(
                          child: Center(
                            child: Text(
                              "No milkman available",
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
                                        duration:
                                            const Duration(milliseconds: 60),
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
                                                      color: Colors.blue),
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
                                                                  index]['id'],
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
                                                              FontWeight.bold),
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
                                    height: MediaQuery.of(context).size.height *
                                        0.65,
                                    child: AnimationLimiter(
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              milkmanListForDeletion.length,
                                          itemBuilder:
                                              (BuildContext ctx, int index) {
                                            return AnimationConfiguration
                                                .staggeredList(
                                              duration: const Duration(
                                                  milliseconds: 60),
                                              position: index,
                                              child: SlideAnimation(
                                                verticalOffset: 50.0,
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
                                                                        .blue),
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
                                                                    milkmanListForDeletion[
                                                                            index]
                                                                        ['id'],
                                                                    index);
                                                              });
                                                            },
                                                          ),
                                                          title: Text(
                                                            milkmanListForDeletion[
                                                                            index]
                                                                        [
                                                                        'name'] !=
                                                                    null
                                                                ? milkmanListForDeletion[
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
          );
  }
}
