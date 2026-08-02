import 'dart:async';
import 'dart:typed_data';

import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/question.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:universal_io/io.dart';

import '../providers/app.dart';
import '../services/web_service.dart';

class SearchSelectMedicines extends StatefulWidget {
  Function callBackBtn;
  bool showManualBtn;
  bool showNormalPriceBtn;
  String tokenDoctor;
  SearchSelectMedicines(this.callBackBtn,
      {this.showManualBtn = true,
      this.showNormalPriceBtn = true,
      this.tokenDoctor = ""});
  @override
  _SearchSelectMedicinesState createState() => _SearchSelectMedicinesState();
}

class _SearchSelectMedicinesState extends State<SearchSelectMedicines> {
  List<dynamic> medicinesShow = [];
  final cSearch = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  var _controllerScroll = ScrollController();

  num limit = 20;
  bool noMore = false;
  bool loading = false;
  @override
  void initState() {
    super.initState();
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

  Future<Null> loadMore() {
    setState(() {
      loading = true;
    });
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getMeidicinesPreload(
            limit,
            medicinesShow.length,
            context,
            (widget.tokenDoctor != "")
                ? widget.tokenDoctor
                : provider.user.token ?? "",
            search: cSearch.text)
        .then((value) {
      if (value.length > 0) {
        if (mounted)
          setState(() {
            medicinesShow.addAll(value);
            noMore = false;
          });
      } else {
        noMore = true;
        print("entre a no hay más");
      }

      Timer(Duration(seconds: 2), () {
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
        .getMeidicinesPreload(
            limit,
            0,
            context,
            (widget.tokenDoctor != "")
                ? widget.tokenDoctor
                : provider.user.token ?? "",
            search: cSearch.text)
        .then((value) {
      if (mounted)
        setState(() {
          medicinesShow = value;
        });
    }).catchError((e) {
      showErrorsDialog(context, e);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<ResponsiveGridCol> progressWidgets =
        medicinesShow.asMap().entries.map((item) {
      dynamic medicine = item.value;
      return ResponsiveGridCol(
          lg: 4,
          xs: 12,
          md: 12,
          child: Visibility(
              visible: true,
              child: InkWell(
                onTap: () async {
                  widget.callBackBtn(medicine);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 2.0),
                  child: Card(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(medicine["SUSTANCIA"],
                                                textAlign: TextAlign.left),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              medicine["Descripción"],
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          )
                                        ],
                                      )),
                                  Flexible(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          (widget.showNormalPriceBtn == true)
                                              ? Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      '\$${medicine["PRECIO_GRUPO_III"]}',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                '\$${medicine["PRECIO_GRUPO_III"] * 2}',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          )
                                        ],
                                      ))
                                ],
                              )
                            ],
                          ),
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
          visible: false,
          child: Container(
            color: Colors.red,
            width: 40,
            height: 40,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Container(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(CustomColors.primary)),
                ),
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

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context, progressWidgets),
    );
  }

  dialogContent(BuildContext context, List<ResponsiveGridCol> progressWidgets) {
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
          hintText: "Buscar medicamento",
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
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
    return ListView(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
              margin: EdgeInsets.only(top: 5),
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
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width - 10,
                    height: MediaQuery.of(context).size.height -
                        ((widget.showManualBtn) ? 200 : 150),
                    child: Stack(
                      children: [
                        Positioned(
                            top: 0,
                            left: 0,
                            width: MediaQuery.of(context).size.width -
                                widthLeftMenu -
                                30,
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
                                        child: Container(
                                          child: searchField,
                                        ),
                                      ),
                                    ]),
                                  ]),
                            )),
                        Positioned.fill(
                            top: 80,
                            child: RefreshIndicator(
                                color: CustomColors.primary,
                                key: _refreshIndicatorKey,
                                displacement:
                                    MediaQuery.of(context).size.height * .20,
                                onRefresh: load,
                                child: SingleChildScrollView(
                                  controller: _controllerScroll,
                                  physics: (loading)
                                      ? NeverScrollableScrollPhysics()
                                      : const BouncingScrollPhysics(
                                          parent:
                                              AlwaysScrollableScrollPhysics()),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Container(
                                        constraints: BoxConstraints(
                                            minHeight: MediaQuery.of(context)
                                                .size
                                                .height,
                                            maxHeight: double.infinity),
                                        child: (medicinesShow.length <= 0)
                                            ? Center(
                                                child: Column(
                                                children: [
                                                  Text(
                                                    "No hay ningún elemento para mostrar",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18),
                                                  ),
                                                ],
                                              ))
                                            : Align(
                                                alignment: Alignment.topCenter,
                                                child: Container(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        ResponsiveGridRow(
                                                            children:
                                                                progressWidgets)
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
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  loading
                      ? Container(
                          child: Container(
                            width: 40,
                            height: 40,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 0.0),
                                child: Container(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          CustomColors.primary)),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 24.0,
                  ),
                  Container(
                    height: 50,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                              child: Text("Cancelar")),
                        ),
                      ],
                    ),
                  ),
                  (widget.showManualBtn)
                      ? Container(
                          height: 50,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: () {
                                      widget.callBackBtn(null);
                                    },
                                    child: Text("Agregar manual")),
                              ),
                            ],
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
