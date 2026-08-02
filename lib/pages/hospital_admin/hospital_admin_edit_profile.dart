import 'dart:typed_data';

import 'package:app/components/custom_dialog.dart';
import 'package:app/components/override_date_picker.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/asset.dart';
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

class HospitalAdminEditProfile extends StatefulWidget {
  const HospitalAdminEditProfile({Key? key}) : super(key: key);

  @override
  _HospitalAdminEditProfileState createState() =>
      _HospitalAdminEditProfileState();
}

class _HospitalAdminEditProfileState extends State<HospitalAdminEditProfile> {
  final cEmail = TextEditingController();
  final cName = TextEditingController();
  final cTel = TextEditingController();
  final cBirdate = TextEditingController();
  final cHasCovid = TextEditingController();
  final cCountVaccines = TextEditingController();
  final cHeight = TextEditingController();
  final cWeight = TextEditingController();

  final cRfc = TextEditingController();
  final cFiscalAddress = TextEditingController();

  final formKey = new GlobalKey<FormState>();

  dynamic imageSelected = null;
  dynamic birdate = null;
  String codeTel = "";
  bool requestInvoice = false;
  final cYears = TextEditingController();
  final cBloodType = TextEditingController();
  final cOrganDonor = TextEditingController();
  final cDiseases = TextEditingController();
  final cAllergies = TextEditingController();

