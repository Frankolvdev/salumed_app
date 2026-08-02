import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewContract extends StatefulWidget {
  String advertId;
  ViewContract(this.advertId, {Key? key}) : super(key: key);

  @override
  _ViewContractState createState() => _ViewContractState();
}

class _ViewContractState extends State<ViewContract> {
  @override
  Widget build(BuildContext context) {
    String url = "${docsUrl}doc_${widget.advertId}.pdf";
    print(url);
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
              icon: new Icon(
                FontAwesomeIcons.arrowLeft,
                size: 20,
                color: CustomColors.primary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )),
        body: Center(
          child: Container(
            constraints:
                kIsWeb ? BoxConstraints(maxWidth: 650) : BoxConstraints(),
            child: kIsWeb
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Este contrato privado es una herramienta legal que os ofrece Chapú para vuestra tranquilidad. El contrato os dará seguridad en cualquier imprevisto que pueda surgir. Recomendamos que lo descargues y firmes antes de que se comience el trabajo.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                minimumSize: Size(150, 50),
                                fixedSize: Size(150, 50),
                                primary: CustomColors.primary,
                                side: BorderSide(
                                    width: 1.0, color: CustomColors.primary),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.all(0)),
                            onPressed: () {
                              launchUrl(context,
                                  "${apiUrl}elementpost/download-contract?id=${widget.advertId}");
                            },
                            child: Center(
                              child: Text("Descargar",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                minimumSize: Size(150, 50),
                                fixedSize: Size(150, 50),
                                primary: CustomColors.primary,
                                side: BorderSide(
                                    width: 1.0, color: CustomColors.primary),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.all(0)),
                            onPressed: () {
                              launchUrl(context,
                                  "${docsUrl}doc_${widget.advertId}.pdf");
                            },
                            child: Center(
                              child: Text("Ver",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                  textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        height: 150,
                        width: MediaQuery.of(context).size.width,
                        child: ListView(
                          children: [
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Este contrato privado es una herramienta legal que os ofrece Chapú para vuestra tranquilidad. El contrato os dará seguridad en cualquier imprevisto que pueda surgir. Recomendamos que lo descargues y firmes antes de que se comience el trabajo.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shadowColor: Colors.transparent,
                                            minimumSize: Size(120, 30),
                                            fixedSize: Size(120, 30),
                                            primary: CustomColors.primary,
                                            side: BorderSide(
                                                width: 1.0,
                                                color: CustomColors.primary),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            padding: EdgeInsets.all(0)),
                                        onPressed: () {
                                          launchUrl(context,
                                              "${apiUrl}elementpost/download-contract?id=${widget.advertId}");
                                        },
                                        child: Center(
                                          child: Text("Descargar",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13.0),
                                              textAlign: TextAlign.center),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      /*Positioned.fill(
                top: 150,
                child: PDF().cachedFromUrl(url, maxAgeCacheObject: Duration(seconds: 10)) )*/
                    ],
                  ),
          ),
        ));
  }
}
