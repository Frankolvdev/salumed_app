import 'dart:async';
import 'dart:convert';

import 'package:app/components/custom_dialog.dart';
import 'package:app/components/preview_asset_image.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/models/advert.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/bid.dart';
import 'package:app/models/budget.dart';
import 'package:app/models/notification.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/promotion.dart';
import 'package:app/models/qualification.dart';
import 'package:app/models/role.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/admin/admin_home.dart';

import 'package:app/pages/chat.dart';
import 'package:app/pages/client/client_home.dart';
import 'package:app/pages/delivery/delivery_home.dart';
import 'package:app/pages/doctor/doctor_home.dart';
import 'package:app/pages/hero.dart';

import 'package:app/pages/home_client.dart';
import 'package:app/pages/hospital_admin/hospital_admin_home.dart';
import 'package:app/pages/laboratory_admin/laboratory_admin_home.dart';

import 'package:app/pages/login.dart';
import 'package:app/pages/notifications.dart';
import 'package:app/pages/pharmacy_admin/pharmacy_admin_home.dart';

import 'package:app/pages/select_type_user.dart';

import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

//import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:location/location.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:image_picker_web/image_picker_web.dart';
import 'package:latlong2/latlong.dart' as distance;

import '../models/order.dart';

dynamic validatePassword1(String value, BuildContext context) {
  if (value.isEmpty) // The form is empty
    return "Ingrese la contraseña";
  return null;
}

dynamic validateEmail(String value, BuildContext context) {
  if (value.isEmpty) {
    // The form is empty
    return "Este campo es requerido";
  }
  // This is just a regular expression for email addresses
  String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
      "\\@" +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
      "(" +
      "\\." +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
      ")+";
  RegExp regExp = new RegExp(p);

  if (regExp.hasMatch(value)) {
    // So, the email is valid
    return null;
  } else {
    return "El correo electrónico no es valido";
  }
}

dynamic requiredField(dynamic value, BuildContext context) {
  if (value.isEmpty) {
    // The form is empty
    return "Este campo es requerido";
  } else {
    return null;
  }
}

dynamic validateRepeatPassword(
    String pass, String passRepeat, BuildContext context) {
  if (pass.isEmpty) // The form is empty
    return "El campo contraseña es necesario";
  if (passRepeat.isEmpty) return "Es campo repetir contraseña es necesario";
  if (pass != passRepeat) return "Las contraseñas no coinciden";
  return null;
}

dynamic validateName(String value, BuildContext context) {
  if (value.isEmpty) // The form is empty
    return "Ingrese su nombre y apellidos";
  return null;
}

bool checkEmpty(data) {
  if (data == null || data == "") {
    return false;
  } else {
    return true;
  }
}

simpleLoading(BuildContext context, Function callback, {String text = ""}) {
  try {
    FocusScope.of(context).requestFocus(FocusNode());
  } catch (e) {}
  BuildContext contextLoadingDialog = context;
  late StateSetter _setState;
  showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext contextd) {
      contextLoadingDialog = contextd;
      return StatefulBuilder(builder: (context, setState) {
        _setState = setState;
        return WillPopScope(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                      visible: text != "",
                      child: Flexible(
                          child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(text,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            )),
                      ))),
                  Container(
                    color: Colors.transparent,
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            CustomColors.primary)),
                  )
                ],
              ),
            ),
            onWillPop: () async {
              return false;
            });
      });
    },
  );
  callback(contextLoadingDialog);
}

showErrorsDialog(BuildContext context, dynamic errors,
    {dynamic callback = null}) async {
  print(errors);
  if (errors is List<dynamic> && errors.length <= 0) return;
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contextDialog) {
        return CustomDialog(
          "",
          errors.join(".\n"),
          "Aceptar",
          () {
            if (callback != null && callback is Function) callback();
          },
          useBtnCancel: false,
          image: '',
        );
      });
}

shareWeb(BuildContext context, String title, String content) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contextDialog) {
        return CustomDialog(
          title,
          content,
          "Copiar",
          () {
            Clipboard.setData(ClipboardData(text: content));
          },
          useBtnCancel: false,
          image: '',
        );
      });
}

bool hasTextOverflow(String text, TextStyle style,
    {double minWidth = 0,
    double maxWidth = double.infinity,
    int maxLines = 2}) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: ui.TextDirection.ltr,
  )..layout(minWidth: minWidth, maxWidth: maxWidth);
  return textPainter.didExceedMaxLines;
}

showDescriptionDialog(BuildContext context, String description) async {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contextDialog) {
        return CustomDialog(
          "",
          description,
          "Aceptar",
          () {},
          useBtnCancel: false,
          image: '',
        );
      });
}

showPropuseDateDialog(BuildContext context, BidModel bid) async {
  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (contextDialog) {
        return CustomDialog(
          "Fecha de finalización propuesta",
          getDateFromStringFormat(bid.proposed_date ?? ""),
          "Aceptar",
          () {},
          useBtnCancel: false,
          image: '',
        );
      });
}

bool checkIsHours(AdvertModel advert) {
  bool flag = false;
  String cat = "Pequeños chapú o reformas (por horas)";
  return (advert.category!.toLowerCase() == cat.toLowerCase());
}

bool propuseDate(List<BidModel> bids) {
  dynamic lowerBid = null;
  if (bids.length > 0) {
    bids.sort((a, b) {
      return a.amount!.compareTo(b.amount!);
    });
    lowerBid = bids[0];
  }

  bids.forEach((element) {
    if (element.status == "win") lowerBid = element;
  });

  if (lowerBid == null) return false;

  return (lowerBid.proposed_date != null &&
      lowerBid.proposed_date!.trim() != "");
}

BidModel getLowerOrWinBid(List<BidModel> bids) {
  dynamic lowerBid = null;
  if (bids.length > 0) {
    bids.sort((a, b) {
      return a.amount!.compareTo(b.amount!);
    });
    lowerBid = bids[0];
  }

  bids.forEach((element) {
    if (element.status == "win") lowerBid = element;
  });

  return lowerBid;
}

num getAmountMoreLower(List<BidModel> bids) {
  num lowerAmount = 0;
  if (bids.length > 0) {
    bids.sort((a, b) {
      return a.amount!.compareTo(b.amount!);
    });
    lowerAmount = bids[0].amount ?? 0;
  }

  bids.forEach((element) {
    if (element.status == "win") lowerAmount = element.amount ?? 0;
  });

  return lowerAmount;
}

List<dynamic> checkErrors(dynamic responseData) {
  try {
    dynamic json = jsonDecode(responseData.toString());
    if (json.containsKey("errors")) {
      return json["errors"];
    } else {
      return ['Ocurrió un error desconocido, intenté de nuevo.'];
    }
  } catch (e) {
    print(e);
    return ['Ocurrió un error desconocido, intenté de nuevo.'];
  }
}

