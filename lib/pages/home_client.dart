import 'dart:async';
import 'dart:convert';

import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/advert.dart';
import 'package:app/models/bid.dart';
import 'package:app/models/message.dart';
import 'package:app/models/notification.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/breathing.dart';

import 'package:app/pages/chat.dart';
import 'package:app/pages/edit_advert.dart';

import 'package:app/pages/notifications.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:app/compat/flutter_page_transition.dart';
//import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class HomeClient extends StatefulWidget {
  HomeClient({Key? key}) : super(key: key);

  @override
  _HomeClientState createState() => _HomeClientState();
}

class _HomeClientState extends State<HomeClient> {
  late IO.Socket socket;
  var timerPushService = null;
  var showDialogLowBudget = true;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);
    initSockets();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      //initPush();
      checkAdvertsPendingAccept(context);
      checkAdvertsPendingQualification(context);

      if (queryParams != null && kIsWeb) {
        print("Si hay parametros son");
        print(queryParams);

        String type = getTypeUser(context);
        if (type == "client") {
          openNotificationClient(
              context,
              new NotificationModel(
                  id: null,
                  title: "",
                  content: "",
                  data: queryParams,
                  link: ""));
          queryParams = null;
        } else {
          // openNotificationProfesional(
          //     context,
          //     new NotificationModel(
          //         id: null,
          //         title: "",
          //         content: "",
          //         data: queryParams,
          //         link: ""));
          queryParams = null;
        }
      }
    });
   /* timerPushService = Timer.periodic(Duration(seconds: 30), (Timer t) {
      registerPushId();
    });*/

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      openAcceptLegalDocuments(context, provider.user);
    });
  }

  @override
  void dispose() {
    try {
      if (timerPushService != null) timerPushService?.cancel();
      //socket.onDisconnect((_) => print('disconnect'));
      //socket.dispose();
    } catch (e) {}
    super.dispose();
  }
