import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/BillDetails.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AreaWithUserPage extends StatefulWidget {
  @override
  _AreaWithUserPageState createState() => _AreaWithUserPageState();
}

class _AreaWithUserPageState extends State<AreaWithUserPage> {
  var getUserUrl;
  var getAreaUrl;
  List userListName;
  List userList;
  List areaList;
  var areaNames;
  List users;
  List icon;
  var connectivityResult;
  var isConnectionActive = true;

  @override
  void initState() {
    // TODO: implement initState

    userListName = [];
    userList = [];
    areaList = [];
    users = [];
    areaNames = [];
    icon = [];

    getAreaUrl = Constants.base_url + "areas/get_areas_user";
    // getUserUrl = Constants.base_url + "users/get_all_users";
    super.initState();
    checkInternetConnection();
    getAreas();
  }

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        isConnectionActive = true;
        print('inhere');
        getAreas();
      } else {
        isConnectionActive = false;
      }
    });
  }

  Future<void> getAreas() async {
    try {
      final storage = new FlutterSecureStorage();
      var token = await storage.read(key: 'token');
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
            icon.add(Icons.arrow_downward);
            areaNames.add(kk['area_name']);
            print(kk['area_name']);

            users.add(kk['users']);
          }
          print(areaList.length);
        });
      } else {}
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
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              elevation: 0.0,
              centerTitle: true,
              title: Text(
                "Areas With Users",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
            ),
            body: areaList.length == 0
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: areaList.length,
                    itemBuilder: (BuildContext ctx, int index) {
                      return Card(
                        color: Colors.blue,
                        margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            ExpansionTile(
                              onExpansionChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    icon[index] = Icons.arrow_upward;
                                  } else {
                                    icon[index] = Icons.arrow_downward;
                                  }
                                });
                              },
                              backgroundColor: Colors.blue,
                              trailing: Icon(
                                icon[index],
                                color: Colors.white,
                              ),
                              title: Text(
                                areaList[index]['area_name'],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              children: <Widget>[
                                Divider(
                                  color: Colors.white,
                                  thickness: 2.0,
                                ),
                                Container(
                                    child: users == null
                                        ? Container()
                                        : areaList[index]['users'].length == 0
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "No Users !",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                              )
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: areaList[index]
                                                        ['users']
                                                    .length,
                                                itemBuilder: (BuildContext ctx,
                                                    int index2) {
                                                  return ListTile(
                                                    onTap: () {
                                                      checkInternetConnection();
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder: (_) {
                                                        return BillDetails(
                                                            areaList[index]
                                                                    ['users']
                                                                [index2]['_id'],
                                                            areaList[index]
                                                                        [
                                                                        'users']
                                                                    [index2]
                                                                ['name']);
                                                      }));
                                                    },
                                                    leading: Icon(
                                                      Icons.mobile_screen_share,
                                                      color: Colors.white,
                                                    ),
                                                    title: Text(
                                                      areaList[index]['users']
                                                          [index2]['name'],
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  );
                                                })),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          );
  }
}
