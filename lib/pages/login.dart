import 'dart:async';

import 'package:app/components/fade_animation.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/role.dart';
import 'package:app/pages/forgot_password.dart';
import 'package:app/pages/home_client.dart';
import 'package:app/pages/register.dart';

import 'package:app/pages/select_type_user.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter_facebook_login_web/flutter_facebook_login_web.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  String messageAfter;
  Login({Key? key, this.messageAfter = ""}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

/*GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  //clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>['email'],
);*/

class _LoginState extends State<Login> {
  bool passwordVisible = true;
  final cEmail = TextEditingController();
  final cPass = TextEditingController();
  final formKey = new GlobalKey<FormState>();
  //late StreamSubscription currentStream;
  bool gmailPress = false;
  bool facebookPress = false;

  bool pharmacyRegister = false;
  bool idRequiredDoctor = false;
  @override
  void initState() {
    super.initState();

    /* currentStream = _googleSignIn.onCurrentUserChanged
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
      if (kIsWeb) {
      } else {
//_googleSignIn.signIn();
      }
    } catch (e) {
      print(e);
      debugPrint(e.toString());
    }
 */
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.messageAfter.trim() != "")
        showErrorsDialog(context, [widget.messageAfter]);
    });

    final provider = Provider.of<AppProvider>(context, listen: false);
    dynamic json = provider.config;
    pharmacyRegister = (json.containsKey("enable_register_pharmacy"))
        ? json["enable_register_pharmacy"]
        : false;
    idRequiredDoctor = (json.containsKey("enable_mandatory_identification"))
        ? json["enable_mandatory_identification"]
        : false;
  }

  @override
  void dispose() {
    // currentStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordField = TextFormField(
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp('[ ]')),
        ],
        validator: (val) {
          return validatePassword1(val ?? "", context);
        },
        controller: cPass,
        obscureText: passwordVisible,
        style: TextStyle(fontSize: 18.0),
        //initialValue: Environment.localPassword(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Su contraseña",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          fillColor: Colors.white,
          filled: true,
          prefixIcon: Icon(
            FontAwesomeIcons.lock,
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

    Widget btnLogin = ElevatedButton(
      style: ElevatedButton.styleFrom(
          elevation: 2, backgroundColor: CustomColors.primary, shape: StadiumBorder()),
      onPressed: () {
        processSignInEmailPassword();
      },
      child: Container(
        width: double.infinity,
        height: 35.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Ingresar",
              style: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
        body: Center(
      child: ListView(
        shrinkWrap: kIsWeb ? true : false,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 40.0, right: 40.0, top: 20, bottom: 20),
                  child: Column(
                    children: [
                      FadeAnimation(
                        1,
                        Image.asset(
                            'assets/images/logo-riandamd-bg-transparent.png',
                            width: (kIsWeb) ? 230 : 150),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 8),
                      //   child: Text("!Bienvenido¡",
                      //       style:
                      //           TextStyle(color: Colors.black, fontSize: 25)),
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                            constraints: (kIsWeb)
                                ? BoxConstraints(maxWidth: 600)
                                : BoxConstraints(),
                            color: CustomColors.primary,
                            height: 2,
                            width: MediaQuery.of(context).size.width * .70),
                      ),
                      SizedBox(height: 15),
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
                                  child: btnLogin,
                                )
                              ],
                            ),
                          ),
                        ),
                        axis: AxisAnimation.y,
                        negative: true,
                      ),
                      FadeAnimation(
                        1,
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: ForgotPassword(),
                                    type: PageTransitionType.slideInRight,
                                    duration: Duration(milliseconds: 250)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("¿Olvidaste tu contraseña?",
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 15)),
                          ),
                        ),
                        axis: AxisAnimation.y,
                        negative: true,
                      ),
                      FadeAnimation(
                        1,
                        Container(
                          constraints: (kIsWeb)
                              ? BoxConstraints(maxWidth: 600)
                              : BoxConstraints(),
                          child: Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 2,
                                    backgroundColor: CustomColors.secondary,
                                    shape: StadiumBorder()),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: Register("client"),
                                          type: PageTransitionType.slideInRight,
                                          duration:
                                              Duration(milliseconds: 250)));
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 35.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "Regístrate como miembro",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 2,
                                    backgroundColor: CustomColors.secondary,
                                    shape: StadiumBorder()),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: Register("doctor"),
                                          type: PageTransitionType.slideInRight,
                                          duration:
                                              Duration(milliseconds: 250)));
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 35.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "Regístrate como médico",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              (pharmacyRegister)
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 2,
                                          backgroundColor: CustomColors.secondary,
                                          shape: StadiumBorder()),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                child:
                                                    Register("pharmacy_admin"),
                                                type: PageTransitionType
                                                    .slideInRight,
                                                duration: Duration(
                                                    milliseconds: 250)));
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 35.0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                "Registra tu Farmacia/Laboratorio",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14.0),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 2,
                                    backgroundColor: CustomColors.secondary,
                                    shape: StadiumBorder()),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: Register("hospital_admin"),
                                          type: PageTransitionType.slideInRight,
                                          duration:
                                              Duration(milliseconds: 250)));
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 35.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "Registra tu Hospital/Clínica",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        axis: AxisAnimation.y,
                        negative: true,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      FadeAnimation(
                        1,
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: ForgotPassword(),
                                    type: PageTransitionType.slideInRight,
                                    duration: Duration(milliseconds: 250)));
                          },
                          child: Container(
                            constraints: (kIsWeb)
                                ? BoxConstraints(maxWidth: 600)
                                : BoxConstraints(),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: InkWell(
                                onTap: () {
                                  openLegalLinks();
                                },
                                child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                        style: TextStyle(
                                          color: CustomColors.primary,
                                          fontSize: 13,
                                        ),
                                        children: [
                                          new TextSpan(
                                              text:
                                                  'Al ingresar o registrarte en esta app estás aceptando nuestra '),
                                          new TextSpan(
                                              text: 'política de privacidad',
                                              style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline,
                                              )),
                                          new TextSpan(
                                              text: ', ',
                                              style: new TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          new TextSpan(
                                              text: 'términos y condiciones',
                                              style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline,
                                              )),
                                        ])),
                              ),
                            ),
                          ),
                        ),
                        axis: AxisAnimation.y,
                        negative: true,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }

  openLegalLinks() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (contextDialog) {
          return Dialog(
              insetPadding: getDialogInsetPaddin(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding:
                    EdgeInsets.only(top: 16, bottom: 8, left: 16, right: 16),
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
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, top: 5),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                FontAwesomeIcons.times,
                                size: 30,
                                color: CustomColors.primary,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          launchUrl(
                              context, "https://riandamd.com/privacy-policies");
                        },
                        child: Column(
                          children: [
                            Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Ver política de privacidad",
                                      textAlign: TextAlign.center,
                                    ),
                                  ))
                                ]),
                            Divider()
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          launchUrl(context,
                              "https://riandamd.com/terms-and-conditions");
                        },
                        child: Column(
                          children: [
                            Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                      child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "Ver términos y condiciones",
                                      textAlign: TextAlign.center,
                                    ),
                                  ))
                                ]),
                            Divider()
                          ],
                        ),
                      )
                    ],
                  )
                ]),
              ));
        });
  }

  enterWithoutRegistration() {
    simpleLoading(context, (BuildContext loadingContext) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      WebService(context)
          .signIn(emailUserUnregister, passwordUserUnregister)
          .then((user) async {
        await provider.setUser(user);
        initProcess(context, user.token ?? "", () {
          Navigator.pop(loadingContext);
          goHome(context, provider.user.roles);
        });
      }).catchError((e) {
        print(e);
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e);
      });
    });
  }

  Future<void> _handleSignInGoogle() async {
    /*  bool signin = await _googleSignIn.isSignedIn();

    try {
      if (signin) {
        await _googleSignIn.disconnect();
      }
      await _googleSignIn.signOut();
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
      debugPrint(error.toString());
      setState(() {
        gmailPress = false;
      });
    }*/
  }

  Future<void> _handleSignInFacebook() async {
    //for web
    /* simpleLoading(context, (BuildContext loadingContext) async {
      try {
        final facebookSignIn = FacebookLoginWeb();
        //await facebookSignIn.logOut();
        final FacebookLoginResult result =
            await facebookSignIn.logIn(['email', 'public_profile']);

        switch (result.status) {
          case FacebookLoginStatus.loggedIn:
            final FacebookAccessToken? accessToken = result.accessToken;

            var res = facebookSignIn.testApi().then((value) {
              Navigator.pop(loadingContext);
              debugPrint("finish inter");
              debugPrint("nombre" + value.toString());
              debugPrint("token" + accessToken!.token);
              processSignInAuth(
                  accessToken.userId, value.toString(), "", "FACEBOOK",
                  picture: "");
            }).catchError((e) {
              Navigator.pop(loadingContext);
              showErrorsDialog(
                  context, ["Ocurrió un error desconocido, intente de nuevo."]);
            });

            debugPrint("finish1");
            break;
          case FacebookLoginStatus.cancelledByUser:
            debugPrint("user cancelled login facebook");
            Navigator.pop(loadingContext);
            break;
          case FacebookLoginStatus.error:
            Navigator.pop(loadingContext);
            showErrorsDialog(
                context, ["Ocurrió un error desconocido, intente de nuevo."]);
            debugPrint(result.errorMessage);

            break;
          default:
            Navigator.pop(loadingContext);
            break;
        }
      } catch (error) {
        showErrorsDialog(context, [error.toString()]);
        Navigator.pop(loadingContext);
        debugPrint(error.toString());
      }
    });*/

    //for app

    simpleLoading(context, (BuildContext loadingContext) async {
      try {
        await FacebookLogin().logOut();

        final facebookLogin = FacebookLogin();

        //facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
        final result = await facebookLogin.logIn(permissions: [
          FacebookPermission.publicProfile,
          FacebookPermission.email
        ]);

        switch (result.status) {
          case FacebookLoginStatus.success:
            final token = result.accessToken!.token;
            // Get profile data
            final profile = await facebookLogin.getUserProfile();
            print('Hello, ${profile!.name}! You ID: ${profile.userId}');

            // Get user profile image url
            final imageUrl = await facebookLogin.getProfileImageUrl(width: 100);
            print('Your profile image: $imageUrl');

            // Get email (since we request email permission)
            final email = await facebookLogin.getUserEmail();
            // But user can decline permission
            if (email != null) print('And your email is $email');
            Navigator.pop(loadingContext);
            processSignInAuth(
                result.accessToken!.userId,
                "${profile.name ?? ''} ${profile.lastName ?? ''}",
                email ?? "",
                "FACEBOOK",
                picture: imageUrl ?? "");

            break;
          case FacebookLoginStatus.cancel:
            print("user cancelled login facebook");
            Navigator.pop(loadingContext);
            break;
          case FacebookLoginStatus.error:
            Navigator.pop(loadingContext);
            showErrorsDialog(
                context, ["Ocurrió un error desconocido, intente de nuevo."]);
            print(result.error);

            break;
        }
      } catch (error) {
        Navigator.pop(loadingContext);
        print(error);
      }
    });
  }

  processSignInEmailPassword() async {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();

      simpleLoading(context, (BuildContext loadingContext) {
        final provider = Provider.of<AppProvider>(context, listen: false);
        WebService(context).signIn(cEmail.text, cPass.text).then((user) async {
          await provider.setUser(user);

          initProcess(context, user.token ?? "", () {
            Navigator.pop(loadingContext);
            goHome(context, provider.user.roles);
          });
        }).catchError((e) {
          print(e);
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e);
        });
      });
    }
  }

  processSignInAuth(
      String token, String name, String email, String providerAuth,
      {String phone = "", String picture = ""}) {
    simpleLoading(context, (BuildContext loadingContext) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      WebService(context)
          .signInAuth(token, formatFirstUpper(name), email, providerAuth, phone,
              picture)
          .then((user) async {
        await provider.setUser(user);

        initProcess(context, user.token ?? "", () {
          Navigator.pop(loadingContext);
          goHome(context, provider.user.roles);
        });
      }).catchError((e) {
        print(e);
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e);
      });
    });
  }
}
