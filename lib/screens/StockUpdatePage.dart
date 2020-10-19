import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class StockUpdatePage extends StatefulWidget {
  var qty, productName, pid, delivered, left, lost, unit;
  StockUpdatePage(this.qty, this.productName, this.pid, this.delivered,
      this.left, this.lost, this.unit);

  @override
  State<StatefulWidget> createState() => StockUpdatePageState();
}

class StockUpdatePageState extends State<StockUpdatePage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;
  var isConnectionActive = true;
  var isLoading = true;
  TextEditingController deliveredController = TextEditingController();
  TextEditingController lostController = TextEditingController();
  TextEditingController leftController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var connectivityResult;
  var addStockUrl;
  FocusNode updateButtonNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // controller =
    //     AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    // scaleAnimation =
    //     CurvedAnimation(parent: controller, curve: Curves.easeInOutCirc);
    // controller.addListener(() {
    //   setState(() {});
    // });
    addStockUrl = Constants.base_url + 'stocks/add_stock_entry';

    // controller.forward();
    setState(() {
      deliveredController.text = widget.delivered;
      leftController.text = widget.left;
      lostController.text = widget.lost;
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

  Future<void> addStockDetails(
      qty, unit2, pid, delivered2, left2, lost2) async {
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

        var responseBody = response.body;
        var decodedResponse = jsonDecode(responseBody);

        if (decodedResponse['state'] == 'success') {
          setState(() {});
          FocusScope.of(context).requestFocus(updateButtonNode);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Updated  Successfully !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 3),
          ));
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              'Cannot Update !',
              style: TextStyle(fontFamily: 'Muli'),
            ),
            duration: Duration(seconds: 3),
          ));
          FocusScope.of(context).requestFocus(updateButtonNode);
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
        FocusScope.of(context).requestFocus(updateButtonNode);
      }
    } catch (e) {
      checkInternetConnection();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          widget.productName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.blue,
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                widget.productName,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                widget.qty.toString(),
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Container(
                  margin: EdgeInsets.only(left: 10),
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
                height: MediaQuery.of(context).size.height * 0.03,
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: deliveredController,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
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
                height: MediaQuery.of(context).size.height * 0.03,
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: lostController,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
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
                height: MediaQuery.of(context).size.height * 0.03,
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  controller: leftController,
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white))),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                    focusNode: updateButtonNode,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                    color: Colors.white,
                    elevation: 5.0,
                    child: Text(
                      "Update",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      addStockDetails(
                          0.toString(),
                          widget.unit.toString(),
                          widget.pid.toString(),
                          deliveredController.text,
                          leftController.text,
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
      ),
    );
  }
}
// SingleChildScrollView(
//       child: Material(
//         color: Colors.transparent,
//         child: ScaleTransition(
//           scale: scaleAnimation,
//           child: Center(
//               child: Container(
//             color: Colors.transparent,
//             child: Dialog(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15.0)),
//               child: Container(
//                 height: MediaQuery.of(context).size.height * 0.45,
//                 width: MediaQuery.of(context).size.width * 0.7,
//                 decoration: ShapeDecoration(
//                     color: Colors.blue,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15.0))),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: <Widget>[
//                     Center(
//                       child: Text(
//                         "Butter Milk",
//                         style: TextStyle(
//                             fontSize: 20.0,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),

//                   ],
//                 ),
//               ),
//             ),
//           )),
//         ),
//       ),
//     );
