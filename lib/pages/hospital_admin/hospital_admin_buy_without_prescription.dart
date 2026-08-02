import 'dart:typed_data';

import 'package:app/models/asset.dart';
import 'package:app/models/prescription.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:universal_io/io.dart';

import '../../components/bottom_sheet_pictures.dart';
import '../../components/select_picture_dialog_wec.dart';
import '../../constants/colors.dart';
import '../../helpers/helpers.dart';
import 'package:snack/snack.dart';

class HospitalAdminBuyWithoutPrescription extends StatefulWidget {
  Function callbackToOrders;
  HospitalAdminBuyWithoutPrescription(this.callbackToOrders, {Key? key})
      : super(key: key);

  @override
  State<HospitalAdminBuyWithoutPrescription> createState() =>
      _HospitalAdminBuyWithoutPrescriptionState();
}

class _HospitalAdminBuyWithoutPrescriptionState
    extends State<HospitalAdminBuyWithoutPrescription> {
  final formKey = new GlobalKey<FormState>();
  final cPrescription = TextEditingController();
  dynamic imageSelected = null;
  @override
  Widget build(BuildContext context) {
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
        labelText: 'Ingrese los medicamentos y cantidad a solicitar',
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
      body: Form(
          key: formKey,
          child: ListView(children: [
            Center(
                child: Container(
                    constraints: kIsWeb
                        ? BoxConstraints(maxWidth: 1000)
                        : BoxConstraints(),
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
                            child: prescriptionField,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                  "Fotografía de la receta (si cuenta con ella)",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15)),
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
                                                            Radius.circular(
                                                                10.0)),
                                                  ),
                                                  child: Container(
                                                    decoration: new BoxDecoration(
                                                        color:
                                                            Colors.transparent,
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
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
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
                                                    color:
                                                        (imageSelected != null)
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
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Icon(
                                                                    FontAwesomeIcons
                                                                        .expandArrowsAlt,
                                                                    color: Colors
                                                                        .grey,
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
                                      "Solicitar",
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
                    )))
          ])),
    );
  }

  processAdd() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final form = formKey.currentState;
    UserModel patientSelected = provider.user;
    bool pass = false;
    if (imageSelected != null) {
      pass = true;
    }
    if (cPrescription.text.trim() != "") {
      pass = true;
    }
    if (pass == false) {
      showErrorsDialog(
          context, ["Debe completar al menos una de las opciones"]);
      return;
    }
    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        try {
          dynamic assets = null;
          dynamic assetsSt = null;
          if (imageSelected != null)
            assets = await WebService(context)
                .uploadAsset("image", imageSelected, provider.user.token ?? "");

          PrescriptionModel prescriptionTmp = await WebService(context)
              .createWithoutPrescription(
                  (patientSelected as UserModel).id ?? "",
                  cPrescription.text,
                  (assets != null && assets is AssetModel)
                      ? assets.id ?? ""
                      : "",
                  [],
                  provider.user.token ?? "");

          dynamic orderTmp = await WebService(context).createOrder(
              "", // typeDeliverySelected,
              "", // typePaymentSelected,
              "", //  (dateSelected as DateTime) .toUtc().millisecondsSinceEpoch.toString(),
              prescriptionTmp.patient!.id ?? "",
              prescriptionTmp.id ?? "",
              "", // (placeSelected != null && placeSelected is Place)  ? Place().toJson(placeSelected) : "",
              provider.user.token ?? "",
              type: "medicines_without_prescription");

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
          widget.callbackToOrders();
        } catch (e) {
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
    }
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
}
