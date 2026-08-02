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
import 'package:back_button_interceptor/back_button_interceptor.dart';

class AdminEditUser extends StatefulWidget {
  Function callBackBack;
  UserModel user;
  AdminEditUser(this.callBackBack, this.user, {Key? key}) : super(key: key);

  @override
  _AdminEditUserState createState() => _AdminEditUserState();
}

class _AdminEditUserState extends State<AdminEditUser> {
  final cEmail = TextEditingController();
  final cName = TextEditingController();
  final cDeliveryCommission = TextEditingController();
  final cProfessionalLicense = TextEditingController();

  final cTel = TextEditingController();
  final cBirdate = TextEditingController();
  final cPass = TextEditingController();
  final cPassRepeat = TextEditingController();

  final cRfc = TextEditingController();
  final cFiscalAddress = TextEditingController();

  final cYears = TextEditingController();

  bool passwordVisible = true;
  bool passwordVisibleRepeat = true;

  final formKey = new GlobalKey<FormState>();

  dynamic imageSelected = null;
  dynamic birdate = null;
  String verifiedDoctor = "no";
  String enabled = "yes";
  String codeTel = "";

  List<Map<String, dynamic>> roles = [
    {"name": "Administrador", "val": "admin"},
    {"name": "Super administrador", "val": "super_admin"},
    {"name": "Administrador de farmacia", "val": "pharmacy_admin"},
    {"name": "Administrador de laboratorio", "val": "laboratory_admin"},
    {"name": "Paciente", "val": "client"},
    {"name": "Repartidor", "val": "delivery"},
    {"name": "Doctor", "val": "doctor"},
    {"name": "Hospital/Clínica", "val": "hospital_admin"}
  ];

  dynamic imageFront = null;
  dynamic imageBack = null;

  late String rolSelected;

  bool isHospital = false;

  bool requestInvoice = false;

