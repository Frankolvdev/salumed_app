import 'dart:async';
import 'dart:typed_data';

import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/components/fade_animation.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/components/studies_selection.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/advert.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/category.dart';
import 'package:app/models/notification.dart';
import 'package:app/models/prescription.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/admin/admin_add_user.dart';
import 'package:app/pages/admin/admin_edit_user.dart';
import 'package:app/pages/chat.dart';
import 'package:app/pages/doctor/doctor_add_prescription.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:universal_io/io.dart';
import 'package:snack/snack.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class DoctorViewPrescription extends StatefulWidget {
  PrescriptionModel prescription;
  Function callBackBack;
  DoctorViewPrescription(this.callBackBack, this.prescription, {Key? key})
      : super(key: key);

  @override
  _DoctorViewPrescriptionState createState() => _DoctorViewPrescriptionState();
}

class _DoctorViewPrescriptionState extends State<DoctorViewPrescription> {
  final cDiagnosis = TextEditingController();
  final cEvolution = TextEditingController();
  final cPrescription = TextEditingController();
  final cPatient = TextEditingController();
  final cOthersLabSts = TextEditingController();
  final formKey = new GlobalKey<FormState>();

  dynamic imageSelected = null;

  late String rolSelected;

  dynamic imageSelectedSt = null;

