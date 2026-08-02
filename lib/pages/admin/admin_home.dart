import 'dart:async';
import 'dart:convert';

import 'package:app/components/dialog_avoid_bottom.dart';
import 'package:app/components/main_layout.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/notification.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/admin/admin_approve_order.dart';
import 'package:app/pages/admin/admin_categories.dart';
import 'package:app/pages/admin/admin_config.dart';
import 'package:app/pages/admin/admin_edit_profile.dart';
import 'package:app/pages/admin/admin_laboratory.dart';
import 'package:app/pages/admin/admin_orders.dart';
import 'package:app/pages/admin/admin_pharmacy.dart';
import 'package:app/pages/admin/admin_promotions.dart';
import 'package:app/pages/admin/admin_statics.dart';
import 'package:app/pages/admin/admin_users.dart';
import 'package:app/pages/notifications.dart';

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

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String title = "";
  List<dynamic> contents = [];
  int contentSelectedIndex = 0;
  var timerPushService = null;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    contents = [
      {
        "icon": FontAwesomeIcons.userAlt,
        "title": "Mi cuenta",
        "widget": AdminEditProfile(),
        "function": () {
          setContent(0);
        }
      },
      {
        "icon": FontAwesomeIcons.chartLine,
        "title": "Estadísticas",
        "widget": AdminStatics(),
        "function": () {
          setContent(1);
        }
      },
      {
        "icon": FontAwesomeIcons.cog,
        "title": "Configuraciones",
        "widget": AdminConfig(),
        "function": () {
          setContent(2);
        }
      },
      {
        "icon": FontAwesomeIcons.folder,
        "title": "Categorías",
        "widget": AdminCategories(),
        "function": () {
          setContent(3);
        }
      },
      {
        "icon": FontAwesomeIcons.users,
        "title": "Usuarios",
        "widget": AdminUsers(),
        "function": () {
          setContent(4);
        }
      },
      {
        "icon": FontAwesomeIcons.building,
        "title": "Farmacias",
        "widget": AdminPharmacy(),
        "function": () {
          setContent(5);
        }
      },
      {
        "icon": FontAwesomeIcons.building,
        "title": "Laboratorios",
        "widget": AdminLaboratory(),
        "function": () {
          setContent(6);
        }
      },
      {
        "icon": FontAwesomeIcons.tag,
        "title": "Promociones",
        "widget": AdminPromotions(),
        "function": () {
          setContent(7);
        }
      },
      {
        "icon": FontAwesomeIcons.book,
        "title": "Pedidos",
        "widget": AdminOrders(),
        "function": () {
          setContent(0);

          WidgetsBinding.instance?.addPostFrameCallback((_) {
            searchPharmacyDialog();
          });
        }
      },
      {
        "icon": FontAwesomeIcons.bell,
        "title": "Notificaciones",
        "widget":
            Notifications(callbackOpenNotification: ({dynamic element = null}) {
          print("entre a abrir notificacion");

          if (element == "open_orders" || element == "open_order") {
            setContent(8, toNotifications: true);
          } else if (element == "open_profile") {
            setContent(0, toNotifications: true);
          }
        }),
        "function": () {
          setContent(9);
        }
      },
      {
        "icon": FontAwesomeIcons.book,
        "title": "Pedidos por aprobar",
        "widget": AdminApproveOrder(),
        "function": () {
          setContent(10);
        }
      },
      {
        "icon": Icons.logout,
        "title": "Cerrar sesión",
        "widget": Container(),
        "function": () {
          logout(context);
        }
      }
    ];

    initSockets();
    /*if (!kIsWeb) {
      registerPushId();
      initPush();
      timerPushService = Timer.periodic(Duration(seconds: 30), (Timer t) {
        registerPushId();
      });
    }*/
    if (kIsWeb) initPushWeb();
  }

  final formKeysearchDelivery = new GlobalKey<FormState>();
  final cSearch = TextEditingController();
  late StateSetter _setStatePharmacy;

  final cPharmacy = TextEditingController();

  searchPharmacyDialog() {
    final provider = Provider.of<AppProvider>(context, listen: false);

    Widget searchField = TextField(
      autofocus: false,
      controller: cSearch,
      style: TextStyle(color: Colors.black),
      textInputAction: TextInputAction.search,
      //maxLength: 1,
      textAlign: TextAlign.left,

      //focusNode: myFocusNode1,
      decoration: InputDecoration(
          counterText: '',
          hintText: "Buscar",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: InkWell(
            onTap: () {
              cSearch.text = "";
              //_refreshIndicatorKey.currentState!.show();
              searchPharmacy();
            },
            child: Icon(
              Icons.cancel,
              size: 20,
              color: CustomColors.primary,
            ),
          ),
          suffixIcon: InkWell(
            splashColor: CustomColors.primary,
            onTap: () {
              // _refreshIndicatorKey.currentState!.show();
              searchPharmacy();
            },
            child: Icon(
              Icons.search,
              size: 20,
              color: CustomColors.primary,
            ),
          ),
          //contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          contentPadding: const EdgeInsets.fromLTRB(45, 0, 0, 0),
          //contentPadding: EdgeInsets.zero,
          filled: true,
          isDense: true,
          fillColor: Colors.grey[300],
          focusColor: Colors.grey[200],
          hoverColor: Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Colors.transparent, width: 0.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Colors.transparent, width: 0.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          border: InputBorder.none),
      onChanged: (valueSearch) {},
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(FocusNode());
        // _refreshIndicatorKey.currentState!.show();
        searchPharmacy();
      },
    );

    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (contextDialog) {
          return DialogAvoidBottom(
              content: StatefulBuilder(builder: (context, setStateT) {
            _setStatePharmacy = setStateT;
            return Stack(
              children: <Widget>[
                Container(
                  padding:
                      EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
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
                  child: Form(
                      key: formKeysearchDelivery,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            "Selecciona una farmacia o negocio para administrar sus pedidos",
                            style: TextStyle(
                                color: CustomColors.primary, fontSize: 18),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          searchField,
                          SizedBox(
                            height: 16.0,
                          ),
                          (messageFound != "")
                              ? Center(
                                  child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(messageFound),
                                ))
                              : Container(),
                          Container(
                            height: (MediaQuery.of(context).size.height * .50),
                            child: ListView(
                              children: [
                                Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: pharmacyFind.map((pharmacy) {
                                      PharmacyModel pTmp = pharmacy;
                                      return InkWell(
                                        onTap: () {
//aquiiiiii

                                          setStateT(() {});
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 8),
                                          child: Column(
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  provider.user
                                                      .pharmacy_assigned = pTmp;
                                                  await provider
                                                      .setUser(provider.user);
                                                  Navigator.pop(contextDialog);
                                                  if (MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      1000) {
                                                    setContent(8,
                                                        toNotifications: true);
                                                  } else {
                                                    setContent(8);
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 2.0,
                                                      vertical: 2.0),
                                                  child: Container(
                                                    constraints: BoxConstraints(
                                                        minHeight: 20,
                                                        maxHeight: 220,
                                                        maxWidth:
                                                            double.infinity,
                                                        minWidth: 20),
                                                    child: Stack(
                                                      children: [
                                                        Positioned.fill(
                                                          child: Card(
                                                            color: Colors.white,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade800,
                                                                  child: Row(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Container(
                                                                              width: 50,
                                                                              height: 50,
                                                                              decoration: new BoxDecoration(
                                                                                border: new Border.all(
                                                                                  width: 1,
                                                                                  color: Colors.grey.shade200,
                                                                                ),
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors.grey.shade200,
                                                                                    spreadRadius: 2,
                                                                                    blurRadius: 2,
                                                                                    offset: Offset(0, 0), // changes position of shadow
                                                                                  ),
                                                                                ], // border color
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
                                                                                child: (pTmp.cover != null && getImageUrl(pTmp.cover!).trim() != "")
                                                                                    ? ClipRRect(
                                                                                        borderRadius: BorderRadius.circular(50.0),
                                                                                        child: FadeInImage.assetNetwork(
                                                                                          placeholder: "assets/images/loading-image1.gif",
                                                                                          image: getImageUrl(pTmp.cover!),
                                                                                          fit: BoxFit.cover,
                                                                                        ),
                                                                                      )
                                                                                    : Container(
                                                                                        decoration: new BoxDecoration(color: Colors.transparent, borderRadius: new BorderRadius.all(Radius.circular(50.0))),
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.all(8.0),
                                                                                          child: Image.asset(
                                                                                            "assets/images/avatar.png",
                                                                                            fit: BoxFit.cover,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(vertical: 8.0),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                                                                child: Text(pTmp.title ?? "", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 3),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Flexible(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(vertical: 8.0),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                                                              child: Text((pTmp.category != null) ? pTmp.category!.title ?? "" : "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 3),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Flexible(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.symmetric(vertical: 8.0),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                                                              child: Text(pTmp.title ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 3),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top:
                                                                          12.0),
                                                                  child: Container(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200,
                                                                      height: 1,
                                                                      width: double
                                                                          .infinity),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          10.0),
                                                                      child: ElevatedButton(
                                                                          style: ElevatedButton.styleFrom(elevation: 2, primary: Colors.grey.shade800, shape: StadiumBorder()),
                                                                          onPressed: () async {
                                                                            provider.user.pharmacy_assigned =
                                                                                pTmp;
                                                                            await provider.setUser(provider.user);
                                                                            Navigator.pop(contextDialog);

                                                                            if (MediaQuery.of(context).size.width <
                                                                                1000) {
                                                                              setContent(8, toNotifications: true);
                                                                            } else {
                                                                              setContent(8);
                                                                            }
                                                                          },
                                                                          child: Container(
                                                                            height:
                                                                                35.0,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(right: 8.0),
                                                                                  child: Icon(Icons.chevron_right, color: Colors.white, size: 15.0),
                                                                                ),
                                                                                Text(
                                                                                  "Seleccionar",
                                                                                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          )),
                                                                    )
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned(
                                                            top: 0,
                                                            left: 0,
                                                            child: Container(
                                                                decoration: new BoxDecoration(
                                                                    color: (pTmp.approved ==
                                                                                null ||
                                                                            pTmp.approved ==
                                                                                "not_approved")
                                                                        ? Colors
                                                                            .orange
                                                                        : Colors
                                                                            .green,
                                                                    borderRadius: new BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            12.0))),
                                                                width: 12,
                                                                height: 12)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8.0,
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList())
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                  child: MaterialButton(
                                      onPressed: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      },
                                      child: Text("Cancelar")),
                                ),
                                Expanded(
                                  child: MaterialButton(
                                      onPressed: () {
                                        searchPharmacy();
                                      },
                                      child: Text("Buscar")),
                                )
                              ],
                            ),
                          )
                        ],
                      )),
                )
              ],
            );
          }));
        });

    searchPharmacy();
  }

  List<PharmacyModel> pharmacyFind = [];
  String messageFound = "";
  searchPharmacy() {
    simpleLoading(context, (BuildContext contextDialog) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      return WebService(context)
          .getPharmacies(0, 0, context, provider.user.token ?? "",
              search: cSearch.text)
          .then((value) {
        if (value.length <= 0) {
          messageFound = "No fue encontrado ningún elemento";
        } else {
          messageFound = "";
        }

        setState(() {
          pharmacyFind = value;
        });

        try {
          _setStatePharmacy(() {});
        } catch (e) {}
        Navigator.pop(contextDialog);
      }).catchError((e) {
        Navigator.pop(contextDialog);
        showErrorsDialog(context, e);
      });
    });
  }

  @override
  void dispose() {
    try {
      if (timerPushService != null) timerPushService?.cancel();
    } catch (e) {}

    super.dispose();
  }

 /* initPush() {
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

 /* registerPushId() async {
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
    final provider = Provider.of<AppProvider>(context, listen: true);
    List<int> hideMenus = [];
    if (provider.user.roles.length > 0 &&
        provider.user.roles[0].name == "admin") {
      hideMenus = [2, 3, 4];
    }
    return MainLayout(
      contents,
      contentSelectedIndex,
      callback,
       (){
         setContent(0);
      },
      hideMenus: hideMenus,
    );
  }

  setContent(int index, {bool toNotifications = false}) {
    double widthLeftMenu =
        (MediaQuery.of(context).size.width >= breakPointDesktop)
            ? desktopMenuLeftWidth
            : 0;
    print(index);
    setState(() {
      contentSelectedIndex = index;
    });
    //if (widthLeftMenu <= 0 && toNotifications == false)
    // Navigator.of(context).pop();
  }

  callback() {
    setContent(9, toNotifications: true);
  }
}