bool updateAppProviderAdvert(BuildContext context, AdvertModel advert,
    {bool updateOfDelete = false}) {
  if (context == null) return false;
  final provider = Provider.of<AppProvider>(context, listen: false);

  if (!updateOfDelete) {
    int indexAdverts =
        provider.adverts.indexWhere((element) => element.id == advert.id);
    if (indexAdverts > -1) provider.adverts[indexAdverts] = advert;

    int indexMyAdverts =
        provider.myAdverts.indexWhere((element) => element.id == advert.id);
    if (indexMyAdverts > -1) provider.myAdverts[indexMyAdverts] = advert;

    int indexPendingAccept = provider.advertsPendingAccept
        .indexWhere((element) => element.id == advert.id);
    if (indexPendingAccept > -1) {
      provider.advertsPendingAccept[indexPendingAccept] = advert;
    }

    int indexFavorites = provider.favoriteAdverts
        .indexWhere((element) => element.id == advert.id);
    if (indexFavorites > -1) provider.favoriteAdverts[indexFavorites] = advert;

    int indexWorkInProgress = provider.advertsInProgress
        .indexWhere((element) => element.id == advert.id);
    if (indexWorkInProgress > -1)
      provider.advertsInProgress[indexWorkInProgress] = advert;
  }

  if (updateOfDelete) {
    provider.adverts.removeWhere((element) => element.id == advert.id);
    provider.myAdverts.removeWhere((element) => element.id == advert.id);
    provider.advertsPendingAccept
        .removeWhere((element) => element.id == advert.id);
    provider.favoriteAdverts.removeWhere((element) => element.id == advert.id);
    provider.advertsInProgress
        .removeWhere((element) => element.id == advert.id);
  }
  bool like = (checkLike(provider.user.id ?? "", advert.likes ?? []));
  if (!like) {
    provider.favoriteAdverts.removeWhere((element) => element.id == advert.id);
  }

  provider.setAdverts(provider.adverts);
  provider.setMyAdverts(provider.myAdverts);
  provider.setAdvertsPendingAccept(provider.advertsPendingAccept);
  provider.setFavoriteAdverts(provider.favoriteAdverts);
  provider.setAdvertsInProgress(provider.advertsInProgress);

  return true;
}

bool updateAppProviderNotification(
    BuildContext context, NotificationModel notification) {
  if (context == null) return false;
  final provider = Provider.of<AppProvider>(context, listen: false);
  int indexNotification = provider.notifications
      .indexWhere((element) => element.id == notification.id);
  if (indexNotification > -1)
    provider.notifications[indexNotification] = notification;
  if (notification.status == "unread")
    provider.setNotificationsUnread(provider.notificationsUnread - 1);
  provider.setNotifications(provider.notifications);
  return true;
}

String getTypeUser(BuildContext context) {
  final provider = Provider.of<AppProvider>(context, listen: false);
  String typeUser = "client";
  if (!checkHasRole(provider.user.roles, "client")) {
    typeUser = "professional";
  }
  return typeUser;
}

bool checkNoCompletedProfileClient(UserModel user, BuildContext context) {
  bool flag = false;
  if ((user.city != null && user.city!.trim() != "") &&
      (user.phone != null && user.phone!.trim() != "") &&
      (user.address != null && user.address!.trim() != "") &&
      (user.email != null && user.email!.trim() != "")) {
    flag = true;
  }

  if (flag == false) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return CustomDialog(
            "Para poder realizar esta acción primero debe completar su perfil como cliente",
            "¿Quiere completar su perfil ahora?",
            "Completar",
            () {},
            useBtnCancel: true,
            image: '',
          );
        });
  }

  return flag;
}

bool checkConfirmEmail(UserModel user, BuildContext context) {
  if ((user.email == null || user.email!.trim() == "")) {
    return true;
  }

  if (user.confirm_email_token != null) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return CustomDialog(
            "Para poder realizar esta acción primero debe confirmar su correo electrónico",
            "Revise sus bandejas de entrada para encontrar el correo de confirmación ",
            "Ok",
            () {},
            useBtnCancel: false,
            image: '',
          );
        });

    return false;
  } else {
    return true;
  }
}

openSlideInUpPage(BuildContext context, Widget page) {
  Navigator.push(
      context,
      PageTransition(
          child: page,
          type: PageTransitionType.slideInUp,
          duration: Duration(milliseconds: 250)));
}

initProcess(BuildContext context, String token, Function callback) async {
  final provider = Provider.of<AppProvider>(context, listen: false);

    /*    if(!kIsWeb){
  bool permission = await OneSignal.Notifications.permission;
if (!permission) {
   OneSignal.Notifications.requestPermission(true);
}
}*/

  String? onesignalUserId = "";

  if (!kIsWeb) {
    onesignalUserId = OneSignal.User.pushSubscription.id;
  }

  String typeUser = "client";
  if (!checkHasRole(provider.user.roles, "client")) {
    typeUser = "professional";
  }

  Future.wait([
    WebService(context).updateTokenPushUser(
        (Theme.of(context).platform == TargetPlatform.android)
            ? "android"
            : "ios",
        onesignalUserId ?? "",
        token),
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: (kIsWeb) ? Size(30, 45) : Size(0.5, 0.5)),
        'assets/images/pin_from.png'),
    WebService(context).getAdverts(0, 0, token,
        filter_color: "red", filter_type: "my_adverts"),
    WebService(context).getAdverts(0, 0, token,
        filter_color: "red",
        filter_type: "my_pendient_qualification_${typeUser}"),
    WebService(context).getNotifications(30, 0, context, token),
    WebService(context).getConfig()
  ]).then((List responses) async {
    provider.setUser(responses[0]);

    provider.setFromIconPin(responses[1]);

    List<AdvertModel> tmpAdverts = [];
    tmpAdverts =
        (responses[2] as List<AdvertModel>).where((AdvertModel advert) {
      return (advert.work_status == null || advert.work_status == "") ||
          advert.bids!.length <= 0;
    }).toList();
    provider.setAdvertsPendingAccept(tmpAdverts);

    provider.setAdvertsPendingQualification(responses[3]);
    provider.setNotifications(responses[4]);
    provider.setConfig(jsonDecode(jsonEncode(responses[5])));

    callback();
  }).catchError((err) {
    print("error al cargar la información inicial");
    print(err);

    simpleLoading(context, (BuildContext loadingContext) async {
      try {
        UserModel user = provider.user;

        UserModel userTmp = UserModel(roles: []);
        userTmp.id = null;
        await provider.setUser(userTmp);

        Navigator.pop(loadingContext);

        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                  child: Login(),
                  type: PageTransitionType.slideInUp,
                  duration: Duration(milliseconds: 250)),
              (Route<dynamic> route) => false);
        });
      } catch (e) {
        print(e);

        Navigator.pop(loadingContext);

        SchedulerBinding.instance?.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                  child: Login(),
                  type: PageTransitionType.slideInUp,
                  duration: Duration(milliseconds: 250)),
              (Route<dynamic> route) => false);
        });
      }
    });
  });
}

bool checkHasRole(List<RoleModel> roles, String nameRol) {
  Iterable<RoleModel> rolFound = roles.where((rol) => rol.name == nameRol);
  return (rolFound.length > 0);
}

goHome(BuildContext context, List<RoleModel> roles,
    {bool fromNotifications = false, dynamic dataGuest = null}) {
  if (checkHasRole(roles, "admin")) {
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            child: AdminHome(),
            type: PageTransitionType.slideInUp,
            duration: Duration(milliseconds: 250)),
        (Route<dynamic> route) => false);
  } else if (checkHasRole(roles, "super_admin")) {
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            child: AdminHome(),
            type: PageTransitionType.slideInUp,
            duration: Duration(milliseconds: 250)),
        (Route<dynamic> route) => false);
  } else if (checkHasRole(roles, "pharmacy_admin")) {
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            child: PharmacyAdminHome(),
            type: PageTransitionType.slideInUp,
            duration: Duration(milliseconds: 250)),
        (Route<dynamic> route) => false);
  } else if (checkHasRole(roles, "laboratory_admin")) {
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            child: LaboratoryAdminHome(),
            type: PageTransitionType.slideInUp,
            duration: Duration(milliseconds: 250)),
        (Route<dynamic> route) => false);
  } else if (checkHasRole(roles, "client")) {
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            child: ClientHome(),
            type: PageTransitionType.slideInUp,
            duration: Duration(milliseconds: 250)),
        (Route<dynamic> route) => false);
  } else if (checkHasRole(roles, "delivery")) {
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            child: DeliveryHome(),
            type: PageTransitionType.slideInUp,
            duration: Duration(milliseconds: 250)),
        (Route<dynamic> route) => false);
  } else if (checkHasRole(roles, "doctor")) {
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            child: DoctorHome(dataGuest: dataGuest),
            type: PageTransitionType.slideInUp,
            duration: Duration(milliseconds: 250)),
        (Route<dynamic> route) => false);
  } else if (checkHasRole(roles, "hospital_admin")) {
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            child: HospitalAdminHome(),
            type: PageTransitionType.slideInUp,
            duration: Duration(milliseconds: 250)),
        (Route<dynamic> route) => false);
  } else {
    logout(context, direct: true);
  }

  if (fromNotifications) {
    Navigator.push(
        context,
        PageTransition(
            child: Notifications(),
            type: PageTransitionType.slideInUp,
            duration: Duration(milliseconds: 250)));
  }
}

