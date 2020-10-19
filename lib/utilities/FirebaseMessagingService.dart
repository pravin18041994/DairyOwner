import 'dart:convert';

import 'package:dairy_app_owner/utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class FirebaseMessagingService extends StatefulWidget {
  var contact;
  FirebaseMessagingService(this.contact);
//  getToken() => createState().update();
  @override
  _FirebaseMessagingServiceState createState() =>
      _FirebaseMessagingServiceState();
}

class _FirebaseMessagingServiceState extends State<FirebaseMessagingService> {
  String textValue = 'Hello World !', fcmToken;
  String url;
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    url = Constants.base_url + 'admins/update_fcm_token';
    var android =
        new AndroidInitializationSettings('drawable/launch_background');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);
    print('inhere');
    firebaseMessaging.configure(
      // ignore: missing_return
      onLaunch: (Map<String, dynamic> msg) {
        print(" onLaunch called ${(msg)}");
      },
      // ignore: missing_return
      onResume: (Map<String, dynamic> msg) {
        print(" onResume called ${(msg)}");
      },
      // ignore: missing_return
      onMessage: (Map<String, dynamic> msg) {
        showNotification(msg);
        print(" onMessage called ${(msg)}");
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    firebaseMessaging.getToken().then((token) {
      fcmToken = token;
      getToken(widget.contact);
    });
  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
      'sdffds dsffds',
      "CHANNEL NAME",
      "channelDescription",
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, "This is title", "this is demo", platform);
  }

  getToken(contact) async {
    print(fcmToken);
    http.Response response =
        await http.post(url, body: {'contact': contact, 'fcm_token': fcmToken});
    print(response.body);
    if (json.decode(response.body)['state'] == 'success') {
      Navigator.of(context).pushNamed('/ownerdashboard');
    }

    // prefs=await SharedPreferences.getInstance();
    // prefs.setString("FCMToken", fcmToken);
  }

  // openDialog() {
  //   Dialog dialog = Dialog(
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
  //     child: Container(
  //       height: 100.0,
  //       width: 100.0,
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: <Widget>[
  //           CircularProgressIndicator(
  //             backgroundColor: Colors.blue,
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  //   showDialog(context: context, barrierDismissible: false, child: dialog);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}
