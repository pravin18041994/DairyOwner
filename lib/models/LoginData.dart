import 'package:http/http.dart' as http;
import 'dart:convert';
class LoginData
{
  var contact;
  var password;

  LoginData({this.contact,this.password});

  factory LoginData.fromJson(Map<String,dynamic> json)
  {
    return LoginData(
      contact:json['contact'],
      password: json['password']
    );
  }
  Map toMap()
  {
    var map = new Map<String,dynamic>();
    map['contact'] = contact;
    map['password'] = password;
    return map;
  }
  Future<LoginData> checkLogin(var url,Map body) async {
    http.post(url, body: body).then((http.Response response) {
      final int statusCode = response.statusCode;
      print(statusCode);
      print(response.body.toString());
      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return LoginData.fromJson(json.decode(response.body));
    });
  }
}


