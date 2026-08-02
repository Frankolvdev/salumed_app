import 'dart:convert';

import 'package:app/components/dialog_select_date_range.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';
import 'package:snack/snack.dart';

class AdminConfig extends StatefulWidget {
  const AdminConfig({Key? key}) : super(key: key);

  @override
  State<AdminConfig> createState() => _AdminConfigState();
}

class _AdminConfigState extends State<AdminConfig> {
  String codeTel = "";
  final cTel = TextEditingController();
  final cEmail = TextEditingController();

  bool pharmacyRegister = false;
  bool idRequiredDoctor = false;

  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);
    dynamic json = provider.config;
    pharmacyRegister = (json.containsKey("enable_register_pharmacy"))
        ? json["enable_register_pharmacy"]
        : false;
    idRequiredDoctor = (json.containsKey("enable_mandatory_identification"))
        ? json["enable_mandatory_identification"]
        : false;
    cEmail.text =
        (json.containsKey("email_support")) ? json["email_support"] : "";
    cTel.text = (json.containsKey("phone")) ? json["phone"] : "";
    codeTel = (json.containsKey("dial_code")) ? json["dial_code"] : "";
  }

  @override
  Widget build(BuildContext context) {
    final telField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cTel,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      maxLength: 10,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Whatsapp',
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
      keyboardType: TextInputType.emailAddress,
      validator: (val) {
        return validateEmail(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Correo de soporte',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 50,
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: CustomColors.secondary,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Text("General",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: emailField,
                      ),

                      //----------------------------new
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                                flex: 2,
                                child: CountryCodePicker(
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
                            Flexible(flex: 10, child: telField)
                          ]),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: CustomColors.secondary,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Text("Login/Registro",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          setState(() {
                            pharmacyRegister = !pharmacyRegister;
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              checkColor: Colors.white,
                              value: pharmacyRegister,
                              onChanged: (bool? value) {
                                setState(() {
                                  pharmacyRegister = value!;
                                });
                              },
                            ),
                            Text("Activar registro farmacia",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          color: CustomColors.secondary,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            child: Text("Registro médico",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          setState(() {
                            idRequiredDoctor = !idRequiredDoctor;
                          });
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              checkColor: Colors.white,
                              value: idRequiredDoctor,
                              onChanged: (bool? value) {
                                setState(() {
                                  idRequiredDoctor = value!;
                                });
                              },
                            ),
                            Text("Identificación obligatoria",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      ),

                      //new
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              primary: CustomColors.primary,
                              shape: StadiumBorder()),
                          onPressed: () {
                            processEdit();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 35.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Guardar",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
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

  processEdit() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);
        try {
          dynamic config = await WebService(context).updateConfig(
              cEmail.text,
              cTel.text,
              codeTel,
              pharmacyRegister,
              idRequiredDoctor,
              provider.user.token ?? "");
          provider.setConfig(jsonDecode(jsonEncode(config)));

          Navigator.pop(loadingContext);
          SnackBar(
                  content: Text("Se ha guardado con éxito",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  elevation: 100,
                  duration: Duration(seconds: 2),
                  backgroundColor: CustomColors.primary)
              .show(context);
        } catch (e) {
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
    }
  }
}
