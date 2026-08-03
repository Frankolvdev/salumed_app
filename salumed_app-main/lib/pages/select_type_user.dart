import 'package:app/components/fade_animation.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class SelectTypeUser extends StatefulWidget {
  const SelectTypeUser({Key? key}) : super(key: key);

  @override
  _SelectTypeUserState createState() => _SelectTypeUserState();
}

class _SelectTypeUserState extends State<SelectTypeUser> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            Center(
              child: Container(
                constraints:
                    kIsWeb ? BoxConstraints(maxWidth: 600) : BoxConstraints(),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 40.0, right: 40.0, top: 20, bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text("Bienvenido",
                            style: TextStyle(
                                color: CustomColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 25)),
                      ),
                      Visibility(
                          visible: kIsWeb,
                          child: SizedBox(
                            height: 30,
                          )),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * .15),
                        child: Text(formatFirstUpper(provider.user.name ?? ""),
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 19),
                            textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("¿Como quieres continuar?",
                            style: TextStyle(
                                color: Colors.grey.shade700, fontSize: 19),
                            textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Container(
                            color: CustomColors.primary,
                            height: 2,
                            width: MediaQuery.of(context).size.width * .70),
                      ),
                      (kIsWeb)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                FadeAnimation(
                                  1,
                                  InkWell(
                                    onTap: () {
                                      updateTypeUser("client");
                                    },
                                    child: Image.asset(
                                        'assets/images/cliente-icon.png',
                                        width: 200),
                                  ),
                                  axis: AxisAnimation.y,
                                  negative: true,
                                ),
                                FadeAnimation(
                                  1,
                                  InkWell(
                                    onTap: () {
                                      updateTypeUser("professional");
                                    },
                                    child: Image.asset(
                                        'assets/images/profesional-icon.png',
                                        width: 200),
                                  ),
                                  axis: AxisAnimation.y,
                                  negative: false,
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                FadeAnimation(
                                  1,
                                  InkWell(
                                    onTap: () {
                                      updateTypeUser("client");
                                    },
                                    child: Image.asset(
                                        'assets/images/cliente-icon.png',
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .44),
                                  ),
                                  axis: AxisAnimation.y,
                                  negative: true,
                                ),
                                FadeAnimation(
                                  1,
                                  InkWell(
                                    onTap: () {
                                      updateTypeUser("professional");
                                    },
                                    child: Image.asset(
                                        'assets/images/profesional-icon.png',
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .45),
                                  ),
                                  axis: AxisAnimation.y,
                                  negative: false,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ));
  }

  updateTypeUser(String rol) {
    /* simpleLoading(context, (BuildContext loadingContext) {
        final provider = Provider.of<AppProvider>(context, listen: false);
        WebService(context).updateUser(provider.user.id??"", "", "", "", "", "", "", rol,"","",[],"", provider.user.token??"").then((user)async {
          await provider.setUser(user);
            initProcess(context, user.token ?? "", () {
            Navigator.pop(loadingContext);
            goHome(context, provider.user.roles);
          });         
        }).catchError((e) {
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e);
        });
      });*/
  }
}