logout(BuildContext context, {bool direct = false, String messageAfter = ""}) {
  BuildContext mainContext = context;
  final provider = Provider.of<AppProvider>(context, listen: false);
  final UserModel user = provider.user;

  /*GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    //clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
    scopes: <String>['email'],
  );*/

  if (direct) {
    simpleLoading(context, (BuildContext loadingContext) async {
      try {
        UserModel user = provider.user;

        try {
          //await _googleSignIn.disconnect();
        } catch (e) {}
        try {
          // await _googleSignIn.signOut();
        } catch (e) {}
        try {
          await FacebookLogin().logOut();
        } catch (e) {}

        UserModel userTmp = UserModel(roles: []);
        userTmp.id = null;
        userTmp.name = null;
        userTmp.one_signal_id = null;
        userTmp.phone = null;
        userTmp.picture = null;
        userTmp.platform_one_signal = null;
        userTmp.roles = [];

        userTmp.status = null;
        userTmp.token = null;
        userTmp.token_apple = null;
        userTmp.token_facebook = null;
        userTmp.token_google = null;
        userTmp.birthdate = null;
        userTmp.created_at = null;
        userTmp.updated_at = null;

        await provider.setUser(userTmp);

        Navigator.pop(loadingContext);

        SchedulerBinding.instance?.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                  child: HeroPage(messageAfter: messageAfter),
                  type: PageTransitionType.slideInUp,
                  duration: Duration(milliseconds: 250)),
              (Route<dynamic> route) => false);
        });
      } catch (e) {
        print(e);

        Navigator.pop(loadingContext);
        showErrorsDialog(
            context, ["Ocurrió un error desconocido, intente de nuevo."]);
      }
    });
  } else {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return CustomDialog(
            "",
            "¿Deseas cerrar la sesión?",
            "Aceptar",
            () {
              simpleLoading(context, (BuildContext loadingContext) async {
                try {
                  UserModel user = provider.user;

                  try {
                    //  await _googleSignIn.disconnect();
                  } catch (e) {}
                  try {
                    // await _googleSignIn.signOut();
                  } catch (e) {}
                  try {
                    // await FacebookLogin().logOut();
                  } catch (e) {}

                  Navigator.pop(loadingContext);

                  SchedulerBinding.instance?.addPostFrameCallback((_) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        PageTransition(
                            child: HeroPage(messageAfter: messageAfter),
                            type: PageTransitionType.slideInUp,
                            duration: Duration(milliseconds: 250)),
                        (Route<dynamic> route) => false);

                    UserModel userTmp = UserModel(roles: []);
                    userTmp.id = null;
                    userTmp.name = null;
                    userTmp.one_signal_id = null;
                    userTmp.phone = null;
                    userTmp.picture = null;
                    userTmp.platform_one_signal = null;
                    userTmp.roles = [];
                    userTmp.status = null;
                    userTmp.token = null;
                    userTmp.token_apple = null;
                    userTmp.token_facebook = null;
                    userTmp.token_google = null;
                    userTmp.birthdate = null;
                    userTmp.created_at = null;
                    userTmp.updated_at = null;

                    provider.setUser(userTmp);
                  });
                } catch (e) {
                  print(e);

                  Navigator.pop(loadingContext);
                  showErrorsDialog(context,
                      ["Ocurrió un error desconocido, intente de nuevo."]);
                }
              });
            },
            useBtnCancel: true,
            image: '',
          );
        });
  }
}

String formatFirstUpper(String value, {bool cutName = false}) {
  try {
    String name = "";

    if (value == null) return "";
    value = value.toLowerCase();
    if (value != null) {
      name = value.toLowerCase().split(' ').map((word) {
        if (word.trim() != "") {
          return word[0].toUpperCase() + word.substring(1);
        } else {
          return "";
        }
      }).join(' ');
    } else {
      return "";
    }

    final pattern = RegExp('\\s+');
    name = name.replaceAll(pattern, " ");

    if (!cutName) return name;

    var nameParts = name.split(' ');
    print("nameParts:" + nameParts.toString());
    if (nameParts.length >= 4) {
      name = nameParts[0] + " " + nameParts[2][0] + ".";
    } else if (nameParts.length == 3) {
      name = nameParts[0] + " " + nameParts[2][0] + ".";
    } else if (nameParts.length == 2) {
      name = nameParts[0] + " " + nameParts[1][0] + ".";
    } else if (nameParts.length == 1) {
      name = nameParts[0];
    }
    return name;
  } catch (e) {
    return value;
  }
}

String getImageUrl(AssetModel asset) {
  if (asset.type == "image_url") {
    return asset.name ?? "";
  } else if (asset.type == "image") {
    if ((asset.name ?? "") == "") return "";
    return imagesUrl + (asset.name ?? "");
  } else if (asset.type == "pdf") {
    if ((asset.name ?? "") == "") return "";
    return imagesUrl + (asset.name ?? "");
  } else {
    return "";
  }
}

String getTimeFromStringFormat(String dateS) {
  DateTime date = DateTime.parse(dateS).toUtc();
  DateTime dateLocal = date.toLocal();

  return DateFormat('hh:mm a').format(dateLocal);
}

String getDateTimeFromStringFormat(String dateS) {
  if (dateS.trim() == "") return "";
  DateTime date = DateTime.parse(dateS).toUtc();
  DateTime dateLocal = date.toLocal();

  return DateFormat('dd-MMMM-yyyy hh:mm a', "es_ES").format(dateLocal);
}

String getDateFromStringFormat(String dateS) {
  if (dateS.trim() == "") return "";
  DateTime date = DateTime.parse(dateS).toUtc();
  DateTime dateLocal = date.toLocal();

  return DateFormat('dd-MMMM-yyyy', "es_ES").format(dateLocal);
}

String getDateFromStringFormatResume(String dateS) {
  if (dateS.trim() == "") return "";
  DateTime date = DateTime.parse(dateS).toUtc();
  DateTime dateLocal = date.toLocal();

  return DateFormat('dd-MMMM-yyyy', "es_ES").format(dateLocal);
}

launchUrl(BuildContext context, String url) async {
  simpleLoading(context, (BuildContext contextLoading) async {
    try {
      bool can = await canLaunch(url);
      Navigator.pop(contextLoading);
      if (can) await launch(url);
    } catch (e) {
      Navigator.pop(contextLoading);
      print(e);
    }
  });
}

previewImageAsset(String imageName, BuildContext context) {
  Navigator.push(
      context,
      PageTransition(
          child: PreviewAssetImage(imageName),
          type: PageTransitionType.slideInUp,
          duration: Duration(milliseconds: 250)));
}

String getTimeDifferenceFromNow(DateTime dateTime) {
  Duration difference = DateTime.now().difference(dateTime);
  if (difference.inSeconds < 5) {
    return "Justo ahora";
  } else if (difference.inMinutes < 1) {
    return "hace ${difference.inSeconds} ${(difference.inSeconds > 1) ? 'segundos' : 'segundo'}";
  } else if (difference.inHours < 1) {
    return "hace ${difference.inMinutes} ${(difference.inMinutes > 1) ? 'minutos' : 'minuto'}";
  } else if (difference.inHours < 24) {
    return "hace ${difference.inHours} ${(difference.inHours > 1) ? 'horas' : 'hora'}";
  } else {
    return "hace ${difference.inDays} ${(difference.inDays > 1) ? 'días' : 'día'}";
  }
}

