import 'dart:typed_data';

import 'package:app/components/bottom_sheet_pictures.dart';
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
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:snack/snack.dart';
import 'package:universal_io/io.dart';

class DoctorEditProfile extends StatefulWidget {
  const DoctorEditProfile({Key? key}) : super(key: key);

  @override
  _DoctorEditProfileState createState() => _DoctorEditProfileState();
}

class _DoctorEditProfileState extends State<DoctorEditProfile> {
  final cEmail = TextEditingController();
  final cName = TextEditingController();
  final cTel = TextEditingController();
  final cBirdate = TextEditingController();
  final cProfessionalLicense = TextEditingController();

  final formKey = new GlobalKey<FormState>();

  dynamic imageSelected = null;
  dynamic imageFront = null;
  dynamic imageBack = null;
  dynamic birdate = null;
  String codeTel = "";
  final cYears = TextEditingController();
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

    cProfessionalLicense.text = provider.user.professional_license ?? "";
    codeTel = provider.user.dial_code ?? "";
    cYears.text = (provider.user.years != null && provider.user.years != "")
        ? provider.user.years ?? ""
        : "";
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
        labelText: 'Nombre',
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

    String localeCode = "mx";
    if (!kIsWeb) localeCode = Platform.localeName.split("_")[1];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: checkNoCompletedProfileDoctor(provider.user, context,
                          show: false)
                      ? Container(
                          color: (provider.user.verified_doctor == "yes")
                              ? Colors.green
                              : Colors.orange,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: (provider.user.verified_doctor == "yes")
                                ? Text(
                                    "Tu perfil como médico ha sido aprobado.",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15))
                                : Text(
                                    "Tu perfil como médico se encuentra en revisión.",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15)),
                          ),
                        )
                      : Container(
                          color: Colors.amber,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "Tu perfil como médico aún no ha sido aprobado. Completa tu perfil para pasar a revisión.",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
                          ),
                        ),
                )
              ],
            ),
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
                                              "assets/images/avatar.png",
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
                                showTakePicture("");
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
                                    child: FaIcon(FontAwesomeIcons.camera,
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

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: yearsField,
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
                            Flexible(flex: 5, child: telField)
                          ]),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: professionalLicenseField,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Fotógrafas de tu identificación oficial",
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      ResponsiveGridRow(children: [
                        ResponsiveGridCol(
                            lg: 6,
                            xs: 12,
                            md: 12,
                            child:

                                /// front
                                Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                    height: 160,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Visibility(
                                            visible: imageFront == null,
                                            child: Container(
                                              height: 160,
                                              decoration: new BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        Radius.circular(10.0)),
                                              ),
                                              child: (user.doc_id_front != null)
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: FadeInImage
                                                          .assetNetwork(
                                                        placeholder:
                                                            "assets/images/loading-image1.gif",
                                                        image: getImageUrl(
                                                            user.doc_id_front!),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    )
                                                  : Container(
                                                      decoration: new BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .all(
                                                                  Radius.circular(
                                                                      45.0))),
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Text("Adverso",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700,
                                                                  fontSize:
                                                                      20)),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                            child: (imageFront != null)
                                                ? Container(
                                                    height: 160,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          new BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                      image: (imageFront
                                                              is Uint8List)
                                                          ? DecorationImage(
                                                              image: MemoryImage(
                                                                  imageFront),
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : DecorationImage(
                                                              fit: BoxFit
                                                                  .contain,
                                                              image: FileImage(
                                                                  imageFront)),
                                                    ),
                                                  )
                                                : Container()),
                                        Positioned.fill(
                                            child: InkWell(
                                          onTap: () {
                                            showTakePicture("front");
                                          },
                                          child: Container(
                                            width: 160,
                                            height: 160,
                                            decoration: new BoxDecoration(
                                                color: (imageFront != null)
                                                    ? Colors.transparent
                                                    : Colors.black
                                                        .withAlpha(80),
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        Radius.circular(10.0))),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    ((user.doc_id_front !=
                                                            null))
                                                        ? InkWell(
                                                            onTap: () {
                                                              BottomSheetPictures(
                                                                  context, 0, [
                                                                user.doc_id_front
                                                              ]).showBottomSheetPictures();
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: FaIcon(FontAwesomeIcons.expandArrowsAlt,
                                                                color: Colors
                                                                    .white,
                                                                size: 25,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: FaIcon(FontAwesomeIcons.camera,
                                                        color: Colors.white,
                                                        size: 25,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        ResponsiveGridCol(
                            lg: 6,
                            xs: 12,
                            md: 12,
                            child:

                                /// back
                                Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                    height: 160,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Visibility(
                                            visible: imageBack == null,
                                            child: Container(
                                              height: 160,
                                              width: 160,
                                              decoration: new BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        Radius.circular(10.0)),
                                              ),
                                              child: (user.doc_id_back != null)
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      child: FadeInImage
                                                          .assetNetwork(
                                                        placeholder:
                                                            "assets/images/loading-image1.gif",
                                                        image: getImageUrl(
                                                            user.doc_id_back!),
                                                        fit: BoxFit.contain,
                                                      ),
                                                    )
                                                  : Container(
                                                      decoration: new BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .all(
                                                                  Radius.circular(
                                                                      45.0))),
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Text("Reverso",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade700,
                                                                  fontSize:
                                                                      20)),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                            child: (imageBack != null)
                                                ? Container(
                                                    height: 160,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          new BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                      image: (imageBack
                                                              is Uint8List)
                                                          ? DecorationImage(
                                                              image: MemoryImage(
                                                                  imageBack),
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : DecorationImage(
                                                              fit: BoxFit
                                                                  .contain,
                                                              image: FileImage(
                                                                  imageBack)),
                                                    ),
                                                  )
                                                : Container()),
                                        Positioned.fill(
                                            child: InkWell(
                                          onTap: () {
                                            showTakePicture("back");
                                          },
                                          child: Container(
                                            height: 160,
                                            decoration: new BoxDecoration(
                                                color: (imageBack != null)
                                                    ? Colors.transparent
                                                    : Colors.black
                                                        .withAlpha(80),
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        Radius.circular(10.0))),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    ((user.doc_id_back != null))
                                                        ? InkWell(
                                                            onTap: () {
                                                              BottomSheetPictures(
                                                                  context, 0, [
                                                                user.doc_id_back
                                                              ]).showBottomSheetPictures();
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: FaIcon(FontAwesomeIcons.expandArrowsAlt,
                                                                color: Colors
                                                                    .white,
                                                                size: 25,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: FaIcon(FontAwesomeIcons.camera,
                                                        color: Colors.white,
                                                        size: 25,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
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

  showTakePicture(String type) async {
    if (kIsWeb) {
      selectPictureWeb(context, (dynamic imageFile) {
        setState(() {
          if (type == "front") {
            this.imageFront = imageFile;
          } else if (type == "back") {
            this.imageBack = imageFile;
          } else {
            this.imageSelected = imageFile;
          }
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
                callbackShowTakePicture(contextDialogd, image, type);
              },
              useBtnCancel: true,
            );
          });
    }
  }

  Future callbackShowTakePicture(contextDialog, image, String type) async {
    if (image == null) return;
    try {
      final XFile? imageFile = await ImagePicker().pickImage(
          source:
              (image == "camera") ? ImageSource.camera : ImageSource.gallery);
      if (imageFile != null) {
        File file = await File(imageFile.path);
        setState(() {
          if (type == "front") {
            this.imageFront = file;
          } else if (type == "back") {
            this.imageBack = file;
          } else {
            this.imageSelected = file;
          }
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

          dynamic assetsFront = null;
          if (imageFront != null)
            assetsFront = await WebService(context)
                .uploadAsset("image", imageFront, provider.user.token ?? "");

          dynamic assetsBack = null;
          if (imageBack != null)
            assetsBack = await WebService(context)
                .uploadAsset("image", imageBack, provider.user.token ?? "");

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
              cProfessionalLicense.text,
              (assetsFront != null && assetsFront is AssetModel)
                  ? assetsFront.id ?? ""
                  : "",
              (assetsBack != null && assetsBack is AssetModel)
                  ? assetsBack.id ?? ""
                  : "",
              cYears.text,
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              provider.user.token ?? "");

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
