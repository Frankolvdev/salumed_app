import 'dart:typed_data';

import 'package:app/components/custom_dialog.dart';
import 'package:app/components/override_date_picker.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/set_change_password.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:snack/snack.dart';
import 'package:universal_io/io.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class AdminAddPromotion extends StatefulWidget {
  Function callBackBack;
  AdminAddPromotion(this.callBackBack, {Key? key}) : super(key: key);

  @override
  _AdminAddPromotionState createState() => _AdminAddPromotionState();
}

class _AdminAddPromotionState extends State<AdminAddPromotion> {
  final cEmail = TextEditingController();
  final cNamePromotion = TextEditingController();
  final cCode = TextEditingController();
  final cDeliveryCommission = TextEditingController();
  final cProfessionalLicense = TextEditingController();

  final cAmountPercent = TextEditingController();
  final cAmount = TextEditingController();
  final cLimitUse = TextEditingController();

  final cTel = TextEditingController();
  final cStart = TextEditingController();
  final cEnd = TextEditingController();
  final cPass = TextEditingController();
  final cPassRepeat = TextEditingController();
  bool passwordVisible = true;
  bool passwordVisibleRepeat = true;

  dynamic start = null;
  dynamic end = null;
  final formKey = new GlobalKey<FormState>();

  dynamic imageSelected = null;
  dynamic birdate = null;
  String type = "percent";
  String apply_to = "buys"; //buys, shipping, all
  String enabled = "yes";
  String codeTel = "";

  List<Map<String, dynamic>> roles = [
    {"name": "Administrador", "val": "admin"},
    {"name": "Super administrador", "val": "super_admin"},
    {"name": "Administrador de farmacia", "val": "pharmacy_admin"},
    {"name": "Paciente", "val": "client"},
    {"name": "Repartidor", "val": "delivery"},
    {"name": "Doctor", "val": "doctor"}
  ];

  late String rolSelected;

  bool monday = true;
  bool tuesday = true;
  bool wednesday = true;
  bool thursday = true;
  bool friday = true;
  bool saturday = true;
  bool sunday = true;
  dynamic businessSelected = null;
  @override
  void initState() {
    super.initState();
    rolSelected = roles[0]["val"];
    cLimitUse.text = "0";
    loadPharmacy();
    BackButtonInterceptor.add(myInterceptor);
  }

  List<PharmacyModel> pharmacies = [];