double getPromQualification(List<QualificationModel> qualification) {
  if (qualification.length == 0) return 0;
  double sum = 0;
  qualification.forEach((element) {
    sum += (element.qualification ?? 0);
  });

  return sum / qualification.length;
}

bool checkLike(String idUser, List<UserModel> likes) {
  dynamic likeFound = null;
  likeFound = likes.where((element) => element.id == idUser);
  return (likeFound != null && likeFound.length > 0) ? true : false;
}

bool checkWeekendOnly(List<BidModel> bids) {
  dynamic lowerBid = null;
  if (bids.length > 0) {
    bids.sort((a, b) {
      return a.amount!.compareTo(b.amount!);
    });
    lowerBid = bids[0];
  }

  bids.forEach((element) {
    if (element.status == "win") lowerBid = element;
  });
  if (lowerBid == null) return false;
  return ((lowerBid as BidModel).weekend_only == true);
}

bool checkMyWeekendOnly(List<BidModel> bids, UserModel user) {
  bool status = false;
  bids.forEach((element) {
    if (element.weekend_only == true && element.user!.id == user.id)
      status = true;
  });
  return status;
}

Color getColorStatus(String status) {
  Color color = Colors.blue;
  switch (status) {
    case "blue":
      color = Colors.blue;
      break;
    case "yellow":
      color = Colors.yellow;
      break;
    case "green":
      color = Colors.green;
      break;
    case "red":
      color = Colors.red;
      break;
    default:
      color = Colors.blue;
  }

  return color;
}

showCustomNotification(BuildContext context, NotificationModel notification) {
  WidgetsBinding.instance?.addPostFrameCallback((_) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return CustomDialog(
            notification.title ?? "",
            notification.content ?? "",
            "Aceptar",
            () {
              provider.setShowingNotification(null);
            },
            image: "assets/images/on-notification.gif",
            useBtnCancel: false,
            callBackBtnCancel: () {
              provider.setShowingNotification(null);
            },
          );
        });
  });
}

openNotificationClient(
    BuildContext context, NotificationModel notification) async {
  /* final provider = Provider.of<AppProvider>(context, listen: false);
  String token = provider.user.token ?? "";
  if (notification.id != null) {
    if (notification.user!.id != provider.user.id) {
      showErrorsDialog(
          context, ["La notificación seleccionada no pertenece a esta cuenta"]);
      return;
    }
    WebService(context)
        .readNotification(
            notification.id ?? "", context, provider.user.token ?? "")
        .then((notification) =>
            updateAppProviderNotification(context, notification))
        .catchError((e) {
      print(e);
    });
  }

  if (notification.data != null && notification.data.isNotEmpty) {
    if (notification.data.containsKey("action")) {
      simpleLoading(context, (BuildContext loadingContext) async {
        try {
          String action = notification.data["action"];
          if (action == "open_questions") {
            //id_advert
            AdvertModel advertTmp = await WebService(context)
                .getAdvertById(notification.data["id_advert"], token);
            updateAppProviderAdvert(context, advertTmp);
            Navigator.pop(loadingContext);
            //openSlideInUpPage(context, ViewSimpleAdvertClient(advertTmp, openQuestions:true));
            goHome(context, provider.user.roles, fromNotifications:true);
           
            Navigator.push(
                context,
                PageTransition(
                    child: AdvertsClientTabs(
                      tab: 1,
                    ),
                    type: PageTransitionType.slideInUp,
                    duration: Duration(milliseconds: 250)));
          } else if (action == "open_chat") {
            //id advert, id_user
            AdvertModel advertTmp = await WebService(context)
                .getAdvertById(notification.data["id_advert"], token);
            UserModel userTmp = await WebService(context)
                .getUser(notification.data["id_user"], token);
            updateAppProviderAdvert(context, advertTmp);
            Navigator.pop(loadingContext);
            goHome(context, provider.user.roles, fromNotifications:true);
            openSlideInUpPage(context, ChatPage(userTmp, advertTmp));
          } else if (action == "open_work_in_progress") {
            // id
            AdvertModel advertTmp = await WebService(context)
                .getAdvertById(notification.data["id"], token);
            updateAppProviderAdvert(context, advertTmp);
            Navigator.pop(loadingContext);
            goHome(context, provider.user.roles, fromNotifications:true);
            openSlideInUpPage(context, WorksInProgressClient());
          } else if (action == "open_advert") {
            // id
            AdvertModel advertTmp = await WebService(context)
                .getAdvertById(notification.data["id"], token);
            updateAppProviderAdvert(context, advertTmp);
            Navigator.pop(loadingContext);
            goHome(context, provider.user.roles, fromNotifications:true);
            //openSlideInUpPage(context,  ViewSimpleAdvertClient(advertTmp));
            Navigator.push(
                context,
                PageTransition(
                    child: AdvertsClientTabs(
                      tab: 1,
                    ),
                    type: PageTransitionType.slideInUp,
                    duration: Duration(milliseconds: 250)));
          } else if (action == "open_share") {
            // id
            AdvertModel advertTmp = await WebService(context)
                .getAdvertById(notification.data["id"], token);
            updateAppProviderAdvert(context, advertTmp);
            Navigator.pop(loadingContext);
            goHome(context, provider.user.roles, fromNotifications:true);
            //openSlideInUpPage(context,  ViewSimpleAdvertClient(advertTmp));
            Navigator.push(
                context,
                PageTransition(
                    child: ViewSimpleAdvertClient(advertTmp),
                    type: PageTransitionType.slideInUp,
                    duration: Duration(milliseconds: 250)));
          } else if (action == "open_adverts") {
            // id
            AdvertModel advertTmp = await WebService(context)
                .getAdvertById(notification.data["id"], token);
            updateAppProviderAdvert(context, advertTmp);
            Navigator.pop(loadingContext);
            goHome(context, provider.user.roles, fromNotifications:true);
            //openSlideInUpPage(context,  ViewSimpleAdvertClient(advertTmp));
            Navigator.push(
                context,
                PageTransition(
                    child: AdvertsClientTabs(
                      tab: 0,
                    ),
                    type: PageTransitionType.slideInUp,
                    duration: Duration(milliseconds: 250)));
          }else if (action == "open_advert_bids") {
            // id_advert
            AdvertModel advertTmp = await WebService(context)
                .getAdvertById(notification.data["id_advert"], token);
            updateAppProviderAdvert(context, advertTmp);
            Navigator.pop(loadingContext);
            //openSlideInUpPage(context,  ViewSimpleAdvertProfessional(advertTmp));
            goHome(context, provider.user.roles, fromNotifications:true);
            Navigator.push(
                context,
                PageTransition(
                    child: AdvertsClientTabs(
                      tab: 1,
                    ),
                    type: PageTransitionType.slideInUp,
                    duration: Duration(milliseconds: 250)));
          } else {
            //showCustomNotification(context,notification);
          }
        } catch (e) {
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e);
        }
      });
    }
  }*/
}

