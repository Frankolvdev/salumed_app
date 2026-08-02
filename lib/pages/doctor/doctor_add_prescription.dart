import 'dart:async';
import 'dart:typed_data';

import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/components/fade_animation.dart';
import 'package:app/components/fixed_pharmacies.dart';
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
import 'package:app/pages/doctor/doctor_client_archivist.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:universal_io/io.dart';
import 'package:snack/snack.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';

import '../../components/search_select_medicines.dart';

class DoctorAddPrescription extends StatefulWidget {
  Function callBackBack;
  DoctorAddPrescription(this.callBackBack, {Key? key}) : super(key: key);

  @override
  _DoctorAddPrescriptionState createState() => _DoctorAddPrescriptionState();
}

class _DoctorAddPrescriptionState extends State<DoctorAddPrescription> {
  final cEmail = TextEditingController();
  final cDiagnosis = TextEditingController();
  final cYears = TextEditingController();

  final cBloodType = TextEditingController();
  final cOrganDonor = TextEditingController();
  final cDiseases = TextEditingController();
  final cAllergies = TextEditingController();

  final cEvolution = TextEditingController();
  final cPrescription = TextEditingController();
  final cPatient = TextEditingController();

  final cHasCovid = TextEditingController();
  final cCountVaccines = TextEditingController();
  final cHeight = TextEditingController();
  final cWeight = TextEditingController();

  final cOthersLabSts = TextEditingController();

  final formKey = new GlobalKey<FormState>();
  dynamic imageSelected = null;
  dynamic imageSelectedSt = null;
  dynamic birdate = null;
  String verifiedDoctor = "no";
  String enabled = "yes";
  String codeTel = "";
  num imc = 0;
  bool showLabSt = false;
  bool showPictureLabSt = false;
  List<Map<String, dynamic>> roles = [
    {"name": "Administrador", "val": "admin"},
    {"name": "Super administrador", "val": "super_admin"},
    {"name": "Administrador de farmacia", "val": "pharmacy_admin"},
    {"name": "Paciente", "val": "client"},
    {"name": "Repartidor", "val": "delivery"},
    {"name": "Doctor", "val": "doctor"}
  ];

  late String rolSelected;

  List<dynamic> medicinesToAdd = [];

  bool loading=false;
  @override
  void initState() {
    super.initState();
    rolSelected = roles[0]["val"];
    BackButtonInterceptor.add(myInterceptor);

    cHeight.addListener(calcImc);
    cWeight.addListener(calcImc);
  }

  StudiesSelectionController studiesSelectionController =
      new StudiesSelectionController();
  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    cHeight.dispose();
    cWeight.dispose();
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

