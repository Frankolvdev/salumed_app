import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/question.dart';
import 'package:flutter/material.dart';

class ChooseComplaintDialog extends StatefulWidget {
  Function callBackBtn;

  ChooseComplaintDialog(this.callBackBtn);
  @override
  _ChooseComplaintDialogState createState() => _ChooseComplaintDialogState();
}

class _ChooseComplaintDialogState extends State<ChooseComplaintDialog> {
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
                  Text(
                    "Denunciar",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 150,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                MaterialButton(
                                    color: CustomColors.primary,
                                    onPressed: () {
                                      Navigator.of(context).pop();

                                      widget.callBackBtn("question");
                                    },
                                    child: Text(
                                      "Pregunta",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    )),
                                SizedBox(height: 10),
                                MaterialButton(
                                    color: CustomColors.primary,
                                    onPressed: () {
                                      Navigator.of(context).pop();

                                      widget.callBackBtn("answer");
                                    },
                                    child: Text(
                                      "Respuesta",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ))
                              ],
                            ),
                          ),
                        )
                      ])
                ],
              )),
        )
      ],
    );
  }
}
