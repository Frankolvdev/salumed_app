import 'package:app/components/fixed_pharmacies.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/question.dart';
import 'package:flutter/material.dart';

class buyWithoutReceipe extends StatefulWidget {
  final bool useBtnCancel;
  Function callBackBtn;

  buyWithoutReceipe(this.callBackBtn, {this.useBtnCancel = true});
  @override
  _buyWithoutReceipeState createState() => _buyWithoutReceipeState();
}

class _buyWithoutReceipeState extends State<buyWithoutReceipe> {
  final cComment = TextEditingController();
  final formKey = new GlobalKey<FormState>();

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
    var fieldsDecoration = InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      hintText: "Puede escribir un comentario",
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
                  ButtonTheme(
                    minWidth: 230.0,
                    child: MaterialButton(
                      color: CustomColors.primary2,
                      padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide.none,
                      ),
                      child: Row(
                        // Replace with a Row for horizontal icon + text

                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Medicamentos",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      onPressed: () {
                        if (showDirectPharmacy) {
                          Navigator.pop(context);
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (contextDialog) {
                                return fixedPharmacies(
                                  () {
                                    Navigator.pop(contextDialog);
                                  },
                                );
                              });
                        } else {
                          widget.callBackBtn("medicines");
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  ButtonTheme(
                    minWidth: 230.0,
                    child: MaterialButton(
                      color: CustomColors.primary2,
                      padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide.none,
                      ),
                      child: Row(
                        // Replace with a Row for horizontal icon + text

                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Estudios de laboratorio",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ],
                      ),
                      onPressed: () {
                        widget.callBackBtn("laboratory_studies");
                      },
                    ),
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
