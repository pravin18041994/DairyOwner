import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/database/DatabaseOperations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utilities/Constants.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TabBarViewAreas extends StatefulWidget {
  @override
  _TabBarViewAreas createState() => _TabBarViewAreas();
}

class _TabBarViewAreas extends State<TabBarViewAreas> {
  var isSearching = false;
  List searchResult = [];
  List duplicateAreas = [];
  var isSearchingForDeletion = false;
  List searchResultForDeletion = [];
  List duplicateAreasForDeletion = [];
  String dropdownValueAdd1;
  String dropdownValueUpdate;
  var addUrl;
  var dropdownValueUpdateMIlkman;
  var dropdownValueUpdateUser;
  var area_id_update;
  final _addFormKey = GlobalKey<FormState>();
  final _updateFormKey = GlobalKey<FormState>();
  List<String> areaNames;
  var token;
  var updateUrl;
  var errorFirstName = false;
  var errorLastName = false;
  var errorMobileNumber = false;
  var isLoading = true;
  var milkmanid_add;
  var errorAddress = false;
  var storage;
  List areaList;
  List userList;

  final FocusNode nodeAreaName = FocusNode();
  final FocusNode nodeMilkmanDropdown = FocusNode();
  final FocusNode nodeAddButton = FocusNode();
  final FocusNode nodeUpdateButton = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List listIcon;

  List userListUpdate;
  var users;
  var deleteUrl;
  var getAreaUrl;
  TextEditingController searchController = TextEditingController();
  TextEditingController searchDeleteController = TextEditingController();
  List milkmenNames2;
  List<String> milkmenNames;
  TextEditingController areaNameAddController = new TextEditingController();

  //  Update Controllers
  TextEditingController areaNameUpdateController = new TextEditingController();

  var getMilkmenUrl;
  var milkmanList;
  var deleteListForConfirmation;
  var getUserUrl;
  List<String> userListName;
  var connectivityResult;
  var isConnectionActive = true;

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  var decodedResponse;
  DatabaseOperations databaseOperations;

  @override
  void initState() {
    // TODO: implement initState

    milkmenNames = [];
    areaNames = [];
    milkmenNames2 = [];
    userListName = [];
    userList = [];
    userListUpdate = [];
    deleteListForConfirmation = [];
    addUrl = Constants.base_url + "areas/add_area";
    updateUrl = Constants.base_url + "areas/update_area";
    users = [];
    deleteUrl = Constants.base_url + "areas/delete_area";
    getAreaUrl = Constants.base_url + "areas/get_areas_user";
    getMilkmenUrl =
        Constants.base_url + "/milkmen/get_all_milkmen_with_dairy_details";
    getUserUrl = Constants.base_url + "users/get_all_users";
    listIcon = [];
    super.initState();
    checkInternetConnection();

    //   final storage = new FlutterSecureStorage();
    getAreas();
    getMilkmen();
    getUser();
  }

