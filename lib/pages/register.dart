import 'package:app/helpers/premium_welcome_helper.dart';
import 'dart:async';

import 'package:app/components/fade_animation.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter_facebook_login_web/flutter_facebook_login_web.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  String type;
  Register(this.type, {Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

/*GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  //clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>['email'],
);*/

class _RegisterState extends State<Register> {
  bool passwordVisible = true;
  bool passwordVisibleRepeat = true;
  final cEmail = TextEditingController();
  final cName = TextEditingController();
  final cPass = TextEditingController();
  final cPassRepeat = TextEditingController();
  final formKey = new GlobalKey<FormState>();
  //late StreamSubscription currentStream;
  bool gmailPress = false;
  bool facebookPress = false;
  String pharmacyOrLaboratory = "";
  @override
  void initState() {
    super.initState();

    /*currentStream = _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      GoogleSignInAccount? _currentUser = account;
      if (_currentUser != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await _currentUser.authentication;
        processSignInAuth(_currentUser.id, _currentUser.displayName ?? "",
            _currentUser.email, "GOOGLE",
            picture: _currentUser.photoUrl ?? "");
      }
    });
     try {
     if(kIsWeb){

     }else{
//_googleSignIn.signIn();
     }   
    } catch (e) {
      print(e);
      debugPrint(e.toString());

    }*/
  }

  @override
  void dispose() {
    // currentStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameField = TextFormField(
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        validator: (val) {
          return validateName(val ?? "", context);
        },
        controller: cName,
        style: TextStyle(fontSize: 18.0),
        //initialValue: Environment.localPassword(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: (widget.type == "hospital_admin")
              ? "Nombre de hospital o clínica"
              : "Nombre completo",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: FaIcon(FontAwesomeIcons.user,
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
          hintText: "Email",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: FaIcon(FontAwesomeIcons.envelope,
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

    final passwordField = TextFormField(
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp('[ ]')),
        ],
        textInputAction: TextInputAction.next,
        validator: (val) {
          return validatePassword1(val ?? "", context);
        },
        controller: cPass,
        obscureText: passwordVisible,
        style: TextStyle(fontSize: 18.0),
        //initialValue: Environment.localPassword(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Contraseña",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: FaIcon(FontAwesomeIcons.lock,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              passwordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                passwordVisible = !passwordVisible;
              });
            },
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

    final repeatPasswordField = TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('[ ]')),
      ],
      validator: (val) {
        return validateRepeatPassword(cPass.text, val ?? "", context);
      },
      controller: cPassRepeat,
      obscureText: passwordVisibleRepeat,
      //initialValue: Environment.localPassword(),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Repetir contraseña",
        hintStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade400,
            fontSize: 14),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: FaIcon(FontAwesomeIcons.lock,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            passwordVisibleRepeat ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            // Update the state i.e. toogle the state of passwordVisible variable
            setState(() {
              passwordVisibleRepeat = !passwordVisibleRepeat;
            });
          },
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
      ),
    );

    Widget btnRegister = ElevatedButton(
      style: ElevatedButton.styleFrom(
          elevation: 2, backgroundColor: CustomColors.primary, shape: StadiumBorder()),
      onPressed: () {
        processRegisterProfessional();
      },
      child: Container(
        width: double.infinity,
        height: 40.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Crear cuenta",
              style: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
              widget.type == "client"
                  ? "Miembro"
                  : widget.type == "doctor"
                      ? "Médico"
                      : widget.type == "pharmacy_admin"
                          ? "Farmacia/Laboratorio"
                          : "Hospital/Clínica",
              style: TextStyle(
                color: CustomColors.primary,
                fontWeight: kIsWeb ? FontWeight.bold : FontWeight.normal,
                fontSize: kIsWeb ? 19.0 : 19.0,
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
      body: Center(
        child: ListView(
          shrinkWrap: kIsWeb ? true : false,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 40.0, right: 40.0, top: 20, bottom: 20),
              child: Column(
                children: [
                  FadeAnimation(
                    1,
                    Container(
                      constraints: (kIsWeb)
                          ? BoxConstraints(maxWidth: 600)
                          : BoxConstraints(),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            (widget.type == "pharmacy_admin")
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: DropdownButtonFormField(
                                      isExpanded: true,
                                      icon: Icon(
                                        Icons.keyboard_arrow_down_outlined,
                                        color: Colors.grey,
                                      ),
                                      iconSize: 42,
                                      items: [
                                        {"val": "", "name": ""},
                                        {"val": "pharmacy", "name": "Farmacia"},
                                        {
                                          "val": "laboratory",
                                          "name": "Laboratorio"
                                        }
                                      ].map((dynamic rol) {
                                        return new DropdownMenuItem(
                                            value: rol["val"],
                                            child: Text(rol["name"],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1));
                                      }).toList(),
                                      onChanged: (rol) {
                                        setState(() {
                                          pharmacyOrLaboratory = rol as String;
                                        });

                                        // do other stuff with _category
                                      },
                                      value: pharmacyOrLaboratory,
                                      decoration: InputDecoration(
                                        labelText: 'Framacia o laboratorio',
                                        labelStyle:
                                            TextStyle(color: Colors.grey),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CustomColors.primary),
                                        ),
                                        border: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: nameField,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: emailField,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: passwordField,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: repeatPasswordField,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: btnRegister,
                            )
                          ],
                        ),
                      ),
                    ),
                    axis: AxisAnimation.y,
                    negative: true,
                  ),
                  Container(
                    constraints: (kIsWeb)
                        ? BoxConstraints(maxWidth: 600)
                        : BoxConstraints(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Row(children: [
                        Expanded(
                          child:
                              Container(color: CustomColors.primary, height: 2),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("O",
                              style: TextStyle(
                                  color: CustomColors.primary, fontSize: 19),
                              textAlign: TextAlign.center),
                        ),
                        Expanded(
                          child:
                              Container(color: CustomColors.primary, height: 2),
                        ),
                      ]),
                    ),
                  ),
                  FadeAnimation(
                    1,
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              side: BorderSide(
                                  width: 1, color: CustomColors.primary),
                              elevation: 2,
                              backgroundColor: Colors.white,
                              shape: StadiumBorder()),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: double.infinity,
                            constraints: (kIsWeb)
                                ? BoxConstraints(maxWidth: 600)
                                : BoxConstraints(),
                            height: 40.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Ya tengo cuenta",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14.0),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  "Iniciar sesión",
                                  style: TextStyle(
                                      color: CustomColors.primary,
                                      fontSize: 15.0),
                                ),
                              ],
                            ),
                          ),
                        )),
                    axis: AxisAnimation.y,
                    negative: true,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  getTypeUser() {}

  processRegisterProfessional() async {
    final form = formKey.currentState;
    String rol = "";

    if (widget.type == "pharmacy_admin") {
      if (pharmacyOrLaboratory == "") {
        showErrorsDialog(
            context, ["Debe seleccionar si es laboratorio o farmacia"]);
        return;
      }
      if (pharmacyOrLaboratory == "pharmacy") {
        rol = "pharmacy_admin";
      } else if (pharmacyOrLaboratory == "laboratory") {
        rol = "laboratory_admin";
      }
    } else {
      rol = widget.type;
    }

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) {
        final provider = Provider.of<AppProvider>(context, listen: false);
        WebService(context)
            .signUp(cEmail.text, formatFirstUpper(cName.text), cPass.text, rol,
                type_business: pharmacyOrLaboratory)
            .then((user) async {
          await provider.setUser(user);

          initProcess(context, user.token ?? "", () async {
            Navigator.pop(loadingContext);
            await queuePremiumWelcome();
            if (mounted) goHome(context, provider.user.roles);
          });
        }).catchError((e) {
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e);
        });
      });
    }
  }
}