createPayment(BuildContext context, String typePayment, Function callbackSucess,
    {String idAdvert = ""}) {
  /* if (kIsWeb) {
    showErrorsDialog(context, [
      "Para completar esta operación ingresa a nuestra aplicación móvil Chapú disponible en Android e Ios"
    ]);
    return;
  }
  final provider = Provider.of<AppProvider>(context, listen: false);
  simpleLoading(context, (BuildContext contextLoading) {
    WebService(context)
        .paymentIntent(typePayment, provider.user.token ?? "",
            idAdvert: idAdvert)
        .then((response) async {
      try {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
          style: ThemeMode.dark,
          applePay: true,
          testEnv: true,
          merchantCountryCode: "es",
          merchantDisplayName: "Chapú App",
          //customerId: "",
          paymentIntentClientSecret: response["client_secret"],
          //customerEphemeralKeySecret: ""
        ));

        try {
          await Stripe.instance.presentPaymentSheet();
          callbackSucess(contextLoading, typePayment);
        } on Exception catch (e) {
          Navigator.pop(contextLoading);
          if (e is StripeException) {
            showErrorsDialog(context, [e.error.localizedMessage]);
          } else {
            print(e);
            showErrorsDialog(
                context, ["Ocurrió un error desconocido, intente de nuevo."]);
          }
        }
      } catch (e) {
        print(e);
        Navigator.pop(contextLoading);
        showErrorsDialog(context, [e]);
      }
    }).catchError((e) {
      print(e);
      Navigator.pop(contextLoading);
      showErrorsDialog(context, e);
    });
  }); */
}


selectPictureWeb(BuildContext context, dynamic callback) async {
 /*simpleLoading(context, (BuildContext loadingContext) async {
    try {
      final imageFile =
          await ImagePickerWeb.getImage(outputType: ImageType.bytes);
      if (imageFile == null) {
        Navigator.pop(loadingContext);
        return;
      } else {
        Navigator.pop(loadingContext);
        callback(imageFile);
      }
    } catch (e) {
      Navigator.pop(loadingContext);
      print(e);
    }
  });*/
}

selectPicturesWebMulti(BuildContext context, dynamic callback) async {
 /*List<dynamic> tmpPictures = [];
  simpleLoading(context, (BuildContext loadingContext) async {
    try {
      final imageFiles =
          await ImagePickerWeb.getMultiImages(outputType: ImageType.bytes);
      if (imageFiles == null) {
        Navigator.pop(loadingContext);
        return;
      }
      await Future.forEach(imageFiles, (dynamic element) async {
        if (element != null) {
          tmpPictures.add(element);
        }
      });
      Navigator.pop(loadingContext);
      callback(tmpPictures);
    } catch (e) {
      Navigator.pop(loadingContext);
      print(e);
    }
  }); */
}

getMedalsWidget(BuildContext context, UserModel user) {
  return InkWell(
      onTap: () {
        openMedals(context, user);
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Image(
              width: 25,
              image: AssetImage('assets/images/certificaciones.png'),
            ),
          ),
        ],
      ));
}

EdgeInsets getDialogInsetPaddin(BuildContext context,
    {dynamic customEdge = null}) {
  return kIsWeb
      ? EdgeInsets.symmetric(
          horizontal: (MediaQuery.of(context).size.width > 1000)
              ? MediaQuery.of(context).size.width * .35
              : 30)
      : (customEdge != null && customEdge is EdgeInsets)
          ? customEdge
          : EdgeInsets.symmetric(horizontal: 35, vertical: 24);
}

openMedals(BuildContext context, UserModel user) {
  simpleLoading(context, (BuildContext loadingContext) async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    WebService(context)
        .getMedals(user.id ?? "", provider.user.token ?? "")
        .then((medals) {
      Navigator.pop(loadingContext);
      showDialog(
          barrierDismissible: true,
          context: context,
          builder: (contextDialog) {
            return Dialog(
                insetPadding: getDialogInsetPaddin(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Container(
                  padding:
                      EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
                  margin: EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(17.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10.0,
                          offset: Offset(0.0, 10.0),
                        )
                      ]),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, top: 5),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  FontAwesomeIcons.times,
                                  size: 30,
                                  color: CustomColors.primary,
                                ),
                              )
                            ],
                          ),
                          Text("Medallas",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    (medals.length <= 0)
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              (provider.user.id == user.id)
                                  ? Text(
                                      "Aún no tienes ninguna insignia",
                                      textAlign: TextAlign.center,
                                    )
                                  : Text(
                                      "${user.name} aún no tiene ninguna insignia",
                                      textAlign: TextAlign.center)
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: medals.map((medal) {
                              return Column(
                                children: [
                                  getMedalsByName(medal, user),
                                  Divider()
                                ],
                              );
                            }).toList(),
                          )
                  ]),
                ));
          });
    }).catchError((e) {
      print(e);
      Navigator.pop(loadingContext);
      showErrorsDialog(context, e);
    });
  });
}

Widget medalWidget(String nameImage, String detail) {
  return Row(
    children: [
      Image(
        width: 25,
        image: AssetImage('assets/images/medals/${nameImage}'),
      ),
      Flexible(child: Text(detail))
    ],
  );
}

Widget getMedalsByName(String medalName, UserModel user) {
  if (medalName == "50_finished") {
    return medalWidget("med-50.png", "50 obras finalizadas con éxito");
  } else if (medalName == "100_finished") {
    return medalWidget("med-100.png", "100 obras finalizadas con éxito");
  } else if (medalName == "500_finished") {
    return medalWidget("med-500.png", "500 obras finalizadas con éxito");
  } else if (medalName == "most_rehired_by_city") {
    return medalWidget(
        "med-recontrato.png", "Más recontratado de ${user.city}");
  } else if (medalName == "best_rating_by_city") {
    return medalWidget(
        "med-mejor-valorado.png", "Mejor valorado de ${user.city}");
  } else if (medalName == "best_rating") {
    return medalWidget(
        "med-mejor-valorado-chapu.png", "Mejor valorado en Chapú");
  } else if (medalName == "crowdfunding") {
    return medalWidget("med-socio-fundador.png", "Socio fundador en Chapú");
  } else if (medalName == "collaborator") {
    return medalWidget("med-colaborador.png", "Colaborador en Chapú");
  } else if (medalName == "Albañilería") {
    return medalWidget(
        "med-albañil.png", "Con más obras terminadas en albañilería");
  } else if (medalName == "Pintura") {
    return medalWidget(
        "med-pintura.png", "Con más obras terminadas en pintura");
  } else if (medalName == "Electricidad") {
    return medalWidget(
        "med-electricidad.png", "Con más obras terminadas en electricidad");
  } else if (medalName == "Fontanería") {
    return medalWidget(
        "med-fontanero.png", "Con más obras terminadas en fontanería");
  } else if (medalName == "Alicatado") {
    return medalWidget(
        "med-alicatado.png", "Con más obras terminadas en alicatado");
  } else if (medalName == "Parquet") {
    return medalWidget(
        "med-parquet.png", "Con más obras terminadas en parquet");
  } else if (medalName == "Mecánica") {
    return medalWidget(
        "med-mecanica.png", "Con más obras terminadas en mecánica");
  } else if (medalName == "Mudanzas") {
    return medalWidget(
        "med-mudanza.png", "Con más obras terminadas en mudanzas");
  } else if (medalName == "Pladur") {
    return medalWidget(
        "med-pladur-yeso.png", "Con más obras terminadas en pladur");
  } else if (medalName == "Carpintería") {
    return medalWidget(
        "med-carpinteria.png", "Con más obras terminadas en carpintería");
  } else if (medalName.toLowerCase() ==
      "Pequeños chapú o reformas (por horas)".toLowerCase()) {
    return medalWidget("med-chapu-por-horas.png",
        "Con más obras terminadas en pequeños chapú o reformas (por horas)");
  } else if (medalName == "Carpintería metálica") {
    return medalWidget("med-carpmetalica.png",
        "Con más obras terminadas en carpintería metálica");
  } else if (medalName == "Chapa y pintura") {
    return medalWidget(
        "med-chapa-pintura.png", "Con más obras terminadas en chapa y pintura");
  } else if (medalName == "Reforma integral") {
    return medalWidget("med-reforma-integral.png",
        "Con más obras terminadas en reforma integral");
  } else {
    return Container();
  }
}

