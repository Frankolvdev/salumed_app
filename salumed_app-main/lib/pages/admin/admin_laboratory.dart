import 'dart:async';
import 'dart:typed_data';

import 'package:app/components/custom_dialog.dart';
import 'package:app/components/fade_animation.dart';

import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/advert.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/category.dart';
import 'package:app/models/notification.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/admin/admin_edit_laboratory.dart';
import 'package:app/pages/admin/admin_edit_pharmacy.dart';
import 'package:app/pages/chat.dart';
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

class AdminLaboratory extends StatefulWidget {
  const AdminLaboratory({Key? key}) : super(key: key);

  @override
  _AdminLaboratoryState createState() => _AdminLaboratoryState();
}

class _AdminLaboratoryState extends State<AdminLaboratory> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  var _controllerScroll = ScrollController();

  PageController _pageController = PageController(initialPage: 0);

  num limit = 30;
  bool noMore = false;
  bool loading = false;

  DateTime currentDate = DateTime.now().toUtc();

  List<PharmacyModel> pharmacies = [];
  List<CategoryModel> categories = [];
  final cSearch = TextEditingController();
  dynamic categorySelected = null;
  dynamic editPharmacy = null;
  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);

    currentDate = DateTime.now().toUtc();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState!.show();
    });

    _controllerScroll.addListener(() {
      if (_controllerScroll.position.atEdge) {
        if (_controllerScroll.position.pixels == 0) {
        } else {
          setState(() {
            loading = true;
          });
          loadMore();
        }
      }
    });
    loadCategories();
  }

  void dispose() {
    super.dispose();
    _controllerScroll.dispose();
  }

  loadCategories() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getCategories(0, 0, context, provider.user.token ?? "", search: "")
        .then((value) {
      if (mounted)
        setState(() {
          categories = value;
        });
    }).catchError((e) {
      showErrorsDialog(context, e);
    });
  }

  Future<Null> loadMore() {
    setState(() {
      loading = true;
    });
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getPharmacies(
            limit, pharmacies.length, context, provider.user.token ?? "",
            search: cSearch.text, type: "laboratory")
        .then((value) {
      if (value.length > 0) {
        if (mounted)
          setState(() {
            pharmacies.addAll(value);
            noMore = false;
          });
      } else {
        noMore = true;
        print("entre a no hay más");
      }

      Timer(Duration(seconds: 1), () {
        WidgetsBinding.instance?.addPostFrameCallback((_) async {
          if (mounted)
            setState(() {
              loading = false;
            });
        });
      });
    }).catchError((e) {
      Timer(Duration(seconds: 1), () {
        if (mounted)
          setState(() {
            loading = false;
          });
      });
      showErrorsDialog(context, e);
    });
  }

  Future<Null> load() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getPharmacies(limit, 0, context, provider.user.token ?? "",
            search: cSearch.text, type: "laboratory")
        .then((value) {
      if (mounted)
        setState(() {
          pharmacies = value;
        });
    }).catchError((e) {
      showErrorsDialog(context, e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    UserModel user = provider.user;

    double widthLeftMenu =
        (MediaQuery.of(context).size.width >= breakPointDesktop)
            ? desktopMenuLeftWidth
            : 0;

    if (editPharmacy != null) {
      return AdminEditLaboratory(() {
        setState(() {
          editPharmacy = null;
        });
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          _refreshIndicatorKey.currentState!.show();
        });
      }, editPharmacy);
    }

    Widget searchField = TextField(
      onTap: () {},
      autofocus: true,
      controller: cSearch,
      style: TextStyle(color: Colors.black),
      textInputAction: TextInputAction.search,
      //maxLength: 1,
      textAlign: TextAlign.left,

      //focusNode: myFocusNode1,
      decoration: InputDecoration(
          counterText: '',
          hintText: "Buscar",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: InkWell(
            onTap: () {
              cSearch.text = "";
              _refreshIndicatorKey.currentState!.show();
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
              _refreshIndicatorKey.currentState!.show();
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
        _refreshIndicatorKey.currentState!.show();
      },
    );

    List<ResponsiveGridCol> progressWidgets =
        pharmacies.asMap().entries.map((pharmacy) {
      PharmacyModel pTmp = pharmacy.value;
      String created = getDateTimeFromStringFormat(
          DateTime.parse(pTmp.created_at!).toLocal().toString());
      return ResponsiveGridCol(
          lg: 4,
          xs: 12,
          md: 12,
          child: Visibility(
              visible: true,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 2.0),
                  child: Container(
                    constraints: BoxConstraints(
                        minHeight: 20,
                        maxHeight: 220,
                        maxWidth: double.infinity,
                        minWidth: 20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Card(
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.grey.shade800,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: new BoxDecoration(
                                                border: new Border.all(
                                                  width: 1,
                                                  color: Colors.grey.shade200,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.shade200,
                                                    spreadRadius: 2,
                                                    blurRadius: 2,
                                                    offset: Offset(0,
                                                        0), // changes position of shadow
                                                  ),
                                                ], // border color
                                                shape: BoxShape.circle,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 1.0,
                                                        horizontal: 1.0),
                                                child: (pTmp.cover != null &&
                                                        getImageUrl(pTmp.cover!)
                                                                .trim() !=
                                                            "")
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50.0),
                                                        child: FadeInImage
                                                            .assetNetwork(
                                                          placeholder:
                                                              "assets/images/loading-image1.gif",
                                                          image: getImageUrl(
                                                              pTmp.cover!),
                                                          fit: BoxFit.cover,
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
                                                                        50.0))),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Image.asset(
                                                            "assets/images/avatar.png",
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, right: 8.0),
                                                child: Text(pTmp.title ?? "",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0, right: 8.0),
                                              child: Text(
                                                  (pTmp.category != null)
                                                      ? pTmp.category!.title ??
                                                          ""
                                                      : "",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0, right: 8.0),
                                              child: Text(pTmp.title ?? "",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Container(
                                      color: Colors.grey.shade200,
                                      height: 1,
                                      width: double.infinity),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              elevation: 2,
                                              backgroundColor: Colors.grey.shade800,
                                              shape: StadiumBorder()),
                                          onPressed: () {
                                            setState(() {
                                              editPharmacy = pTmp;
                                            });
                                          },
                                          child: Container(
                                            height: 35.0,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: Icon(Icons.edit,
                                                      color: Colors.white,
                                                      size: 15.0),
                                                ),
                                                Text(
                                                  "Gestionar",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15.0),
                                                )
                                              ],
                                            ),
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 15.0),
                                      child: InkWell(
                                        onTap: () {
                                          updateApproved(pTmp);
                                        },
                                        child: Container(
                                          height: 35.0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  (pTmp.approved == null ||
                                                          pTmp.approved ==
                                                              "not_approved")
                                                      ? "Activar"
                                                      : "Desactivar",
                                                  style: TextStyle(
                                                      color:
                                                          CustomColors.primary,
                                                      fontSize: 15.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                                decoration: new BoxDecoration(
                                    color: (pTmp.approved == null ||
                                            pTmp.approved == "not_approved")
                                        ? Colors.orange
                                        : Colors.green,
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(12.0))),
                                width: 12,
                                height: 12)),
                      ],
                    ),
                  ),
                ),
              )));
    }).toList();

    progressWidgets.add(ResponsiveGridCol(
        lg: 12,
        xs: 12,
        md: 12,
        child: Visibility(
          visible: loading,
          child: Container(
            width: 30,
            height: 30,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(CustomColors.primary)),
              ),
            ),
          ),
        )));

    if (noMore) {
      progressWidgets.add(ResponsiveGridCol(
          lg: 12,
          xs: 12,
          md: 12,
          child: Visibility(
            visible: !loading,
            child: Center(
              child: Container(
                  height: 30,
                  child: Text("No hay mas elementos para mostrar.")),
            ),
          )));
    }
    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Stack(
          children: [
            Positioned(
                top: (MediaQuery.of(context).padding.top),
                left: 0,
                width: MediaQuery.of(context).size.width - widthLeftMenu,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResponsiveGridRow(children: [
                          ResponsiveGridCol(
                            lg: 10,
                            xs: 12,
                            md: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: searchField,
                            ),
                          ),
                          ResponsiveGridCol(
                            lg: 2,
                            xs: 12,
                            md: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 2,
                                      backgroundColor: CustomColors.primary,
                                      shape: StadiumBorder()),
                                  onPressed: () {
                                    add();
                                  },
                                  child: Container(
                                    height: 35.0,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Agregar",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.0),
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          )
                        ])
                      ]),
                )),
            Positioned.fill(
                top: (MediaQuery.of(context).padding.top) + 120 + 20,
                child: RefreshIndicator(
                    color: CustomColors.primary,
                    key: _refreshIndicatorKey,
                    displacement: MediaQuery.of(context).size.height * .40,
                    onRefresh: load,
                    child: SingleChildScrollView(
                      controller: _controllerScroll,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height,
                                maxHeight: double.infinity),
                            child: (pharmacies.length <= 0)
                                ? Center(
                                    child: Column(
                                    children: [
                                      Text(
                                        "No hay ningún elemento para mostrar",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                    ],
                                  ))
                                : Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            ResponsiveGridRow(
                                                children: progressWidgets)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    )))
          ],
        ));
  }

  dynamic imageSelected = null;
  final cTitle = TextEditingController();
  late StateSetter _setState;
  final formKey = new GlobalKey<FormState>();
  add() {
    final nameField = TextFormField(
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
        labelText: 'Nombre o título',
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

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return StatefulBuilder(builder: (context, setState) {
            _setState = setState;
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
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 160,
                                  height: 160,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                          child: (imageSelected != null)
                                              ? Container(
                                                  width: 160,
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
                                                            fit: BoxFit.cover,
                                                          )
                                                        : DecorationImage(
                                                            fit: BoxFit.cover,
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
                                                  : Colors.black.withAlpha(80),
                                              borderRadius:
                                                  new BorderRadius.all(
                                                      Radius.circular(10.0))),
                                          child: Align(
                                            alignment: (imageSelected != null)
                                                ? Alignment.bottomRight
                                                : Alignment.center,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                  height: 16.0,
                                ),
                                nameField,
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: DropdownButtonFormField(
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_outlined,
                                      color: Colors.grey,
                                    ),
                                    iconSize: 42,
                                    items: categories.map((CategoryModel cat) {
                                      return new DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat.title ?? "",
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1));
                                    }).toList(),
                                    onChanged: (cat) {
                                      setState(() {
                                        categorySelected = cat;
                                      });

                                      // do other stuff with _category
                                    },
                                    value: categorySelected,
                                    decoration: InputDecoration(
                                      labelText: 'Categoría',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: CustomColors.primary),
                                      ),
                                      border: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
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
                                              processAdd(contextDialog);
                                            },
                                            child: Text("Agregar")),
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

  showTakePicture() async {
    if (kIsWeb) {
      selectPictureWeb(context, (dynamic imageFile) {
        setState(() {
          this.imageSelected = imageFile;
          this.imageSelectedEdit = imageFile;
        });
        try {
          _setState(() {});
        } catch (e) {}
        try {
          _setStateEdit(() {});
        } catch (e) {}
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
          this.imageSelectedEdit = file;
        });
        try {
          _setState(() {});
        } catch (e) {}
        try {
          _setStateEdit(() {});
        } catch (e) {}
      }
    } catch (e) {
      print(e);
    }
  }

  delete(CategoryModel category) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return CustomDialog(
            "",
            "¿Realmente desea eliminar el elemento?",
            "Aceptar",
            () {
              simpleLoading(context, (BuildContext loadingContext) {
                final provider =
                    Provider.of<AppProvider>(context, listen: false);

                WebService(context)
                    .deleteCategory(
                        category.id ?? "", provider.user.token ?? "")
                    .then((categoryDelete) {
                  SnackBar(
                          content: Text("Se ha eliminado correctamente",
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          elevation: 100,
                          duration: Duration(seconds: 2),
                          backgroundColor: CustomColors.primary)
                      .show(context);
                  Navigator.pop(loadingContext);
                  _refreshIndicatorKey.currentState!.show();
                }).catchError((e) {
                  Navigator.pop(loadingContext);
                  showErrorsDialog(context, e);
                });
              });
            },
            useBtnCancel: true,
            image: '',
          );
        });
  }

  processAdd(BuildContext contextDialog) async {
    if (categorySelected == null) {
      showErrorsDialog(context, ["Debe seleccionar una categoría"]);
      return;
    }
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);

        try {
          dynamic tmpAsset = null;
          if (imageSelected != null) {
            tmpAsset = await WebService(context)
                .uploadAsset("image", imageSelected, provider.user.token ?? "");
          }

          await WebService(context).createPharmacy(
              cTitle.text,
              (tmpAsset != null && tmpAsset is AssetModel)
                  ? tmpAsset.id ?? ""
                  : "",
              (categorySelected as CategoryModel).id ?? "",
              "laboratory",
              provider.user.token ?? "");

          Navigator.pop(loadingContext);
          SnackBar(
                  content: Text("Se ha creado correctamente",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  elevation: 100,
                  duration: Duration(seconds: 2),
                  backgroundColor: CustomColors.primary)
              .show(context);

          setState(() {
            imageSelected = null;
            categorySelected = null;
            cTitle.text = "";
          });
          try {
            _setState(() {});
          } catch (e) {}
          _refreshIndicatorKey.currentState!.show();
          Navigator.pop(contextDialog);
        } catch (e) {
          print(e.toString());
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
    }
  }

  dynamic imageSelectedEdit = null;
  final cTitleEdit = TextEditingController();
  late StateSetter _setStateEdit;
  final formKeyEdit = new GlobalKey<FormState>();
  edit(CategoryModel category) {
    setState(() {
      imageSelectedEdit = null;
      imageSelectedEdit = category.cover;
      cTitleEdit.text = category.title ?? "";
    });
    final nameField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cTitleEdit,
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

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return StatefulBuilder(builder: (context, setState) {
            _setStateEdit = setState;
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
                            key: formKeyEdit,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 160,
                                  height: 160,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                          child: (imageSelectedEdit != null)
                                              ? Container(
                                                  width: 160,
                                                  height: 160,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        new BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                    image: (imageSelectedEdit
                                                            is Uint8List)
                                                        ? DecorationImage(
                                                            image: MemoryImage(
                                                                imageSelectedEdit),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : (imageSelectedEdit
                                                                is AssetModel)
                                                            ? DecorationImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                image: NetworkImage(
                                                                    getImageUrl(
                                                                        imageSelectedEdit)))
                                                            : DecorationImage(
                                                                fit: BoxFit
                                                                    .cover,
                                                                image: FileImage(
                                                                    imageSelectedEdit)),
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
                                              color: (imageSelectedEdit != null)
                                                  ? Colors.transparent
                                                  : Colors.black.withAlpha(80),
                                              borderRadius:
                                                  new BorderRadius.all(
                                                      Radius.circular(10.0))),
                                          child: Align(
                                            alignment:
                                                (imageSelectedEdit != null)
                                                    ? Alignment.bottomRight
                                                    : Alignment.center,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                  height: 16.0,
                                ),
                                nameField,
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
                                              processEdit(
                                                  contextDialog, category);
                                            },
                                            child: Text("Guardar")),
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

  updateApproved(PharmacyModel pharmacy) async {
    simpleLoading(context, (BuildContext loadingContext) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      try {
        PharmacyModel pharmacyTmp = await WebService(context)
            .updateApprovedPharmacy(
                pharmacy.id ?? "", provider.user.token ?? "");

        for (var i = 0; i < pharmacies.length; i++) {
          if (pharmacies[i].id == pharmacy.id) {
            setState(() {
              pharmacies[i] = pharmacyTmp;
            });
          }
        }
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

  processEdit(BuildContext contextDialog, CategoryModel category) async {
    if (imageSelectedEdit == null) {
      showErrorsDialog(
          context, ["Debe seleccionar una imagen para la categoría"]);
      return;
    }
    final form = formKeyEdit.currentState;

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);

        try {
          dynamic tmpAsset = null;
          if (!(imageSelectedEdit is AssetModel)) {
            tmpAsset = await WebService(context).uploadAsset(
                "image", imageSelectedEdit, provider.user.token ?? "");
          } else {
            tmpAsset = imageSelectedEdit;
          }

          await WebService(context).editCategory(cTitleEdit.text,
              tmpAsset.id ?? "", category.id ?? "", provider.user.token ?? "");
          Navigator.pop(loadingContext);
          SnackBar(
                  content: Text("Se ha guardado correctamente",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  elevation: 100,
                  duration: Duration(seconds: 2),
                  backgroundColor: CustomColors.primary)
              .show(context);

          setState(() {
            imageSelectedEdit = null;
            cTitleEdit.text = "";
          });
          try {
            _setStateEdit(() {});
          } catch (e) {}
          _refreshIndicatorKey.currentState!.show();
          Navigator.pop(contextDialog);
        } catch (e) {
          print(e.toString());
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
    }
  }
}
