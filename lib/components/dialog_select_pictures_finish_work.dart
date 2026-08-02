import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/advert.dart';
import 'package:app/models/asset.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:provider/provider.dart';
import 'package:snack/snack.dart';
import 'package:universal_io/io.dart';

class DialogSelectPicturesFinishWork extends StatefulWidget {
  AdvertModel advert;
  Function callBack;
  DialogSelectPicturesFinishWork(this.callBack, this.advert);

  @override
  _DialogSelectPicturesFinishWorkState createState() =>
      _DialogSelectPicturesFinishWorkState();
}

class _DialogSelectPicturesFinishWorkState
    extends State<DialogSelectPicturesFinishWork> {
  CarouselSliderController buttonCarouselController = CarouselSliderController();
  List<dynamic> pictures = [];
  int currentImage = 0;
  List<String> imagesToRemove = [];

  @override
  void initState() {
    super.initState();

    pictures.addAll(widget.advert.pictures_completed_work ?? []);
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 4, bottom: 8, left: 8, right: 8),
          margin: EdgeInsets.only(top: 8),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                        width: 30,
                        child: CircleAvatar(
                          backgroundColor: CustomColors.primary,
                          child: Icon(
                            FontAwesomeIcons.times,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              Visibility(
                  visible: pictures.length > 0,
                  child: Text("${currentImage + 1}/${pictures.length}")),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ButtonTheme(
                    minWidth: 0.0,
                    child: MaterialButton(
                      color: CustomColors.primary,
                      padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide.none,
                      ),
                      child: Row(
                        // Replace with a Row for horizontal icon + text

                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(right: 8, left: 5),
                              child: Icon(FontAwesomeIcons.camera,
                                  size: 12, color: Colors.white)),
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Text(
                                "Añadir",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        showTakePicture();
                      },
                    ),
                  ),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * .30,
                width: MediaQuery.of(context).size.width,
                child: (pictures.length <= 0)
                    ? Center(
                        child: InkWell(
                        onTap: () {
                          showTakePicture();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Debe añadir al menos 2 fotografías donde muestre el trabajo del Chapú finalizado",
                              textAlign: TextAlign.center),
                        ),
                      ))
                    : CarouselSlider(
                        carouselController: buttonCarouselController,
                        items: pictures.asMap().entries.map((picture) {
                          return Stack(
                            children: [
                              Positioned.fill(
                                  child: InkWell(
                                onTap: () {
                                  BottomSheetPictures(
                                          context, picture.key, pictures)
                                      .showBottomSheetPictures();
                                },
                                child: (picture.value is File)
                                    ? Image.file(
                                        picture.value,
                                        fit: BoxFit.cover,
                                      )
                                    : (picture.value is AssetModel)
                                        ? FadeInImage.assetNetwork(
                                            placeholder:
                                                "assets/images/loading-image1.gif",
                                            image: getImageUrl(picture.value),
                                            fit: BoxFit.cover,
                                          )
                                        : Image.memory(picture.value,
                                            fit: BoxFit.cover),
                              )),
                              Positioned(
                                  left: 2,
                                  top: 2,
                                  height: 30,
                                  width: 30,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        pictures.removeAt(picture.key);
                                        if (picture.value is AssetModel) {
                                          imagesToRemove.add(
                                              (picture.value as AssetModel)
                                                      .id ??
                                                  "");
                                        }
                                      });
                                    },
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Colors.black.withAlpha(60),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  )),
                              Positioned(
                                width: 20,
                                height: 20,
                                right: 5,
                                top: 5,
                                child: InkWell(
                                    onTap: () {
                                      BottomSheetPictures(
                                              context, picture.key, pictures)
                                          .showBottomSheetPictures();
                                    },
                                    child: Icon(
                                      FontAwesomeIcons.expandAlt,
                                      color: Colors.grey.shade400,
                                    )),
                              )
                            ],
                          );
                        }).toList(),
                        options: CarouselOptions(
                            enlargeCenterPage: true,
                            disableCenter: false,
                            autoPlay: true,
                            onPageChanged: (int index, rason) {
                              setState(() {
                                currentImage = index;
                              });
                            }),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  InkWell(
                    onTap: () {
                      buttonCarouselController.previousPage();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.keyboard_arrow_left,
                        size: 38,
                        color: CustomColors.primary,
                      ),
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: pictures.asMap().entries.map((picture) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          child: Container(
                            height: 8.0,
                            width: 8.0,
                            decoration: new BoxDecoration(
                              color: (currentImage == picture.key)
                                  ? CustomColors.primary
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }).toList()),
                  InkWell(
                    onTap: () {
                      buttonCarouselController.nextPage();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        size: 38,
                        color: CustomColors.primary,
                      ),
                    ),
                  )
                ]),
              ),
              Container(
                color: Colors.grey,
                height: 1,
                width: MediaQuery.of(context).size.width,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: CustomColors.primary,
                      shape: StadiumBorder()),
                  onPressed: () {
                    progressImages();
                  },
                  child: Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.save,
                          size: 18,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Guardar",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.0),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  showTakePicture() async {
    if (kIsWeb) {
      selectPicturesWebMulti(context, (List<dynamic> images) {
        setState(() {
          pictures.addAll(images);
        });
      });
    } else {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SelectPictureDialogWec(
              "Seleccionar fotografias",
              (contextDialog, image) {
                Navigator.pop(contextDialog);
                if (image == "gallery") {
                  callbackShowSelectPictures(contextDialog);
                } else {
                  callbackShowTakePicture(contextDialog);
                }
              },
              useBtnCancel: true,
            );
          });
    }
  }

  Future callbackShowSelectPictures(contextDialog) async {
    simpleLoading(context, (BuildContext loadingContext) async {
      try {
        final imageFiles = await ImagePicker().pickMultiImage();
        if (imageFiles == null) {
          Navigator.pop(loadingContext);
          return;
        }
        await Future.forEach(imageFiles, (XFile element) async {
          if (element != null) {
            final file = await File(element.path);
            pictures.add(file);
          }
        });
        setState(() {
          pictures = pictures;
        });
        Navigator.pop(loadingContext);
      } catch (e) {}
    });
  }

  Future callbackShowTakePicture(contextDialog) async {
    simpleLoading(context, (BuildContext loadingContext) async {
      try {
        final imageFile =
            await ImagePicker().pickImage(source: ImageSource.camera);
        if (imageFile == null) {
          Navigator.pop(loadingContext);
          return;
        }
        final file = await File(imageFile.path);
        setState(() {
          pictures.add(file);
        });
        Navigator.pop(loadingContext);
      } catch (e) {}
    });
  }

  progressImages() {
    final provider = Provider.of<AppProvider>(context, listen: false);

    simpleLoading(context, (BuildContext loadingContext) async {
      List<Future<AssetModel>> assetsProcess = [];
      try {
        pictures.forEach((element) {
          if (!(element is AssetModel))
            assetsProcess.add(WebService(context)
                .uploadAsset("image", element, provider.user.token ?? ""));
        });

        List<AssetModel> assets = await Future.wait(assetsProcess);

        AdvertModel advertTmp = await WebService(context)
            .updatePicturesFinishWork(
                widget.advert.id ?? "",
                assets.map((e) => e.id).toList() as List<String>,
                imagesToRemove,
                provider.user.token ?? "");

        setState(() {
          widget.advert = advertTmp;
        });

        updateAppProviderAdvert(context, advertTmp);

        Navigator.pop(loadingContext);
        Navigator.pop(context);
        SnackBar(
                content: Text("Se ha actualizado",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                elevation: 100,
                duration: Duration(seconds: 2),
                backgroundColor: CustomColors.primary)
            .show(context);
      } catch (e) {
        print(e.toString());
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e as dynamic);
      }
    });
  }

  Widget bullet() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Container(
        height: 5.0,
        width: 5.0,
        decoration: new BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