getCategoryWidget(BuildContext context, AdvertModel advert) {
  final provider = Provider.of<AppProvider>(context, listen: false);

  String imageCategory = "";
  String nameCategory = "";

  if (advert.category == "Albañilería") {
    imageCategory = "icon-albañil.png";
    nameCategory = "Albañilería";
  } else if (advert.category == "Pintura") {
    imageCategory = "icon-pintura.png";
    nameCategory = "Pintura";
  } else if (advert.category == "Electricidad") {
    imageCategory = "icon-electricidad.png";
    nameCategory = "Electricidad";
  } else if (advert.category == "Fontanería") {
    imageCategory = "icon-fontanero.png";
    nameCategory = "Fontanería";
  } else if (advert.category == "Alicatado") {
    imageCategory = "ico-alicatado.png";
    nameCategory = "Alicatado";
  } else if (advert.category == "Parquet") {
    imageCategory = "icono-parquet.png";
    nameCategory = "Parquet";
  } else if (advert.category == "Mecánica") {
    imageCategory = "icon-mecanica.png";
    nameCategory = "Mecánica";
  } else if (advert.category == "Mudanzas") {
    imageCategory = "icon-mudanza.png";
    nameCategory = "Mudanzas";
  } else if (advert.category == "Pladur" || advert.category == "Pladur/Yeso") {
    imageCategory = "icon-pladur-yeso.png";
    nameCategory = "Pladur";
  } else if (advert.category == "Carpintería") {
    imageCategory = "icon-carpinteria.png";
    nameCategory = "Carpintería";
  } else if (advert.category!.toLowerCase() ==
      "Pequeños chapú o reformas (por horas)".toLowerCase()) {
    imageCategory = "icon-reformas-por-horas.png";
    nameCategory = "Pequeños chapú o reformas (por horas)";
  } else if (advert.category == "Carpintería metálica") {
    imageCategory = "icon-carp-metalica.png";
    nameCategory = "Carpintería metálica";
  } else if (advert.category == "Chapa y pintura") {
    imageCategory = "icon-chapa-pintura.png";
    nameCategory = "Chapa y pintura";
  } else if (advert.category == "Reforma integral") {
    imageCategory = "icon-reforma-integral.png";
    nameCategory = "Reforma integral";
  } else {
    imageCategory = "";
    nameCategory = "";
  }
  if (nameCategory != "" && imageCategory != "") {
    return Tooltip(
      message: nameCategory,
      triggerMode: TooltipTriggerMode.tap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
        child: Image(
          width: 35,
          image: AssetImage('assets/images/categories/${imageCategory}'),
        ),
      ),
    );
  } else {
    return Container();
  }
}

openAcceptLegalDocuments(BuildContext context, UserModel user) {
  var documentsNoAccepted = 0;

  if (user.accept_doc1 == false) documentsNoAccepted++;
  if (user.accept_doc2 == false) documentsNoAccepted++;
  if (user.accept_doc3 == false) documentsNoAccepted++;
  if (user.accept_doc4 == false) documentsNoAccepted++;

  if (documentsNoAccepted > 0)
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return WillPopScope(
              child: Dialog(
                  insetPadding: getDialogInsetPaddin(context),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 16, bottom: 8, left: 16, right: 16),
                    margin: EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(17.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: Offset(0.0, 10.0),
                          )
                        ]),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      (documentsNoAccepted == 1)
                          ? Text(
                              "Se han modificado el siguiente documento. Lee atentamente y acepta los cambios y podrás seguir disfrutando de Chapú, tu comunidad de confianza.",
                              textAlign: TextAlign.center)
                          : Text(
                              "Se han modificado los siguientes documentos. Lee atentamente y acepta los cambios y podrás seguir disfrutando de Chapú, tu comunidad de confianza.",
                              textAlign: TextAlign.center),
                      SizedBox(height: 15),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: (user.accept_doc1 == false),
                            child: InkWell(
                              onTap: () {
                                launchUrl(context,
                                    "https://chapureformas.es/privacy-policies");
                              },
                              child: Column(
                                children: [
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Ver política de privacidad y datos",
                                            textAlign: TextAlign.center,
                                          ),
                                        ))
                                      ]),
                                  Divider()
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: (user.accept_doc2 == false),
                            child: InkWell(
                              onTap: () {
                                launchUrl(context,
                                    "https://chapureformas.es/politica-uso");
                              },
                              child: Column(
                                children: [
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Ver política de uso",
                                            textAlign: TextAlign.center,
                                          ),
                                        ))
                                      ]),
                                  Divider()
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: (user.accept_doc3 == false),
                            child: InkWell(
                              onTap: () {
                                launchUrl(context,
                                    "https://chapureformas.es/aviso-legal");
                              },
                              child: Column(
                                children: [
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Ver aviso legal",
                                            textAlign: TextAlign.center,
                                          ),
                                        ))
                                      ]),
                                  Divider()
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: (user.accept_doc4 == false),
                            child: InkWell(
                              onTap: () {
                                launchUrl(context,
                                    "https://chapureformas.es/cancellation-policies");
                              },
                              child: Column(
                                children: [
                                  Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                            child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Ver política de cancelación",
                                            textAlign: TextAlign.center,
                                          ),
                                        ))
                                      ]),
                                  Divider()
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: MaterialButton(
                                onPressed: () {
                                  logout(context, direct: true);
                                },
                                child: Text("No aceptar")),
                          ),
                          Expanded(
                            child: MaterialButton(
                                onPressed: () {
                                  simpleLoading(context,
                                      (BuildContext loadingContext) async {
                                    final provider = Provider.of<AppProvider>(
                                        context,
                                        listen: false);
                                    WebService(context)
                                        .acceptLegalDocs(user.token ?? "")
                                        .then((user) async {
                                      await provider.setUser(user);

                                      Navigator.pop(loadingContext);
                                      goHome(context, provider.user.roles);
                                    }).catchError((e) {
                                      print(e);
                                      Navigator.pop(loadingContext);
                                      showErrorsDialog(context, e);
                                    });
                                  });
                                },
                                child: Text(
                                  "Aceptar",
                                  style: TextStyle(color: CustomColors.primary),
                                  textAlign: TextAlign.center,
                                )),
                          )
                        ],
                      )
                    ]),
                  )),
              onWillPop: () async {
                return false;
              });
        });
}

num getCostByTag(BuildContext context, String tag) {
  num costViewAll = 0;
  final provider = Provider.of<AppProvider>(context, listen: false);
  provider.config["payments"].forEach((item) {
    if (item["tag"].toString() == tag) {
      costViewAll = item["price"];
    }
  });
  return costViewAll;
}

String getRoleName(RoleModel rol) {
  switch (rol.name) {
    case "super_admin":
      return "Super administrador";
      break;
    case "admin":
      return "administrador";
      break;
    case "pharmacy_admin":
      return "Administrador de farmacia";
      break;
    case "laboratory_admin":
      return "Administrador de laboratorio";
      break;
    case "client":
      return "Paciente";
      break;
    case "delivery":
      return "Repartidor";
      break;
    case "doctor":
      return "Doctor";
      break;
    case "hospital_admin":
      return "Hospital";
      break;
    default:
      return "";
  }
}

Color getColor(Set<MaterialState> states) {
  const Set<MaterialState> interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };
  if (states.any(interactiveStates.contains)) {
    return Colors.blue;
  }
  return CustomColors.primary;
}

Map<String, dynamic> getDiscount(PromotionModel promo) {
  if (promo.type == "percent") {
    return {"text": promo.amount.toString() + " %", "value": promo.amount};
  } else {
    return {"text": promo.amount.toString(), "value": promo.amount};
  }
}