/*
  initPush() {
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
  } */

  /* registerPushId() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.user.one_signal_id == null ||
        provider.user.one_signal_id!.trim() == "") {
      try {
        var status = await OneSignal.shared.getDeviceState();
        String? onesignalUserId = status!.userId;
        print("onesignalUserId: $onesignalUserId");

        WebService(context)
            .updateTokenPushUser(
                (Theme.of(context).platform == TargetPlatform.android)
                    ? "android"
                    : "ios",
                onesignalUserId!,
                provider.user.token ?? "")
            .then((value) => provider.setUser(value));
      } catch (e) {
        print("error on registerPushId");
      }
    }
  } */

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
      await WebService(context)
          .updateMessagesToReceived(provider.user.token ?? "");
      socket.emit(
          'set-update-messages', UserModel(roles: []).toJson(provider.user));
    });

    socket.on("on-new-notification", (notification) {
      /*  try {
        final provider = Provider.of<AppProvider>(context, listen: false);
        NotificationModel notificationTmp =
            NotificationModel.fromJson(notification);
        if (notificationTmp.user!.id == provider.user.id) {
          List<NotificationModel> notificationsTmp = provider.notifications;
          notificationsTmp.insert(0, notificationTmp);
          provider.setNotifications(notificationsTmp);
          provider.setNotificationsUnread(provider.notificationsUnread + 1);
          AssetsAudioPlayer.newPlayer().open(
              Audio("assets/sound/notification.mp3"),
              autoStart: true,
              showNotification: false,
              loopMode: LoopMode.none);

          if (provider.showingNotification == null) {
            provider.setShowingNotification(notificationTmp);

            new Timer(Duration(milliseconds: 1000), () async {
              showCustomNotification(context, notificationTmp);
            });
          }
        }
      } catch (e) {
        print(e);
      }*/
    });

    socket.on("on-update-adverts", (adverts) {
      print("entry on on-update-adverts");
      try {
        final provider = Provider.of<AppProvider>(context, listen: false);
        if (adverts is String) adverts = jsonDecode(adverts);
        List<AdvertModel> advertsTmp = adverts.map<AdvertModel>((advert) {
          return AdvertModel.fromJson(advert);
        }).toList();
        advertsTmp.forEach((advertToReplace) {
          print("Actualización desde sockets de la advert id: " +
              (advertToReplace.id ?? ""));
          updateAppProviderAdvert(context, advertToReplace);
          if (((advertToReplace.work_status == null ||
                      advertToReplace.work_status == "") ||
                  advertToReplace.bids!.length <= 0) &&
              advertToReplace.status == "red" &&
              advertToReplace.type == "auction" &&
              advertToReplace.user != null &&
              advertToReplace.user!.id == provider.user.id) {
            provider.advertsPendingAccept.insert(0, advertToReplace);
          }
          if ((advertToReplace.professional_qualification == null ||
                  advertToReplace.professional_qualification == "") &&
              advertToReplace.status == "red" &&
              advertToReplace.work_status == "finalized" &&
              advertToReplace.user != null &&
              advertToReplace.user!.id == provider.user.id) {
            provider.advertsPendingQualification.insert(0, advertToReplace);
          }
        });
        provider.setAdvertsPendingAccept(provider.advertsPendingAccept);
        provider.setAdvertsPendingQualification(
            provider.advertsPendingQualification);
        checkAdvertsPendingAccept(context);
        checkAdvertsPendingQualification(context);
      } catch (e) {
        print(e);
      }
    });

    socket.on("on-update-users", (users) {
      print("entry on on-update-users");
      try {
        final provider = Provider.of<AppProvider>(context, listen: false);
        if (users is String) users = jsonDecode(users);
        List<UserModel> usersTmp = users.map<UserModel>((user) {
          return UserModel.fromJson(user);
        }).toList();

        usersTmp.forEach((user) {
          if (user.id == provider.user.id) {
            print("My user updated from sockets");

            provider.user.status = user.status;
            provider.user.confirm_email_token = user.confirm_email_token;

            provider.user.accept_doc1 = user.accept_doc1;
            provider.user.accept_doc2 = user.accept_doc2;
            provider.user.accept_doc3 = user.accept_doc3;
            provider.user.accept_doc4 = user.accept_doc4;

            provider.user.accept_doc5 = user.accept_doc5;
            provider.user.accept_doc6 = user.accept_doc6;
            provider.setUser(provider.user);

            WidgetsBinding.instance?.addPostFrameCallback((_) {
              openAcceptLegalDocuments(context, provider.user);
            });
          }
        });
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

    socket.on("on-config-update", (config) {
      print("entry on on-config-update");
      try {
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.setConfig(jsonDecode(jsonEncode(config)));
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

    return Scaffold(
        backgroundColor: CustomColors.primary,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Column(children: [
              Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: kIsWeb
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () {},
                                          child: Column(
                                            children: [
                                              Image(
                                                width: kIsWeb
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        .20
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        .20,
                                                fit: kIsWeb
                                                    ? BoxFit.fitWidth
                                                    : BoxFit.scaleDown,
                                                image: AssetImage(
                                                    'assets/images/eleccion-cliente-circulo-icon.png'),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text("Subastas",
                                                    style: TextStyle(
                                                        fontSize: 28,
                                                        color: Colors.black)),
                                              )
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {},
                                          child: Column(
                                            children: [
                                              Image(
                                                width: kIsWeb
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        .20
                                                    : MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        .20,
                                                fit: kIsWeb
                                                    ? BoxFit.fitWidth
                                                    : BoxFit.scaleDown,
                                                image: AssetImage(
                                                    'assets/images/eleccion-anunciate-circulo-icon.png'),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text("Anúnciate",
                                                    style: TextStyle(
                                                        fontSize: 28,
                                                        color: Colors.black)),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ])
                            : Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        Image(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .20,
                                          image: AssetImage(
                                              'assets/images/eleccion-cliente-circulo-icon.png'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text("Subastas",
                                              style: TextStyle(
                                                  fontSize: 28,
                                                  color: Colors.black)),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        Image(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .20,
                                          image: AssetImage(
                                              'assets/images/eleccion-anunciate-circulo-icon.png'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text("Anúnciate",
                                              style: TextStyle(
                                                  fontSize: 28,
                                                  color: Colors.black)),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                      ),
                      Positioned(
                        height: kIsWeb ? 100 : 80,
                        left: 0,
                        top: 10,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                                child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              child: Image(
                                                height: kIsWeb ? 50 : 35,
                                                image: AssetImage(
                                                    'assets/images/client-boton-perfil.png'),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text("Perfil",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: kIsWeb ? 20 : 15,
                                                color: Colors.black))
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              child: Notifications(),
                                              type:
                                                  PageTransitionType.slideInUp,
                                              duration:
                                                  Duration(milliseconds: 250)));
                                    },
                                    child: Container(
                                      width: kIsWeb ? 40 : 31,
                                      height: kIsWeb ? 40 : 30,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                              child: Transform.scale(
                                                  scale: 1.8,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 25.0,
                                                            top: 8.0),
                                                    child: Icon(
                                                        Icons.notifications,
                                                        color: Colors.white,
                                                        size: kIsWeb ? 30 : 20),
                                                  ))),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              child: Center(
                                                child: FittedBox(
                                                  fit: BoxFit.fitWidth,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            2.0),
                                                    child: Text(
                                                      provider
                                                          .notificationsUnread
                                                          .toString(),
                                                      textScaleFactor: 1,
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                                color: Colors.red,
                                              ),
                                              height: 25,
                                              width: 25,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ))
                          ],
                        ),
                      )
                    ],
                  ))
            ]),
          ),
        ));
  }

  checkAdvertsPendingQualification(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.advertsPendingQualification.length <= 0) return;

    final cComments = TextEditingController();

    Timer(Duration(milliseconds: 1500), () async {
      showDialog<void>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext contextd) {
          return StatefulBuilder(builder: (contextS, setStateD) {
            num qualificationTmp = 5;

            final provider = Provider.of<AppProvider>(contextS, listen: true);
            if (provider.advertsPendingQualification.length <= 0)
              return Container();
            //
            AdvertModel advert = provider.advertsPendingQualification[0];

            final commentsField = TextFormField(
              textInputAction: TextInputAction.done,
              readOnly: false,
              controller: cComments,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 5,
              validator: (val) {
                return requiredField(val ?? 0, context);
              },
              obscureText: false,
              style: TextStyle(fontSize: 18.0),
              //initialValue: Environment.localUsername(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: "Escribe tu comentario aquí...",
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                fillColor: Colors.white,
                focusColor: Colors.grey,
                hoverColor: Colors.grey,
                filled: true,
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade500, width: 1.0),
                    borderRadius: BorderRadius.circular(6.0)),
                focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade500, width: 1.0),
                    borderRadius: BorderRadius.circular(6.0)),
                enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade500, width: 1.0),
                    borderRadius: BorderRadius.circular(6.0)),
                errorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.red.shade500, width: 1.0),
                    borderRadius: BorderRadius.circular(6.0)),
                focusedErrorBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.red.shade500, width: 1.0),
                    borderRadius: BorderRadius.circular(6.0)),
              ),
              onChanged: (val) {
                setState(() {});
              },
              onEditingComplete: () {
                setState(() {});
              },
              onTap: () async {},
            );

            return WillPopScope(
                child: Scaffold(
                    backgroundColor: Colors.white,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      title: Text("VALORACIÓN",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 25,
                              color: CustomColors.primary)),
                      elevation: 0,
                      centerTitle: true,
                      leading: Container(),
                    ),
                    body: ListView(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shadowColor: Colors.transparent,
                                    minimumSize: Size(70, 10),
                                    primary: CustomColors.primary,
                                    side: BorderSide(
                                        width: 1.0,
                                        color: CustomColors.primary),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    padding: EdgeInsets.all(0)),
                                onPressed: () {},
                                child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Ver anuncio",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.0),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Icon(
                                              FontAwesomeIcons.arrowRight,
                                              size: 15,
                                              color: Colors.white),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10.0, left: 10, right: 10),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      decoration: new BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: new BorderRadius.all(
                                            Radius.circular(70.0)),
                                      ),
                                      child: (advert.professional_in_work!
                                                  .picture !=
                                              null)
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(70.0),
                                              child: FadeInImage.assetNetwork(
                                                placeholder:
                                                    "assets/images/loading-image1.gif",
                                                image: getImageUrl(advert
                                                    .professional_in_work!
                                                    .picture!),
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(
                                              decoration: new BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius: new BorderRadius
                                                          .all(
                                                      Radius.circular(45.0))),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Image.asset(
                                                  "assets/images/avatar.png",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {},
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Profesional",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 19,
                                                      color:
                                                          CustomColors.primary),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2),
                                              Text(
                                                  formatFirstUpper(advert
                                                          .professional_in_work!
                                                          .name ??
                                                      ""),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 19,
                                                      color: Colors.black),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        /* Center(
                          child: RatingBar(
                              initialRating: 5,
                              allowHalfRating: false,
                              ignoreGestures: false,
                              itemSize: 44.0,
                              direction: Axis.horizontal,
                              itemCount: 5,
                              ratingWidget: RatingWidget(
                                  full: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Icon(FontAwesomeIcons.solidStar,
                                        color: CustomColors.primary, size: 10),
                                  ),
                                  half: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Icon(FontAwesomeIcons.starHalfAlt,
                                        color: CustomColors.primary, size: 10),
                                  ),
                                  empty: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Icon(FontAwesomeIcons.star,
                                        color: CustomColors.primary, size: 10),
                                  )),
                              onRatingUpdate: (double rating) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      qualificationTmp = rating;
                                    });
                                  }
                                });
                              }),
                        ),*/
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "ESCRIBE UN COMENTARIO",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 25,
                                color: CustomColors.primary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: commentsField,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 15.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 2,
                                primary: CustomColors.primary,
                                shape: StadiumBorder()),
                            onPressed: () {
                              if (mounted) {
                                sendQualifications(
                                    contextd,
                                    advert,
                                    advert.professional_in_work!,
                                    qualificationTmp,
                                    cComments.text);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 35.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Enviar",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 17.0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                onWillPop: () async {
                  return false;
                });
          });
        },
      );
    });
  }

  sendQualifications(BuildContext contextd, AdvertModel advert, UserModel user,
      num qualification, String comment) {
    final provider = Provider.of<AppProvider>(contextd, listen: false);
    simpleLoading(context, (BuildContext loadingContext) {
      WebService(context)
          .rateUser(advert.id ?? "", user.id ?? "", qualification,
              "professional", provider.user.token ?? "",
              comment: comment)
          .then((advertTmp) {
        Navigator.pop(loadingContext);

        initProcess(context, provider.user.token ?? "", () {});
      }).catchError((e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e);
      });
    });
  }

  checkAdvertsPendingAccept(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.advertsPendingAccept.length <= 0) return;
    double hFoot = 60;
    showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext contextd) {
        return StatefulBuilder(builder: (contextS, setState) {
          final provider = Provider.of<AppProvider>(contextS, listen: true);
          if (provider.advertsPendingAccept.length <= 0) return Container();
          //
          AdvertModel advert = provider.advertsPendingAccept[0];

          List<BidModel> bids = []..addAll(advert.bids ?? []);
          bids.sort((a, b) => a.amount!.compareTo(b.amount!));

          List<String> toRemove = [];
          for (var i = 0; i < bids.length; i++) {
            for (var i2 = 0; i2 < bids.length; i2++) {
              if (bids[i].user!.id == bids[i2].user!.id && i2 > i) {
                toRemove.add(bids[i2].id ?? "");
              }
            }
          }

          bids.removeWhere((element) => toRemove.contains(element.id));
          List<BidModel> bidsTmp = []..addAll(bids);

          //dos mejores pujas
          List<BidModel> twoBest = [];
          bids.forEach((bid) {
            if (twoBest.length < 2) twoBest.add(bid);
          });

          //mejor puja a la baja sin a ver modificado tiempo de finalización ni haber dado en weekendonly
          dynamic bestUnmodified = null;
          bids.forEach((bid) {
            if ((bid.proposed_date == null || bid.proposed_date == "") &&
                (bid.weekend_only == null || bid.weekend_only == false) &&
                bestUnmodified == null) bestUnmodified = bid;
          });

          //mejor valorado
          dynamic bestRated = null;

          //recomendado (gold)
          List<BidModel> recomendedL = [];
          dynamic recomended = null;

          recomendedL.shuffle();
          if (recomendedL.length > 0) recomended = recomendedL[0];

          if ((advert.work_status == null || advert.work_status == "") &&
              showDialogLowBudget &&
              advert.generic_questionnaire!.containsKey("answer2") &&
              advert.generic_questionnaire!["answer2"].toString() ==
                  "Profesional") {
            Timer(Duration(seconds: 2), () async {
              if (mounted)
                showErrorsDialog(contextS, [
                  "Ojo, presupuestos excesivamente bajos, puede significar la baja calidad de los materiales."
                ]);

              setState(() {
                if (showDialogLowBudget) showDialogLowBudget = false;
              });
            });
          }

          var showingWihoutPay = (recomendedL.length +
              (bestRated != null ? 1 : 0) +
              (bestUnmodified != null ? 1 : 0) +
              twoBest.length);

          //
          return WillPopScope(
              child: (bidsTmp.length > 0)
                  ? Scaffold(
                      body: Stack(
                      children: [
                        Positioned.fill(
                          bottom: hFoot,
                          child: ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                          "La subasta del anuncio ubicado en ${advert.location!.city ?? ""} ${advert.location!.written_address ?? ""} n. ${advert.location!.num ?? ""}  ha finalizado.",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: CustomColors.primary,
                                              fontWeight: FontWeight.normal)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          shadowColor: Colors.transparent,
                                          minimumSize: Size(70, 10),
                                          primary: CustomColors.primary,
                                          side: BorderSide(
                                              width: 1.0,
                                              color: CustomColors.primary),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          padding: EdgeInsets.all(0)),
                                      onPressed: () {},
                                      child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Ver anuncio",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13.0),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Icon(
                                                    FontAwesomeIcons.arrowRight,
                                                    size: 15,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "¡Elija alguna puja para comenzar el proceso de trabajo, aquí te mostramos las mejores opciones!",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: CustomColors.primary,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: twoBest.length > 0 &&
                                    checkEmpty(advert.show_all_bids) == false,
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 18.0),
                                        child: Text(
                                          "Mejores pujas",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: CustomColors.primary,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Column(
                                        children:
                                            twoBest.asMap().entries.map((e) {
                                          if (e.key == twoBest.length - 1) {
                                            return itemBidPendient(
                                                e.value, advert,
                                                showDivider: false);
                                          } else {
                                            return itemBidPendient(
                                                e.value, advert,
                                                showDivider: true);
                                          }
                                        }).toList(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: bestUnmodified != null &&
                                    checkEmpty(advert.show_all_bids) == false,
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 18.0),
                                        child: Text(
                                          "Mejor puja cumpliendo con los requerimientos",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: CustomColors.primary,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Column(
                                        children: (bestUnmodified != null)
                                            ? [
                                                itemBidPendient(
                                                    bestUnmodified, advert,
                                                    showDivider: false)
                                              ]
                                            : [],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: bestRated != null &&
                                    checkEmpty(advert.show_all_bids) == false,
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 18.0),
                                        child: Text(
                                          "Mejor valorado",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: CustomColors.primary,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Column(
                                        children: (bestRated != null)
                                            ? [
                                                itemBidPendient(
                                                    bestRated, advert,
                                                    showDivider: false)
                                              ]
                                            : [],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: recomended != null &&
                                    checkEmpty(advert.show_all_bids) == false,
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 18.0),
                                        child: Text(
                                          "PROFESIONAL ORO",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: CustomColors.primary,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Column(
                                        children: (recomended != null)
                                            ? [
                                                itemBidPendient(
                                                    recomended, advert,
                                                    showDivider: false)
                                              ]
                                            : [],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: advert.show_all_bids!.trim() != "",
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 18.0),
                                        child: Text(
                                          "Has pagado ${advert.show_all_bids} €",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: CustomColors.primary,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Column(
                                        children:
                                            bidsTmp.asMap().entries.map((e) {
                                          if (e.key == bidsTmp.length - 1 ||
                                              e.key == 29) {
                                            return itemBidPendient(
                                                e.value, advert,
                                                showDivider: false);
                                          } else if (e.key < 30) {
                                            return itemBidPendient(
                                                e.value, advert,
                                                showDivider: true);
                                          } else {
                                            return Container();
                                          }
                                        }).toList(),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            left: 0,
                            height: hFoot,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 2,
                                    primary: Colors.white,
                                    shadowColor: Colors.transparent,
                                    shape: StadiumBorder(),
                                    side: BorderSide(
                                        width: 1.0,
                                        color: CustomColors.primary),
                                  ),
                                  onPressed: () {
                                    showCancelDialog(
                                        advert, bidsTmp, showingWihoutPay);
                                  },
                                  child: Container(
                                    height: 40.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Cancelar",
                                          style: TextStyle(
                                              color: CustomColors.primary,
                                              fontSize: 17.0),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Icon(FontAwesomeIcons.times,
                                              size: 15,
                                              color: CustomColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ))
                      ],
                    ))
                  : Scaffold(
                      body: Center(
                          child: ListView(
                      children: [
                        Column(children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                      "La subasta del anuncio ubicado en ${advert.location!.city ?? ""} ${advert.location!.written_address ?? ""} n. ${advert.location!.num ?? ""}  ha finalizado.",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: CustomColors.primary,
                                          fontWeight: FontWeight.normal)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shadowColor: Colors.transparent,
                                      minimumSize: Size(70, 10),
                                      primary: CustomColors.primary,
                                      side: BorderSide(
                                          width: 1.0,
                                          color: CustomColors.primary),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: EdgeInsets.all(0)),
                                  onPressed: () {},
                                  child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Ver anuncio",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.0),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Icon(
                                                FontAwesomeIcons.arrowRight,
                                                size: 15,
                                                color: Colors.white),
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .28,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "Lamentablemente su publicación no ha recibido ninguna puja, pero puede editarla y publicarla nuevamente",
                                style: TextStyle(
                                    color: CustomColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                                textAlign: TextAlign.center),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          ButtonTheme(
                            child: MaterialButton(
                              color: CustomColors.primary,
                              padding:
                                  EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: BorderSide.none,
                              ),
                              child: Text("Editar y publicar nuevamente",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        child: EditAdvert(advert, isNew: true),
                                        type: PageTransitionType.slideInRight,
                                        duration: Duration(milliseconds: 250)));
                              },
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text("O",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              textAlign: TextAlign.center),
                          ButtonTheme(
                            child: MaterialButton(
                              color: CustomColors.primary,
                              padding:
                                  EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: BorderSide.none,
                              ),
                              child: Text("Borrar definitivamente",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                deleteAdvert(advert);
                              },
                            ),
                          )
                        ]),
                      ],
                    ))),
              onWillPop: () async {
                //checkAdvertsPendingAccept(context, advertsPendient);
                return false;
              });
        });
      },
    );
  }

  Widget itemBidPendient(BidModel bid, AdvertModel advert,
      {showDivider = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    minimumSize: Size(70, 10),
                    primary: CustomColors.primary,
                    side: BorderSide(width: 1.0, color: CustomColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.all(0)),
                onPressed: () {},
                child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(FontAwesomeIcons.images,
                              size: 15, color: Colors.white),
                        ),
                        Text(
                          "Ver trabajos",
                          style: TextStyle(color: Colors.white, fontSize: 13.0),
                        ),
                      ],
                    )),
              ),
            ],
          ),
          Row(
            children: [
              InkWell(
                  onTap: () {
                    // ratingBottomSheetTemplate(context, bid.user!);
                    openMedals(context, bid.user!);
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        decoration: new BoxDecoration(
                          color: Colors.transparent,
                          borderRadius:
                              new BorderRadius.all(Radius.circular(48.0)),
                        ),
                        child: (bid.user!.picture != null)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(48.0),
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                      "assets/images/loading-image1.gif",
                                  image: getImageUrl(bid.user!.picture!),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                decoration: new BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(48.0))),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Image.asset(
                                    "assets/images/avatar.png",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            getMedalsWidget(context, bid.user!),
                            Visibility(
                              visible: bid.explanation != null &&
                                  bid.explanation != "",
                              child: InkWell(
                                onTap: () {
                                  showErrorsDialog(context, [bid.explanation]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Image.asset(
                                      "assets/images/explicacion_subasta.png",
                                      height: 28),
                                ),
                              ),
                            ),
                          ])
                    ],
                  )),
              Expanded(
                child: InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formatFirstUpper(bid.user!.name ?? ""),
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                  color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Text("${bid.amount} €",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black)),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shadowColor: Colors.transparent,
                        minimumSize: Size(70, 10),
                        primary: CustomColors.primary,
                        side:
                            BorderSide(width: 1.0, color: CustomColors.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.all(0)),
                    onPressed: () {
                      confirmAcceptBid(bid, advert);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Aceptar puja",
                        style: TextStyle(color: Colors.white, fontSize: 13.0),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Visibility(
                visible: bid.weekend_only ?? false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Image.asset(
                      "assets/images/anuncio-weekend-only-icon.png",
                      height: 28),
                ),
              ),
              Visibility(
                visible: bid.proposed_date != null &&
                    bid.proposed_date!.trim() != "",
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.hourglassHalf,
                          size: 20, color: CustomColors.primary),
                      Text(getDateFromStringFormat(bid.proposed_date ?? ""),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14))
                    ],
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible: showDivider,
            child: Divider(
              color: Colors.grey.shade800,
            ),
          )
        ],
      ),
    );
  }

  showCancelDialog(
      AdvertModel advert, List<BidModel> bids, num showingWihoutPay) {
    late StateSetter _setState;
    final cBecause = TextEditingController();
    final provider = Provider.of<AppProvider>(context, listen: false);

    var costViewAll = getCostByTag(context, "view_all_bids");

    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext contextd) {
        final becauseField = TextFormField(
          textInputAction: TextInputAction.done,
          readOnly: false,
          controller: cBecause,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          validator: (val) {
            return requiredField(val ?? 0, context);
          },
          obscureText: false,
          style: TextStyle(fontSize: 18.0),
          //initialValue: Environment.localUsername(),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "¿Nos podrías decir por qué?",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            fillColor: Colors.white,
            focusColor: Colors.grey,
            hoverColor: Colors.grey,
            filled: true,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                borderRadius: BorderRadius.circular(6.0)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                borderRadius: BorderRadius.circular(6.0)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                borderRadius: BorderRadius.circular(6.0)),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade300, width: 1.0),
                borderRadius: BorderRadius.circular(6.0)),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade300, width: 1.0),
                borderRadius: BorderRadius.circular(6.0)),
          ),
          onChanged: (val) {
            setState(() {});
          },
          onEditingComplete: () {
            setState(() {});
          },
          onTap: () async {},
        );
        return StatefulBuilder(builder: (context, setStateD) {
          _setState = setState;
          return Dialog(
            insetPadding: getDialogInsetPaddin(context,
                customEdge:
                    EdgeInsets.all(MediaQuery.of(context).size.width * .08)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Container(
                    padding:
                        EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  backgroundColor: CustomColors.primary,
                                  child: Icon(
                                    FontAwesomeIcons.times,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            )
                          ],
                        ),
                        Text(
                            "Ver hasta 30 presupuestos (Otros profesionales que pujaron ${(bids.length - showingWihoutPay > 0) ? (bids.length - showingWihoutPay) : 0})",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 15,
                        ),
                        ButtonTheme(
                          child: MaterialButton(
                            color: CustomColors.primary,
                            padding:
                                EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide.none,
                            ),
                            child: Text("Ver por ${costViewAll} €",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            onPressed: () {
                              createPayment(context, "view_all_bids",
                                  (BuildContext loadingContext,
                                      String typePayment) {
                                WebService(context)
                                    .setShowAllBids(
                                        advert.id ?? "",
                                        "${costViewAll}",
                                        provider.user.token ?? "")
                                    .then((advertTmp) {
                                  Navigator.pop(loadingContext);
                                  updateAppProviderAdvert(context, advertTmp);
                                  initProcess(
                                      context, provider.user.token ?? "", () {
                                    Navigator.pop(loadingContext);
                                    goHome(context, provider.user.roles);
                                  });
                                }).catchError((e) {
                                  Navigator.pop(loadingContext);
                                  showErrorsDialog(context, e);
                                });
                              });
                            },
                          ),
                        ),
                        /*SizedBox(
                          height: 15,
                        ),
                        Text(
                            "Mi anuncio no corresponde a lo que quiero, quisiera editarlo y publicarlo nuevamente",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 15,
                        ),
                        ButtonTheme(
                          child: MaterialButton(
                            color: CustomColors.primary,
                            padding:
                                EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide.none,
                            ),
                            child: Text("Editar y publicar",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      child: EditAdvert(advert, isNew: true),
                                      type: PageTransitionType.slideInRight,
                                      duration: Duration(milliseconds: 250)));
                            },
                          ),
                        ),*/
                        SizedBox(
                          height: 15,
                        ),
                        Text("Borrarlo",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            textAlign: TextAlign.center),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: becauseField,
                        ),
                        ButtonTheme(
                          child: MaterialButton(
                            color: CustomColors.primary,
                            padding:
                                EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide.none,
                            ),
                            child: Text("Borrarlo",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            onPressed: () {
                              deleteAdvert(advert);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  confirmAcceptBid(BidModel bid, AdvertModel advert) {
    num cost = getCostByTag(context, "cancel_advert");
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return CustomDialog(
            "Por seguridad para el profesional y el correcto funcionamiento de la plataforma, la anulación de un presupuesto aceptado tendrá un coste de ${cost} euros",
            "¿Realmente desea aceptar la puja por el presupuesto de ${bid.amount} euros ?",
            "Aceptar",
            () {
              acceptBid(bid, advert);
            },
            useBtnCancel: true,
            textBtnCancel: "Rechazar",
            image: '',
            callBackBtnCancel: () {
              deleteAdvert(advert);
            },
          );
        });
  }

  acceptBid(BidModel bid, AdvertModel advert) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    simpleLoading(context, (BuildContext loadingContext) {
      WebService(context)
          .acceptBid(advert.id ?? "", bid.id ?? "", provider.user.token ?? "")
          .then((advertTmp) {
        Navigator.pop(loadingContext);
        updateAppProviderAdvert(context, advertTmp);
        initProcess(context, provider.user.token ?? "", () {
          Navigator.pop(loadingContext);
          goHome(context, provider.user.roles);
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            Navigator.push(
                context,
                PageTransition(
                    child: ChatPage(
                      advertTmp.professional_in_work!,
                      advert,
                      openMessage:
                          "Chapú recomienda que el pago al profesional sea la totalidad al finalizar la obra o adelantar como máximo un 30% si el profesional incluye los materiales en el presupuesto",
                    ),
                    type: PageTransitionType.slideInUp,
                    duration: Duration(milliseconds: 250)));
          });
        });
      }).catchError((e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e);
      });
    });
  }

  deleteAdvert(AdvertModel advert) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return CustomDialog(
            "",
            "¿Al aceptar está opción se borrará la subasta y el anuncio automáticamente?",
            "Aceptar",
            () {
              simpleLoading(context, (BuildContext loadingContext) {
                WebService(context)
                    .deleteAdvert(advert.id ?? "", provider.user.token ?? "")
                    .then((advertTmp) {
                  updateAppProviderAdvert(
                      context, new AdvertModel(id: advert.id ?? ""),
                      updateOfDelete: true);
                  Navigator.pop(loadingContext);

                  initProcess(context, provider.user.token ?? "", () {
                    Navigator.pop(loadingContext);
                    goHome(context, provider.user.roles);
                    WidgetsBinding.instance?.addPostFrameCallback((_) {});
                  });
                }).catchError((e) {
                  Navigator.pop(loadingContext);
                  showErrorsDialog(context, e);
                });
              });
            },
            useBtnCancel: true,
            image: '',
          );
        });
  }
}
