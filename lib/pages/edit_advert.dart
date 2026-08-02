import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/electricity_questionnaire.dart';
import 'package:app/components/integral_questionnaire.dart';
import 'package:app/components/mechanics_questionnaire.dart';
import 'package:app/components/paint_questionnaire.dart';
import 'package:app/components/painting_sheet_questionnaire.dart';
import 'package:app/components/parquet_questionnaire.dart';
import 'package:app/components/plasterboard_questionnaire.dart';
import 'package:app/components/plumbing_questionnaire.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/components/tiling_questionnaire.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';

import 'package:app/models/advert.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/place.dart';
import 'package:app/pages/select_location.dart';
import 'package:app/pages/select_location_web.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:snack/snack.dart';
import 'package:universal_io/io.dart' as iosuniveraal;
import 'package:app/components/override_date_picker.dart';

class EditAdvert extends StatefulWidget {
  AdvertModel advert;
  bool isNew;

  EditAdvert(this.advert, {Key? key, this.isNew = false}) : super(key: key);

  @override
  _EditAdvertState createState() => _EditAdvertState();
}

class _EditAdvertState extends State<EditAdvert> {
  List<dynamic> pictures = [];
  CarouselSliderController buttonCarouselController = CarouselSliderController();
  int currentImage = 0;
  PageController _pageController = PageController(initialPage: 0);
  List<String> imagesToRemove = [];

  final formKey = new GlobalKey<FormState>();

  String city = "";
  String answer1 = "";
  dynamic answer2 = "";
  dynamic answer3 = "";
  dynamic answer4 = "";
  String answer5 = "";
  String answer6 = "";
  String answer7 = "";
  String answer8 = "";
  String answer9 = "";
  String answer10 = "";
  String answer11 = "";
  String answer12 = "";

