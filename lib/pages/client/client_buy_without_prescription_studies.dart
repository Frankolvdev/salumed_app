import 'dart:typed_data';

import 'package:app/components/studies_selection.dart';
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

class ClientBuyWithoutPrescriptionStudies extends StatefulWidget {
  Function callbackToOrders;
  ClientBuyWithoutPrescriptionStudies(this.callbackToOrders, {Key? key})
      : super(key: key);

  @override
  State<ClientBuyWithoutPrescriptionStudies> createState() =>
      _ClientBuyWithoutPrescriptionStudiesState();
}

class _ClientBuyWithoutPrescriptionStudiesState
    extends State<ClientBuyWithoutPrescriptionStudies> {
  final formKey = new GlobalKey<FormState>();
  final cPrescription = TextEditingController();

  final cOthersLabSts = TextEditingController();

  dynamic imageSelected = null;

  dynamic imageSelectedSt = null;

  StudiesSelectionController studiesSelectionController =
      new StudiesSelectionController();

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
                          Column(
                            children: [
                              StudiesSelection(
                                controller: studiesSelectionController,
                                preventSelect: false,
                              ),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(child: otherslabStField),
                                    InkWell(
                                      onTap: () {
                                        showTakePictureSt();
                                      },
                                      child: FaIcon(FontAwesomeIcons.camera,
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
                                            padding: const EdgeInsets.all(8.0),
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
                                                          child: Container(
                                                            height: 160,
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
                                                            child: Container(
                                                              decoration: new BoxDecoration(
                                                                  color: Colors
                                                                      .transparent,
                                                                  borderRadius: new BorderRadius
                                                                          .all(
                                                                      Radius.circular(
                                                                          45.0))),
                                                              child: Center(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10.0),
                                                                  child: Text(
                                                                      "Foto de estudios",
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
                                                          child:
                                                              (imageSelectedSt !=
                                                                      null)
                                                                  ? Container(
                                                                      height:
                                                                          160,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            new BorderRadius.all(Radius.circular(10.0)),
                                                                        image: (imageSelectedSt
                                                                                is Uint8List)
                                                                            ? DecorationImage(
                                                                                image: MemoryImage(imageSelectedSt),
                                                                                fit: BoxFit.contain,
                                                                              )
                                                                            : DecorationImage(
                                                                                fit: BoxFit.contain,
                                                                                image: FileImage(imageSelectedSt)),
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
                                                                  : Colors.black
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
                                                                      .all(8.0),
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
                                                                            BottomSheetPictures(context,
                                                                                0, [
                                                                              imageSelectedSt
                                                                            ]).showBottomSheetPictures();
                                                                          },
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                FaIcon(FontAwesomeIcons.expandArrowsAlt,
                                                                              color: Colors.grey,
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
                                                                      FontAwesomeIcons
                                                                          .camera,
                                                                      color: Colors
                                                                          .white,
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

                              /// end picture studies
                              ///    SizedBox(
                              SizedBox(
                                height: 20,
                              ),

                              //new
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 2,
                                      backgroundColor: CustomColors.primary2,
                                      shape: StadiumBorder()),
                                  onPressed: () {
                                    processAdd();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 35.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Solicitar",
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
                        ],
                      ),
                    )))
          ])),
    );
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
    final provider = Provider.of<AppProvider>(context, listen: false);
    final form = formKey.currentState;
    UserModel patientSelected = provider.user;
    bool pass = false;
    if (imageSelectedSt != null) {
      pass = true;
    }
    if (cOthersLabSts.text.trim() != "") {
      pass = true;
    }
    if (studiesSelectionController.getLabSts().length > 0) {
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
          dynamic assetsSt = null;
          if (imageSelectedSt != null)
            assetsSt = await WebService(context).uploadAsset(
                "image", imageSelectedSt, provider.user.token ?? "");

          PrescriptionModel prescriptionTmp = await WebService(context)
              .createWithoutPrescriptionStudies(
                  (patientSelected as UserModel).id ?? "",
                  studiesSelectionController.getLabSts(),
                  cOthersLabSts.text,
                  (assetsSt != null && assetsSt is AssetModel)
                      ? assetsSt.id ?? ""
                      : "",
                  provider.user.token ?? "");

          dynamic orderTmp = await WebService(context).createOrder(
              "", // typeDeliverySelected,
              "", // typePaymentSelected,
              "", //  (dateSelected as DateTime) .toUtc().millisecondsSinceEpoch.toString(),
              prescriptionTmp.patient!.id ?? "",
              prescriptionTmp.id ?? "",
              "", // (placeSelected != null && placeSelected is Place)  ? Place().toJson(placeSelected) : "",
              provider.user.token ?? "",
              type: "studies_without_prescription");

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
