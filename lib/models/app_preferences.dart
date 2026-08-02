import 'dart:convert';

import 'package:app/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const USER = "user";
  setUser(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(USER, jsonEncode(UserModel(roles: []).toJson(user)));
  }

  Future<UserModel> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userString = prefs.getString(USER) ?? null;

    if (userString != null && userString != "") {
      var tmp = UserModel.fromJson(jsonDecode(userString));
      return tmp;
    } else {
      return UserModel(roles: []);
    }
  }

  setAcceptToBid(String accept) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ACCEPT_TO_BID", accept);
  }

  Future<bool> getAcceptToBid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var acceptString = prefs.getString("ACCEPT_TO_BID") ?? null;
    if (acceptString != null && acceptString != "") {
      var tmp = (acceptString == "true") ? true : false;
      return tmp;
    } else {
      return false;
    }
  }
}
