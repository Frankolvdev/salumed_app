import 'package:app/components/custom_dialog.dart';
import 'package:app/components/dialog_accept_to_bid.dart';
import 'package:app/components/dialog_select_date.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/advert.dart';
import 'package:app/models/app_preferences.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snack/snack.dart';

class BidUp extends StatefulWidget {
  AdvertModel advert;
  BidUp(this.advert, {Key? key}) : super(key: key);

  @override
  _BidUpState createState() => _BidUpState();
}

class _BidUpState extends State<BidUp> {
  final cAmount = TextEditingController();
  bool weekendOnly = false;
  dynamic newDate = null;
  num lowerAmount = 0;
  bool lookWeekendOnly = false;
  bool showExplanation = false;

  final cExplanation = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    WebService(context)
        .getAdvertById(widget.advert.id ?? "", provider.user.token ?? "")
        .then((value) {
      widget.advert = value;
    });
    if (widget.advert.bids != null && widget.advert.bids!.length > 0) {
      widget.advert.bids!.sort((a, b) {
        return a.amount!.compareTo(b.amount!);
      });
      lowerAmount = widget.advert.bids![0].amount ?? 0;
    }

    weekendOnly = checkMyWeekendOnly(widget.advert.bids ?? [], provider.user);
    lookWeekendOnly = weekendOnly;
  }

  @override
  Widget build(BuildContext context) {
    var fieldsDecorationExplanation = InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      hintText: "Ingresa tu explicación",
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
    );
    final explanationField = TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      minLines: 2,

      controller: cExplanation,

      maxLength: 250,
      validator: (val) {
        return null;
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecorationExplanation,
      onFieldSubmitted: (val) {},
    );

    var fieldsDecoration = InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 10),
      hintText: "Introduzca la cantidad",
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
      fillColor: Colors.white,
      focusColor: Colors.grey,
      hoverColor: Colors.grey,
      filled: true,
      suffixIcon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text("${checkIsHours(widget.advert) ? '€/hora' : '€'}",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 23.0,
                    fontWeight: FontWeight.bold)),
          )
        ],
      ),
      prefixIcon: Icon(
        Icons.euro,
        color: Colors.transparent,
      ),
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
    );

    final amountField = TextFormField(
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.done,

      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      controller: cAmount,
      keyboardType: TextInputType.number,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 40.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration,
      onFieldSubmitted: (val) {},
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              )),
          elevation: 0,
          centerTitle: true,
          leading: new IconButton(
            icon: new FaIcon(FontAwesomeIcons.arrowLeft,
              size: 20,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          )),
      backgroundColor: CustomColors.primary,
      body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: ListView(
            children: [
              Center(
                child: Container(
                  constraints: (kIsWeb)
                      ? BoxConstraints(maxWidth: 700)
                      : BoxConstraints(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (lowerAmount > 0)
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Puja más baja: ",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0,
                                          )),
                                      Text(
                                          "${lowerAmount} ${checkIsHours(widget.advert) ? '€/hora' : '€'}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              : Container(),
                          Padding(
                            padding: kIsWeb
                                ? EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                    top: 100,
                                    bottom: 8.0)
                                : EdgeInsets.all(8.0),
                            child: amountField,
                          ),
                          ButtonTheme(
                            child: MaterialButton(
                              color: Colors.white,
                              padding:
                                  EdgeInsets.fromLTRB(10.0, 16.0, 10.0, 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: BorderSide.none,
                              ),
                              child: Row(
                                // Replace with a Row for horizontal icon + text

                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                      padding:
                                          EdgeInsets.only(right: 8, left: 8),
                                      child: Image.asset(
                                          "assets/images/explicacion_subasta.png",
                                          width: 20)),
                                  Text(
                                    "Explica tu presupuesto",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: CustomColors.primary,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              onPressed: () {
                                setState(() {
                                  showExplanation = !showExplanation;
                                });
                              },
                            ),
                          ),
                          Visibility(
                            visible: showExplanation,
                            child: Padding(
                              padding: kIsWeb
                                  ? EdgeInsets.only(
                                      left: 8.0,
                                      right: 8.0,
                                      top: 100,
                                      bottom: 8.0)
                                  : EdgeInsets.all(8.0),
                              child: explanationField,
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * .50,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                    onTap: () {
                                      //  if(lookWeekendOnly)return;

                                      if (!weekendOnly) {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (contextDialog) {
                                              return CustomDialog(
                                                "¿Desea marcar la puja como Weekend Only?",
                                                "Si marca la puja como Weekend Only el cliente podrá ver en sus pujas que usted solo podrá trabajar los fines de semana.",
                                                "Aceptar",
                                                () {
                                                  setState(() {
                                                    weekendOnly = true;
                                                  });
                                                },
                                                useBtnCancel: true,
                                                image: '',
                                              );
                                            });
                                      } else {
                                        setState(() {
                                          weekendOnly = false;
                                        });
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0),
                                      child: Image.asset(
                                        (weekendOnly)
                                            ? "assets/images/anuncio-weekend-only-icon-green.png"
                                            : "assets/images/anuncio-weekend-only-icon-white.png",
                                        width: kIsWeb
                                            ? 400
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .60,
                                      ),
                                    )),
                                Visibility(
                                  visible: !checkIsHours(widget.advert),
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (contextDialog) {
                                            return DialogSelectDate(
                                              "¿Desea proponer al cliente otro tiempo para finalizar la obra o reforma?",
                                              "Su usted quiere hacer una puja, pero considera que el tiempo propuesto para finalizar no es correcto puede proponer al cliente una nueva fecha de término.",
                                              "Aceptar",
                                              (dynamic date) {
                                                if (date != null &&
                                                    date is DateTime) {
                                                  setState(() {
                                                    newDate = date;
                                                  });
                                                }
                                              },
                                              useBtnCancel: true,
                                              image: '',
                                            );
                                          });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Image.asset(
                                        "assets/images/reloj1.png",
                                        height: kIsWeb
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .10
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .20,
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ),
                                ),
                                (newDate != null && newDate is DateTime)
                                    ? Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Text(
                                            getDateFromStringFormat(
                                                newDate.toString()),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          ButtonTheme(
                            minWidth: kIsWeb ? 400 : 230.0,
                            child: MaterialButton(
                              color: Colors.white,
                              padding: EdgeInsets.fromLTRB(30.0,
                                  kIsWeb ? 25 : 10.0, 30.0, kIsWeb ? 25 : 10.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: BorderSide.none,
                              ),
                              child: Row(
                                // Replace with a Row for horizontal icon + text

                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: FaIcon(FontAwesomeIcons.check,
                                          size: 20,
                                          color: CustomColors.primary)),
                                  Text(
                                    "Enviar",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: CustomColors.primary,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              onPressed: () async {
                                if (cExplanation.text.trim() == "") {
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (contextDialog) {
                                        return CustomDialog(
                                          "No has explicado tu presupuesto, esto puede influirte en la elección del profesional por parte del cliente",
                                          "¿Deseas enviar la puja?",
                                          "Aceptar",
                                          () async {
                                            bool accept = await AppPreferences()
                                                .getAcceptToBid();
                                            if (accept) {
                                              sendBid();
                                            } else {
                                              showAcceptToBid();
                                            }

                                            //
                                          },
                                          useBtnCancel: true,
                                          image: '',
                                        );
                                      });
                                } else {
                                  bool accept =
                                      await AppPreferences().getAcceptToBid();
                                  if (accept) {
                                    sendBid();
                                  } else {
                                    showAcceptToBid();
                                  }
                                }
                              },
                            ),
                          )
                        ]),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  showAcceptToBid() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return DialogAcceptToBid(
            "Si tu presupuesto es aceptado tendrás que abonar los gastos de gestión para que se habilite el chat/teléfono. Estos serán el 3.5% de tu presupuesto. Si no se abonara serás penalizado.",
            "Ver políticas de penalización",
            "Aceptar",
            () {
              sendBid();
            },
            textLink: "https://chapureformas.es/cancellation-policies",
            useBtnCancel: true,
            textBtnCancel: "Atras",
            image: '',
          );
        });
  }

  sendBid() {
    if (cAmount.text.trim() == "") {
      showErrorsDialog(context, ["Debe ingresar la cantidad"]);
      return;
    }

    final provider = Provider.of<AppProvider>(context, listen: false);
    simpleLoading(context, (BuildContext loadingContext) {
      WebService(context)
          .createBid(
              widget.advert.id ?? "",
              weekendOnly,
              int.parse(cAmount.text),
              (newDate != null && newDate is DateTime)
                  ? (newDate as DateTime)
                      .toUtc()
                      .millisecondsSinceEpoch
                      .toString()
                  : "",
              provider.user.token ?? "",
              cExplanation.text)
          .then((value) {
        updateAppProviderAdvert(context, value);
        Navigator.pop(loadingContext);
        SnackBar(
                content: Text("Se ha enviado correctamente",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                elevation: 100,
                duration: Duration(seconds: 2),
                backgroundColor: CustomColors.primary)
            .show(context);
        Navigator.pop(context);
      }).catchError((e) {
        print(e);
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e);
      });
    });
  }
}

