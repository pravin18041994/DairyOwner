import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/database/DatabaseOperations.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  List messageList;
  var storage;
  var token;
  var getMessageUrl;
  var isLoading = true;
  var deleteMessageUrl;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var connectivityResult;
  var isConnectionActive = true;
  var decodedResponse;
  DatabaseOperations databaseOperations;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getMessageUrl = Constants.base_url + 'messages/get_messages';
    deleteMessageUrl = Constants.base_url + 'messages/delete_message';
    messageList = [];
    checkInternetConnection();
    getMessages();
  }

  callUser(var contact) async {
    var url = 'tel:+91 ' + contact;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> deleteMessage(var id, var index) async {
    try {
      openDialog();

      storage = FlutterSecureStorage();
      token = await storage.read(key: 'token');
      http.Response response = await http.post(deleteMessageUrl,
          body: {'id': id}, headers: {"Authorization": 'Bearer ' + token});
      print(response.body);
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        if (decodedResponse['state'] == 'success') {
          Navigator.pop(context);
          Navigator.pop(context);
          setState(() {
            messageList.removeAt(index);
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Deleted Successfully !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 2),
          ));
        } else {
          Navigator.pop(context);
          Navigator.pop(context);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Please Try Again Later !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 2),
          ));
        }
      } else {}
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

  Future<void> getMessages() async {
    try {
      storage = FlutterSecureStorage();
      token = await storage.read(key: 'token');

      // databaseOperations = DatabaseOperations();
      // int len = await databaseOperations.checkMessagesPresent("messages");
      // if (len == 0) {
      http.Response response = await http
          .get(getMessageUrl, headers: {"Authorization": 'Bearer ' + token});
      print(response.body);
      if (response.statusCode == 200) {
        decodedResponse = json.decode(response.body);
        if (decodedResponse['state'] == 'success') {
          messageList = decodedResponse['data'];
          setState(() {
            isLoading = false;
          });
        } else {}
      } else {}
      // databaseOperations.insertMessages(
      //     json.encode(decodedResponse['data']), "messages");
      // } else {
      //   List<Map> list = [];
      //   list = await databaseOperations.getMessages();
      //   setState(() {
      //     isLoading = false;
      //     print(list[0]);
      //     List ss = list.toList();
      //     var qq = json.decode(ss[0]['data']);
      //     print(qq);
      //     messageList = qq;
      //   });
      // }
    } catch (e) {
      checkInternetConnection();
    }
  }

  void dialogBoxConfirmation(var id, var index) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
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
                        "Yes",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        deleteMessage(id, index);
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

  checkInternetConnection() async {
    connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        isConnectionActive = true;
        // getMessages();
      } else {
        isConnectionActive = false;
      }
    });
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
              elevation: 0.0,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.blue),
              centerTitle: true,
              title: Text(
                "Messages",
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Muli"),
              ),
            ),
            body: isLoading == true
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ),
                  )
                : messageList.length == 0
                    ? Center(
                        child: Text(
                        "No Messages",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold),
                      ))
                    : ListView.builder(
                        itemCount: messageList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 5.0, right: 5.0),
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12.0),
                                    border: Border.all(color: Colors.black)),
                                child: ExpansionTile(
                                    leading: IconButton(
                                        icon: Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          checkInternetConnection();
                                          callUser(messageList[index]['user']
                                                  ['contactno']
                                              .toString());
                                        }),
                                    trailing: IconButton(
                                        icon: Icon(
                                          Icons.delete_forever,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          dialogBoxConfirmation(
                                              messageList[index]['_id'], index);
                                        }),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    'Sub :  ' +
                                                        messageList[index]
                                                            ['subject'],
                                                    style: TextStyle(
                                                        fontFamily: 'Muli',
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color: Colors.white,
                                              thickness: 2.0,
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                      'Message :  ' +
                                                          messageList[index]
                                                              ['message'],
                                                      style: TextStyle(
                                                          fontFamily: 'Muli',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                    title: Chip(
                                        avatar: CircleAvatar(
                                          backgroundColor: Colors.grey.shade800,
                                          child: Text(
                                            messageList[index]['user']['name']
                                                    .toString()
                                                    .split(' ')[0][0] +
                                                messageList[index]['user']
                                                        ['name']
                                                    .toString()
                                                    .split(' ')[1][0],
                                          ),
                                        ),
                                        label: Text(
                                          messageList[index]['user']['name'],
                                          style: TextStyle(fontSize: 12.0),
                                        ))),
                              ),
                              SizedBox(
                                height: 10.0,
                              )
                            ],
                          );
                        }));
  }
}
