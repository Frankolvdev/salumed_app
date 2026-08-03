import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/does_work.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snack/snack.dart';

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    UserModel user = provider.user;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text("",
                style: TextStyle(
                  color: CustomColors.primary,
                  fontSize: 20.0,
                )),
            elevation: 0,
            centerTitle: true,
            leading: new IconButton(
              icon: new FaIcon(FontAwesomeIcons.arrowLeft,
                size: 20,
                color: CustomColors.primary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )),
        body: ListView(children: [
          Center(
            child: Container(
              constraints:
                  kIsWeb ? BoxConstraints(maxWidth: 600) : BoxConstraints(),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    itemTemplate("CÓMO FUNCIONA", () {
                      Navigator.push(
                          context,
                          PageTransition(
                              child: DoesWork(),
                              type: PageTransitionType.slideInUp,
                              duration: Duration(milliseconds: 250)));
                    }),
                    Divider(
                      color: Colors.grey,
                    ),
                    itemTemplate("PREGUNTAS FRECUENTES", () {
                      launchUrl(context, frequentQuestionsLink);
                    }),
                    Divider(
                      color: Colors.grey,
                    ),
                    itemTemplate("CONTACTA CON NOSOTROS", () {
                      contact();
                    }),
                    Divider(
                      color: Colors.grey,
                    ),
                    itemTemplate("POLÍTICAS DE PRIVACIDAD Y DATOS", () {
                      launchUrl(context, privacyPoliciesLink);
                    }),
                    Divider(
                      color: Colors.grey,
                    ),
                    itemTemplate("POLÍTICA DE USO", () {
                      launchUrl(
                          context, "https://chapureformas.es/politica-uso");
                    }),
                    Divider(
                      color: Colors.grey,
                    ),
                    itemTemplate("AVISO LEGAL", () {
                      launchUrl(
                          context, "https://chapureformas.es/aviso-legal");
                    }),
                    Divider(
                      color: Colors.grey,
                    ),
                    itemTemplate("POLÍTICA DE CANCELACIÓN", () {
                      launchUrl(context,
                          "https://chapureformas.es/cancellation-policies");
                    }),
                    Divider(
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Text("ENCUENTRÁNOS EN",
                                      textAlign: TextAlign.left,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: new TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                      )),
                                ),
                              ),
                            ],
                          )),
                        ],
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                              onTap: () {
                                launchUrl(context, tiktokLink);
                              },
                              child: Image.asset(
                                  "assets/images/encontranos-en-tik-tok.png",
                                  width: 80)),
                          InkWell(
                              onTap: () {
                                launchUrl(context, instagramLink);
                              },
                              child: Image.asset(
                                  "assets/images/encontranos-en-instagram.png",
                                  width: 80)),
                          InkWell(
                              onTap: () {
                                launchUrl(context, facebookLink);
                              },
                              child: Image.asset(
                                  "assets/images/encontranos-en-fb.png",
                                  width: 80)),
                        ]),
                    SizedBox(
                      height: 18,
                    ),
                    Column(
                      children: [
                        InkWell(
                            onTap: () {
                              launchUrl(context, appLinkAndroid);
                            },
                            child: Image.asset(
                                "assets/images/store-google-boton.png",
                                height: 80)),
                        InkWell(
                            onTap: () {
                              launchUrl(context, appLinkIos);
                            },
                            child: Image.asset(
                                "assets/images/store-app-store-boton.png",
                                height: 80)),
                      ],
                    )
                  ])),
            ),
          )
        ]));
  }

  contact() {
    final provider = Provider.of<AppProvider>(context, listen: false);
  }

  itemTemplate(String title, Function callback) {
    return InkWell(
      onTap: () async {
        callback();
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
                child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(title,
                        textAlign: TextAlign.left,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        )),
                  ),
                ),
              ],
            )),
            Container(
              width: 18,
              child: FaIcon(FontAwesomeIcons.chevronRight,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
