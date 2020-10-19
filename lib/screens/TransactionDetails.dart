import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/database/DatabaseOperations.dart';
import 'package:dairy_app_owner/screens/PastTransactionOwner.dart';
import 'package:dairy_app_owner/screens/SendMessageOwnerPage.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

class TransactionDetailsOwner extends StatefulWidget {
  @override
  _TransactionDetailsOwnerState createState() =>
      _TransactionDetailsOwnerState();
}

class _TransactionDetailsOwnerState extends State<TransactionDetailsOwner> {
  TextEditingController dateController = new TextEditingController();
  var connectivityResult;
  var isConnectionActive = true;

  var getTransactionUrl;
  FlutterSecureStorage storage;
  var token;
  var selectedDate;
  List transactionDetails;
  var getMilkmenUrl;
  DatabaseOperations databaseOperations;
  var isLoading = true;
  List milkmanList;
  var decRes;
  List<String> choice;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    transactionDetails = [];
    milkmanList = [];
    getMilkmenUrl =
        Constants.base_url + "/milkmen/get_all_milkmen_with_dairy_details";
    storage = new FlutterSecureStorage();
    choice = ["send message"];

    // getTransactionUrl = Constants.base_url +
    //     'transactions/get_all_transactions_with_all_details';
    // getTransactionDetails();
    checkInternetConnection();
    getMilkmen();
  }

  Future<void> getMilkmen() async {
    try {
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
          decRes = json.decode(response.body);

          setState(() {
            isLoading = false;
            milkmanList = decRes['milkmen'];
          });
        } else {}

        databaseOperations.insertMilkman(
            json.encode(decRes['milkmen']), "milkman");
      } else {
        print("inhere");
        List<Map> list = [];
        list = await databaseOperations.getMilkman();
        print(list[0]);
        List ss = list.toList();
        var qq = json.decode(ss[0]['data']);
        setState(() {
          milkmanList = qq;
          isLoading = false;
        });
      }
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

  // Future<void> getTransactionDetails() async {
  //   token = await storage.read(key: 'token');
  //   http.Response response = await http
  //       .get(getTransactionUrl, headers: {"Authorization": 'Bearer ' + token});
  //   print(response.body);

  //   var decodedResponse = json.decode(response.body);

  //   if (response.statusCode == 200) {
  //     setState(() {
  //       transactionDetails = decodedResponse['data'];
  //     });
  //   } else {}
  // }

  Future<Null> showDateTimePicker(BuildContext context2) async {
    DateTime d = await showDatePicker(
      context: context2,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if (d != null && d != selectedDate) {
      setState(() {
        print(d);
        var finalDate = d.toLocal().toString().split(' ');
        dateController.text = finalDate[0];
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
              centerTitle: true,
              actions: [
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == "send message") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SendMessageOwnerPage()));
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return choice.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(
                          choice,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
              title: Text(
                "Transaction Details",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Muli'),
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
            ),
            body: isLoading == true
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: RefreshIndicator(
                      onRefresh: getRefresh,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AnimationLimiter(
                          child: new ListView.builder(
                              shrinkWrap: true,
                              itemCount: milkmanList.length,
                              itemBuilder: (BuildContext ctx, int index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 600),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: Card(
                                        color: Colors.blue,
                                        margin: EdgeInsets.all(10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            ListTile(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            PastTransactionOwner(
                                                                milkmanList[
                                                                        index]
                                                                    ['_id'])));
                                              },
                                              title: Text(
                                                milkmanList[index]['name'],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
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
                    ),
                  ));
  }
}