bool checkNoCompletedProfileDoctor(UserModel user, BuildContext context,
    {show = false}) {
  bool flag = false;
  if (((user.phone != null && user.phone!.trim() != "") &&
          (user.picture != null) &&
          (user.name != null && user.name!.trim() != "") &&
          (user.email != null && user.email!.trim() != "") &&
          (user.professional_license != null &&
              user.professional_license!.trim() != "") &&
          (user.doc_id_front != null) &&
          (user.doc_id_back != null)) ||
      (user.verified_doctor != null && user.verified_doctor == "yes")) {
    flag = true;
  }

  if (flag == false && show) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return CustomDialog(
            "",
            "Para poder realizar esta acción primero debe completar su perfil como médico y esperar a que sea aprobado",
            "Ok",
            () {},
            useBtnCancel: false,
            image: '',
          );
        });
  }

  return flag;
}

String getTypeSend(String type, {dynamic order = null}) {
  if (order is OrderModel) {
    if (order.type == "studies_without_prescription" && type == "store") {
      return "en laboratorio";
    }
  }

  if (type == "home") {
    return "a domicilio";
  } else if (type == "store") {
    return "en tienda";
  } else {
    return "no definido";
  }
}

String getTypePayment(String type) {
  if (type == "tj") {
    return "tarjeta";
  } else if (type == "cash") {
    return "en efectivo";
  } else {
    return "no definido";
  }
}

String getTypeOrder(String type) {
  if (type == "medicines_without_prescription") {
    return "Medicamentos sin prescripción";
  } else if (type == "studies_without_prescription") {
    return "Estudios medicos sin prescripción";
  } else {
    return "No definido";
  }
}

openWhatsappTel(BuildContext context, String whatsapp) async {
  whatsapp = whatsapp.replaceAll('+', '');

  var whatsappURl_android = "whatsapp://send?phone=" + whatsapp + "&text=hello";
  var whatappURL_ios = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
  var whatappURL_web = "https://api.whatsapp.com/send?phone=" + whatsapp;
  if (Platform.isIOS) {
    // for iOS phone only
    if (await canLaunch(whatappURL_ios)) {
      await launch(whatappURL_ios, forceSafariVC: false);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
    }
  } else {
    // android , web
    if (kIsWeb) {
      if (await canLaunch(whatappURL_web)) {
        await launch(whatappURL_web);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    } else {
      if (await canLaunch(whatsappURl_android)) {
        await launch(whatsappURl_android);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("Whatsapp no ​​instalado")));
      }
    }
  }
}

dynamic getMyLastBudget(List<BudgetModel> budgets, PharmacyModel pharmacy) {
  dynamic budgetFound = null;

  if (!(budgets is List<BudgetModel>)) return null;

  if (!(pharmacy is PharmacyModel)) return null;

  budgets.forEach((item) {
    if (item.pharmacy != null && item.pharmacy!.id == pharmacy.id)
      budgetFound = item;
  });
  return budgetFound;
}

num getTotalOrder(BudgetModel budgets) {
  num total = 0;
  num cost_delivery = 0;
  num cost_products = 0;

  if (budgets.cost_delivery != null && budgets.cost_delivery != "") {
    cost_delivery = double.parse(budgets.cost_delivery ?? "");
  }

  if (budgets.cost_products != null && budgets.cost_products != "") {
    cost_products = double.parse(budgets.cost_products ?? "");
  }

  total = cost_delivery + cost_products;
  return total;
}

num getTotalOrderNoShipping(BudgetModel budgets) {
  num total = 0;
  num cost_delivery = 0;
  num cost_products = 0;

  if (budgets.cost_products != null && budgets.cost_products != "") {
    cost_products = double.parse(budgets.cost_products ?? "");
  }

  total = cost_delivery + cost_products;
  return total;
}

dynamic getLastBudget(List<BudgetModel> budgets) {
  dynamic budgetFound = null;

  if (!(budgets is List<BudgetModel>) || budgets.length <= 0) return null;

  budgetFound = budgets[budgets.length - 1];
  return budgetFound;
}

dynamic getStatusPatient(OrderModel order) {
  String status = order.status ?? "";
  String approval = order.approval ?? "";
  String type = order.type ?? "";
  if (status == "pendient") {
    if (type != "normal") {
      if (approval == "pending") {
        return "Esperando aprobación";
      } else if (approval == "approved") {
        return "Esperando costos de pedido (aprobada)";
      } else if (approval == "rejected") {
        return "Rechazada";
      } else {
        return "No aplica";
      }
    } else {
      return "Esperando costos de pedido";
    }
  } else if (status == "budget_acceptance_pending") {
    return "Aceptar costos";
  } else if (status == "waiting_delivery") {
    return "Asignando repartidor";
  } else if (status == "waiting_package") {
    if (order.type == "studies_without_prescription") {
      return "Acude a realizar tus estudios";
    } else {
      return "Preparando el paquete";
    }
  } else if (status == "delivery_assigned") {
    return "Repartidor asignado";
  } else if (status == "ready_in_store") {
    return "Puedes recojer tu pedido";
  } else if (status == "go_deliver") {
    return "Tu pedido esta en camino";
  } else if (status == "cancelled") {
    return "Cancelada";
  } else if (status == "completed") {
    return "Entregado";
  } else {
    return "";
  }
}

dynamic getStatusAdmin(String status, OrderModel order) {
  if (status == "waiting_delivery") {
    return "Asigna un repartidor";
  } else if (status == "waiting_package") {
    if (order.type == "studies_without_prescription") {
      return "Prepara los estudios";
    } else {
      return "Prepara el paquete";
    }
  } else if (status == "delivery_assigned") {
    return "Esperando entrega por repartidor";
  } else if (status == "waiting_package") {
    return "Preparando el paquete";
  } else if (status == "ready_in_store") {
    return "Marcar como entregado";
  } else if (status == "go_deliver") {
    return "En proceso de entrega";
  } else if (status == "cancelled") {
    return "Cancelada";
  } else if (status == "completed") {
    return "Pedido entregado";
  } else {
    return "";
  }
}

dynamic getStatusDelivery(String status) {
  if (status == "delivery_assigned") {
    return "Ir a su entrega";
  } else if (status == "go_deliver") {
    return "Entregar pedido";
  } else if (status == "completed") {
    return "Pedido entregado";
  } else {
    return "";
  }
}

dynamic getDistanceMetters(
    dynamic myLat, dynamic myLong, dynamic lat, dynamic long) {
  distance.Distance dist = new distance.Distance();
  print("myLat");
  print(myLat);
  print("myLong");
  print(myLong);
  print("lat");
  print(lat);
  print("long");
  print(long);
  if ((myLat != null && myLat is double) &&
      (myLong != null && myLong is double) &&
      (lat != null && lat is double) &&
      (long != null && long is double)) {
    try {
      return dist
          .distance(distance.LatLng(myLat, myLong), distance.LatLng(lat, long))
          .toString();
    } catch (e) {
      return null;
    }
  } else {
    return null;
  }
}

dynamic getDistanceKm(dynamic myLat, dynamic myLong, dynamic lat, dynamic long,
    {bool formated = false}) {
  distance.Distance dist = new distance.Distance();
  print("myLat");
  print(myLat);
  print("myLong");
  print(myLong);
  print("lat");
  print(lat);
  print("long");
  print(long);
  if ((myLat != null && myLat is double) &&
      (myLong != null && myLong is double) &&
      (lat != null && lat is double) &&
      (long != null && long is double)) {
    try {
      if (formated) {
        return "a " +
            parseMetersToKm(dist.distance(
                    distance.LatLng(myLat, myLong), distance.LatLng(lat, long)))
                .toString() +
            " km";
      } else {
        return parseMetersToKm(dist.distance(
                distance.LatLng(myLat, myLong), distance.LatLng(lat, long)))
            .toString();
      }
    } catch (e) {
      return null;
    }
  } else {
    return null;
  }
}

double parseMetersToKm(num meters) {
  double distanceInKiloMeters = meters / 1000;
  double roundDistanceInKM =
      double.parse((distanceInKiloMeters).toStringAsFixed(2));
  return roundDistanceInKM;
}

