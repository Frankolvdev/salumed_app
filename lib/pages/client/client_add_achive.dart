import 'dart:typed_data';

import 'package:app/components/custom_dialog.dart';
import 'package:app/components/override_date_picker.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/components/select_picture_dialog_wec_files.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/archive.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/set_change_password.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
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

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:universal_io/io.dart';
import 'package:permission_handler/permission_handler.dart';

class ClientAddArchive extends StatefulWidget {
  ClientAddArchive({Key? key}) : super(key: key);

  @override
  _ClientAddArchiveState createState() => _ClientAddArchiveState();
}

class _ClientAddArchiveState extends State<ClientAddArchive> {
  final cTitle = TextEditingController();

  final formKey = new GlobalKey<FormState>();
  dynamic imageSelected = null;
  dynamic fileSelected = null;
  @override
  void initState() {
    super.initState();

    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);

    final titleField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cTitle,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Título',
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
                        Navigator.pop(context);
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
                      Container(
                        width: 160,
                        height: 160,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Visibility(
                                visible: imageSelected == null &&
                                    fileSelected == null,
                                child: Container(
                                  height: 160,
                                  width: 160,
                                  decoration: new BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(10.0)),
                                  ),
                                  child: Container(
                                    decoration: new BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: new BorderRadius.all(
                                            Radius.circular(45.0))),
                                    child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.fileUpload,
                                              color: Colors.black,
                                              size: 50,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  "Click para seleccionar archivo",
                                                  textAlign: TextAlign.center),
                                            )
                                          ],
                                        )),
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
                                    : (fileSelected != null)
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: 160,
                                              height: 160,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        Radius.circular(10.0)),
                                                image: DecorationImage(
                                                  image: new AssetImage(
                                                      'assets/images/pdf.png'),
                                                  fit: BoxFit.scaleDown,
                                                ),
                                              ),
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
                        child: titleField,
                      ),

                      //new
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
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

  Future callbackShowTakeFile() async {


  await requestStoragePermission();
    print("entre a callbackShowTakeFile");
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["pdf"],
        allowMultiple: false);
         print("entre a callbackShowTakeFile1");
    if (result != null) {
      if (kIsWeb) {
        if (result.files.single != null) {
          setState(() {
            this.fileSelected = result.files.single.bytes ?? [];
            this.imageSelected = null;
          });

          setState(() {
            cTitle.text = result.files.single.name;
          });
        } else {
          print("no entre a createFileFromBytes");
        }
      } else {
           print("entre a callbackShowTakeFile2");
      
        File file = File(result.files.single.path!);
        setState(() {
          this.fileSelected = file;
          this.imageSelected = null;
        });
        setName(file);
      }
    } else {
      // User canceled the picker
    }
  }

  File createFileFromBytes(Uint8List bytes) {
    return File.fromRawPath(bytes);
  }

  showTakePicture() async {
    await showDialog(
        context: context,
        builder: (contextDialog) {
          return SelectPictureDialogWecFiles(
            "Seleccionar archivo",
            (contextDialogd, image) {
              Navigator.pop(contextDialog);
              if (image != "pdf") {
                if (kIsWeb) {
                  selectPictureWeb(context, (dynamic imageFile) {
                    setState(() {
                      this.imageSelected = imageFile;
                      this.fileSelected = null;
                    });
                    if (imageFile is File) {
                      setName(imageFile);
                    }
                  });
                } else {
                  callbackShowTakePicture(contextDialogd, image);
                }
              } else {
                callbackShowTakeFile();
              }
            },
            useBtnCancel: true,
          );
        });
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
          this.fileSelected = null;
        });
        setName(file);
      }
    } catch (e) {
      print(e);
    }
  }

  setName(File file) {
    setState(() {
      cTitle.text = file.name;
    });
  }

  processAdd() async {
    final form = formKey.currentState;

    if (imageSelected == null && fileSelected == null) {
      showErrorsDialog(context, ["Debe seleccionar un archivo"]);
    }

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);
        try {
          dynamic assets = null;
          if (imageSelected != null) {
            assets = await WebService(context)
                .uploadAsset("image", imageSelected, provider.user.token ?? "");
          } else if (fileSelected != null) {
            assets = await WebService(context)
                .uploadAsset("pdf", fileSelected, provider.user.token ?? "");
          }

          List<ArchiveModel> archives = await WebService(context).addFileUser(
              (assets != null && assets is AssetModel) ? assets.id ?? "" : "",
              cTitle.text,
              provider.user.token ?? "");

          provider.user.archives = archives;
          provider.setUser(provider.user);

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
          Navigator.pop(context);
        } catch (e) {
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
    }
  }
}

extension FileExtention on FileSystemEntity {
  String get name {
    return this?.path?.split("/")?.last ?? "";
  }
}
