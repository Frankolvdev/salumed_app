import 'dart:async';

import 'package:app/components/fade_animation.dart';

import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/advert.dart';
import 'package:app/models/notification.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/chat.dart';

import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  Function? callbackOpenNotification;
  Notifications({Key? key, Function? this.callbackOpenNotification})
      : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  var _controllerScroll = ScrollController();

  final cQuestion = TextEditingController();
  PageController _pageController = PageController(initialPage: 0);

  num limit = 30;
  bool noMore = false;
  bool loading = false;

  DateTime currentDate = DateTime.now().toUtc();

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);

    currentDate = DateTime.now().toUtc();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState!.show();
    });

    _controllerScroll.addListener(() {
      if (_controllerScroll.position.atEdge) {
        if (_controllerScroll.position.pixels == 0) {
        } else {
          setState(() {
            loading = true;
          });
          loadMore();
        }
      }
    });
  }

  void dispose() {
    super.dispose();
    _controllerScroll.dispose();
  }

  Future<Null> loadMore() {
    setState(() {
      loading = true;
    });
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getNotifications(limit, provider.notifications.length, context,
            provider.user.token ?? "")
        .then((value) {
      if (value.length > 0) {
        if (mounted)
          setState(() {
            provider.notifications.addAll(value);
            provider.setNotifications(provider.notifications);
            noMore = false;
          });
      } else {
        noMore = true;
        print("entre a no hay más");
      }

      Timer(Duration(seconds: 1), () {
        WidgetsBinding.instance?.addPostFrameCallback((_) async {
          if (mounted)
            setState(() {
              loading = false;
            });
        });
      });
    }).catchError((e) {
      Timer(Duration(seconds: 1), () {
        if (mounted)
          setState(() {
            loading = false;
          });
      });
      showErrorsDialog(context, e);
    });
  }

  Future<Null> load() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getNotifications(limit, 0, context, provider.user.token ?? "")
        .then((value) {
      if (mounted)
        setState(() {
          provider.setNotifications(value);
        });
    }).catchError((e) {
      showErrorsDialog(context, e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    UserModel user = provider.user;

    List<Widget> progressWidgets =
        provider.notifications.asMap().entries.map((notification) {
      NotificationModel notificationTmp = notification.value;
      String created = getDateTimeFromStringFormat(
          DateTime.parse(notificationTmp.created_at!).toLocal().toString());
      return Visibility(
          visible: true,
          child: InkWell(
            onTap: () {
              simpleLoading(context, (BuildContext contextLoading) {
                WebService(context)
                    .readNotification(notificationTmp.id ?? "", context,
                        provider.user.token ?? "")
                    .then((notification) async {
                  await updateAppProviderNotification(context, notification);

                  Navigator.pop(contextLoading);
                  if (notification.data != null &&
                      notification.data.isNotEmpty) {
                    if (notification.data.containsKey("action")) {
                      String action = notification.data["action"];
                      try {
                        widget.callbackOpenNotification!(element: action);
                      } catch (e) {}
                    }
                  }
                }).catchError((e) {
                  Navigator.pop(contextLoading);
                  print(e);
                });
              });
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
              child: Card(
                color: (notificationTmp.status == "unread")
                    ? CustomColors.primary
                    : Colors.white,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 4, left: 8.0, right: 8.0),
                          child: Text(created,
                              style: TextStyle(
                                  color: (notificationTmp.status == "unread")
                                      ? Colors.white
                                      : CustomColors.primary,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ),
                        InkWell(
                          onTap: () {
                            final provider = Provider.of<AppProvider>(context,
                                listen: false);
                            simpleLoading(context,
                                (BuildContext loadingContext) {
                              WebService(context)
                                  .deleteNotification(notificationTmp.id ?? "",
                                      provider.user.token ?? "")
                                  .then((value) {
                                Navigator.pop(loadingContext);
                                this.load();
                              }).catchError((e) {
                                print(e);
                                Navigator.pop(loadingContext);
                                showErrorsDialog(context, e);
                              });
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(FontAwesomeIcons.times,
                                color: (notificationTmp.status == "unread")
                                    ? Colors.white
                                    : CustomColors.primary,
                                size: 17),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.notification_important,
                            size: 40,
                            color: (notificationTmp.status == "unread")
                                ? Colors.white
                                : CustomColors.primary),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Text(notificationTmp.title ?? "",
                                      style: TextStyle(
                                          color: (notificationTmp.status ==
                                                  "unread")
                                              ? Colors.white
                                              : CustomColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0, top: 5.0),
                                  child: Text(notificationTmp.content ?? "",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 14,
                                          color: (notificationTmp.status ==
                                                  "unread")
                                              ? Colors.white
                                              : Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 10),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ));
    }).toList();

    progressWidgets.add(Visibility(
      visible: loading,
      child: Container(
        width: 30,
        height: 30,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(CustomColors.primary)),
          ),
        ),
      ),
    ));
    if (noMore) {
      progressWidgets.add(Visibility(
        visible: !loading,
        child: Container(
            height: 30, child: Text("No hay mas notificaciones para mostrar.")),
      ));
    }
    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: RefreshIndicator(
            color: CustomColors.primary,
            key: _refreshIndicatorKey,
            displacement: MediaQuery.of(context).size.height * .40,
            onRefresh: load,
            child: SingleChildScrollView(
              controller: _controllerScroll,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                        maxHeight: double.infinity),
                    child: (provider.notifications.length <= 0)
                        ? Center(
                            child: Column(
                            children: [
                              Text(
                                "No hay ningúna notificación para mostrar",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                            ],
                          ))
                        : Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              constraints: kIsWeb
                                  ? BoxConstraints(maxWidth: 1000)
                                  : BoxConstraints(),
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: progressWidgets),
                            ),
                          ),
                  ),
                ],
              ),
            )));
  }
}