registerLocation(BuildContext context, {dynamic contextDialog = null}) async {
  try {
    if (contextDialogLocation != null &&
        contextDialogLocation is BuildContext) {
      Navigator.pop(contextDialogLocation);
    }
  } catch (e) {}
  final provider = Provider.of<AppProvider>(context, listen: false);
  bool serviceEnabled = false;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
  }
  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  await Geolocator.requestPermission();
  permission = await Geolocator.checkPermission();

  if (serviceEnabled == true &&
      (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever)) {
    try {
      if (contextDialogLocation != null &&
          contextDialogLocation is BuildContext) {
        Navigator.pop(contextDialogLocation);
      }
    } catch (e) {}

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      provider.user.lat = position.latitude;
      provider.user.long = position.longitude;
      provider.setUser(provider.user);
      print("lat");
      print(position.latitude);
      print("lng");
      print(position.longitude);
      WebService(context).updateLocationUser(
          provider.user.id ?? "",
          position.latitude ?? 0,
          position.longitude ?? 0,
          provider.user.token ?? "");
    } catch (e) {
      registerLocation(context);
    }
  } else {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return;
    }
    ;
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext contextd) {
        contextDialogLocation = contextd;
        return StatefulBuilder(builder: (contextS, setState) {
          return WillPopScope(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(110 / 2)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: CustomColors.primary.withOpacity(0.5),
                          blurRadius: 110 / 10,
                          offset: Offset(0, 110 / 10),
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      color: CustomColors.primary,
                      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide.none,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                                width: 20,
                                child: Icon(
                                  Icons.location_off,
                                  color: Colors.white,
                                  size: 35,
                                )),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "Es necesario activar los permisos de ubicación. ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center),
                                ),
                              )
                            ],
                          ),
                          Row(
                            // Replace with a Row for horizontal icon + text
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "Activar los servicios de ubicación.",
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                  width: 20,
                                  child: Icon(
                                    FontAwesomeIcons.chevronRight,
                                    color: Colors.white,
                                    size: 20,
                                  )),
                            ],
                          )
                        ],
                      ),
                      onPressed: () async {
                        registerLocation(context, contextDialog: contextd);
                      },
                    ),
                  ),
                ),
              ),
              onWillPop: () async {
                return false;
              });
        });
      },
    );
  }

  /*final provider = Provider.of<AppProvider>(context, listen: false);
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
  }

  if (contextDialog != null) Navigator.pop(contextDialog);

  bool grantedStatus =
      (_permissionGranted != PermissionStatus.granted) ? false : true;

  if (grantedStatus && _serviceEnabled) {
    location.getLocation().then((value) async {
      LocationData currentLocation = value;
      provider.user.lat = currentLocation.latitude;
      provider.user.long = currentLocation.longitude;
      provider.setUser(provider.user);

      WebService(dialogConn, context).updateLocationUser(
          provider.user.id ?? "",
          currentLocation.latitude ?? 0,
          currentLocation.longitude ?? 0,
          provider.user.token ?? "");
    }).catchError((e) {
      registerLocation(context, dialogConn);
    });
  } else {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext contextd) {
        return StatefulBuilder(builder: (contextS, setState) {
          return WillPopScope(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(110 / 2)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: CustomColors.primaryColor.withOpacity(0.5),
                          blurRadius: 110 / 10,
                          offset: Offset(0, 110 / 10),
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      color: CustomColors.primaryColor,
                      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide.none,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                                width: 20,
                                child: Icon(
                                  Icons.location_off,
                                  color: Colors.white,
                                  size: 35,
                                )),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "Es necesario activar los permisos de ubicación. ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center),
                                ),
                              )
                            ],
                          ),
                          Row(
                            // Replace with a Row for horizontal icon + text
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "Activar los servicios de ubicación.",
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                  width: 20,
                                  child: Icon(
                                    FontAwesomeIcons.chevronRight,
                                    color: Colors.white,
                                    size: 20,
                                  )),
                            ],
                          )
                        ],
                      ),
                      onPressed: () async {
                        registerLocation(context, dialogConn,
                            contextDialog: contextd);
                      },
                    ),
                  ),
                ),
              ),
              onWillPop: () async {
                return false;
              });
        });
      },
    );
  }*/
}

/*registerLocation(BuildContext context, {dynamic contextDialog = null}) async {
  final provider = Provider.of<AppProvider>(context, listen: false);
  try {
    if(contextDialogLocation!=null && contextDialogLocation is BuildContext){
      Navigator.pop(contextDialogLocation);
    }
  } catch (e) {
  }
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
  }

  if (contextDialog != null) Navigator.pop(contextDialog);

  bool grantedStatus =
      (_permissionGranted != PermissionStatus.granted) ? false : true;

  if (grantedStatus && _serviceEnabled) {
    location.getLocation().then((value) async {
      LocationData currentLocation = value;
      provider.user.lat = currentLocation.latitude;
      provider.user.long = currentLocation.longitude;
      provider.setUser(provider.user);

      provider.setLocation(currentLocation.latitude??provider.lat,  currentLocation.longitude??provider.long);
      WebService(context).updateLocationUser(
          provider.user.id ?? "",
          currentLocation.latitude ?? 0,
          currentLocation.longitude ?? 0,
          provider.user.token ?? "");

    }).catchError((e) {
      registerLocation(context);
    });
  } else {
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext contextd) {
              contextDialogLocation=contextd;
        return Dialog(
               elevation: 0,
      backgroundColor: Colors.transparent,
             insetPadding: getDialogInsetPaddin(context ) ,
          child:StatefulBuilder(builder: (contextS, setState) {
    
          return WillPopScope(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(110 / 2)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: CustomColors.primary.withOpacity(0.5),
                          blurRadius: 110 / 10,
                          offset: Offset(0, 110 / 10),
                        ),
                      ],
                    ),
                    child: MaterialButton(
                      color: CustomColors.primary,
                      padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide.none,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                                width: 20,
                                child: Icon(
                                  Icons.location_off,
                                  color: Colors.white,
                                  size: 35,
                                )),
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "Es necesario activar los permisos de ubicación para continuar. ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal),
                                      textAlign: TextAlign.center),
                                ),
                              )
                            ],
                          ),
                          Row(
                            // Replace with a Row for horizontal icon + text
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "Revisar los servicios de ubicación.",
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                  width: 20,
                                  child: Icon(
                                    FontAwesomeIcons.chevronRight,
                                    color: Colors.white,
                                    size: 20,
                                  )),
                            ],
                          )
                        ],
                      ),
                      onPressed: () async {
                        registerLocation(context,contextDialog: null);
                      },
                    ),
                  ),
                ),
              ),
              onWillPop: () async {
                return false;
              });
        }) ,
        ) ;
      },
    );
  }
}*/

Future<void> getPermissionNotificationWeb() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');
}

void notificationWebListener(BuildContext context) {
  final provider = Provider.of<AppProvider>(context, listen: false);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data.toString()}');

    if (message.data != null && message.data != {}) {
      NotificationModel notification = NotificationModel.fromJson(message.data);

      if (provider.showingNotification == null) {
        provider.setShowingNotification(notification);
        new Timer(Duration(milliseconds: 500), () async {
          showCustomNotification(context, notification);
        });
      }
      print(
          'Message also contained a notification: ${message.notification!.body}');
    }
  });
}

Future<bool> requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    // Solicita el permiso de almacenamiento si no está otorgado
    status = await Permission.storage.request();
    
    if (status.isGranted) {
      print("Permiso de almacenamiento otorgado.");
      return true;
    } else {
      print("Permiso de almacenamiento denegado.");
            return false;

    }
  } else {
    print("El permiso de almacenamiento ya fue otorgado.");
                return true;

  }
}