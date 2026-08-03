import 'dart:async';

import 'package:app/components/custom_dialog.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/advert.dart';
import 'package:app/models/message.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/home_client.dart';

import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  UserModel user;
  AdvertModel advert;
  String openMessage;
  ChatPage(this.user, this.advert, {Key? key, this.openMessage = ""})
      : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Map<dynamic, dynamic> session = {};

  String typing = "";
  String messageText = "";
  String sendMessageHintText = "Escribe un mensaje...";
  bool initMessages = false;
  String loadingText = "Cargando chat...";

  final _formKey = GlobalKey<FormState>();
  int messagesUnread = 0;
  List<MessageModel> messages = [];

  bool loading = false;
  bool noMore = false;
  num limit = 20;
  num limitEnd = 20;

  var _controllerScroll = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      loadMessages();
      initSockets();
    });

    _controllerScroll.addListener(() {
      if (_controllerScroll.position.atEdge) {
        if (_controllerScroll.position.pixels == 0) {
        } else {
          loadMoreMessages();
        }
      }
    });
  }

  void dispose() {
    super.dispose();
    _controllerScroll.dispose();
  }

  initSockets() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (socketObject != null) {
      (socketObject as IO.Socket).on('on-new-messages', (data) async {
        MessageModel message = MessageModel.fromJson(data);
        await WebService(context)
            .updateMessagesToReceived(provider.user.token ?? "");
        if ((message.transmitter!.id == provider.user.id ||
                message.receiver!.id == provider.user.id) &&
            message.advert_id.toString() == widget.advert.id.toString()) {
          loadSilency();
        }
      });

      (socketObject as IO.Socket).on('on-update-messages', (data) {
        print("on-update-messages");
        try {
          // loadSilency();
        } catch (e) {}
      });
    } else {
      print("socket null");
    }
  }

  loadSilency() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await WebService(context).updateMessagesToRead(widget.user.id ?? "",
        widget.advert.id ?? "", provider.user.token ?? "");

    WebService(context)
        .getMessages(limitEnd, 0, widget.user.id ?? "", widget.advert.id ?? "",
            provider.user.token ?? "")
        .then((value) {
      if (mounted) {
        setState(() {
          messages = value;
        });
      }
    }).catchError((e) {
      showErrorsDialog(context, e);
    });
  }

  loadMessages() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    if (socketObject != null)
      (socketObject as IO.Socket).emit(
          'set-update-messages',
          UserModel(roles: []).toJson(
            widget.user,
          ));

    simpleLoading(context, (BuildContext loadingContext) async {
      await WebService(context).updateMessagesToRead(widget.user.id ?? "",
          widget.advert.id ?? "", provider.user.token ?? "");
      return WebService(context)
          .getMessages(limitEnd, 0, widget.user.id ?? "",
              widget.advert.id ?? "", provider.user.token ?? "")
          .then((value) {
        Navigator.pop(loadingContext);
        setState(() {
          messages = value;
        });

        checkPendients();
      }).catchError((e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e);
        checkPendients();
      });
    });
  }

  checkPendients() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (widget.advert.status_professional_paid_commission == null ||
        widget.advert.status_professional_paid_commission == "") {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (contextDialog) {
            return WillPopScope(
                child: CustomDialog(
                  "",
                  (checkHasRole(provider.user.roles, "client"))
                      ? "El profesional aún no ha completado el proceso para poder iniciar el Chapú cuando lo haga le avisaremos."
                      : "Aún no has pagado la comisión del proceso de gestión.",
                  "Aceptar",
                  () {
                    Navigator.pop(context);
                  },
                  useBtnCancel: false,
                  image: '',
                ),
                onWillPop: () async {
                  return false;
                });
          });

      if (widget.openMessage != "") {
        showErrorsDialog(context, [widget.openMessage]);
        setState(() {
          widget.openMessage = "";
        });
      }
    }
  }

  loadMoreMessages() {
    setState(() {
      loading = true;
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _controllerScroll.animateTo(_controllerScroll.position.maxScrollExtent,
          duration: Duration(milliseconds: 5), curve: Curves.linear);
    });

    final provider = Provider.of<AppProvider>(context, listen: false);

    Timer(Duration(milliseconds: 500), () {
      WebService(context)
          .getMessages(limit, messages.length, widget.user.id ?? "",
              widget.advert.id ?? "", provider.user.token ?? "")
          .then((value) {
        if (value.length > 0) {
          setState(() {
            messages.addAll(value);
            noMore = false;
            limitEnd = messages.length + 1;
          });
        } else {
          setState(() {
            noMore = true;
          });
        }

        setState(() {
          loading = false;
        });
      }).catchError((e) {
        Timer(Duration(seconds: 1), () {
          setState(() {
            loading = false;
          });
        });
        showErrorsDialog(context, e);
      });
    });
  }

  sendMessage(String message) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    simpleLoading(context, (BuildContext loadingContext) async {
      WebService(context)
          .sendMessage(message, widget.user.id ?? "", [],
              widget.advert.id ?? "", provider.user.token ?? "")
          .then((value) {
        setState(() {
          messages.insert(0, value);
          sendMessageHintText = "Escribe un mensaje...";
        });
        Navigator.pop(loadingContext);
      }).catchError((e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);

    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade300,
          centerTitle: true,
          leading: new IconButton(
            icon: new Icon(
              Icons.keyboard_arrow_left,
              size: 40,
              color: Colors.grey.shade800,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 0),
              child: SizedBox.fromSize(
                size: Size(60, 56), // button width and height
                child: Material(
                  color: Colors.transparent, // button color
                  child: InkWell(
                    splashColor: Colors.transparent, // splash color
                    onTap: () async {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (contextDialog) {
                            return CustomDialog(
                              "Llamar al ${widget.user.phone}",
                              "¿Estás seguro de que quieres llamar?",
                              "Aceptar",
                              () async {
                                if (kIsWeb) {
                                  showErrorsDialog(context, [
                                    "Para llamar directamente debe hacerlo desde nuestra aplicación móvil"
                                  ]);
                                } else {
                                  try {
                                    await FlutterPhoneDirectCaller.callNumber(
                                        widget.user.phone ?? "");
                                  } catch (e) {}
                                }
                              },
                              useBtnCancel: true,
                              image: '',
                            );
                          });
                    }, // button pressed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.call,
                          color: CustomColors.primary,
                        ), // icon
                        // text
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          title: Text(
            formatFirstUpper(widget.user.name!),
            style: TextStyle(color: Colors.grey.shade800, fontSize: 19),
          ),
          // bottomOpacity: 0.0,
          elevation: 0.0,
        ),
        body: GestureDetector(
          child: getChatPage(),
          onTap: () => FocusScope.of(context).unfocus(),
        ));
  }

  Widget getChatPage() {
    List<Widget> messagesWidgets = [];

    messagesWidgets.addAll(messages.map((message) {
      return buildMessage(message);
    }).toList());

    messagesWidgets.add((loading)
        ? Container(
            width: 30,
            height: 30,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(CustomColors.primary)),
              ),
            ),
          )
        : Container());

    if (noMore) {
      messagesWidgets.add(Visibility(
        visible: !loading,
        child: Align(
          alignment: Alignment.center,
          child: Container(
              height: 30, child: Text("No hay mas mensajes para mostrar.")),
        ),
      ));
    }

    //messagesWidgets=messagesWidgets.reversed.toList();

    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0))),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0)),
              child: ListView(
                controller: _controllerScroll,
                reverse: true,
                padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
                children: messagesWidgets,
              ),
            ),
          ),
        ),
        (typing != "")
            ? Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Container(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15.0),
                                child: Text(typing,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold)),
                              ))),
                    ],
                  )
                ],
              )
            : Container(
                color: Colors.white,
              ),
        buildMessageComposer()
      ],
    );
  }

  Widget buildMessage(MessageModel msg) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    DateTime date = DateTime.parse(msg.created_at!).toUtc();
    DateTime dateLocal = date.toLocal();
    String createdAt = getTimeDifferenceFromNow(dateLocal);

    String type = "transmitter";
    UserModel user = (msg.receiver!.id == provider.user.id)
        ? msg.receiver!
        : msg.transmitter!;
    UserModel other = (msg.receiver!.id != provider.user.id)
        ? msg.receiver!
        : msg.transmitter!;

    if (msg.receiver!.id == provider.user.id) {
      type = "receiver";
    } else {
      type = "transmitter";
    }

    return Container(
        margin: const EdgeInsets.only(top: 0.0, bottom: 0.0),
        child: (type != "transmitter")
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxWidth: 50, maxHeight: 50),
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.all(4),
                      child: ClipOval(
                        child: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: (other.picture == null || other.picture == "")
                              ? Image.asset('assets/images/avatar.png',
                                  fit: BoxFit.fitWidth)
                              : Image.network(
                                  getImageUrl(other.picture!),
                                  fit: BoxFit.fitWidth,
                                  height: 50,
                                  width: 50,
                                ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 15.0),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8.0),
                              bottomRight: Radius.circular(8.0),
                              bottomLeft: Radius.circular(8.0),
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            /* Text(formatFirstUpper(other.name!), style: TextStyle(color: Colors.grey)),
                              SizedBox(
                                height: 8.0,
                              ),*/
                            Text(
                              createdAt,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              msg.message ?? "",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 15.0),
                      decoration: BoxDecoration(
                          color: CustomColors.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                          )),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        direction: Axis.vertical,
                        children: <Widget>[
                          Text(
                            createdAt,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: Colors.grey.shade300,
                                fontSize: 10.0,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Container(
                            constraints: new BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 70),
                            child: Text(
                              msg.message ?? "",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                          /*Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: getStatusMessage(msg.status ?? ""),
                          )*/
                        ],
                      ),
                    )
                  ],
                ),
              ));
  }

  Widget getStatusMessage(String status) {
    switch (status) {
      case "without_receiving":
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FaIcon(FontAwesomeIcons.check,
              size: 9,
              color: Colors.white,
            )
          ],
        );
        break;
      case "received":
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FaIcon(FontAwesomeIcons.check,
              size: 9,
              color: Colors.white,
            ),
            FaIcon(FontAwesomeIcons.check,
              size: 9,
              color: Colors.white,
            )
          ],
        );
        break;
      case "read":
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FaIcon(FontAwesomeIcons.check,
              size: 9,
              color: Colors.blue,
            ),
            FaIcon(FontAwesomeIcons.check,
              size: 9,
              color: Colors.blue,
            )
          ],
        );
        break;
      default:
        return Container();
    }
  }

  buildMessageComposer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(
          color: Color.fromRGBO(0, 0, 0, 0.07),
          // width: 3.0 --> you can set a custom width too!
        )),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      child: Row(children: <Widget>[
        IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              final form = _formKey.currentState;
              form!.reset();
            },
            iconSize: 25.0,
            color: CustomColors.primary),
        Expanded(
            child: Form(
                key: _formKey,
                child: TextFormField(
                  onSaved: (value) => messageText = value ?? "",
                  onChanged: (value) {
                    setState(() {});
                  },
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                      InputDecoration.collapsed(hintText: sendMessageHintText),
                ))),
        IconButton(
          icon: Icon(Icons.send, color: CustomColors.primary),
          onPressed: () {
            final form = _formKey.currentState;
            if (form!.validate()) {
              form.save();
              if (messageText != "") {
                setState(() {
                  sendMessageHintText = "Enviando mensaje....";
                });
                sendMessage(messageText);
                form.reset();
              }
            }
          },
          iconSize: 25.0,
          color: CustomColors.primary,
        )
      ]),
    );
  }
}
