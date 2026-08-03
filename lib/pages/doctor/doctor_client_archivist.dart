import 'dart:async';
import 'dart:typed_data';

import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/components/fade_animation.dart';
import 'package:app/components/notify_dialog.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/advert.dart';
import 'package:app/models/archive.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/category.dart';
import 'package:app/models/notification.dart';
import 'package:app/models/user.dart';

import 'package:app/pages/admin/admin_add_user.dart';
import 'package:app/pages/admin/admin_edit_user.dart';
import 'package:app/pages/chat.dart';
import 'package:app/pages/client/client_add_achive.dart';
import 'package:app/pages/pdf.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:universal_io/io.dart';
import 'package:snack/snack.dart';

import '../../components/notify_users_dialog.dart';
import '../../components/select_open_pdf_dialog.dart';

class DoctorClientArchivist extends StatefulWidget {
  UserModel user;
  String tokenDoctor;
  DoctorClientArchivist(this.user, {Key? key, this.tokenDoctor = ""})
      : super(key: key);

  @override
  State<DoctorClientArchivist> createState() => _DoctorClientArchivistState();
}

class _DoctorClientArchivistState extends State<DoctorClientArchivist> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  var _controllerScroll = ScrollController();

  PageController _pageController = PageController(initialPage: 0);

  num limit = 30;
  bool noMore = false;
  bool loading = false;

  DateTime currentDate = DateTime.now().toUtc();

  List<ArchiveModel> archives = [];
  final cSearch = TextEditingController();

  bool addUser = false;
  dynamic editUser = null;
  dynamic addUserDoctor = null;
  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);

    currentDate = DateTime.now().toUtc();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
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
  }

  void dispose() {
    super.dispose();
    _controllerScroll.dispose();
  }

  Future<Null> loadMore() {
    setState(() {
      loading = true;
    });
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getArchives(
            limit,
            archives.length,
            context,
            widget.user.id ?? "",
            (widget.tokenDoctor != "")
                ? widget.tokenDoctor
                : provider.user.token ?? "",
            search: cSearch.text)
        .then((value) {
      if (value.length > 0) {
        if (mounted)
          setState(() {
            archives.addAll(value);
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
        .getArchives(
            limit,
            0,
            context,
            widget.user.id ?? "",
            (widget.tokenDoctor != "")
                ? widget.tokenDoctor
                : provider.user.token ?? "",
            search: cSearch.text)
        .then((value) {
      if (mounted)
        setState(() {
          archives = value;
        });
    }).catchError((e) {
      showErrorsDialog(context, e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    UserModel user = provider.user;

    if (addUser)
      return AdminAddUser(() {
        setState(() {
          addUser = false;
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            _refreshIndicatorKey.currentState!.show();
          });
        });
      });

    if (editUser != null) {
      if (addUserDoctor != null) {
        return AdminEditUser(() {
          setState(() {
            addUserDoctor = null;
          });
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            _refreshIndicatorKey.currentState!.show();
          });
        }, addUserDoctor);
      } else {
        return AdminEditUser(() {
          setState(() {
            editUser = null;
          });
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            _refreshIndicatorKey.currentState!.show();
          });
        }, editUser);
      }
    }

    double widthLeftMenu =
        (MediaQuery.of(context).size.width >= breakPointDesktop)
            ? desktopMenuLeftWidth
            : 0;

    Widget searchField = TextField(
      onTap: () {},
      autofocus: false,
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
        archives.asMap().entries.map((archive) {
      ArchiveModel aTmp = archive.value;
      String created = getDateTimeFromStringFormat(
          DateTime.parse(aTmp.created_at!).toLocal().toString());
      return ResponsiveGridCol(
          lg: 4,
          xs: 12,
          md: 12,
          child: Visibility(
              visible: true,
              child: InkWell(
                onTap: () async {
                  if (aTmp.file!.type == "image") {
                    BottomSheetPictures(context, 0, [aTmp.file])
                        .showBottomSheetPictures();

                    print(getImageUrl(aTmp.file!));
                  } else if (aTmp.file!.type == "pdf") {
                    await showDialog(
                        context: context,
                        builder: (contextDialog) {
                          return SelectOpenPdfDialog(
                            "Abrir pdf con",
                            (contextDialogd, type) {
                              Navigator.pop(contextDialog);
                              if (type == "internal") {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        child: PdfView(getImageUrl(aTmp.file!)),
                                        type: PageTransitionType.slideInRight,
                                        duration: Duration(milliseconds: 250)));
                              } else {
                                launchUrl(context, getImageUrl(aTmp.file!));
                              }
                            },
                            useBtnCancel: true,
                          );
                        });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 2.0),
                  child: Card(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 4, left: 8.0, right: 8.0),
                              child: Text(created,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 11),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1),
                            ),
                            /*Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    delete(aTmp);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FaIcon(FontAwesomeIcons.times,
                                        color: CustomColors.primary, size: 17),
                                  ),
                                )
                              ],
                            )*/
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                    width: 85,
                                    height: 85,
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
                                    child: (aTmp.file!.type == "pdf")
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5.0, horizontal: 5.0),
                                            child: (aTmp.file != null)
                                                ? Container(
                                                    decoration:
                                                        new BoxDecoration(
                                                      color: Colors.transparent,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Image.asset(
                                                        "assets/images/pdf.png",
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    decoration: new BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            new BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    85.0))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Image.asset(
                                                        "assets/images/avatar.png",
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5.0, horizontal: 5.0),
                                            child: (aTmp.file != null &&
                                                    getImageUrl(aTmp.file!)
                                                            .trim() !=
                                                        "")
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            75.0),
                                                    child: FadeInImage
                                                        .assetNetwork(
                                                      placeholder:
                                                          "assets/images/loading-image1.gif",
                                                      image: getImageUrl(
                                                          aTmp.file!),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Container(
                                                    decoration: new BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            new BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    85.0))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Text(aTmp.title ?? "",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
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
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text("",
                style: TextStyle(
                  color: CustomColors.primary,
                  fontSize: 20.0,
                )),
            elevation: 0,
            centerTitle: true,
            leading: new IconButton(
              icon: new FaIcon(FontAwesomeIcons.arrowLeft,
                size: 20,
                color: CustomColors.primary,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )),
        body: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                width: MediaQuery.of(context).size.width - widthLeftMenu,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResponsiveGridRow(children: [
                          ResponsiveGridCol(
                            lg: 12,
                            xs: 12,
                            md: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: searchField,
                            ),
                          ),
                        ]),
                      ]),
                )),
            Positioned.fill(
                top: (MediaQuery.of(context).padding.top) + 60,
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
                            child: (archives.length <= 0)
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

  delete(ArchiveModel archive) {
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
                    .deleteArchive(
                        (widget.tokenDoctor != "")
                            ? widget.tokenDoctor
                            : provider.user.token ?? "",
                        archive.id ?? "")
                    .then((res) {
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
}
