import 'dart:async';
import 'dart:convert';
import 'package:app/components/fade_animation.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/app_preferences.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/guest_prescription.dart';
import 'package:app/pages/login.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

import 'hero.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  int lagSeconds = 2;

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      SystemChrome.setEnabledSystemUIOverlays([]);

      _initProcess();
    });
  }

  _initProcess() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    Timer(Duration(seconds: lagSeconds), () async {
      try {
        UserModel user = await AppPreferences().getUser();

        // if (!kIsWeb) {
        //   await OneSignal.shared.promptUserForPushNotificationPermission(
        //       fallbackToSettings: true);

        //   OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
        //   //OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
        //   await OneSignal.shared.setAppId(
        //       (Theme.of(context).platform == TargetPlatform.android)
        //           ? oneSignalAppIdAndroid
        //           : oneSignalAppIdIos);
        // }

        dynamic config = await WebService(context).getConfig();
        provider.setConfig(jsonDecode(jsonEncode(config)));
        if (tokenPrescription != null) {
          try {
            dynamic dataGuest =
                await WebService(context).getGuestDoctorData(tokenPrescription);
            if (user.id == null) {
              Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      child: GuestPrescription(() {}, dataGuest),
                      type: PageTransitionType.slideInUp,
                      duration: Duration(milliseconds: 250)),
                  (Route<dynamic> route) => false);
            } else {
              await provider.setUser(user);
              initProcess(context, user.token ?? "", () {
                goHome(context, provider.user.roles, dataGuest: dataGuest);
              });
            }

            return;
          } catch (e) {}
        }

        if (user.id == null) {


          // Navigator.pushAndRemoveUntil(
          //     context,
          //     PageTransition(
          //         child: Login(),
          //         type: PageTransitionType.slideInUp,
          //         duration: Duration(milliseconds: 250)),
          //     (Route<dynamic> route) => false);

 Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                  child: HeroPage(),
                  type: PageTransitionType.slideInUp,
                  duration: Duration(milliseconds: 250)),
              (Route<dynamic> route) => false);

        } else {

           Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                  child: HeroPage(),
                  type: PageTransitionType.slideInUp,
                  duration: Duration(milliseconds: 250)),
              (Route<dynamic> route) => false);
         /* await provider.setUser(user);
          initProcess(context, user.token ?? "", () {
            goHome(context, provider.user.roles);
          });*/
        }
      } catch (e) {
        print("error al cargar");
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: FadeAnimation(
                      1,
                      Image.asset(
                          'assets/images/logo-riandamd-bg-transparent.png',
                          width: kIsWeb
                              ? MediaQuery.of(context).size.width * .20
                              : MediaQuery.of(context).size.width * .50)),
                ),
                SizedBox(
                  height: 20,
                ),
                /*  FadeAnimation(
                    1,
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Bienvenido",
                          style: TextStyle(
                              color: CustomColors.primary, fontSize: 27)),
                    )),*/
                JumpingDotsProgressIndicator(
                  fontSize: 50.0,
                  color: CustomColors.primary,
                  numberOfDots: 4,
                  milliseconds: 150,
                ),
              ],
            ),
          ),
        ));
  }
}
