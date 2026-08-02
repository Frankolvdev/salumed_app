import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/question.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotifyDialog extends StatefulWidget {
  Function callBackBtn;

  NotifyDialog(this.callBackBtn);
  @override
  _NotifyDialogState createState() => _NotifyDialogState();
}

class _NotifyDialogState extends State<NotifyDialog> {
  final cMessage = TextEditingController();
  final cTitle = TextEditingController();
  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    cMessage.text = "";
  }

  String filterRol = "";
  List<Map<String, dynamic>> roles = [
    {"name": "Todos", "val": ""},
    {"name": "Administradores", "val": "admin"},
    {"name": "Super administradores", "val": "super_admin"},
    {"name": "Administradores de farmacia", "val": "pharmacy_admin"},
    {"name": "Pacientes", "val": "client"},
    {"name": "Repartidores", "val": "delivery"},
    {"name": "Doctores", "val": "doctor"}
  ];
  bool notification = false;
  bool email = false;

  @override
  Widget build(BuildContext context) {
    EdgeInsets edges = kIsWeb
        ? EdgeInsets.symmetric(
            horizontal: (MediaQuery.of(context).size.width > 1000)
                ? MediaQuery.of(context).size.width * .25
                : 30)
        : EdgeInsets.symmetric(horizontal: 8, vertical: 24);
    return Dialog(
      insetPadding: edges,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    var fieldsDecoration = InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      hintText: "",
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      fillColor: Colors.white,
      focusColor: Colors.white,
      hoverColor: Colors.white,
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
    final messageField = TextFormField(
      maxLines: 3,
      maxLength: 500,
      textInputAction: TextInputAction.done,
      controller: cMessage,
      keyboardType: TextInputType.multiline,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration.copyWith(hintText: "Introduzca el mensaje"),
      onFieldSubmitted: (val) {},
    );

    final titleField = TextFormField(
      textInputAction: TextInputAction.done,
      controller: cTitle,
      maxLength: 100,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration.copyWith(hintText: "Introduzca el título"),
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
                    "Notificar",
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        email = !email;
                      });
                    },
                    child: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: const Text('Enviar Email'),
                        leading: Checkbox(
                          checkColor: Colors.white,
                          fillColor:
                              MaterialStateProperty.resolveWith(getColor),
                          value: email,
                          onChanged: (bool? value) {
                            setState(() {
                              email = !email;
                            });
                          },
                        )),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        notification = !notification;
                      });
                    },
                    child: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: const Text('Enviar Push Notificación'),
                        leading: Checkbox(
                          checkColor: Colors.white,
                          fillColor:
                              MaterialStateProperty.resolveWith(getColor),
                          value: notification,
                          onChanged: (bool? value) {
                            setState(() {
                              notification = !notification;
                            });
                          },
                        )),
                  ),
                  Container(
                    height: 1,
                    color: Color.fromARGB(255, 195, 195, 195),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  DropdownButtonFormField(
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Colors.grey,
                    ),
                    iconSize: 42,
                    items: roles.map((dynamic rol) {
                      return new DropdownMenuItem(
                          value: rol["val"],
                          child: Text(rol["name"],
                              overflow: TextOverflow.ellipsis, maxLines: 1));
                    }).toList(),
                    onChanged: (rol) {
                      setState(() {
                        filterRol = rol as String;
                      });

                      // do other stuff with _category
                    },
                    value: filterRol,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                      hintText: "Enviar a",
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      fillColor: Colors.white,
                      focusColor: Colors.grey,
                      hoverColor: Colors.grey,
                      filled: true,
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade300, width: 1.0),
                          borderRadius: BorderRadius.circular(6.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade300, width: 1.0),
                          borderRadius: BorderRadius.circular(6.0)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade300, width: 1.0),
                          borderRadius: BorderRadius.circular(6.0)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.red.shade300, width: 1.0),
                          borderRadius: BorderRadius.circular(6.0)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.red.shade300, width: 1.0),
                          borderRadius: BorderRadius.circular(6.0)),
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Container(
                    height: 1,
                    color: Color.fromARGB(255, 195, 195, 195),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  titleField,
                  SizedBox(
                    height: 8.0,
                  ),
                  messageField,
                  Container(
                    height: 50,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: MaterialButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                              child: Text("Cancelar")),
                        ),
                        Expanded(
                          child: MaterialButton(
                              onPressed: () {
                                widget.callBackBtn(
                                  context,
                                  cTitle.text,
                                  cMessage.text,
                                  filterRol,
                                  notification ? "true" : "false",
                                  email ? "true" : "false",
                                );
                              },
                              child: Text("Enviar")),
                        )
                      ],
                    ),
                  )
                ],
              )),
        ),
      ],
    );
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return CustomColors.primary;
  }
}