    final yearsField = TextFormField(
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
        labelText: 'Edad ',
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

    final evolutionField = TextFormField(
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
      autofocus: false,
      autocorrect: false,
      controller: cPrescription,
      keyboardType: TextInputType.multiline,
      maxLines: null,

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
      onTap: () {
        searchPatientDialog();
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Paciente',
        suffixIcon: Icon(
          Icons.keyboard_arrow_down_outlined,
        ),
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
        labelText: 'Cuantas vacunas contra COVID-19 tiene puestas',
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
        labelText: 'Ha tenido COVID-19',
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: patientField,
                      ),

                      (patientSelected != null)
                          ? Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: CustomColors.primary)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    "IMC",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: CustomColors
                                                            .secondary),
                                                  ),
                                                  (!(imc != null && imc > 0))
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            "Ingresa el peso y altura del paciente para calcular su indice de masa corporal",
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                        )
                                                      : Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                imc.toStringAsFixed(
                                                                    2),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: CustomColors
                                                                        .primary,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                getImcDesc(imc),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    color: CustomColors
                                                                        .secondary,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: weightField,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: heightField,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: yearsField,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: bloodTypeField,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: allergiesField,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: diseasesField,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: organDonorField,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: hasCovidField,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: countVaccinesField,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        elevation: 2,
                                        backgroundColor: CustomColors.primary,
                                        shape: StadiumBorder()),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              child: DoctorClientArchivist(
                                                  patientSelected),
                                              type:
                                                  PageTransitionType.slideInUp,
                                              duration:
                                                  Duration(milliseconds: 250)));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 35.0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Ver archivos del paciente",
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
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: diagnosisField,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: evolutionField,
                      ),
                   /*   Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: EdgeInsetsDirectional.all(8.0),
                                    elevation: 2,
                                    backgroundColor: CustomColors.primary2,
                                    shape: StadiumBorder()),
                                onPressed: () {
                                  showSearchSelectMedicines();
                                },
                                child: Text("Buscar medicamento")),
                          )
                        ],
                      ),*/
                      (showDirectPharmacy)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding:
                                              EdgeInsetsDirectional.all(8.0),
                                          elevation: 2,
                                          backgroundColor: CustomColors.primary2,
                                          shape: StadiumBorder()),
                                      onPressed: () {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (contextDialog) {
                                              return fixedPharmacies(
                                                () {
                                                  Navigator.pop(contextDialog);
                                                },
                                              );
                                            });
                                      },
                                      child: Text("Farmacias")),
                                )
                              ],
                            )
                          : Container(),
                      Column(
                        children: medicinesToAdd.map((e) {
                          return Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: () {
                                        removeMedicine(e);
                                      },
                                      child: Container(
                                        decoration: new BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(FontAwesomeIcons.times,
                                            color: Colors.red),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(e["SUSTANCIA"] +
                                          " - " +
                                          e["Descripción"]),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      child: TextFormField(
                                        autofocus: false,
                                        autocorrect: false,
                                        controller: e["cant"],
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.digitsOnly
                                        ],

                                        obscureText: false,
                                        style: TextStyle(fontSize: 18.0),
                                        //initialValue: Environment.localUsername(),
                                        decoration: InputDecoration(
                                          labelText: 'Cant',
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                child: TextFormField(
                                  autofocus: false,
                                  autocorrect: false,
                                  controller: e["prescription"],
                                  keyboardType: TextInputType.text,

                                  obscureText: false,
                                  style: TextStyle(fontSize: 18.0),
                                  //initialValue: Environment.localUsername(),
                                  decoration: InputDecoration(
                                    labelText: 'Prescripción del medicamento',
                                  ),
                                ),
                              )
                            ],
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: prescriptionField,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                              "Fotografía de la receta (complementaria)",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15)),
                        ),
                      ),

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
                                  Container(
                                    height: 160,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Visibility(
                                            visible: imageSelected == null,
                                            child: Container(
                                              height: 160,
                                              decoration: new BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        Radius.circular(10.0)),
                                              ),
                                              child: Container(
                                                decoration: new BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        new BorderRadius.all(
                                                            Radius.circular(
                                                                45.0))),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Text(
                                                        "Foto de receta",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade700,
                                                            fontSize: 20)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                            child: (imageSelected != null)
                                                ? Container(
                                                    height: 160,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          new BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                      image: (imageSelected
                                                              is Uint8List)
                                                          ? DecorationImage(
                                                              image: MemoryImage(
                                                                  imageSelected),
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : DecorationImage(
                                                              fit: BoxFit
                                                                  .contain,
                                                              image: FileImage(
                                                                  imageSelected)),
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
                                                    ((imageSelected != null))
                                                        ? InkWell(
                                                            onTap: () {
                                                              BottomSheetPictures(
                                                                  context, 0, [
                                                                imageSelected
                                                              ]).showBottomSheetPictures();
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Icon(
                                                                FontAwesomeIcons
                                                                    .expandArrowsAlt,
                                                                color:
                                                                    Colors.grey,
                                                                size: 25,
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                        FontAwesomeIcons.camera,
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
                      Column(
                        children: [
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

                          ////
                          (showLabSt)
                              ? Column(
                                  children: [
                                    StudiesSelection(
                                        controller: studiesSelectionController,
                                        preventSelect: false),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(child: otherslabStField),
                                          InkWell(
                                            onTap: () {
                                              showTakePictureSt();
                                            },
                                            child: Icon(
                                              FontAwesomeIcons.camera,
                                              color: CustomColors.primary,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),

                                    /// picture studies

                                    (imageSelectedSt != null)
                                        ? ResponsiveGridRow(children: [
                                            ResponsiveGridCol(
                                                lg: 12,
                                                xs: 12,
                                                md: 12,
                                                child:

                                                    /// front
                                                    Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 160,
                                                        child: Stack(
                                                          children: [
                                                            Positioned.fill(
                                                              child: Visibility(
                                                                visible:
                                                                    imageSelectedSt ==
                                                                        null,
                                                                child:
                                                                    Container(
                                                                  height: 160,
                                                                  decoration:
                                                                      new BoxDecoration(
                                                                    color: Colors
                                                                        .transparent,
                                                                    borderRadius: new BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10.0)),
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    decoration: new BoxDecoration(
                                                                        color: Colors
                                                                            .transparent,
                                                                        borderRadius:
                                                                            new BorderRadius.all(Radius.circular(45.0))),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(10.0),
                                                                        child: Text(
                                                                            "Foto de estudios",
                                                                            style:
                                                                                TextStyle(color: Colors.grey.shade700, fontSize: 20)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned.fill(
                                                                child: (imageSelectedSt !=
                                                                        null)
                                                                    ? Container(
                                                                        height:
                                                                            160,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              new BorderRadius.all(Radius.circular(10.0)),
                                                                          image: (imageSelectedSt is Uint8List)
                                                                              ? DecorationImage(
                                                                                  image: MemoryImage(imageSelectedSt),
                                                                                  fit: BoxFit.contain,
                                                                                )
                                                                              : DecorationImage(fit: BoxFit.contain, image: FileImage(imageSelectedSt)),
                                                                        ),
                                                                      )
                                                                    : Container()),
                                                            Positioned.fill(
                                                                child: InkWell(
                                                              onTap: () {
                                                                showTakePictureSt();
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
                                                                    borderRadius: new BorderRadius
                                                                            .all(
                                                                        Radius.circular(
                                                                            10.0))),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .bottomRight,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        ((imageSelectedSt !=
                                                                                null))
                                                                            ? InkWell(
                                                                                onTap: () {
                                                                                  BottomSheetPictures(context, 0, [
                                                                                    imageSelectedSt
                                                                                  ]).showBottomSheetPictures();
                                                                                },
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: Icon(
                                                                                    FontAwesomeIcons.expandArrowsAlt,
                                                                                    color: Colors.grey,
                                                                                    size: 25,
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : Container(),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              Icon(
                                                                            FontAwesomeIcons.camera,
                                                                            color:
                                                                                Colors.white,
                                                                            size:
                                                                                25,
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

                                    /// end picture studies
                                  ],
                                )
                              : Container()

                          ///
                        ],
                      ),
                      SizedBox(
                        height: 20,
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
                          onPressed:loading?null: () {
                            processAdd();
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

                                (loading)?Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Container(  height: 24, width: 24, child: CircularProgressIndicator(color: CustomColors.primary,)),
                                ):Container()
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

  removeMedicine(dynamic medicine) {
    medicinesToAdd
        .removeWhere((element) => element["Clave"] == medicine["Clave"]);
    setState(() {});
  }

  showSearchSelectMedicines() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return SearchSelectMedicines((dynamic medicine) {
            if (medicine == null) {
            } else {
              if (medicinesToAdd
                      .where((element) => element["Clave"] == medicine["Clave"])
                      .length <=
                  0) {
                final controller = TextEditingController();
                final controller2 = TextEditingController();

                controller.text = "1";
                medicine["cant"] = controller;
                medicine["prescription"] = controller2;
                medicinesToAdd.add(medicine);
              } else {
                int index = medicinesToAdd.indexWhere(
                    (element) => element["Clave"] == medicine["Clave"]);
                if (index != -1) {
                  if ((medicinesToAdd[index]["cant"] as TextEditingController)
                          .text !=
                      "") {
                    (medicinesToAdd[index]["cant"] as TextEditingController)
                        .text = (int.parse((medicinesToAdd[index]["cant"]
                                    as TextEditingController)
                                .text) +
                            1)
                        .toString();
                  } else {
                    (medicinesToAdd[index]["cant"] as TextEditingController)
                        .text = "0";
                  }
                }
              }
              setState(() {});
            }
            Navigator.pop(contextDialog);
          }, showManualBtn: false, showNormalPriceBtn: false);
        });
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

  showTakePictureSt() async {
    if (kIsWeb) {
      selectPictureWeb(context, (dynamic imageFile) {
        setState(() {
          this.imageSelectedSt = imageFile;
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
                callbackShowTakePictureSt(contextDialogd, image);
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

  Future callbackShowTakePictureSt(contextDialog, image) async {
    if (image == null) return;
    try {
      final XFile? imageFile = await ImagePicker().pickImage(
          source:
              (image == "camera") ? ImageSource.camera : ImageSource.gallery);
      if (imageFile != null) {
        File file = await File(imageFile.path);
        setState(() {
          this.imageSelectedSt = file;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  processAdd() async {
    final form = formKey.currentState;
    bool pass = false;
    if (imageSelected != null) {
      pass = true;
    }
    if (cPrescription.text.trim() != "") {
      pass = true;
    }
    if (medicinesToAdd.length > 0) {
      pass = true;
      medicinesToAdd.forEach((element) {
        dynamic valuePrescription = element["prescription"].text;
        if (!checkEmpty(valuePrescription)) {
          pass = false;
        }
      });

      if (pass == false) {
        showErrorsDialog(context,
            ["Debe completar la prescripción de cada medicamento agregado"]);
        return;
      }
    }
    if (pass == false) {
      showErrorsDialog(
          context, ["Debe completar al menos una de las opciones"]);
      return;
    }
    if (form!.validate()) {
      form.save();
     
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);
        setState(() {
          loading=true;
        });
            Navigator.pop(loadingContext);
        try {
          dynamic assets = null;
          dynamic assetsSt = null;
          if (imageSelected != null)
            assets = await WebService(context)
                .uploadAsset("image", imageSelected, provider.user.token ?? "");

          if (imageSelectedSt != null)
            assetsSt = await WebService(context).uploadAsset(
                "image", imageSelectedSt, provider.user.token ?? "");
   

          PrescriptionModel prescriptionTmp =
              await WebService(context).createPrescription(
            (patientSelected as UserModel).id ?? "",
            provider.user.id ?? "",
            cDiagnosis.text,
            cEvolution.text,
            cPrescription.text,
            (assets != null && assets is AssetModel) ? assets.id ?? "" : "",
            studiesSelectionController.labSts,
            cOthersLabSts.text,
            (assetsSt != null && assetsSt is AssetModel)
                ? assetsSt.id ?? ""
                : "",
            provider.user.token ?? "",
            medicinesToAdd.map((e) {
              return {
                "cant": int.parse(e["cant"].text),
                "SUSTANCIA": e["SUSTANCIA"],
                "Descripción": e["Descripción"],
                "PRECIO_GRUPO_III": e["PRECIO_GRUPO_III"],
                "Línea": e["Línea"],
                "Clave": e["Clave"],
                "prescription": e["prescription"].text
              };
            }).toList(),
          );
  
          dynamic orderTmp = await WebService(context).createOrder(
              "", // typeDeliverySelected,
              "", // typePaymentSelected,
              "", //  (dateSelected as DateTime) .toUtc().millisecondsSinceEpoch.toString(),
              prescriptionTmp.patient!.id ?? "",
              prescriptionTmp.id ?? "",
              "", // (placeSelected != null && placeSelected is Place)  ? Place().toJson(placeSelected) : "",
              provider.user.token ?? "");

          if (studiesSelectionController.labSts.length > 0 ||
              cOthersLabSts.text != "" ||
              imageSelectedSt != null) {
            dynamic orderStudiesTmp = await WebService(context).createOrder(
                "", // typeDeliverySelected,
                "", // typePaymentSelected,
                "", //  (dateSelected as DateTime) .toUtc().millisecondsSinceEpoch.toString(),
                prescriptionTmp.patient!.id ?? "",
                prescriptionTmp.id ?? "",
                "", // (placeSelected != null && placeSelected is Place)  ? Place().toJson(placeSelected) : "",
                provider.user.token ?? "",
                type: "studies_without_prescription",
                approval: "approved");
          }
  
          try {
            UserModel userUpdated = await WebService(context).updateUser(
                (patientSelected as UserModel).id ?? "",
                "",
                "",
                "",
                "", // (birdate as DateTime).toUtc().millisecondsSinceEpoch.toString(),
                "",
                "",
                "",
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
                "",
                provider.user.token ?? "");
          } catch (e) {}

      
          // SnackBar(
          //         content: Text("Se ha agregado con éxito",
          //             style: TextStyle(
          //               color: Colors.white,
          //             )),
          //         elevation: 100,
          //         duration: Duration(seconds: 2),
          //         backgroundColor: CustomColors.primary)
          //     .show(context);


                  Timer(Duration(seconds: 3), () async {
   widget.callBackBack();

                  });
       
        } catch (e) {
                 setState(() {
          loading=false;
        });
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
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

                                            cYears.text =
                                                (patient.years != null &&
                                                        patient.years != "")
                                                    ? patient.years ?? ""
                                                    : "";
                                            cBloodType.text =
                                                (patient.blood_type != null &&
                                                        patient.blood_type !=
                                                            "")
                                                    ? patient.blood_type ?? ""
                                                    : "";
                                            cOrganDonor.text =
                                                (patient.organ_donor != null &&
                                                        patient.organ_donor !=
                                                            "")
                                                    ? patient.organ_donor ?? ""
                                                    : "";
                                            cDiseases.text =
                                                (patient.diseases != null &&
                                                        patient.diseases != "")
                                                    ? patient.diseases ?? ""
                                                    : "";
                                            cAllergies.text =
                                                (patient.allergies != null &&
                                                        patient.allergies != "")
                                                    ? patient.allergies ?? ""
                                                    : "";
                                          });

                                          cHasCovid.text =
                                              (patient.has_covid != null &&
                                                      patient.has_covid != "")
                                                  ? patient.has_covid ?? ""
                                                  : "";

                                          cCountVaccines.text =
                                              (patient.count_vaccines != null &&
                                                      patient.count_vaccines !=
                                                          "" &&
                                                      patient.count_vaccines! >
                                                          0)
                                                  ? patient.count_vaccines
                                                      .toString()
                                                  : "";

                                          cHeight.text =
                                              (patient.height != null &&
                                                      patient.height != "" &&
                                                      patient.height! > 0)
                                                  ? patient.height.toString()
                                                  : "";

                                          cWeight.text =
                                              (patient.weight != null &&
                                                      patient.weight != "" &&
                                                      patient.weight! > 0)
                                                  ? patient.weight.toString()
                                                  : "";

                                          cHeight.addListener(calcImc);
                                          cWeight.addListener(calcImc);

                                          WidgetsBinding.instance!
                                              .addPostFrameCallback((_) {
                                            calcImc();
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
    simpleLoading(context, (BuildContext contextDialog) async {
      final provider = Provider.of<AppProvider>(context, listen: false);

      return WebService(context)
          .getUsers(0, 0, context, provider.user.token ?? "",
              search: cSearch.text, filter_rol: "client")
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
