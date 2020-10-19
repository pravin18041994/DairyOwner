import 'package:barcode_scan/barcode_scan.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dairy_app_owner/screens/AreaWithUserPage.dart';
import 'package:dairy_app_owner/screens/DayWiseStockDetails.dart';
import 'package:dairy_app_owner/screens/FAQPage.dart';
import 'package:dairy_app_owner/screens/FatRate.dart';
import 'package:dairy_app_owner/screens/LoginButtons.dart';
import 'package:dairy_app_owner/screens/MilkDistributorPage.dart';
import 'package:dairy_app_owner/screens/OrderDetailsByUser.dart';
import 'package:dairy_app_owner/screens/PrivacyPolicy.dart';
import 'package:dairy_app_owner/screens/PuechaseSalesDetails.dart';
import 'package:dairy_app_owner/screens/Settings.dart';
import 'package:dairy_app_owner/screens/TermsAndConditions.dart';
import '../screens/OwnerProfilePage.dart';
import '../screens/ProductsDetailsPage.dart';
import '../screens/AreaDetailsPage.dart';
import '../screens/MilkManDetailsPage.dart';
import '../screens/StockMaster.dart';
import '../screens/UserDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ExtraItemPageOwner.dart';

import 'TransactionDetails.dart';

class OwnerDrawer extends StatefulWidget {
  @override
  _OwnerDrawer createState() => _OwnerDrawer();
}

class _OwnerDrawer extends State<OwnerDrawer> {
  String barcode;
  var storage;

  var connectivityResult;
  var isConnectionActive = true;

  @override
  void initState() {
    super.initState();
    storage = new FlutterSecureStorage();
    checkInternetConnection();
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
        : SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            child: Drawer(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: <Widget>[
                        new ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return OwnerProfilePage();
                            }));
                          },
                          title: new Text(
                            "Profile ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                        ),

                        new ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return UserDetailsPage();
                            }));
                          },
                          title: new Text(
                            "User Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                        ),
                        new ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return MilkmanDetailsPage();
                            }));
                          },
                          title: new Text(
                            "Milkman Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.perm_identity,
                            color: Colors.blue,
                          ),
                        ),

                        new ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return AreaDetailsPage();
                            }));
                          },
                          title: new Text(
                            "Area Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                          ),
                        ),
                        new ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return ExtraItemPageOwner();
                            }));
                          },
                          title: new Text(
                            "Extra Item Requests",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.vertical_align_bottom,
                            color: Colors.blue,
                          ),
                        ),
                        // new ListTile(
                        //   onTap: scan,
                        //   title: new Text(
                        //     "Maintain Stock",
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.blue,
                        //         fontSize: 15.0),
                        //   ),
                        //   leading: Icon(
                        //     Icons.store_mall_directory,
                        //     color: Colors.blue,
                        //   ),
                        // ),
                        new ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return ProductDetailsPage();
                            }));
                          },
                          title: new Text(
                            "Products",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.beach_access,
                            color: Colors.blue,
                          ),
                        ),
                        new ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return PurchaseSalesDetails();
                            }));
                          },
                          title: new Text(
                            "Purchase / Sales Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.touch_app,
                            color: Colors.blue,
                          ),
                        ),
                        new ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return TransactionDetailsOwner();
                            }));
                          },
                          title: new Text(
                            "Transaction Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.attach_money,
                            color: Colors.blue,
                          ),
                        ),
                        new ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return DayWiseStockDetails();
                            }));
                          },
                          title: new Text(
                            "Day Wise Stock Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.attach_money,
                            color: Colors.blue,
                          ),
                        ),
                        new ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return OrderDetailsByUSer();
                            }));
                          },
                          title: new Text(
                            "Order Details ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.touch_app,
                            color: Colors.blue,
                          ),
                        ),
                        new ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return AreaWithUserPage();
                            }));
                          },
                          title: new Text(
                            "Bill Details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.report,
                            color: Colors.blue,
                          ),
                        ),
                        //  ListTile(
                        //   onTap: () {
                        //     Navigator.pop(context);
                        //     Navigator.push(context,
                        //         MaterialPageRoute(builder: (_) {
                        //       return MilkDistributorpage();
                        //     }));
                        //   },
                        //   title: new Text(
                        //     "Milk Distributors",
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.blue,
                        //         fontSize: 15.0),
                        //   ),
                        //   leading: Icon(
                        //     Icons.person,
                        //     color: Colors.blue,
                        //   ),
                        // ),
                        //   ListTile(
                        //   onTap: () {
                        //     Navigator.pop(context);
                        //     Navigator.push(context,
                        //         MaterialPageRoute(builder: (_) {
                        //       return FatRate();
                        //     }));
                        //   },
                        //   title: new Text(
                        //     "Fat Rate",
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         color: Colors.blue,
                        //         fontSize: 15.0),
                        //   ),
                        //   leading: Icon(
                        //     Icons.person,
                        //     color: Colors.blue,
                        //   ),
                        // ),

                        ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return Settings();
                            }));
                          },
                          title: new Text(
                            "Settings",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                        ),
                        new ListTile(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return FAQPage();
                            }));
                          },
                          title: new Text(
                            "FAQ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.question_answer,
                            color: Colors.blue,
                          ),
                        ),
                        new ListTile(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return PrivacyPolicy();
                            }));
                          },
                          title: new Text(
                            "Privacy Policy",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.device_hub,
                            color: Colors.blue,
                          ),
                        ),
                        new ListTile(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return TermsAndCondition();
                            }));
                          },
                          title: new Text(
                            "Terms & Conditions",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.terrain,
                            color: Colors.blue,
                          ),
                        ),
                        new ListTile(
                          onTap: () async {
                            await storage.delete(key: "token");
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return LoginButtons();
                            }));
                          },
                          title: new Text(
                            "Logout",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 15.0),
                          ),
                          leading: Icon(
                            Icons.clear,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            child: Center(
                              child: Text(
                                'Version : 1.0.0',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    fontSize: 15.0),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Future scan() async {
    Navigator.pop(context);
    String barcode = await BarcodeScanner.scan();

    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return StockMaster();
    }));
    setState(() {
      this.barcode = barcode;
      print(this.barcode);
    });
  }
}