  bool showLabSt = false;
  StudiesSelectionController studiesSelectionController =
      new StudiesSelectionController();
  @override
  void initState() {
    super.initState();
    PrescriptionModel prescription = widget.prescription;
    cDiagnosis.text = prescription.diagnosis ?? "";
    cEvolution.text = prescription.evolution ?? "";
    cPrescription.text = prescription.prescription_text ?? "";
    cPatient.text = prescription.patient!.name ?? "";
    imageSelected = prescription.prescription_picture;

    cOthersLabSts.text = prescription.other_studies ?? "";

    if (prescription.medical_studies != null &&
        prescription.medical_studies is List) {
      studiesSelectionController.labSts =
          prescription.medical_studies!.map((e) => e.toString()).toList();
    }

    if (prescription.picture_studies != null &&
        prescription.picture_studies is AssetModel) {
      imageSelectedSt = prescription.picture_studies;
    }

    if ((prescription.picture_studies != null &&
            prescription.picture_studies is AssetModel) ||
        (prescription.medical_studies != null &&
            prescription.medical_studies is List &&
            prescription.medical_studies!.length > 0) ||
        (prescription.other_studies != "" &&
            prescription.other_studies != null)) {
      showLabSt = true;
    }
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

    final diagnosisField = TextFormField(
      readOnly: true,
      autofocus: false,
      autocorrect: false,
      controller: cDiagnosis,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Diagnóstico ',
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

    final evolutionField = TextFormField(
      readOnly: true,
      autofocus: false,
      autocorrect: false,
      controller: cEvolution,
      keyboardType: TextInputType.multiline,
      maxLines: null,

      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Evolución de los síntomas',
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

    final prescriptionField = TextFormField(
      readOnly: true,
      autofocus: false,
      autocorrect: false,
      controller: cPrescription,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Receta o prescripción',
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
    final otherslabStField = TextFormField(
      autofocus: false,
      autocorrect: false,
      readOnly: true,
      controller: cOthersLabSts,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Otros estudios',
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
    final patientField = TextFormField(
      autofocus: false,
      autocorrect: false,
      readOnly: true,
      controller: cPatient,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      onTap: () {},
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Paciente',
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
                        child: FaIcon(FontAwesomeIcons.arrowLeft,
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
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                                "Folio: " +
                                    widget.prescription.id!.substring(0, 8),
                                style: TextStyle(
                                    color: CustomColors.primary, fontSize: 15)),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: patientField,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: diagnosisField,
                      ),
                      (cEvolution.text != "")
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: evolutionField,
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: prescriptionField,
                      ),
                      (imageSelected != null)
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                    "Fotografía de la receta (complementaria)",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 15)),
                              ),
                            )
                          : Container(),
                      ResponsiveGridRow(children: [
                        ResponsiveGridCol(
                            lg: 12,
                            xs: 12,
                            md: 12,
                            child:

                                /// front
                                Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  (imageSelected != null)
                                      ? Container(
                                          height: 160,
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: Visibility(
                                                  visible:
                                                      imageSelected == null,
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
                                                    child: Container(
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
                                                          child: Text(
                                                              "Foto de receta",
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
                                                  child: Positioned.fill(
                                                child: Container(
                                                  height: 160,
                                                  width: 160,
                                                  decoration: new BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        new BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                  ),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder:
                                                        "assets/images/loading-image1.gif",
                                                    image: getImageUrl(
                                                        imageSelected!),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              )),
                                              Positioned.fill(
                                                  child: InkWell(
                                                onTap: () {
                                                  BottomSheetPictures(
                                                      context, 0, [
                                                    imageSelected
                                                  ]).showBottomSheetPictures();
                                                },
                                                child: Container(
                                                  width: 160,
                                                  height: 160,
                                                  decoration: new BoxDecoration(
                                                      color: (imageSelected !=
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
                                                          ((imageSelected !=
                                                                  null))
                                                              ? InkWell(
                                                                  onTap: () {
                                                                    BottomSheetPictures(
                                                                        context,
                                                                        0, [
                                                                      imageSelected
                                                                    ]).showBottomSheetPictures();
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: FaIcon(FontAwesomeIcons.expandArrowsAlt,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 25,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ))
                                            ],
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            )),
                      ]),

                      //------------------------------- laboratory studies
                      SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            showLabSt = !showLabSt;
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Estudios de laboratorio",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 18)),
                            Icon(
                              (!showLabSt)
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              size: 30,
                              color: CustomColors.primary,
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        color: Colors.grey,
                      ),

                      (showLabSt)
                          ? Column(
                              children: [
                                StudiesSelection(
                                    controller: studiesSelectionController,
                                    preventSelect: true),
                                (widget.prescription!.other_studies != "")
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: otherslabStField,
                                      )
                                    : Container(),
                                ResponsiveGridRow(children: [
                                  ResponsiveGridCol(
                                      lg: 12,
                                      xs: 12,
                                      md: 12,
                                      child:

                                          /// front
                                          Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            (imageSelectedSt != null)
                                                ? Container(
                                                    height: 160,
                                                    child: Stack(
                                                      children: [
                                                        Positioned.fill(
                                                          child: Container(
                                                            height: 160,
                                                            width: 160,
                                                            decoration:
                                                                new BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              borderRadius:
                                                                  new BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          10.0)),
                                                            ),
                                                            child: FadeInImage
                                                                .assetNetwork(
                                                              placeholder:
                                                                  "assets/images/loading-image1.gif",
                                                              image: getImageUrl(
                                                                  imageSelectedSt!),
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                        ),
                                                        Positioned.fill(
                                                            child: InkWell(
                                                          onTap: () {
                                                            BottomSheetPictures(
                                                                context, 0, [
                                                              imageSelectedSt
                                                            ]).showBottomSheetPictures();
                                                          },
                                                          child: Container(
                                                            width: 160,
                                                            height: 160,
                                                            decoration: new BoxDecoration(
                                                                color: (imageSelectedSt !=
                                                                        null)
                                                                    ? Colors
                                                                        .transparent
                                                                    : Colors
                                                                        .black
                                                                        .withAlpha(
                                                                            80),
                                                                borderRadius:
                                                                    new BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10.0))),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .bottomRight,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    ((imageSelectedSt !=
                                                                            null))
                                                                        ? InkWell(
                                                                            onTap:
                                                                                () {
                                                                              BottomSheetPictures(context, 0, [
                                                                                imageSelectedSt
                                                                              ]).showBottomSheetPictures();
                                                                            },
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: FaIcon(FontAwesomeIcons.expandArrowsAlt,
                                                                                color: Colors.grey,
                                                                                size: 25,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ))
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      )),
                                ]),
                              ],
                            )
                          : Container(),

                      //------------------------------- end laboratory studies
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

  final formKeySearchPatient = new GlobalKey<FormState>();
  final cSearch = TextEditingController();
  late StateSetter _setStatePatient;

  dynamic patientSelected = null;
  searchPatientDialog() {
    Widget searchField = TextField(
      autofocus: true,
      controller: cSearch,
      style: TextStyle(color: Colors.black),
      textInputAction: TextInputAction.search,
      //maxLength: 1,
      textAlign: TextAlign.left,

      //focusNode: myFocusNode1,
      decoration: InputDecoration(
          counterText: '',
          hintText: "Correo electrónico o nombre completo",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: InkWell(
            onTap: () {
              cSearch.text = "";
              //_refreshIndicatorKey.currentState!.show();
              searchPatient();
            },
            child: Icon(
              Icons.cancel,
              size: 20,
              color: CustomColors.primary,
            ),
          ),
          suffixIcon: InkWell(
            splashColor: CustomColors.primary,
            onTap: () {
              // _refreshIndicatorKey.currentState!.show();
              searchPatient();
            },
            child: Icon(
              Icons.search,
              size: 20,
              color: CustomColors.primary,
            ),
          ),
          //contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          contentPadding: const EdgeInsets.fromLTRB(45, 0, 0, 0),
          //contentPadding: EdgeInsets.zero,
          filled: true,
          isDense: true,
          fillColor: Colors.grey[300],
          focusColor: Colors.grey[200],
          hoverColor: Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Colors.transparent, width: 0.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Colors.transparent, width: 0.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          border: InputBorder.none),
      onChanged: (valueSearch) {},
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(FocusNode());
        // _refreshIndicatorKey.currentState!.show();
        searchPatient();
      },
    );

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return StatefulBuilder(builder: (context, setStateT) {
            _setStatePatient = setStateT;
            return WillPopScope(
                child: Dialog(
                  insetPadding: getDialogInsetPaddin(context),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                            top: 16, bottom: 16, left: 16, right: 16),
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
                        child: Form(
                            key: formKeySearchPatient,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  height: 16.0,
                                ),
                                searchField,
                                (messageFound != "")
                                    ? Center(
                                        child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Text(messageFound),
                                      ))
                                    : Container(),
                                Column(
                                    children: patientsFind.map((patient) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            patientSelected = patient;
                                            cPatient.text =
                                                patient.name ?? "Sin nombre";
                                          });

                                          setStateT(() {});
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 8),
                                          child: Column(children: [
                                            Text(patient.name ?? "",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 100),
                                            Divider(
                                              height: 2,
                                              color: CustomColors.primary,
                                            )
                                          ]),
                                        ),
                                      )
                                    ],
                                  );
                                }).toList()),
                                Container(
                                  height: 50,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: MaterialButton(
                                            onPressed: () {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                            },
                                            child: Text("Cancelar")),
                                      ),
                                      Expanded(
                                        child: MaterialButton(
                                            onPressed: () {
                                              searchPatient();
                                            },
                                            child: Text("Buscar")),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )),
                      )
                    ],
                  ),
                ),
                onWillPop: () async {
                  return true;
                });
          });
        });
  }

  List<UserModel> patientsFind = [];
  String messageFound = "";
  searchPatient() {
    if (cSearch.text.trim() == "") {
      setState(() {
        patientsFind = [];
        messageFound = "";
      });

      try {
        _setStatePatient(() {});
      } catch (e) {}
      return;
    }
    simpleLoading(context, (BuildContext contextDialog) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      return WebService(context)
          .getUsers(0, 0, context, provider.user.token ?? "",
              search: cSearch.text, filter_rol: "")
          .then((value) {
        if (value.length <= 0) {
          messageFound = "No fue encontrado ningún paciente";
        } else {
          messageFound = "";
        }

        setState(() {
          patientsFind = value;
        });

        try {
          _setStatePatient(() {});
        } catch (e) {}
        Navigator.pop(contextDialog);
      }).catchError((e) {
        Navigator.pop(contextDialog);
        showErrorsDialog(context, e);
      });
    });
  }
}

