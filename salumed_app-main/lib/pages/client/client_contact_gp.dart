import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snack/snack.dart';
import 'package:universal_io/io.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientContactGp extends StatefulWidget {
  const ClientContactGp({Key? key}) : super(key: key);

  @override
  State<ClientContactGp> createState() => _ClientContactGpState();
}

class _ClientContactGpState extends State<ClientContactGp> {
  final cEmail = TextEditingController();
  final cName = TextEditingController();
  final cTel = TextEditingController();
  final cDescription = TextEditingController();

  final formKey = new GlobalKey<FormState>();

  String codeTel = "";
  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      getDoctor();
    });
  }

  dynamic doctor = null;
  getDoctor() {
    simpleLoading(context, (BuildContext loadingContext) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      try {
        doctor = await WebService(context).getGp(provider.user.token ?? "");

        Navigator.pop(loadingContext);

        setState(() {
          doctor = doctor;
        });
        cEmail.text = doctor.email ?? "";
        cTel.text = doctor.phone ?? "";
        cName.text = formatFirstUpper(doctor.name ?? "");
        codeTel = doctor.dial_code ?? "";
      } catch (e) {
        Navigator.pop(loadingContext);
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    UserModel user = provider.user;
    final nameField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cName,

      readOnly: true,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Nombre de tu médico',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CustomColors.primary),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );

    final emailField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cEmail,
      readOnly: true,
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        return validateEmail(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CustomColors.primary),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );

    final telField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cTel,
      readOnly: true,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      maxLength: 10,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Teléfono',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CustomColors.primary),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );

    final descriptionField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cDescription,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Asunto ',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CustomColors.primary),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );

    String localeCode = "mx";
    if (!kIsWeb) localeCode = Platform.localeName.split("_")[1];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            Center(
              child: Container(
                constraints:
                    kIsWeb ? BoxConstraints(maxWidth: 600) : BoxConstraints(),
                child: Padding(
                  padding: (kIsWeb)
                      ? const EdgeInsets.only(
                          left: 35.0,
                          right: 35.0,
                        )
                      : const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                        ),
                  child: (doctor == null)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * .45,
                                child: Center(
                                  child: Text(
                                      "Aún no tienes ningún medico de cabecera asignado.",
                                      style: TextStyle(
                                        color: CustomColors.primary,
                                        fontSize: 25,
                                      ),
                                      textAlign: TextAlign.center),
                                ),
                              )
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            SizedBox(
                              height: 20,
                            ),

                            //new

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
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                      flex: 2,
                                      child: CountryCodePicker(
                                        enabled: false,
                                        padding: EdgeInsets.only(top: 18),
                                        onInit: (code) {
                                          if (mounted) {
                                            WidgetsBinding.instance
                                                ?.addPostFrameCallback((_) {
                                              setState(() {
                                                codeTel = code.toString();
                                              });
                                            });
                                          }
                                        },
                                        onChanged: (code) {
                                          setState(() {
                                            codeTel = code.dialCode.toString();
                                          });
                                        },
                                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                        initialSelection:
                                            (codeTel != "" && codeTel != null)
                                                ? codeTel
                                                : localeCode,

                                        // optional. Shows only country name and flag
                                        showCountryOnly: false,
                                        // optional. Shows only country name and flag when popup is closed.
                                        showOnlyCountryWhenClosed: false,
                                        // optional. aligns the flag and the Text left
                                        alignLeft: false,
                                      )),
                                  Flexible(flex: 5, child: telField)
                                ]),

                            //----------------------------new

                            //new
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(vertical: 15.0),
                            //   child: ElevatedButton(
                            //     style: ElevatedButton.styleFrom(
                            //         elevation: 2,
                            //         backgroundColor: CustomColors.primary,
                            //         shape: StadiumBorder()),
                            //     onPressed: () {
                            //       sendProcess();
                            //     },
                            //     child: Container(
                            //       width: double.infinity,
                            //       height: 35.0,
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.center,
                            //         children: [
                            //           Text(
                            //             "Enviar",
                            //             style: TextStyle(
                            //                 color: Colors.white, fontSize: 15.0),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 2,
                                    backgroundColor: Color.fromARGB(255, 0, 137, 48),
                                    shape: StadiumBorder()),
                                onPressed: () {
                                  openWhatsapp(
                                      ((codeTel != "" && codeTel != null)
                                              ? codeTel
                                              : localeCode) +
                                          ((doctor as UserModel).phone ?? ""));
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 35.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.whatsapp,
                                          color: Colors.white, size: 30),
                                      Text(
                                        "Chatea con tu médico de cabecera",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  openWhatsapp(String tel) async {
    var whatsappURl_android = "whatsapp://send?phone=" + tel + "&text=hello";
    var whatappURL_ios = "https://wa.me/$tel?text=${Uri.parse("hello")}";
    var whatappURL_web = "https://api.whatsapp.com/send?phone=" + tel;
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunch(whatappURL_ios)) {
        await launch(whatappURL_ios, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("whatsapp no installed")));
      }
    } else {
      // android , web
      if (kIsWeb) {
        if (await canLaunch(whatappURL_web)) {
          await launch(whatappURL_web);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: new Text("whatsapp no installed")));
        }
      } else {
        if (await canLaunch(whatsappURl_android)) {
          await launch(whatsappURl_android);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: new Text("Whatsapp no ​​instalado")));
        }
      }
    }
  }

  sendProcess() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);
        try {
          dynamic assets = null;

          await WebService(context).contact(
              cDescription.text,
              "",
              cEmail.text,
              cName.text,
              (cTel.text != "") ? (codeTel + cTel.text) : "",
              "client");

          Navigator.pop(loadingContext);
          SnackBar(
                  content: Text("Se ha enviado con éxito",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  elevation: 100,
                  duration: Duration(seconds: 2),
                  backgroundColor: CustomColors.primary)
              .show(context);

          setState(() {
            cDescription.text = "";
          });
        } catch (e) {
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
    }
  }
}
