import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/question.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GuestPrescriptionDialog extends StatefulWidget {
  Function callBackBtn;

  GuestPrescriptionDialog(this.callBackBtn);
  @override
  _GuestPrescriptionDialogState createState() =>
      _GuestPrescriptionDialogState();
}

class _GuestPrescriptionDialogState extends State<GuestPrescriptionDialog> {
  final formKey = new GlobalKey<FormState>();
  final cHours = TextEditingController();
  final cEmail = TextEditingController();

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
    final emailField = TextFormField(
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        validator: (val) {
          return validateEmail(val ?? "", context);
        },
        controller: cEmail,
        style: TextStyle(fontSize: 18.0),
        //initialValue: Environment.localPassword(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email medico",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            FontAwesomeIcons.envelope,
            size: 20,
          ),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
              borderRadius: BorderRadius.circular(10.0)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
              borderRadius: BorderRadius.circular(10.0)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
              borderRadius: BorderRadius.circular(10.0)),
        ));

    final hoursField = TextFormField(
        validator: (val) {
          return requiredField(val ?? "", context);
        },
        autofocus: false,
        autocorrect: false,
        controller: cHours,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        maxLines: null,
        readOnly: false,
        obscureText: false,
        style: TextStyle(fontSize: 18.0),
        //initialValue: Environment.localUsername(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Tiempo de acceso (horas)",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            FontAwesomeIcons.clock,
            size: 20,
          ),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
              borderRadius: BorderRadius.circular(10.0)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
              borderRadius: BorderRadius.circular(10.0)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
              borderRadius: BorderRadius.circular(10.0)),
        ));
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
                    "Comparte un link de acceso a un medico",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  emailField,
                  SizedBox(
                    height: 16.0,
                  ),
                  hoursField,
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

                                if (form!.validate()) {
                                  widget.callBackBtn(cEmail.text, cHours.text);
                                }
                              },
                              child: Text(
                                "Enviar",
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