  num imc = 0;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);

    cEmail.text = provider.user.email ?? "";
    cTel.text = provider.user.phone ?? "";

    cName.text = formatFirstUpper(provider.user.name ?? "");
    cBirdate.text = (provider.user.birthdate != null &&
            provider.user.birthdate != "")
        ? getDateFromStringFormat(
            DateTime.parse(provider.user.birthdate ?? "").toLocal().toString())
        : "";
    birdate = (provider.user.birthdate != null && provider.user.birthdate != "")
        ? DateTime.parse(provider.user.birthdate ?? "").toUtc()
        : null;
    codeTel = provider.user.dial_code ?? "";

    cYears.text = (provider.user.years != null && provider.user.years != "")
        ? provider.user.years ?? ""
        : "";
    cBloodType.text =
        (provider.user.blood_type != null && provider.user.blood_type != "")
            ? provider.user.blood_type ?? ""
            : "";
    cOrganDonor.text =
        (provider.user.organ_donor != null && provider.user.organ_donor != "")
            ? provider.user.organ_donor ?? ""
            : "";
    cDiseases.text =
        (provider.user.diseases != null && provider.user.diseases != "")
            ? provider.user.diseases ?? ""
            : "";
    cAllergies.text =
        (provider.user.allergies != null && provider.user.allergies != "")
            ? provider.user.allergies ?? ""
            : "";

    cHasCovid.text =
        (provider.user.has_covid != null && provider.user.has_covid != "")
            ? provider.user.has_covid ?? ""
            : "";

    cCountVaccines.text = (provider.user.count_vaccines != null &&
            provider.user.count_vaccines != "" &&
            provider.user.count_vaccines! > 0)
        ? provider.user.count_vaccines.toString()
        : "";

    cHeight.text = (provider.user.height != null &&
            provider.user.height != "" &&
            provider.user.height! > 0)
        ? provider.user.height.toString()
        : "";

    cWeight.text = (provider.user.weight != null &&
            provider.user.weight != "" &&
            provider.user.weight! > 0)
        ? provider.user.weight.toString()
        : "";

    cHeight.addListener(calcImc);
    cWeight.addListener(calcImc);

    cRfc.text = provider.user.rfc ?? "";
    cFiscalAddress.text = provider.user.fiscal_address ?? "";
    requestInvoice = provider.user.request_invoice == "yes" ? true : false;

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      calcImc();
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    cHeight.dispose();
    cWeight.dispose();

    super.dispose();
  }

  calcImc() {
    num height = 0;
    num weight = 0;

    if (cHeight.text.trim() != "" && cWeight.text.trim() != "") {
      height = double.parse(cHeight.text) / 100;
      weight = double.parse(cWeight.text);

      double imcTmp = weight / (height * height);

      setState(() {
        imc = imcTmp;
      });
    } else {
      setState(() {
        imc = 0;
      });
    }
  }

  String getImcDesc(num imc) {
    String _info = "";
    if (imc < 18.6) {
      _info = 'Estas bajo de peso';
    } else if (imc >= 18.6 && imc < 24.9) {
      _info = 'Tu peso es el ideal';
    } else if (imc >= 24.9 && imc < 29.9) {
      _info = 'Un poco de sobrepeso';
    } else if (imc >= 29.9 && imc < 34.9) {
      _info = 'Obesidad grado I';
    } else if (imc >= 34.9 && imc < 39.9) {
      _info = 'Obesidad grado II';
    } else if (imc >= 40) {
      _info = 'Obesidad grado III';
    } else {}
    return _info;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    UserModel user = provider.user;
    final nameField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cName,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Nombre o razón social',
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

    final birdateField = TextFormField(
      onTap: () {
        selectDateTime((DateTime date) {
          num years = new DateTime.now().difference(date).inDays / 365;

          if (years < 18) {
            showErrorsDialog(context, [
              "Debe tener más de 18 años para poder utilizar la aplicación"
            ]);
            setState(() {
              cBirdate.text = "";
              birdate = null;
            });
          } else {
            setState(() {
              cBirdate.text = getDateFromStringFormat(date.toString());
              birdate = date;
            });
          }
        });
      },
      autofocus: false,
      autocorrect: false,
      readOnly: true,
      controller: cBirdate,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Fecha de nacimiento',
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

    final rfcField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cRfc,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'RFC con homoclave',
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

    final fiscalAddressField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cFiscalAddress,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Dirección fiscal',
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

    final yearsField = TextFormField(
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      autofocus: false,
      autocorrect: false,
      controller: cYears,
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
        labelText: 'Edad en años',
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

    final weightField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cWeight,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      maxLines: null,
      readOnly: false,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Peso en Kg',
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

    final heightField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cHeight,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      maxLines: null,
      readOnly: false,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Altura en cm',
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

    final countVaccinesField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cCountVaccines,
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
        labelText: 'Cuantas vacunas contra COVID-19 tienes puestas',
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

    final bloodTypeField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cBloodType,
      keyboardType: TextInputType.text,
      maxLines: null,
      readOnly: false,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Tipo de sangre ',
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

    final hasCovidField = TextFormField(
      autofocus: false,

      autocorrect: false,
      controller: cHasCovid,
      keyboardType: TextInputType.text,
      maxLines: null,
      readOnly: false,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Has tenido COVID-19',
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

    final allergiesField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cAllergies,
      keyboardType: TextInputType.text,
      maxLines: null,
      readOnly: false,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Alergias ',
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

    final diseasesField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cDiseases,
      keyboardType: TextInputType.text,
      maxLines: null,
      readOnly: false,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Enfermedades crónicas ',
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

    final organDonorField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cOrganDonor,
      keyboardType: TextInputType.text,
      maxLines: null,
      readOnly: false,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Donador de organos ',
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
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        width: 160,
                        height: 160,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Visibility(
                                visible: imageSelected == null,
                                child: Container(
                                  height: 160,
                                  width: 160,
                                  decoration: new BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(10.0)),
                                  ),
                                  child: (user.picture != null)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                "assets/images/loading-image1.gif",
                                            image: getImageUrl(user.picture!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          decoration: new BoxDecoration(
                                              color: Colors.transparent,
                                              borderRadius:
                                                  new BorderRadius.all(
                                                      Radius.circular(45.0))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Image.asset(
                                              "assets/images/hospital_avatar.png",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                                child: (imageSelected != null)
                                    ? Container(
                                        width: 160,
                                        height: 160,
                                        decoration: BoxDecoration(
                                          borderRadius: new BorderRadius.all(
                                              Radius.circular(10.0)),
                                          image: (imageSelected is Uint8List)
                                              ? DecorationImage(
                                                  image: MemoryImage(
                                                      imageSelected),
                                                  fit: BoxFit.cover,
                                                )
                                              : DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image:
                                                      FileImage(imageSelected)),
                                        ),
                                      )
                                    : Container()),
                            Positioned.fill(
                                child: InkWell(
                              onTap: () {
                                showTakePicture();
                              },
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: new BoxDecoration(
                                    color: (imageSelected != null)
                                        ? Colors.transparent
                                        : Colors.black.withAlpha(80),
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(10.0))),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      FontAwesomeIcons.camera,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: nameField,
                      ),

                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                      //   child: birdateField,
                      // ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: emailField,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: rfcField,
                      ),

                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: fiscalAddressField),
                      InkWell(
                        onTap: () {
                          setState(() {
                            requestInvoice = !requestInvoice;
                          });
                        },
                        child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: const Text('Solicitar factura'),
                            leading: Checkbox(
                              checkColor: Colors.white,
                              fillColor:
                                  MaterialStateProperty.resolveWith(getColor),
                              value: requestInvoice,
                              onChanged: (bool? value) {
                                setState(() {
                                  requestInvoice = !requestInvoice;
                                });
                              },
                            )),
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
                            Flexible(flex: 5, child: telField)
                          ]),

                      //new
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: CustomColors.primary,
                              shape: StadiumBorder()),
                          onPressed: () {
                            processUpdate();
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
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 2,
                                backgroundColor: CustomColors.primary,
                                shape: StadiumBorder()),
                            onPressed: () {
                              simpleLoading(context,
                                  (BuildContext contextLoading) {
                                WebService(context)
                                    .getHasPassword(provider.user.token ?? "")
                                    .then((value) {
                                  Navigator.pop(contextLoading);
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: setChangePassword(value),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)));
                                }).catchError((e) {
                                  Navigator.pop(contextLoading);
                                  showErrorsDialog(context, e);
                                });
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock,
                                      color: Colors.white, size: 15),
                                  Flexible(
                                    child: Text(
                                        "Establecer o cambiar contraseña",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0),
                                        textAlign: TextAlign.center),
                                  ),
                                ],
                              ),
                            ),
                          ))
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
        theme: LegacyDatePickerTheme(),
        showTitleActions: true,
        maxTime: DateTime.now(),
        minTime: DateTime(1940),
        onChanged: (date) {}, onConfirm: (date) {
      setState(() {
        callback(date);
      });
    },
        currentTime: DateTime.now().subtract(Duration(days: 7300)),
        locale: LocaleType.es);
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

  processUpdate() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);
        try {
          dynamic assets = null;
          if (imageSelected != null)
            assets = await WebService(context)
                .uploadAsset("image", imageSelected, provider.user.token ?? "");

          UserModel userUpdated = await WebService(context).updateUser(
              provider.user.id ?? "",
              cEmail.text,
              cName.text,
              (assets != null && assets is AssetModel) ? assets.id ?? "" : "",
              "", // (birdate as DateTime).toUtc().millisecondsSinceEpoch.toString(),
              "",
              cTel.text,
              codeTel,
              "",
              "",
              "",
              "",
              cYears.text,
              cBloodType.text,
              cAllergies.text,
              cDiseases.text,
              cOrganDonor.text,
              cHasCovid.text,
              cCountVaccines.text,
              cHeight.text,
              cWeight.text,
              imc.toString(),
              provider.user.token ?? "",
              rfc: cRfc.text,
              fiscal_address: cFiscalAddress.text,
              request_invoice: requestInvoice ? "yes" : "no");

          await provider.setUser(userUpdated);
          setState(() {
            imageSelected = null;
          });
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
