import 'package:app/models/advert.dart';
import 'package:app/models/app_preferences.dart';
import 'package:app/models/notification.dart';
import 'package:app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppProvider with ChangeNotifier {
  UserModel _user = UserModel(roles: []);
  List<AdvertModel> _adverts = [];
  List<AdvertModel> _myAdverts = [];
  List<AdvertModel> _favoriteAdverts = [];
  List<AdvertModel> _advertsPendingAccept = [];
  List<AdvertModel> _advertsInProgress = [];
  List<AdvertModel> _advertsPendingQualification = [];
  List<NotificationModel> _notifications = [];
  num _notificationsUnread = 0;
  dynamic _showingNotification = null;
  dynamic _config = null;

  UserModel get user => _user;
  List<AdvertModel> get myAdverts => _myAdverts;
  List<AdvertModel> get favoriteAdverts => _favoriteAdverts;
  List<AdvertModel> get adverts => _adverts;
  List<AdvertModel> get advertsPendingAccept => _advertsPendingAccept;
  List<AdvertModel> get advertsInProgress => _advertsInProgress;
  List<AdvertModel> get advertsPendingQualification =>
      _advertsPendingQualification;
  List<NotificationModel> get notifications => _notifications;
  num get notificationsUnread => _notificationsUnread;
  dynamic get showingNotification => _showingNotification;
  dynamic get config => _config;

  double _lat = 40.411179;
  double _long = -3.701137;
  dynamic _fromIconPin = null;
  double get lat => _lat;
  double get long => _long;
  BitmapDescriptor get getFromIconPin => _fromIconPin;

  setConfig(dynamic config) {
    _config = config;
    notifyListeners();
  }

  setShowingNotification(dynamic notification) {
    _showingNotification = notification;
    notifyListeners();
  }

  setLocation(double lat, double long) {
    _lat = lat;
    _long = long;
    notifyListeners();
  }

  setNotificationsUnread(num unerad) {
    _notificationsUnread = unerad;
    notifyListeners();
  }

  setFromIconPin(BitmapDescriptor fromIconPin) {
    _fromIconPin = fromIconPin;
    notifyListeners();
  }

  setUser(UserModel user) async {
  
    _user = user;
    await AppPreferences().setUser(user);
    notifyListeners();
  }

  setAdverts(List<AdvertModel> adverts) async {
    _adverts = adverts;
    notifyListeners();
  }

  setMyAdverts(List<AdvertModel> adverts) async {
    _myAdverts = adverts;
    notifyListeners();
  }

  setFavoriteAdverts(List<AdvertModel> adverts) async {
    _favoriteAdverts = adverts;
    notifyListeners();
  }

  setAdvertsPendingAccept(List<AdvertModel> adverts) async {
    _advertsPendingAccept = adverts;
    notifyListeners();
  }

  setAdvertsInProgress(List<AdvertModel> adverts) async {
    _advertsInProgress = adverts;
    notifyListeners();
  }

  setAdvertsPendingQualification(List<AdvertModel> adverts) async {
    _advertsPendingQualification = adverts;
    notifyListeners();
  }

  setNotifications(List<NotificationModel> notifications) async {
    _notifications = notifications;
    notifyListeners();
  }
}
