import 'dart:async';
import 'dart:convert';

import 'package:app/components/buy_without_receipe.dart';
import 'package:app/components/main_layout.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/notification.dart';
import 'package:app/models/order.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/breathing.dart';
import 'package:app/pages/client/client_archivist.dart';
import 'package:app/pages/client/client_buy_without_prescription.dart';
import 'package:app/pages/client/client_buy_without_prescription_studies.dart';
import 'package:app/pages/client/client_contact.dart';
import 'package:app/pages/client/client_contact_gp.dart';
import 'package:app/pages/client/client_edit_profile.dart';
import 'package:app/pages/client/client_orders.dart';
import 'package:app/pages/client/client_prescriptions.dart';
import 'package:app/pages/notifications.dart';
import 'package:app/pages/start.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({Key? key}) : super(key: key);

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String title = "";
  List<dynamic> contents = [];
  int contentSelectedIndex = 0;
  var timerPushService = null;
  late IO.Socket socket;
  var timerLocationServices = null;
  OrderModel? orderView = null;
  @override
  void initState() {
    super.initState();
    contents = [
      {
        "icon": Icons.self_improvement,
        "title": "Inicio",
        "widget": StartPage(true),
        "function": () {
          setContent(0);
        }
      },
      {
        "icon": FontAwesomeIcons.fileArchive.data,
        "title": "Archivero",
        "widget": ClientArchivist(),
        "function": () {
          setContent(1);
        }
      },
      // {
      //   "icon": FontAwesomeIcons.hospitalUser.data,
      //   "title": "Médico de cabecera",
      //   "widget": ClientContactGp(),
      //   "function": () {
      //     setContent(2);
      //   }
      // },
      // {
      //   "icon": FontAwesomeIcons.book.data,
      //   "title": "Consultas/recetas",
      //   "widget": ClientPrescriptions(setOrders),
      //   "function": () {
      //     setContent(3);
      //   }
      // },
      {
        "icon": FontAwesomeIcons.shoppingBasket.data,
        "title": "Surtir/solicitar",
        "widget": ClientBuyWithoutPrescription(setOrders),
        "function": () {
          // setContent(1);

          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (contextDialog) {
                return buyWithoutReceipe(
                  (String type)async {
                    if (type == "laboratory_studies") {
                     // setContent(11);
                      String linkStudies="https://laboratorioxotepingo.com/promociones.html";
              if (await canLaunch(linkStudies)) {
                            await launch(linkStudies);
                          }
                    } else {
                      setContent(10);
                    }
                    Navigator.pop(contextDialog);
                  },
                );
              });
        }
      },
      // {
      //   "icon": FontAwesomeIcons.book.data,
      //   "title": "Mis pedidos",
      //   "widget": ClientOrders(),
      //   "function": () {
      //    // setContent(5);
      //          showDialog(
      //         barrierDismissible: false,
      //         context: context,
      //         builder: (contextDialog) {
      //           return buyWithoutReceipe(
      //             (String type) {
      //               if (type == "laboratory_studies") {
      //                 setContent(11);
      //               } else {
      //                 setContent(10);
      //               }
      //               Navigator.pop(contextDialog);
      //             },
      //           );
      //         });
      //   }
      // },
      // {
      //   "icon": FontAwesomeIcons.wind.data,
      //   "title": "Ejercicios de respiración",
      //   "widget": Breathing(),
      //   "function": () {
      //     setContent(6);
      //   }
      // },
      {
        "icon": FontAwesomeIcons.comment.data,
        "title": "Ayuda y soporte técnico",
        "widget": ClientContact(),
        "function": () {
          setContent(7);
        },
      },
      {
        "icon": FontAwesomeIcons.bell.data,
        "title": "Notificaciones",
        "widget":
            Notifications(callbackOpenNotification: ({dynamic element = null}) {
          print("entre a abrir notificacion");

         if (element == "open_orders" || element == "open_order") {
  setContent(2, toNotifications: true); // antes era 5
} else if (element == "open_prescriptions" || element == "open_prescription") {
 // setContent(??, toNotifications: true); // Recetas comentadas, decidir nuevo destino o eliminar
} else if (element == "open_profile") {
  setContent(0, toNotifications: true);
}

        }),
        "function": () {
          setContent(4);
        },
      },
      {
        "icon": Icons.logout,
        "title": "Cerrar sesión",
        "widget": Container(),
        "function": () {
          logout(context);
        }
      },
      {
        "icon": FontAwesomeIcons.userAlt.data,
        "title": "Medicamentos",
        "widget": ClientBuyWithoutPrescription(setOrders),
        "function": () {},
        "hide": true
      },
      {
        "icon": FontAwesomeIcons.userAlt.data,
        "title": "Estudios de laboratorio",
        "widget": ClientBuyWithoutPrescriptionStudies(setOrders),
        "function": () {},
        "hide": true,
      }
    ];

    initSockets();
   /* if (!kIsWeb) {
      registerPushId();
      initPush();
      timerPushService = Timer.periodic(Duration(seconds: 30), (Timer t) {
        registerPushId();
      });
    } */
    if (kIsWeb) initPushWeb();
    registerLocation(context);
    timerLocationServices = Timer.periodic(Duration(seconds: 30), (Timer t) {
      registerLocation(context);
    });
  }

  @override
  void dispose() {
    try {
      if (timerPushService != null) timerPushService?.cancel();
    } catch (e) {}
    try {
      if (timerLocationServices != null) timerLocationServices?.cancel();
    } catch (e) {}
    super.dispose();
  }

  /*initPush() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent notification) async {});
    OneSignal.shared.setNotificationOpenedHandler((openedResult) {
      dynamic additionalData = openedResult.notification.additionalData;
      if (additionalData.containsKey("notification")) {
        simpleLoading(context, (BuildContext loadingContext) async {
          WebService(context)
              .getNotificationsById(
                  additionalData["notification"], provider.user.token ?? "")
              .then((notificationTmp) {
            Navigator.pop(loadingContext);

            String type = getTypeUser(context);
            if (type == "client") {
              openNotificationClient(context, notificationTmp);
            } else {
              //openNotificationProfesional(context, notificationTmp);
            }
          }).catchError((e) {
            Navigator.pop(loadingContext);
            print(e);
          });
        });
      }
    });
  }*/

  /*registerPushId() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.user.one_signal_id == null ||
        provider.user.one_signal_id!.trim() == "") {
      try {
        var status = await OneSignal.shared.getDeviceState();
        String? onesignalUserId = status!.userId;

        WebService(context)
            .updateTokenPushUser(
                (Theme.of(context).platform == TargetPlatform.android)
                    ? "android"
                    : "ios",
                onesignalUserId!,
                provider.user.token ?? "")
            .then((value) => provider.setUser(value));
      } catch (e) {}
    }
  }*/

  dynamic _tokenStream;
  initPushWeb() async {
    await getPermissionNotificationWeb();
    print("Entry on registerPushIdWeb");
    final provider = Provider.of<AppProvider>(context, listen: false);
    FirebaseMessaging.instance.getToken().then(changeTokenWeb);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(changeTokenWeb);
    notificationWebListener(context);
  }

  void changeTokenWeb(String? token) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    if (!(token is String)) return;
    try {
      WebService(context)
          .updateTokenWebPushUser(token ?? "", provider.user.token ?? "")
          .then((value) => provider.setUser(value));
    } catch (e) {}
  }

  initSockets() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    socket = io(
        apiSocket,
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .setExtraHeaders({'foo': 'bar'}) // optional
            .build());
    socket.connect();

    socket.onConnect((_) async {
      socketObject = socket;
      print("Iam connected");
      ;
    });

    socket.on("on-new-notification", (notification) {
      try {
        final provider = Provider.of<AppProvider>(context, listen: false);
        NotificationModel notificationTmp =
            NotificationModel.fromJson(notification);
        if (notificationTmp.user!.id == provider.user.id) {
          List<NotificationModel> notificationsTmp = provider.notifications;
          notificationsTmp.insert(0, notificationTmp);
          provider.setNotifications(notificationsTmp);
          provider.setNotificationsUnread(provider.notificationsUnread + 1);

          //openNotification

          if (provider.showingNotification == null && kIsWeb) {
            provider.setShowingNotification(notificationTmp);
            new Timer(Duration(milliseconds: 500), () async {
              showCustomNotification(context, notificationTmp);
            });
          }

          //
        }
      } catch (e) {
        print(e);
      }
    });

    socket.on("on-delete-users", (users) {
      print("entry on on-delete-users");
      try {
        final provider = Provider.of<AppProvider>(context, listen: false);
        if (users is String) users = jsonDecode(users);
        List<UserModel> usersTmp = users.map<UserModel>((user) {
          return UserModel.fromJson(user);
        }).toList();

        usersTmp.forEach((user) {
          if (user.id == provider.user.id) logout(context, direct: true);
        });
      } catch (e) {
        print(e);
      }
    });

    socket.on("on-disabled-users", (users) {
      print("entry on on-disabled-users");
      try {
        final provider = Provider.of<AppProvider>(context, listen: false);
        if (users is String) users = jsonDecode(users);
        List<UserModel> usersTmp = users.map<UserModel>((user) {
          return UserModel.fromJson(user);
        }).toList();

        usersTmp.forEach((user) {
          if (user.id == provider.user.id) logout(context, direct: true);
        });
      } catch (e) {
        print(e);
      }
    });

    socket.onConnectError((e) {
      print("error sokets: ");
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      contents,
      contentSelectedIndex,
      callback,
      (){
         setContent(0, toNotifications: true);
      },
      hideMenus: [8],
    );
  }

  setContent(int index, {bool toNotifications = false}) {
    double widthLeftMenu =
        (MediaQuery.of(context).size.width >= breakPointDesktop)
            ? desktopMenuLeftWidth
            : 0;

    setState(() {
      contentSelectedIndex = index;
    });
    if (widthLeftMenu <= 0 && toNotifications == false)
      Navigator.of(context).pop();
  }

  setOrders() {
    double widthLeftMenu =
        (MediaQuery.of(context).size.width >= breakPointDesktop)
            ? desktopMenuLeftWidth
            : 0;

    setState(() {
      contentSelectedIndex = 2;
    });
    //if(widthLeftMenu<=0)
    // Navigator.of(context).pop();
  }

  callback() {
    setContent(8, toNotifications: true);
  }
}