  final ctypeDwelling = TextEditingController();
  final cNum = TextEditingController();
  final cAddress = TextEditingController();
  dynamic location = null;
  final cDescription = TextEditingController();
  final cFloor = TextEditingController();

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);
    pictures.addAll(widget.advert.pictures ?? []);
    Map<String, dynamic> genericQ = widget.advert.generic_questionnaire ?? {};
    answer1 = widget.advert.category ?? "";
    answer2 = (DateTime.parse(widget.advert.end_auction ?? "")
                .toUtc()
                .difference(
                    DateTime.parse(widget.advert.created_at ?? "").toUtc())
                .inDays -
            1)
        .toString();
    //answer2=((answer2<=0)?1:answer2).toString();

    answer3 = DateTime.parse(widget.advert.start ?? "").toLocal();
    answer4 = DateTime.parse(widget.advert.end ?? "").toLocal();

    cAddress.text = widget.advert.location!.written_address ?? "";
    cNum.text = widget.advert.location!.num ?? "";

    //answer5 = genericQ["answer1"];
    answer6 = genericQ["answer2"];

    answer7 = genericQ["answer3"];
    answer8 = genericQ["answer4"];
    answer9 = genericQ["answer5"];

    ctypeDwelling.text = genericQ["answer6"];
    cDescription.text = genericQ["answer7"];

    if (answer1 != "Mudanzas" &&
        answer1 != "Mecánica" &&
        answer1 != "Chapa y pintura") {
      try {
        answer11 = genericQ["answer8"];
      } catch (e) {}
    }

    try {
      cFloor.text = genericQ["answer9"];
    } catch (e) {}

    try {
      answer12 = genericQ["answer10"];
    } catch (e) {}

    location = widget.advert.location;
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0,
            )),
        elevation: 0,
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(
            FontAwesomeIcons.arrowLeft,
            size: 20,
            color: CustomColors.primary,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Container(
              constraints:
                  (kIsWeb) ? BoxConstraints(maxWidth: 600) : BoxConstraints(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Card(
                      child: Column(
                        children: [
                          Visibility(
                              visible: pictures.length > 0,
                              child: Text(
                                  "${currentImage + 1}/${pictures.length}")),
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
                                          "Debe seleccionar al menos 2 fotografías para el anuncio",
                                          textAlign: TextAlign.center),
                                    ),
                                  ))
                                : CarouselSlider(
                                    carouselController:
                                        buttonCarouselController,
                                    items:
                                        pictures.asMap().entries.map((picture) {
                                      return Stack(
                                        children: [
                                          Positioned.fill(
                                              child: InkWell(
                                            onTap: () {
                                              BottomSheetPictures(context,
                                                      picture.key, pictures)
                                                  .showBottomSheetPictures();
                                            },
                                            child: (picture.value
                                                    is iosuniveraal.File)
                                                ? Image.file(
                                                    picture.value,
                                                    fit: BoxFit.cover,
                                                  )
                                                : (picture.value is AssetModel)
                                                    ? FadeInImage.assetNetwork(
                                                        placeholder:
                                                            "assets/images/loading-image1.gif",
                                                        image: getImageUrl(
                                                            picture.value),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.memory(
                                                        picture.value,
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
                                                    pictures
                                                        .removeAt(picture.key);
                                                    if (picture.value
                                                        is AssetModel) {
                                                      imagesToRemove.add((picture
                                                                      .value
                                                                  as AssetModel)
                                                              .id ??
                                                          "");
                                                    }
                                                  });
                                                },
                                                child: CircleAvatar(
                                                  backgroundColor: Colors.black
                                                      .withAlpha(60),
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
                                                  BottomSheetPictures(context,
                                                          picture.key, pictures)
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 8),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: pictures
                                          .asMap()
                                          .entries
                                          .map((picture) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          child: Container(
                                            height: 8.0,
                                            width: 8.0,
                                            decoration: new BoxDecoration(
                                              color:
                                                  (currentImage == picture.key)
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ButtonTheme(
                                minWidth: 0.0,
                                child: MaterialButton(
                                  color: CustomColors.primary,
                                  padding:
                                      EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    side: BorderSide.none,
                                  ),
                                  child: Row(
                                    // Replace with a Row for horizontal icon + text

                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(right: 8),
                                          child: Icon(FontAwesomeIcons.camera,
                                              size: 12, color: Colors.white)),
                                      Flexible(
                                        child: Text(
                                          "Añadir fotos",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
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
                        ],
                      ),
                    ),
                    getContentGeneralQ(),
                    Visibility(
                        visible: getCategoryQuestionnaire() != null,
                        child: Text(
                          "Preguntas sobre la categoría",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        )),
                    Column(
                      children: [
                        Visibility(
                            visible: getCategoryQuestionnaire() != null,
                            child: Divider()),
                        (getCategoryQuestionnaire() != null)
                            ? getCategoryQuestionnaire()
                            : Container()
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getContentGeneralQ() {
    var fieldsDecoration = InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      hintText: "",
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      fillColor: Colors.white,
      focusColor: Colors.grey,
      hoverColor: Colors.grey,
      filled: true,
      border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          borderRadius: BorderRadius.circular(6.0)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          borderRadius: BorderRadius.circular(6.0)),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          borderRadius: BorderRadius.circular(6.0)),
      errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade300, width: 1.0),
          borderRadius: BorderRadius.circular(6.0)),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade300, width: 1.0),
          borderRadius: BorderRadius.circular(6.0)),
    );
    final typeDwellingField = TextFormField(
      textInputAction: TextInputAction.send,
      controller: ctypeDwelling,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration,
      onFieldSubmitted: (val) {},
    );

    final descriptionField = TextFormField(
      textInputAction: TextInputAction.next,
      controller: cDescription,
      readOnly: false,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      maxLength: 500,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration,
    );

    final floorField = TextFormField(
      textInputAction: TextInputAction.send,
      controller: cFloor,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration,
      onFieldSubmitted: (val) {},
    );

    final numField = TextFormField(
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.next,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      controller: cNum,
      keyboardType: TextInputType.number,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      onChanged: (val) {
        setState(() {});
      },
      onEditingComplete: () {
        setState(() {});
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration.copyWith(
          hintText: "N°",
          contentPadding: EdgeInsets.fromLTRB(4.0, 15.0, 2.0, 15.0)),
      onFieldSubmitted: (val) {},
    );

    final addressField = TextFormField(
      textInputAction: TextInputAction.next,
      readOnly: false,
      controller: cAddress,
      keyboardType: TextInputType.text,

      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration.copyWith(hintText: "Dirección"),
      onChanged: (val) {
        setState(() {});
      },
      onEditingComplete: () {
        setState(() {});
      },
      onTap: () async {},
    );

    return Form(
        key: formKey,
        child: Column(children: [
          //answer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [getCategoryWidget(answer1)],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Text("Categoría",
                        style: TextStyle(
                            color: CustomColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: DropdownButtonFormField(
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: Colors.grey,
                        ),
                        iconSize: 42,
                        items: categories.map((String category) {
                          return new DropdownMenuItem(
                              value: category,
                              child: Text(category,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            answer1 = val as String;
                          });
                          // do other stuff with _category
                        },
                        value: answer1,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                          hintText: "Selecciona la categoría",
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
                      ))
                ],
              ),
            ),
          ),
          (answer1 == "Pladur/Yeso")
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("Especifique el tipo de trabajo",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              btnSwitch("Pladur", answer12, () {
                                answer12 = "Pladur";
                              }),
                              btnSwitch("Yeso", answer12, () {
                                answer12 = "Yeso";
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Text("Explicación de lo que necesita",
                        style: TextStyle(
                            color: CustomColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: descriptionField),
                ],
              ),
            ),
          ),
          //answer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Text("Ciudad donde se realizara el trabajo",
                        style: TextStyle(
                            color: CustomColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  //----------------------------new
                  //new,
                ],
              ),
            ),
          ),
          //answer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Text(
                        "¿Lugar? (Asegúrese de que corresponda con la ciudad que eligió)",
                        style: TextStyle(
                            color: CustomColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 5.0),
                    child: Row(
                      children: [
                        Flexible(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: addressField,
                            )),
                        Flexible(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: numField,
                            ))
                      ],
                    ),
                  ),
                  Visibility(
                    visible: cAddress.text.trim() != "" &&
                        cNum.text != "" &&
                        city != "",
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: ButtonTheme(
                        minWidth: 230.0,
                        child: MaterialButton(
                          color: CustomColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide.none,
                          ),
                          child: Row(
                            // Replace with a Row for horizontal icon + text

                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Confirmar lugar en mapa",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(FontAwesomeIcons.map,
                                      size: 12, color: Colors.white)),
                            ],
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Navigator.push(
                                    context,
                                    PageTransition(
                                        child: (kIsWeb)
                                            ? SelectLocationWeb(
                                                defaultAddress: city +
                                                    " " +
                                                    cAddress.text +
                                                    " " +
                                                    cNum.text,
                                              )
                                            : SelectLocation(
                                                defaultAddress: city +
                                                    " " +
                                                    cAddress.text +
                                                    " " +
                                                    cNum.text,
                                              ),
                                        type: PageTransitionType.slideInUp,
                                        duration: Duration(milliseconds: 250)))
                                .then((value) {
                              if (value is Place) {
                                setState(() {
                                  location = value;
                                  /*cAddress.text = (location as Place).formatted_address ??
                                            "Ubicación incorrecta";*/
                                });
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          //answer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Text(
                        "¿Cuántos días durará la subasta después del periodo de preguntas? (El periodo de preguntas es de 1 día)",
                        style: TextStyle(
                            color: CustomColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        btnSwitch("1", answer2, () {
                          answer2 = "1";
                        }, expandedWidth: true),
                        btnSwitch("2", answer2, () {
                          answer2 = "2";
                        }, expandedWidth: true),
                        btnSwitch("3", answer2, () {
                          answer2 = "3";
                        }, expandedWidth: true),
                        btnSwitch("4", answer2, () {
                          answer2 = "4";
                        }, expandedWidth: true),
                        btnSwitch("5", answer2, () {
                          answer2 = "5";
                        }, expandedWidth: true),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          /*
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text(
                              "¿Cuanto tiempo durara la subasta después del periodo de preguntas? (El periodo de preguntas es de 1 día)",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 0.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: Size(100, 10),
                                      fixedSize: Size(100, 25),
                                      backgroundColor: CustomColors.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: EdgeInsets.all(0)),
                                  onPressed: () {
                                    selectDateTime((DateTime date) {
                                      answer2 = date;
                                    }, Duration(days: 1, hours: 5),
                                        Duration(days: 6, hours: 5));
                                  },
                                  child: Text(
                                    "Cambiar fecha",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12.0),
                                  ),
                                ),
                              ),
                              Text(
                                getDateTimeFromStringFormat(answer2.toString()),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),*/

          //answer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Text("¿Cuándo deberá iniciar la obra o reforma?",
                        style: TextStyle(
                            color: CustomColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 0.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(100, 10),
                                fixedSize: Size(100, 25),
                                backgroundColor: CustomColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.all(0)),
                            onPressed: () {
                              selectDateTime((DateTime date) {
                                answer3 = date;
                              }, Duration(days: 1, hours: 8),
                                  Duration(days: 31));
                            },
                            child: Text(
                              "Cambiar fecha",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.0),
                            ),
                          ),
                        ),
                        Text(
                          getDateFromStringFormat(answer3.toString()),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          //answer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Text(
                        "¿Para cuándo necesitas que esté terminada la obra o reforma?",
                        style: TextStyle(
                            color: CustomColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 0.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(100, 10),
                                fixedSize: Size(100, 25),
                                backgroundColor: CustomColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.all(0)),
                            onPressed: () {
                              selectDateTime((DateTime date) {
                                answer4 = date;
                              }, Duration(days: 1, hours: 16),
                                  Duration(days: 1000));
                            },
                            child: Text(
                              "Cambiar fecha",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.0),
                            ),
                          ),
                        ),
                        Text(
                          getDateFromStringFormat(answer4.toString()),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          (answer1 != "Mudanzas" &&
                  answer1 != "Mecánica" &&
                  answer1 != "Chapa y pintura")
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text(
                              "¿Tiene muebles, sanitarios, ... instalados dónde quiere hacer la reforma?",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              btnSwitch("Si", answer11, () {
                                answer11 = "Si";
                              }),
                              btnSwitch("No", answer11, () {
                                answer11 = "No";
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
          //answer
          /* Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Text("¿Quieres factura?",
                        style: TextStyle(
                            color: CustomColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        btnSwitch("Sí", answer5, () {
                          answer5 = "Sí";
                        }),
                        btnSwitch("No", answer5, () {
                          answer5 = "No";
                        }),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),*/
          //answer
          (answer1 != "Mudanzas")
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("¿Quién compra los materiales?",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              btnSwitch("Yo", answer6, () {
                                answer6 = "Yo";
                              }),
                              btnSwitch("Profesional", answer6, () {
                                answer6 = "Profesional";
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
          //answer
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Text("¿Tiene fácil aparcamiento?",
                        style: TextStyle(
                            color: CustomColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        btnSwitch("Sí", answer7, () {
                          answer7 = "Sí";
                        }),
                        btnSwitch("No", answer7, () {
                          answer7 = "No";
                        }),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          //answer
          (answer1 != "Mecánica" &&
                  answer1 != "Chapa y pintura" &&
                  answer1 != "Mudanzas")
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("¿Obra nueva o reforma?",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              btnSwitch("Nueva", answer8, () {
                                answer8 = "Nueva";
                              }),
                              btnSwitch("Reforma", answer8, () {
                                answer8 = "Reforma";
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
          //answer
          (answer1 != "Mecánica" && answer1 != "Chapa y pintura")
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("¿Tiene ascensor?",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              btnSwitch("Sí", answer9, () {
                                answer9 = "Sí";
                              }),
                              btnSwitch("No", answer9, () {
                                answer9 = "No";
                              }),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
          //answer
          (answer1 != "Mecánica" && answer1 != "Chapa y pintura")
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("¿Qué planta es?",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: floorField),
                      ],
                    ),
                  ),
                )
              : Container(),
          //answer
          (answer1 != "Mecánica" && answer1 != "Chapa y pintura")
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("Tipo de vivienda",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: typeDwellingField),
                      ],
                    ),
                  ),
                )
              : Container(),

          Visibility(
            visible: getCategoryQuestionnaire() == null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * .10,
                  vertical: 15),
              child: ButtonTheme(
                minWidth: 230.0,
                child: MaterialButton(
                  color: CustomColors.primary,
                  padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
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
                          padding: EdgeInsets.only(right: 8),
                          child: Icon(FontAwesomeIcons.save,
                              size: 12, color: Colors.white)),
                      Flexible(
                        child: Text(
                          "Guardar cuestionario",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    next();
                  },
                ),
              ),
            ),
          )
        ]));
  }

  int getSeconds(dynamic datetime) {
    return (datetime as DateTime).microsecondsSinceEpoch;
  }

  dynamic validates() {
    if (answer1 == "") {
      showErrorsDialog(context, ["Debe seleccionar la categoría"]);
      return false;
    }
    ;

    if (answer2 == "") {
      showErrorsDialog(
          context, ["Debe seleccionar cuantos días durará la subasta"]);
      return false;
    }
    ;
    if (answer3 == "") {
      showErrorsDialog(context,
          ["Debe seleccionar cuando deberá iniciar la obra o reforma"]);
      return false;
    }
    ;
    if (answer4 == "") {
      showErrorsDialog(context, [
        "Debe seleccionar para cuando necesita que la obra o reforma esté terminada"
      ]);
      return false;
    }
    ;

    if (answer3 != "" && answer4 != "") {
      if (getSeconds(answer4) <= getSeconds(answer3)) {
        showErrorsDialog(context, [
          "La fecha de termino de obra o reforma debe ser mayor a la fecha de inicio de obra o reforma"
        ]);
        return false;
      }
    }

    /*if (answer5 == "") {
      showErrorsDialog(context, ["Debe seleccionar si necesita factura"]);
      return false;
    }
    ;*/
    if (answer6 == "") {
      showErrorsDialog(
          context, ["Debe seleccionar quien comprara los materiales"]);
      return false;
    }
    ;
    if (answer7 == "") {
      showErrorsDialog(
          context, ["Debe seleccionar si tiene fácil aparcamento"]);
      return false;
    }
    ;
    if (answer1 != "Mecánica" &&
        answer1 != "Chapa y pintura" &&
        answer8 == "") {
      showErrorsDialog(
          context, ["Debe seleccionar si es nueva obra ó reforma"]);
      return false;
    }
    ;
    if (answer1 != "Mecánica" &&
        answer1 != "Chapa y pintura" &&
        answer9 == "") {
      showErrorsDialog(context, ["Debe seleccionar si tiene ascensor"]);
      return false;
    }
    ;
    if (cAddress.text.trim() == "") {
      showErrorsDialog(context,
          ["Debe ingresar la dirección de donde se realizara el trabajo"]);
      return false;
    }
    ;

    if (cNum.text.trim() == "") {
      showErrorsDialog(context, ["Debe ingresar el número de la ubicación"]);
      return false;
    }
    ;
    if (location == null) {
      showErrorsDialog(context, ["Debe confirmar la ubicación en el mapa"]);
      return false;
    }
    ;

    if (pictures.length < 2) {
      showErrorsDialog(context, ["Debe cargar por lo menos 2 fotografías"]);
      return false;
    }

    if (pictures.length > 20) {
      showErrorsDialog(
          context, ["Solo puede cargar 20 fotografías como máximo"]);
      return false;
    }

    if (answer1 != "Mudanzas" &&
        answer1 != "Mecánica" &&
        answer1 != "Chapa y pintura" &&
        answer11 == "") {
      showErrorsDialog(context, [
        "Debe seleccionar si tiene muebles, sanitarios, ... instalados dónde quiere hacer la reforma"
      ]);
      return false;
    }
    ;

    if (answer1 == "Pladur/Yeso" && answer12 == "") {
      showErrorsDialog(context, ["Debe especificar si es pladur o yeso"]);
      return false;
    }
    ;

    return true;
  }

  next() {
    final form = formKey.currentState;
    List<String> errors = [];

    if (!validates()) {
      return;
    }

    if (form!.validate()) {
      form.save();
      final provider = Provider.of<AppProvider>(context, listen: false);
      location.written_address = cAddress.text;
      location.city = this.city;
      location.num = cNum.text;

      simpleLoading(context, (BuildContext loadingContext) async {
        List<Future<AssetModel>> assetsProcess = [];
        try {
          pictures.forEach((element) {
            if (!(element is AssetModel))
              assetsProcess.add(WebService(context)
                  .uploadAsset("image", element, provider.user.token ?? ""));
          });
          int minutesToEnd = int.parse(answer2) * 1440;

          List<AssetModel> assets = await Future.wait(assetsProcess);

          AdvertModel advertTmp = await WebService(context).updateAdvert(
              widget.advert.id ?? "",
              answer1,
              assets.map((e) => e.id).toList() as List<String>,
              getGenericQuestionnaire(),
              {},
              minutesToEnd,
              answer3,
              answer4,
              location,
              cNum.text,
              imagesToRemove,
              provider.user.token ?? "",
              isNew: widget.isNew);

          setState(() {
            widget.advert = advertTmp;
          });

          updateAppProviderAdvert(context, advertTmp);

          if (widget.isNew) {
            initProcess(context, provider.user.token ?? "", () {});
          } else {
            Navigator.pop(loadingContext);
            SnackBar(
                    content: Text("Se ha actualizado",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    elevation: 100,
                    duration: Duration(seconds: 2),
                    backgroundColor: CustomColors.primary)
                .show(context);
          }
        } catch (e) {
          print(e.toString());
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
    }
  }

  Map<String, dynamic> getGenericQuestionnaire() {
    Map<String, dynamic> genericQuestionnaire = {
      //"answer1": answer5,
      "answer2": answer6,
      "answer3": answer7,
      "answer4": answer8,
      "answer5": answer9,
      "answer6": ctypeDwelling.text,
      "answer7": cDescription.text,
      "answer8": answer11,
      "answer9": cFloor.text,
      "answer10": answer12
    };
    return genericQuestionnaire;
  }

  Widget getCategoryQuestionnaire() {
    dynamic q = null;

    switch (answer1) {
      case "Electricidad":
        q = ElectricityQuestionnaire(
          questionnaire: widget.advert.category_questionnaire,
          edit: true,
          callback: callbackCategoryQ,
        );
        break;
      case "Mecánica":
        q = MechanicsQuestionnaire(
          questionnaire: widget.advert.category_questionnaire,
          edit: true,
          callback: callbackCategoryQ,
        );
        break;
      case "Pintura":
        q = PainQuestionnaire(
          questionnaire: widget.advert.category_questionnaire,
          edit: true,
          callback: callbackCategoryQ,
        );
        break;
      case "Parquet":
        q = ParquetQuestionnaire(
          questionnaire: widget.advert.category_questionnaire,
          edit: true,
          callback: callbackCategoryQ,
        );
        break;
      case "Pladur/Yeso":
        if (answer12 == "Pladur")
          q = PlasterboardQuestionnaire(
            questionnaire: widget.advert.category_questionnaire,
            edit: true,
            callback: callbackCategoryQ,
          );
        break;
      case "Fontanería":
        q = PlumbingQuestionnaire(
          questionnaire: widget.advert.category_questionnaire,
          edit: true,
          callback: callbackCategoryQ,
        );
        break;
      case "Alicatado":
        q = TilingQuestionnaire(
          questionnaire: widget.advert.category_questionnaire,
          edit: true,
          callback: callbackCategoryQ,
        );
        break;
      case "Chapa y pintura":
        q = PaintingSheetQuestionnaire(
          questionnaire: widget.advert.category_questionnaire,
          edit: true,
          callback: callbackCategoryQ,
        );
        break;
      case "Reforma integral":
        q = IntegralQuestionnaire(
          questionnaire: widget.advert.category_questionnaire,
          edit: true,
          callback: callbackCategoryQ,
        );
        break;
      default:
        null;
    }

    return q;
  }

  callbackCategoryQ(Map<String, dynamic> q) {
    final form = formKey.currentState;
    List<String> errors = [];
    if (!validates()) {
      return;
    }

    if (form!.validate()) {
      form.save();
      final provider = Provider.of<AppProvider>(context, listen: false);
      location.written_address = cAddress.text;
      location.city = this.city;
      location.num = cNum.text;

      simpleLoading(context, (BuildContext loadingContext) async {
        List<Future<AssetModel>> assetsProcess = [];
        try {
          pictures.forEach((element) {
            if (!(element is AssetModel))
              assetsProcess.add(WebService(context)
                  .uploadAsset("image", element, provider.user.token ?? ""));
          });
          int minutesToEnd = int.parse(answer2) * 1440;

          List<AssetModel> assets = await Future.wait(assetsProcess);

          AdvertModel advertTmp = await WebService(context).updateAdvert(
              widget.advert.id ?? "",
              answer1,
              assets.map((e) => e.id).toList() as List<String>,
              getGenericQuestionnaire(),
              q,
              minutesToEnd,
              answer3,
              answer4,
              location,
              cNum.text,
              imagesToRemove,
              provider.user.token ?? "",
              isNew: widget.isNew);

          setState(() {
            widget.advert = advertTmp;
          });

          updateAppProviderAdvert(context, advertTmp);

          Navigator.pop(loadingContext);
          if (widget.isNew) {
            initProcess(context, provider.user.token ?? "", () {});
          } else {
            Navigator.pop(loadingContext);
            SnackBar(
                    content: Text("Se ha actualizado",
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    elevation: 100,
                    duration: Duration(seconds: 2),
                    backgroundColor: CustomColors.primary)
                .show(context);
          }
        } catch (e) {
          print(e.toString());
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
    }
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
            final file = await iosuniveraal.File(element.path);
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
        final file = await iosuniveraal.File(imageFile.path);
        setState(() {
          pictures.add(file);
        });
        Navigator.pop(loadingContext);
      } catch (e) {}
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

  Widget btnSwitch(String text, dynamic answer, Function callback,
      {bool expandedWidth = false}) {
    bool status = (answer == text);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: (expandedWidth) ? Size(0, 10) : Size(100, 10),
            fixedSize: (expandedWidth) ? null : Size(100, 25),
            backgroundColor: status ? CustomColors.primary : Colors.grey.shade100,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.all(0)),
        onPressed: () {
          setState(() {
            callback();
          });
        },
        child: (expandedWidth)
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text,
                  style: TextStyle(
                      color: status ? Colors.white : Colors.grey,
                      fontSize: 12.0),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                    color: status ? Colors.white : Colors.grey, fontSize: 12.0),
              ),
      ),
    );
  }

  selectDateTime(Function callback, Duration minTime, Duration maxTime) {
    OverrideDatePicker.showDatePicker(context,
        theme: LegacyDatePickerTheme(),
        showTitleActions: true,
        minTime: DateTime.now().add(minTime),
        maxTime: DateTime.now().add(maxTime),
        onChanged: (date) {}, onConfirm: (date) {
      setState(() {
        callback(date);
      });
    }, currentTime: DateTime.now().add(minTime), locale: LocaleType.es);
  }

  getCategoryWidget(String category) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    String imageCategory = "";
    String nameCategory = "";

    if (category == "Albañilería") {
      imageCategory = "icon-albañil.png";
      nameCategory = "Albañilería";
    } else if (category == "Pintura") {
      imageCategory = "icon-pintura.png";
      nameCategory = "Pintura";
    } else if (category == "Electricidad") {
      imageCategory = "icon-electricidad.png";
      nameCategory = "Electricidad";
    } else if (category == "Fontanería") {
      imageCategory = "icon-fontanero.png";
      nameCategory = "Fontanería";
    } else if (category == "Alicatado") {
      imageCategory = "ico-alicatado.png";
      nameCategory = "Alicatado";
    } else if (category == "Parquet") {
      imageCategory = "icono-parquet.png";
      nameCategory = "Parquet";
    } else if (category == "Mecánica") {
      imageCategory = "icon-mecanica.png";
      nameCategory = "Mecánica";
    } else if (category == "Mudanzas") {
      imageCategory = "icon-mudanza.png";
      nameCategory = "Mudanzas";
    } else if (category == "Pladur" || category == "Pladur/Yeso") {
      imageCategory = "icon-pladur-yeso.png";
      nameCategory = "Pladur";
    } else if (category == "Carpintería") {
      imageCategory = "icon-carpinteria.png";
      nameCategory = "Carpintería";
    } else if (category.toLowerCase() ==
        "Pequeños chapú o reformas (por horas)".toLowerCase()) {
      imageCategory = "icon-reformas-por-horas.png";
      nameCategory = "Pequeños chapú o reformas (por horas)";
    } else if (category == "Carpintería metálica") {
      imageCategory = "icon-carp-metalica.png";
      nameCategory = "Carpintería metálica";
    } else if (category == "Chapa y pintura") {
      imageCategory = "icon-chapa-pintura.png";
      nameCategory = "Chapa y pintura";
    } else if (category == "Reforma integral") {
      imageCategory = "icon-reforma-integral.png";
      nameCategory = "Reforma integral";
    } else {
      imageCategory = "";
      nameCategory = "";
    }
    if (nameCategory != "" && imageCategory != "") {
      return Tooltip(
        message: nameCategory,
        triggerMode: TooltipTriggerMode.tap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 8.0),
          child: Image(
            width: 75,
            image: AssetImage('assets/images/categories/${imageCategory}'),
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
