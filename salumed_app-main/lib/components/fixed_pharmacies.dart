import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/question.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class fixedPharmacies extends StatefulWidget {
  final bool useBtnCancel;
  Function callBackBtn;

  fixedPharmacies(this.callBackBtn, {this.useBtnCancel = true});
  @override
  _fixedPharmaciesState createState() => _fixedPharmaciesState();
}

class _fixedPharmaciesState extends State<fixedPharmacies> {
  final cComment = TextEditingController();
  final formKey = new GlobalKey<FormState>();

  List<dynamic> pharmacies = [
    {
      'title': 'Farmacias del Ahorro',
      'link': 'https://www.fahorro.com',
      'picture': 'farmacia_del_ahorro.png'
    },
    {
      'title': 'Farmacia San Pablo',
      'link': 'https://www.farmaciasanpablo.com.mx',
      'picture': 'farmacia_sanpablo.png'
    },
        {
      'title': 'Farmacias Similares',
      'link': 'https://www.farmaciasdesimilares.com',
      'picture': 'farmacias_similares.png'
    },
           {
      'title': 'Farmacias Benavides',
      'link': 'https://www.benavides.com.mx',
      'picture': 'farmacias_benavides.png'
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: getDialogInsetPaddin(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
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
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    "Selecciona una farmacia",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Column(
                    children: pharmacies.map((e) {
                      return InkWell(
                        onTap: () async {
                          if (await canLaunch(e["link"])) {
                            await launch(e["link"]);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/${e['picture']}",
                                      width: 110,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 18,
                              ),
                              Container(
                                height: 1,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  Container(
                    height: 50,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: MaterialButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancelar")),
                        ),
                      ],
                    ),
                  )
                ],
              )),
        ),
      ],
    );
  }
}