  Future<Null> loadPharmacy() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getPharmacies(0, 0, context, provider.user.token ?? "", search: "")
        .then((value) {
      if (mounted)
        setState(() {
          pharmacies = value;
        });
    }).catchError((e) {
      showErrorsDialog(context, e);
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    widget.callBackBack();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);

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
          labelText: "Contraseña",
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
          )),
    );

    final repeatPasswordField = TextFormField(
      style: TextStyle(fontSize: 18.0),
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
          labelText: "Confirmar contraseña",
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
          )),
    );

    final deliveryCommissionField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cDeliveryCommission,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Comisión del repartidor',
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

    final namePromotionField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cNamePromotion,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Nombre de la promoción',
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
    final codeField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cCode,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Código',
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

    final professionalLicenseField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cProfessionalLicense,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Cédula profesional',
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

    final LimitUseField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cLimitUse,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Límite de usos (0 para usos ilimitados)',
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

    final amountPercentField = TextFormField(
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: cAmountPercent,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Porcentaje',
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
      onFieldSubmitted: (val) {},
    );

    final amountField = TextFormField(
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: cAmount,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Monto',
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
      onFieldSubmitted: (val) {},
    );

    final startField = TextFormField(
      onTap: () {
        selectDateTime((DateTime date) {
          cStart.text = getDateFromStringFormat(date.toString());

          setState(() {
            start = date;
          });
        });
      },
      autofocus: false,
      autocorrect: false,
      readOnly: true,
      controller: cStart,
      keyboardType: TextInputType.text,

      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Fecha de inicio',
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

    final endField = TextFormField(
      onTap: () {
        selectDateTime((DateTime date) {
          cEnd.text = getDateFromStringFormat(date.toString());

          setState(() {
            end = date;
          });
        });
      },
      autofocus: false,
      autocorrect: false,
      readOnly: true,
      controller: cEnd,
      keyboardType: TextInputType.text,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Fecha de vencimiento',
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
    String localeCode = "mx";
    if (!kIsWeb) localeCode = Platform.localeName.split("_")[1];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () {
                        widget.callBackBack()();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Icon(FontAwesomeIcons.arrowLeft,
                            size: 20, color: CustomColors.primary),
                      ))
                ],
              ),
            ),
            Center(
              child: Container(
                constraints:
                    kIsWeb ? BoxConstraints(maxWidth: 1000) : BoxConstraints(),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: namePromotionField,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: codeField,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("Tipo",
                            style: TextStyle(color: Colors.grey, fontSize: 15)),
                      ),
                      Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                type = "percent";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Por porcentaje'),
                              leading: Radio<String>(
                                value: "percent",
                                groupValue: type,
                                onChanged: (String? value) {
                                  setState(() {
                                    type = value ?? "percent";
                                  });
                                },
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                type = "amount";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Por monto'),
                              leading: Radio<String>(
                                value: "amount",
                                groupValue: type,
                                onChanged: (String? value) {
                                  setState(() {
                                    type = value ?? "amount";
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      (type == "percent")
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: amountPercentField,
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: amountField,
                            ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("En donde se aplica",
                            style: TextStyle(color: Colors.grey, fontSize: 15)),
                      ),
                      Column(
                        //buys, shipping, all
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                apply_to = "buys";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Monto de compra'),
                              leading: Radio<String>(
                                value: "buys",
                                groupValue: apply_to,
                                onChanged: (String? value) {
                                  setState(() {
                                    apply_to = value ?? "buys";
                                  });
                                },
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                apply_to = "shipping";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Envío'),
                              leading: Radio<String>(
                                value: "shipping",
                                groupValue: apply_to,
                                onChanged: (String? value) {
                                  setState(() {
                                    apply_to = value ?? "shipping";
                                  });
                                },
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                apply_to = "all";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Ambos'),
                              leading: Radio<String>(
                                value: "all",
                                groupValue: apply_to,
                                onChanged: (String? value) {
                                  setState(() {
                                    apply_to = value ?? "all";
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: LimitUseField,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: startField,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: endField,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Valido los dias",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15)),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                monday = !monday;
                              });
                            },
                            child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: const Text('Lunes'),
                                leading: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: monday,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      monday = !monday;
                                    });
                                  },
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                tuesday = !tuesday;
                              });
                            },
                            child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: const Text('Martes'),
                                leading: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: tuesday,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      tuesday = !tuesday;
                                    });
                                  },
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                wednesday = !wednesday;
                              });
                            },
                            child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: const Text('Miércoles'),
                                leading: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: wednesday,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      wednesday = !wednesday;
                                    });
                                  },
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                thursday = !thursday;
                              });
                            },
                            child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: const Text('Jueves'),
                                leading: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: thursday,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      thursday = !thursday;
                                    });
                                  },
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                friday = !friday;
                              });
                            },
                            child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: const Text('Viernes'),
                                leading: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: friday,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      friday = !friday;
                                    });
                                  },
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                saturday = !saturday;
                              });
                            },
                            child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: const Text('Sábado'),
                                leading: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: saturday,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      saturday = !saturday;
                                    });
                                  },
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                sunday = !sunday;
                              });
                            },
                            child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: const Text('Domingo'),
                                leading: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: sunday,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      sunday = !sunday;
                                    });
                                  },
                                )),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text("Negocio",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15)),
                            ),
                          ),
                          DropdownButtonFormField(
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color: Colors.grey,
                            ),
                            iconSize: 42,
                            items: pharmacies.map((PharmacyModel p) {
                              return new DropdownMenuItem(
                                  value: p,
                                  child: Text(p.title ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1));
                            }).toList(),
                            onChanged: (p) {
                              setState(() {
                                businessSelected = p;
                              });
                            },
                            value: businessSelected,
                            decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                              hintText: "Selecciona el negocio",
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 14),
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
                          )
                        ],
                      ),

                      //----------------------------new

                      //new
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: CustomColors.primary,
                              shape: StadiumBorder()),
                          onPressed: () {
                            processAdd();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 35.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Agregar",
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

  selectDateTime(Function callback) {
    OverrideDatePicker.showDatePicker(context,
        theme: DatePickerTheme(),
        showTitleActions: true,
        minTime: DateTime.now(),
        onChanged: (date) {}, onConfirm: (date) {
      setState(() {
        callback(date);
      });
    }, locale: LocaleType.es);
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

  showTakePicture() async {
    if (kIsWeb) {
      selectPictureWeb(context, (dynamic imageFile) {
        setState(() {
          this.imageSelected = imageFile;
        });
      });
    } else {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SelectPictureDialogWec(
              "Seleccionar imagen",
              (contextDialogd, image) {
                Navigator.pop(contextDialog);
                callbackShowTakePicture(contextDialogd, image);
              },
              useBtnCancel: true,
            );
          });
    }
  }

  Future callbackShowTakePicture(contextDialog, image) async {
    if (image == null) return;
    try {
      final XFile? imageFile = await ImagePicker().pickImage(
          source:
              (image == "camera") ? ImageSource.camera : ImageSource.gallery);
      if (imageFile != null) {
        File file = await File(imageFile.path);
        setState(() {
          this.imageSelected = file;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  processAdd() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);
        try {
          await WebService(context).createPromotion(
              cNamePromotion.text,
              cCode.text,
              type,
              double.parse(
                  (type == "percent") ? cAmountPercent.text : cAmount.text),
              apply_to,
              (cLimitUse.text.trim() != "") ? int.parse(cLimitUse.text) : 0,
              (start != null && start is DateTime)
                  ? (start as DateTime)
                      .toUtc()
                      .millisecondsSinceEpoch
                      .toString()
                  : "",
              (end != null && end is DateTime)
                  ? (end as DateTime).toUtc().millisecondsSinceEpoch.toString()
                  : "",
              (businessSelected != null)
                  ? (businessSelected as PharmacyModel).id ?? ""
                  : "",
              monday,
              tuesday,
              wednesday,
              thursday,
              friday,
              saturday,
              sunday,
              provider.user.token ?? "");

          Navigator.pop(loadingContext);
          SnackBar(
                  content: Text("Se ha agregado con éxito",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  elevation: 100,
                  duration: Duration(seconds: 2),
                  backgroundColor: CustomColors.primary)
              .show(context);
          widget.callBackBack();
        } catch (e) {
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
    }
  }
}
