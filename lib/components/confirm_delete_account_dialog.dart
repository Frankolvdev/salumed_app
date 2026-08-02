import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/question.dart';
import 'package:flutter/material.dart';

class ConfirmDeleteAccountDialog extends StatefulWidget {
  Function callBackBtn;

  ConfirmDeleteAccountDialog(this.callBackBtn);
  @override
  _ConfirmDeleteAccountDialogState createState() =>
      _ConfirmDeleteAccountDialogState();
}

class _ConfirmDeleteAccountDialogState
    extends State<ConfirmDeleteAccountDialog> {
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
      hintText: "Puede escribir aquí",
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
    final answerField = TextFormField(
      maxLines: null,
      textInputAction: TextInputAction.done,
      controller: cComment,
      keyboardType: TextInputType.text,
      validator: (val) {
        return null;
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration,
      onFieldSubmitted: (val) {},
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
                  Text(
                    "¿Por qué razón te quieres dar de baja?",
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
                  answerField,
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
                        Expanded(
                          child: MaterialButton(
                              onPressed: () {
                                final form = formKey.currentState;

                                Navigator.of(context).pop();

                                widget.callBackBtn(cComment.text);
                              },
                              child: Text(
                                "Continuar",
                                style: TextStyle(color: CustomColors.primary),
                                textAlign: TextAlign.center,
                              )),
                        )
                      ],
                    ),
                  )
                ],
              )),
        )
      ],
    );
  }
}