  void filterSearchResults(String query) async {
    print("in search");

    if (query.isNotEmpty) {
      setState(() {
        searchResult.clear();
        isSearching = true;
      });
      print(duplicateAreas);
      duplicateAreas.forEach((item) {
        print(item['area_name']);
        if (item['area_name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase())) {
          setState(() {
            searchResult.add(item);
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

      duplicateAreasForDeletion.forEach((item) {
        print(item['name']);
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

  void deleteAreas(id, index) async {
    try {
      openDialog();
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http.post(deleteUrl, body: {
        'id': id,
      }, headers: {
        'Authorization': 'Bearer' + ' ' + token,
        "Accept": "application/json"
      });
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        if (decodedResponse['state'] == 'success') {
          setState(() {
            deleteListForConfirmation.removeAt(index);
            areaNames.removeAt(index);
            areaList.removeAt(index);
          });
          Navigator.pop(context);
          Navigator.pop(context);
          int len = await databaseOperations.updateAreaData(
              json.encode(decodedResponse['data']), "areas");
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
      Navigator.pop(context);
      checkInternetConnection();
    }
  }

  void callUser(contactno) async {
    var url = "tel:+91 " + contactno;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
                        deleteAreas(id, index);
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

  Future<void> getMilkmen() async {
    try {
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      print("token");
      print(token);
      http.Response response = await http.get(getMilkmenUrl, headers: {
        'Authorization': 'Bearer' + ' ' + token,
        "Accept": "application/json"
      });
      print(response.body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        setState(() {
          milkmanList = decodedResponse['milkmen'];
          for (var i in milkmanList) {
            var obj = {
              'id': i['_id'],
              'name': i['name'],
              'contact': i['contact']
            };
            milkmenNames2.add(json.encode(obj));
            milkmenNames.add(json.encode(obj));
          }
          print(milkmanList.length);
        });
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<void> getUser() async {
    try {
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      print("token");
      print(token);
      http.Response response = await http.get(getUserUrl, headers: {
        'Authorization': 'Bearer' + ' ' + token,
        "Accept": "application/json"
      });
      print("users" + response.body.toString());
      if (response.statusCode == 200) {
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);

        setState(() {
          userList = decodedResponse['data'];
          for (var jj in userList) {
            userListName.add(jj['name']);
          }
        });
      } else {}
    } catch (e) {
      checkInternetConnection();
    }
  }

  Future<void> getAreas() async {
    try {
      areaList = [];
      areaNames = [];
      deleteListForConfirmation = [];

      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      print("token");
      print(token);

      databaseOperations = DatabaseOperations();
      int len = await databaseOperations.checkAreas("areas");
      if (len == 0) {
        http.Response response = await http.get(getAreaUrl, headers: {
          'Authorization': 'Bearer' + ' ' + token,
          "Accept": "application/json"
        });
        print(response.body);
        if (response.statusCode == 200) {
          var responseBody = response.body;
          decodedResponse = jsonDecode(responseBody);
          setState(() {
            isLoading = false;
            areaList = decodedResponse['data'];
            duplicateAreas = decodedResponse['data'];

            for (var kk in areaList) {
              listIcon.add(Icons.arrow_downward);
              areaNames.add(kk['area_name']);
              print(kk['area_name']);
              var obj = {'id': kk['_id'], 'name': kk['area_name']};
              deleteListForConfirmation.add(obj);
              duplicateAreasForDeletion.add(obj);
              users.add(kk['users']);
            }
            print(areaList.length);
            print("DUPLICATE AREAS" + duplicateAreasForDeletion.toString());
          });
        } else {}
        databaseOperations.insertAres(
            json.encode(decodedResponse['data']), "areas");
      } else {
        print("inhere");
        List<Map> list = [];
        list = await databaseOperations.getAreas();
        print(list[0]);
        List ss = list.toList();
        var qq = json.decode(ss[0]['data']);
        setState(() {
          areaList = qq;
          duplicateAreas = qq;

          isLoading = false;
          // areaList = decodedResponse['data'];
          for (var kk in areaList) {
            listIcon.add(Icons.arrow_downward);
            areaNames.add(kk['area_name']);
            print(kk['area_name']);
            var obj = {'id': kk['_id'], 'name': kk['area_name']};
            deleteListForConfirmation.add(obj);
            duplicateAreasForDeletion.add(obj);
            users.add(kk['users']);
          }
          print(areaList.length);
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
        if (areaNameAddController.text == "") {
          this.errorFirstName = true;
          return;
        }
      });

      http.Response response = await http.post(addUrl, body: {
        'area_name': capitalize(areaNameAddController.text.trim()),
        'milkman_id': milkmanid_add,
      }, headers: {
        'Authorization': "Bearer " + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context); //this statement closes the dialog
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse['state'] == 'success') {
          FocusScope.of(context).requestFocus(nodeAddButton);
          getAreas();
          areaNameAddController.clear();
          dropdownValueAdd1 = null;
          int len = await databaseOperations.updateAreaData(
              json.encode(decodedResponse['data']), "areas");
          final snackBar = SnackBar(
              content: Text(
            "Added Successfully !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
        } else {
          dropdownValueAdd1 = null;
          FocusScope.of(context).requestFocus(nodeAddButton);

          areaNameAddController.clear();
          final snackBar = SnackBar(
              content: Text(
            "Already Exists !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
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
      final storage = new FlutterSecureStorage();
      token = await storage.read(key: 'token');
      setState(() {
        if (areaNameUpdateController.text == "") {
          this.errorFirstName = true;
          return;
        }
      });

      var milkmn_id;
      for (var m in milkmanList) {
        if (m['_id'] == dropdownValueUpdateMIlkman) {
          milkmn_id = m['_id'];
        }
      }
      var users_arr = [];
      for (var uu in userList) {
        for (var kk in userListUpdate) {
          if (uu['name'] == kk) {
            users_arr.add({'id': uu['_id']});
          }
        }
      }
      var final_users_arr = json.encode(users_arr);
      print(area_id_update);
      http.Response response = await http.post(updateUrl, body: {
        'area_name': areaNameUpdateController.text.trim(),
        'milkman_id': milkmn_id,
        'users': final_users_arr,
        'id': area_id_update
      }, headers: {
        "Authorization": "Bearer " + token,
        "Accept": "application/json"
      });
      print(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context); //this statement closes the dialog
        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);
        if (decodedResponse['state'] == 'success') {
          FocusScope.of(context).requestFocus(nodeUpdateButton);

          setState(() {
            dropdownValueUpdate = null;
            areaNameUpdateController.clear();
            dropdownValueUpdateMIlkman = null;
            dropdownValueUpdateUser = null;
          });

          int len = await databaseOperations.updateAreaData(
              json.encode(decodedResponse['data']), "areas");

          final snackBar = SnackBar(
              content: Text(
            "Updated Successfully !",
            style: TextStyle(fontFamily: 'Muli'),
          ));
          Scaffold.of(context).showSnackBar(snackBar);
        } else {
          FocusScope.of(context).requestFocus(nodeUpdateButton);
          Navigator.pop(context);
          final snackbar = SnackBar(
              content: Text(
            "Please try again later !",
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

  Future<Null> getRefresh() async {
    try {
      getAreas();
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      checkInternetConnection();
    }
  }

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
        : TabBarView(
            children: <Widget>[
              isLoading == true
                  ? Center(
                      child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ))
                  : areaList.length == 0
                      ? Center(
                          child: Text(
                            "No Data Found",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
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
                                    itemBuilder: (BuildContext ctx, int index) {
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
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0)),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  ExpansionTile(
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
                                                          ['area_name'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    children: <Widget>[
                                                      Divider(
                                                        color: Colors.white,
                                                      ),
                                                      Container(
                                                          child: searchResult[index]
                                                                          [
                                                                          'users']
                                                                      .length ==
                                                                  0
                                                              ? ListTile(
                                                                  title: Text(
                                                                    "No users assigned yet !",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                )
                                                              : new ListView
                                                                      .builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount: searchResult[
                                                                              index]
                                                                          [
                                                                          'users']
                                                                      .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              ctx,
                                                                          int index2) {
                                                                    return ListTile(
                                                                      leading:
                                                                          IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          callUser(searchResult[index]['users'][index2]
                                                                              [
                                                                              'contactno']);
                                                                        },
                                                                        icon: Icon(
                                                                            Icons.call),
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      title:
                                                                          Text(
                                                                        searchResult[index]['users'][index2]
                                                                            [
                                                                            'name'],
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    );
                                                                  }))
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : RefreshIndicator(
                                    onRefresh: getRefresh,
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.65,
                                      child: AnimationLimiter(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: areaList.length,
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
                                                    margin: EdgeInsets.fromLTRB(
                                                        10.0, 10.0, 10.0, 10.0),
                                                    shape:
                                                        RoundedRectangleBorder(
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
                                                            color: Colors.white,
                                                          ),
                                                          title: Text(
                                                            areaList[index]
                                                                ['area_name'],
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          children: <Widget>[
                                                            Divider(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            Container(
                                                                child: areaList[index]['users']
                                                                            .length ==
                                                                        0
                                                                    ? ListTile(
                                                                        title:
                                                                            Text(
                                                                          "No users assigned yet !",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      )
                                                                    : new ListView
                                                                            .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        itemCount:
                                                                            areaList[index]['users']
                                                                                .length,
                                                                        itemBuilder:
                                                                            (BuildContext ctx,
                                                                                int index2) {
                                                                          return ListTile(
                                                                            leading:
                                                                                IconButton(
                                                                              onPressed: () {
                                                                                callUser(areaList[index]['users'][index2]['contactno']);
                                                                              },
                                                                              icon: Icon(Icons.call),
                                                                              color: Colors.white,
                                                                            ),
                                                                            title:
                                                                                Text(
                                                                              areaList[index]['users'][index2]['name'],
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                            ),
                                                                          );
                                                                        }))
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
                                    ),
                                  ),
                          ],
                        ),

              //Add
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
                                  cursorColor: Colors.white,
                                  style: TextStyle(color: Colors.white),
                                  focusNode: nodeAreaName,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please Enter Area Name';
                                    }
                                    return null;
                                  },
                                  controller: areaNameAddController,
                                  keyboardType: TextInputType.streetAddress,
                                  decoration: InputDecoration(
                                    labelText: "Area Name",
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
                                title: DropdownButton<String>(
                                  dropdownColor: Colors.blue,
                                  focusNode: nodeMilkmanDropdown,
                                  value: dropdownValueAdd1,
                                  icon: Icon(
                                    Icons.arrow_downward,
                                    color: Colors.white,
                                  ),
                                  iconSize: 0.0,
                                  elevation: 16,
                                  hint: Text(
                                    "Select Milkman",
                                    style: TextStyle(
                                        fontFamily: 'Muli',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.0),
                                  ),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  underline: Container(
                                    height: 2,
                                    color: Colors.white,
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      dropdownValueAdd1 = newValue;
                                      print(newValue);
                                      for (var m in milkmanList) {
                                        if (m['_id'] == newValue) {
                                          milkmanid_add = m['_id'];
                                          print(m['_id']);
                                        }
                                      }
                                    });
                                  },
                                  items: milkmenNames
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: json.decode(value)['id'],
                                      child: Text(
                                        json.decode(value)['name'] +
                                            " ( " +
                                            json
                                                .decode(value)['contact']
                                                .toString() +
                                            " ) ",
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Colors.white,
                                            fontFamily: 'Muli',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15.0),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(18.0)),
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
                      ],
                    ),
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
                          margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: ListView(
                                  shrinkWrap: true,
                                  children: <Widget>[
                                    ListTile(
                                      title: DropdownButton<String>(
                                        dropdownColor: Colors.blue,
                                        value: dropdownValueUpdate,
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
                                            userListUpdate.clear();
                                            dropdownValueUpdate = newValue;
                                            for (var i in areaList) {
                                              if (newValue == i['area_name']) {
                                                setState(() {
                                                  area_id_update = i['_id'];
                                                  areaNameUpdateController
                                                      .text = newValue;
                                                  dropdownValueUpdateMIlkman =
                                                      i['milkman_id']['_id'] !=
                                                              null
                                                          ? i['milkman_id']
                                                              ['_id']
                                                          : '';
                                                  for (var u in i['users']) {
                                                    print(u);

                                                    userListUpdate
                                                        .add(u['name']);
                                                  }
                                                });
                                              }
                                            }
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
                                                  decoration:
                                                      TextDecoration.none,
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
                                        cursorColor: Colors.white,
                                        style: TextStyle(color: Colors.white),
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        controller: areaNameUpdateController,
                                        decoration: InputDecoration(
                                          labelText: " Name",
                                          labelStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white)),
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white)),
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: DropdownButton<String>(
                                        dropdownColor: Colors.blue,
                                        value: dropdownValueUpdateMIlkman,
                                        icon: Icon(
                                          Icons.arrow_downward,
                                          color: Colors.white,
                                        ),
                                        iconSize: 0.0,
                                        elevation: 16,
                                        hint: Text(
                                          "Select Milkmans",
                                          style: TextStyle(
                                              decoration: TextDecoration.none,
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
                                            dropdownValueUpdateMIlkman =
                                                newValue;
                                          });
                                        },
                                        items: milkmenNames2
                                            .map<DropdownMenuItem<String>>(
                                                (var value2) {
                                          return DropdownMenuItem<String>(
                                            value: json.decode(value2)['id'],
                                            child: Text(
                                              json.decode(value2)['name'] +
                                                  " ( " +
                                                  json.decode(
                                                      value2)['contact'] +
                                                  " ) ",
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.none,
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
                                      title: DropdownButton<String>(
                                        dropdownColor: Colors.blue,
                                        value: dropdownValueUpdateUser,
                                        icon: Icon(
                                          Icons.arrow_downward,
                                          color: Colors.white,
                                        ),
                                        iconSize: 0.0,
                                        elevation: 16,
                                        hint: Text(
                                          "Select Users",
                                          style: TextStyle(
                                              fontFamily: 'Muli',
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0),
                                        ),
                                        style: TextStyle(color: Colors.white),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.white,
                                        ),
                                        onChanged: (String newValue) {
                                          setState(() {
                                            dropdownValueUpdateUser = newValue;
                                            print(newValue);
                                            for (var i in userListUpdate) {
                                              if (i == newValue) {
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
                                            for (var us in userList) {
                                              if (us['name'] == newValue) {
                                                userListUpdate.add(us['name']);
                                              }
                                            }
                                            dropdownValueUpdateUser = null;
                                          });
                                        },
                                        items: userListName
                                            .map<DropdownMenuItem<String>>(
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
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15.0),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    Divider(
                                      thickness: 3.0,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          "Users",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      thickness: 3.0,
                                      color: Colors.white,
                                    ),
                                    Container(
                                        child: userListUpdate == null
                                            ? Container()
                                            : Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.15,
                                                child: new ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        userListUpdate.length,
                                                    itemBuilder:
                                                        (BuildContext ctx,
                                                            int index) {
                                                      return Card(
                                                        color: Colors.blue,
                                                        margin: EdgeInsets.all(
                                                            10.0),
                                                        shape: RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: Colors
                                                                    .white),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5.0)),
                                                        child: Container(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              ListTile(
                                                                title: Text(
                                                                  userListUpdate[
                                                                              index] !=
                                                                          null
                                                                      ? userListUpdate[
                                                                          index]
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
                                                      );
                                                    }),
                                              )),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    child: RaisedButton(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side:
                                              BorderSide(color: Colors.white)),
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
                  child: deleteListForConfirmation == null
                      ? Container(
                          child: Center(
                            child: Text(
                              "No areas available",
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
                                      child: new ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              deleteListForConfirmation.length,
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
                                                    margin: EdgeInsets.fromLTRB(
                                                        10.0, 10.0, 10.0, 10.0),
                                                    shape:
                                                        RoundedRectangleBorder(
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
                                                                    deleteListForConfirmation[
                                                                            index]
                                                                        ['id'],
                                                                    index);
                                                              });
                                                            },
                                                          ),
                                                          title: Text(
                                                            deleteListForConfirmation[
                                                                            index]
                                                                        [
                                                                        'name'] !=
                                                                    null
                                                                ? deleteListForConfirmation[
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