  @override
  void initState() {
    super.initState();
    UserModel user = widget.user;
    rolSelected = user.roles[0].name ?? roles[0]["val"];
    enabled = user.enabled ?? "no";
    verifiedDoctor = user.verified_doctor ?? "no";

    cEmail.text = user.email ?? "";
    cName.text = user.name ?? "";
    cDeliveryCommission.text = (user.delivery_commission).toString();
    cProfessionalLicense.text = user.professional_license ?? "";
    cTel.text = user.phone ?? "";
    codeTel = user.dial_code ?? "";
    cBirdate.text = (user.birthdate != null && user.birthdate != "")
        ? getDateFromStringFormat(
            DateTime.parse(user.birthdate ?? "").toLocal().toString())
        : "";
    birdate = (user.birthdate != null && user.birthdate != "")
        ? DateTime.parse(user.birthdate ?? "").toUtc()
        : null;

    cYears.text =
        (user.years != null && user.years != "") ? user.years ?? "" : "";

    isHospital = (rolSelected == "hospital_admin") ? true : false;

    cRfc.text = user.rfc ?? "";
    cFiscalAddress.text = user.fiscal_address ?? "";
    requestInvoice = user.request_invoice == "yes" ? true : false;
    BackButtonInterceptor.add(myInterceptor);
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
    UserModel user = widget.user;

    final passwordField = TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('[ ]')),
      ],
      textInputAction: TextInputAction.next,
      validator: (val) {
        return null;
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
          labelText: "Nueva contraseña",
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
        return null;
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
          labelText: "Confirmar nueva contraseña",
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
        labelText: (!isHospital) ? 'Nombre' : "Nombre o razón social",
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
                    children: [
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
                                  child: (widget.user.picture != null)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                "assets/images/loading-image1.gif",
                                            image: getImageUrl(
                                                widget.user.picture!),
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
                      (user.roles[0].name == "doctor")
                          ? ResponsiveGridRow(children: [
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
                                                    decoration:
                                                        new BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          new BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                    ),
                                                    child:
                                                        (user.doc_id_front !=
                                                                null)
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                child: FadeInImage
                                                                    .assetNetwork(
                                                                  placeholder:
                                                                      "assets/images/loading-image1.gif",
                                                                  image: getImageUrl(
                                                                      user.doc_id_front!),
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              )
                                                            : Container(
                                                                decoration: new BoxDecoration(
                                                                    color: Colors
                                                                        .transparent,
                                                                    borderRadius: new BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            45.0))),
                                                                child: Center(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .all(
                                                                        10.0),
                                                                    child: Text(
                                                                        "Adverso",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey.shade700,
                                                                            fontSize: 20)),
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
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .all(
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
                                                  showTakePictureId("front");
                                                },
                                                child: Container(
                                                  width: 160,
                                                  height: 160,
                                                  decoration: new BoxDecoration(
                                                      color: (imageFront !=
                                                              null)
                                                          ? Colors.transparent
                                                          : Colors.black
                                                              .withAlpha(80),
                                                      borderRadius:
                                                          new BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0))),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
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
                                                                        context,
                                                                        0, [
                                                                      user.doc_id_front
                                                                    ]).showBottomSheetPictures();
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                      FontAwesomeIcons
                                                                          .expandArrowsAlt,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 25,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Icon(
                                                              FontAwesomeIcons
                                                                  .camera,
                                                              color:
                                                                  Colors.white,
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
                                                    decoration:
                                                        new BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          new BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                    ),
                                                    child:
                                                        (user.doc_id_back !=
                                                                null)
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                child: FadeInImage
                                                                    .assetNetwork(
                                                                  placeholder:
                                                                      "assets/images/loading-image1.gif",
                                                                  image: getImageUrl(
                                                                      user.doc_id_back!),
                                                                  fit: BoxFit
                                                                      .contain,
                                                                ),
                                                              )
                                                            : Container(
                                                                decoration: new BoxDecoration(
                                                                    color: Colors
                                                                        .transparent,
                                                                    borderRadius: new BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            45.0))),
                                                                child: Center(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .all(
                                                                        10.0),
                                                                    child: Text(
                                                                        "Reverso",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey.shade700,
                                                                            fontSize: 20)),
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
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                new BorderRadius
                                                                        .all(
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
                                                  showTakePictureId("back");
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
                                                              Radius.circular(
                                                                  10.0))),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          ((user.doc_id_back !=
                                                                  null))
                                                              ? InkWell(
                                                                  onTap: () {
                                                                    BottomSheetPictures(
                                                                        context,
                                                                        0, [
                                                                      user.doc_id_back
                                                                    ]).showBottomSheetPictures();
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Icon(
                                                                      FontAwesomeIcons
                                                                          .expandArrowsAlt,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 25,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Icon(
                                                              FontAwesomeIcons
                                                                  .camera,
                                                              color:
                                                                  Colors.white,
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
                            ])
                          : Container(),

                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: nameField,
                      ),

                      (!isHospital)
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: yearsField,
                            )
                          : Container(),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: emailField,
                      ),

                      (isHospital)
                          ? Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: rfcField,
                                ),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
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
                                            MaterialStateProperty.resolveWith(
                                                getColor),
                                        value: requestInvoice,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            requestInvoice = !requestInvoice;
                                          });
                                        },
                                      )),
                                ),
                              ],
                            )
                          : Container(),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: Colors.grey,
                          ),
                          iconSize: 42,
                          items: roles.map((dynamic rol) {
                            return new DropdownMenuItem(
                                value: rol["val"],
                                child: Text(rol["name"],
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1));
                          }).toList(),
                          onChanged: (rol) {
                            setState(() {
                              rolSelected = rol as String;
                              isHospital = (rolSelected == "hospital_admin")
                                  ? true
                                  : false;
                            });

                            // do other stuff with _category
                          },
                          value: rolSelected,
                          decoration: InputDecoration(
                            labelText: 'Tipo de usuario',
                            labelStyle: TextStyle(color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: CustomColors.primary),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      (rolSelected == "delivery")
                          ? Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: deliveryCommissionField,
                                )
                              ],
                            )
                          : Container(),
                      (rolSelected == "doctor")
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: professionalLicenseField,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text("Médico verificado",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15)),
                                ),
                                Column(
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          verifiedDoctor = "yes";
                                        });
                                      },
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(0),
                                        title: const Text('Sí'),
                                        leading: Radio<String>(
                                          value: "yes",
                                          groupValue: verifiedDoctor,
                                          onChanged: (String? value) {
                                            setState(() {
                                              verifiedDoctor = value ?? "yes";
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          verifiedDoctor = "no";
                                        });
                                      },
                                      child: ListTile(
                                        contentPadding: EdgeInsets.all(0),
                                        title: const Text('No'),
                                        leading: Radio<String>(
                                          value: "no",
                                          groupValue: verifiedDoctor,
                                          onChanged: (String? value) {
                                            setState(() {
                                              verifiedDoctor = value ?? "no";
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          : Container(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Estatus del usuario",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15)),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                enabled = "yes";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Activo'),
                              leading: Radio<String>(
                                value: "yes",
                                groupValue: enabled,
                                onChanged: (String? value) {
                                  setState(() {
                                    enabled = value ?? "yes";
                                  });
                                },
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                enabled = "no";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Inactivo'),
                              leading: Radio<String>(
                                value: "no",
                                groupValue: enabled,
                                onChanged: (String? value) {
                                  setState(() {
                                    enabled = value ?? "no";
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
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
                                      WidgetsBinding.instance!
                                          .addPostFrameCallback((_) {
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

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Cambiar contraseña",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: passwordField,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: repeatPasswordField,
                      ),

                      //new
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: CustomColors.primary,
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
                      //new
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: CustomColors.primary,
                              shape: StadiumBorder()),
                          onPressed: () {
                            processGenerateLinkResetPassword();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 35.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Generar enlace para restablecer contraseña",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SelectableText(linkResetPassword,
                            style: TextStyle(
                                color: CustomColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                      )
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
        minTime: DateTime(1940),
        maxTime: DateTime.now(),
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

  showTakePictureId(String type) async {
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
                callbackShowTakePictureId(contextDialogd, image, type);
              },
              useBtnCancel: true,
            );
          });
    }
  }

  Future callbackShowTakePictureId(contextDialog, image, String type) async {
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

  String linkResetPassword = "";

  processGenerateLinkResetPassword() {
    simpleLoading(context, (BuildContext loadingContext) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      try {
        String link = await WebService(context).getLinkResetPassword(
            widget.user.email ?? "", provider.user.token ?? "");

        Navigator.pop(loadingContext);
        SnackBar(
                content: Text("Se ha generado con éxito",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                elevation: 100,
                duration: Duration(seconds: 2),
                backgroundColor: CustomColors.primary)
            .show(context);
        setState(() {
          linkResetPassword = link;
        });
      } catch (e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e as dynamic);
      }
    });
  }

  processEdit() async {
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

          await WebService(context).updateUserAdmin(
              widget.user.id ?? "",
              cEmail.text,
              cName.text,
              (assets != null && assets is AssetModel) ? assets.id ?? "" : "",
              "", // (birdate as DateTime).toUtc().millisecondsSinceEpoch.toString(),
              cTel.text,
              codeTel,
              rolSelected,
              cPass.text,
              cPassRepeat.text,
              enabled,
              verifiedDoctor,
              cDeliveryCommission.text,
              cProfessionalLicense.text,
              (assetsFront != null && assetsFront is AssetModel)
                  ? assetsFront.id ?? ""
                  : "",
              (assetsBack != null && assetsBack is AssetModel)
                  ? assetsBack.id ?? ""
                  : "",
              cYears.text,
              provider.user.token ?? "",
              rfc: cRfc.text,
              fiscal_address: cFiscalAddress.text,
              request_invoice: requestInvoice ? "yes" : "no");

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
          widget.callBackBack();
        } catch (e) {
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
    }
  }
}
