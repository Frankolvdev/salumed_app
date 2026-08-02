import 'package:app/components/fade_animation.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:snack/snack.dart';

class setChangePassword extends StatefulWidget {
  bool hasPassword;
  setChangePassword(this.hasPassword);
  @override
  _setChangePasswordState createState() => _setChangePasswordState();
}

class _setChangePasswordState extends State<setChangePassword> {
  TextStyle style = TextStyle(fontSize: 18.0);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final formKeySetPassword = new GlobalKey<FormState>();
  final formKeyChangePassword = new GlobalKey<FormState>();

  final myCtrlCurrentPass = TextEditingController();
  final myCtrlPass = TextEditingController();
  final myCtrlPassRep = TextEditingController();

  bool currentPasswordVisible = true;
  bool passwordVisible = true;
  bool passwordVisibleRepeat = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    //set password

    final currentPasswordField = TextFormField(
        validator: (val) {
          return validatePassword1(val ?? "", context);
        },
        controller: myCtrlCurrentPass,
        obscureText: currentPasswordVisible,
        style: style,
        //initialValue: Environment.localPassword(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Contraseña actual",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          fillColor: Colors.white,
          focusColor: CustomColors.primary,
          hoverColor: CustomColors.primary,
          filled: true,
          prefixIcon: Icon(
            FontAwesomeIcons.lock,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              // Based on passwordVisible state choose the icon
              currentPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              // Update the state i.e. toogle the state of passwordVisible variable
              setState(() {
                currentPasswordVisible = !currentPasswordVisible;
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
    final passwordField = TextFormField(
        validator: (val) {
          return validatePassword1(val ?? "", context);
        },
        controller: myCtrlPass,
        obscureText: passwordVisible,
        style: style,
        //initialValue: Environment.localPassword(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Contraseña",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          fillColor: Colors.white,
          focusColor: CustomColors.primary,
          hoverColor: CustomColors.primary,
          filled: true,
          prefixIcon: Icon(
            FontAwesomeIcons.lock,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              // Based on passwordVisible state choose the icon
              passwordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              // Update the state i.e. toogle the state of passwordVisible variable
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
      validator: (val) {
        return validateRepeatPassword(myCtrlPass.text, val ?? "", context);
      },
      controller: myCtrlPassRep,
      obscureText: passwordVisibleRepeat,
      style: style,
      //initialValue: Environment.localPassword(),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Repetir contraseña",
        hintStyle: TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.grey.shade400,
            fontSize: 14),
        fillColor: Colors.white,
        focusColor: CustomColors.primary,
        hoverColor: CustomColors.primary,
        filled: true,
        prefixIcon: Icon(
          FontAwesomeIcons.lock,
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

    final setPasswordButton = ButtonTheme(
      child: MaterialButton(
        color: CustomColors.primary,
        padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide.none,
        ),
        child: Row(
          // Replace with a Row for horizontal icon + text

          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Establecer",
              textAlign: TextAlign.center,
              style: style.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold),
            )
          ],
        ),
        onPressed: () async {
          final form = formKeySetPassword.currentState;
          if (form!.validate()) {
            form.save();
            setPassword();
          }
        },
      ),
    );

    final changePasswordButton = ButtonTheme(
      child: MaterialButton(
        color: CustomColors.primary,
        padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
          side: BorderSide.none,
        ),
        child: Row(
          // Replace with a Row for horizontal icon + text

          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Cambiar contraseña",
              textAlign: TextAlign.center,
              style: style.copyWith(
                  color: Colors.white, fontWeight: FontWeight.bold),
            )
          ],
        ),
        onPressed: () async {
          final form = formKeyChangePassword.currentState;
          if (form!.validate()) {
            form.save();
            changePassword();
          }
        },
      ),
    );

    Widget contentSetPassword = SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Form(
        key: formKeySetPassword,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Text(
                    "Actualmente no tiene establecida una contraseña de acceso, para poder acceder con correo electrónico y contraseña antes debe establecer una contraseña de acceso.",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.black)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Container(
                  height: 1,
                  color: Colors.grey[300],
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                    "Por favor, ingresa un contraseña que por lo menos tenga 6 caracteres.",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[500])),
              ),*/
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: passwordField,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: repeatPasswordField,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: setPasswordButton,
              )
            ],
          ),
        ),
      )
    ]));

    Widget contentChangePassword = SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      Form(
        key: formKeyChangePassword,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: Text(
                    "Actualmente cuentas con una contraseña asignada, para cambiar tu contraseña completa el siguiente formulario.",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.black)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Container(
                  height: 1,
                  color: Colors.grey[300],
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                    "Por favor, ingresa un contraseña que por lo menos tenga 6 caracteres.",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[500])),
              ),*/

              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                child: currentPasswordField,
              ),
              Text("Nueva contraseña"),
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: passwordField,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: repeatPasswordField,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: changePasswordButton,
              )
            ],
          ),
        ),
      )
    ]));

    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Stack(
          children: <Widget>[
            // The containers in the background
            new Column(
              children: <Widget>[
                FadeAnimation(
                  0.5,
                  Container(
                    height: MediaQuery.of(context).size.height * .40,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/background1.jpg'),
                            fit: BoxFit.cover)),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                            left:
                                ((MediaQuery.of(context).size.width) / 2) - 75,
                            top: 40,
                            width: 150,
                            height: 200,
                            child: FadeAnimation(
                              1,
                              Container(
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/app_icons/icon_foreground.png'),
                                )),
                              ),
                            ))
                      ],
                    ),
                  ),
                ),
                new Container(
                  height: MediaQuery.of(context).size.height * .60,
                  color: Colors.white,
                ),
              ],
            ),
            // The card widget with top padding,
            // incase if you wanted bottom padding to work,
            // set the `alignment` of container to Alignment.bottomCenter
            Center(
              child: new Container(
                alignment: Alignment.topCenter,
                constraints:
                    (kIsWeb) ? BoxConstraints(maxWidth: 600) : BoxConstraints(),
                padding: new EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * .30,
                    right: 20.0,
                    left: 20.0),
                child: new Container(
                  width: MediaQuery.of(context).size.width,
                  child: new Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.white,
                    elevation: 4.0,
                    child: DefaultTabController(
                        length: 1,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: const EdgeInsets.only(top: 12.0),
                              height: 45,
                              color: Colors.transparent,
                              child: TabBar(
                                isScrollable: false,
                                tabs: [
                                  Tab(
                                    text: checkHavePassword()
                                        ? "Cambiar contraseña"
                                        : "Establecer una contraseña",
                                    iconMargin: EdgeInsets.all(0),
                                    icon: null,
                                  )
                                ],
                                labelColor: Colors.grey[900],
                                labelStyle: TextStyle(fontSize: 18.0),
                                unselectedLabelColor: Colors.grey[400],
                                indicatorSize: TabBarIndicatorSize.label,
                                indicatorPadding: EdgeInsets.all(0),
                                indicatorColor: Colors.white,
                                labelPadding: EdgeInsets.only(top: 10),
                                onTap: (i) {},
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                height: 2,
                                color: Colors.grey[100],
                              ),
                            ),
                            (checkHavePassword())
                                ? contentChangePassword
                                : contentSetPassword
                          ],
                        )),
                  ),
                ),
              ),
            ),
            AppBar(
                iconTheme: IconThemeData(
                  color: CustomColors.primary, //change your color here
                ),
                title: Text(""),
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                centerTitle: true)
          ],
        )));
  }

  changePassword() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    simpleLoading(context, (BuildContext contextLoading) {
      WebService(context)
          .changePassword(myCtrlPass.text, myCtrlCurrentPass.text,
              provider.user.token ?? "")
          .then((value) {
        Navigator.pop(contextLoading);
        SnackBar(
                content: Text("Su contraseña ha sido cambiada",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                elevation: 100,
                duration: Duration(seconds: 2),
                backgroundColor: CustomColors.primary)
            .show(context);
        Navigator.pop(context);
      }).catchError((e) {
        Navigator.pop(contextLoading);
        showErrorsDialog(context, e);
      });
    });
  }

  setPassword() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    simpleLoading(context, (BuildContext contextLoading) {
      WebService(context)
          .setPassword(myCtrlPass.text, provider.user.token ?? "")
          .then((value) {
        Navigator.pop(contextLoading);
        SnackBar(
                content: Text("Su contraseña ha sido establecida",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                elevation: 100,
                duration: Duration(seconds: 2),
                backgroundColor: CustomColors.primary)
            .show(context);
        Navigator.pop(context);
      }).catchError((e) {
        Navigator.pop(contextLoading);
        showErrorsDialog(context, e);
      });
    });
  }

  bool checkHavePassword() {
    return widget.hasPassword;
  }
}
