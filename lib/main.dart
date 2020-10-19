import 'package:dairy_app_owner/screens/MilkmanDashboard.dart';
import 'package:dairy_app_owner/screens/OwnerDashboard.dart';
import 'package:dairy_app_owner/screens/UserDetailsPage.dart';
import 'package:dairy_app_owner/utilities/AppTranslationsDelegate.dart';
import 'package:dairy_app_owner/utilities/Application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import './screens/MilkmanLogin.dart';
import './screens/Splashscreen.dart';
import './screens/OwnerLogin.dart';
import './screens/OwnerDashboard.dart';
import './screens/WalkthroughPage2.dart';
import './screens/WalkthroughPage3.dart';
import './screens/MilkmanDashboard.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppTranslationsDelegate _newLocaleDelegate;

  @override
  void initState() {
    super.initState();
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: null);
    application.onLocaleChanged = onLocaleChange;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      localizationsDelegates: [
        _newLocaleDelegate,
        //provides localised strings
        GlobalMaterialLocalizations.delegate,
        //provides RTL support
        GlobalWidgetsLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Muli',
      ),
      title: "Login form",
      supportedLocales: [
        const Locale("en", ""),
        const Locale("mr", ""),
      ],
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => OwnerLogin(),
        '/milkmanlogin': (BuildContext context) => MilkManLogin(),
        '/ownerdashboard': (BuildContext context) => OwnerDashboard(),
        '/WalkthroughPage2': (BuildContext context) => WalkthroughPage2(),
        '/WalkthroughPage3': (BuildContext context) => WalkthroughPage3(),
        '/MilkmanDashboard': (BuildContext context) => MilkmanDashboard(),
      },
      home: new SplashScreen(),
    );
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }
}

void main() {  
  runApp(MyApp());
}
