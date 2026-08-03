import 'dart:convert';

import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:snack/snack.dart';

class ClientPressureSigarRecord extends StatefulWidget {
  UserModel user;
  ClientPressureSigarRecord(this.user, {Key? key}) : super(key: key);

  @override
  State<ClientPressureSigarRecord> createState() =>
      _ClientPressureSigarRecordState();
}

class _ClientPressureSigarRecordState extends State<ClientPressureSigarRecord> {
  List<Widget> widgetsTable = [];
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      simpleLoading(context, (BuildContext loading) {
        widgetsTable.add(Column(
          children: [
            dayTable(1),
            dayTable(2),
            dayTable(3),
            dayTable(4),
            dayTable(5),
            dayTable(6),
            dayTable(7),
          ],
        ));
        setState(() {});
        setValues(provider.user.records_pressure_sugar ?? []);
        bool full = checkFull();
        if (full) {
          calcProm();
        }
        Navigator.pop(loading);
      });
    });
  }

  setValues(List<dynamic> records_pressure_sugar) {
    for (var i = 1; i < 8; i++) {
      records_pressure_sugar.forEach((element) {
        if ((element
            .containsKey("controller_pressure_day_${i}_part1_record_1"))) {
          records.forEach((elementTmp) {
            if (elementTmp
                .containsKey("controller_pressure_day_${i}_part1_record_1")) {
              elementTmp["controller_pressure_day_${i}_part1_record_1"].text =
                  element["controller_pressure_day_${i}_part1_record_1"];
              elementTmp["controller_pressure_day_${i}_part2_record_1"].text =
                  element["controller_pressure_day_${i}_part2_record_1"];
              elementTmp["controller_sugar_day_${i}_record_1"].text =
                  element["controller_sugar_day_${i}_record_1"];
            }
          });
        } else if ((element
            .containsKey("controller_pressure_day_${i}_part1_record_2"))) {
          records.forEach((elementTmp) {
            if (elementTmp
                .containsKey("controller_pressure_day_${i}_part1_record_2")) {
              elementTmp["controller_pressure_day_${i}_part1_record_2"].text =
                  element["controller_pressure_day_${i}_part1_record_2"];
              elementTmp["controller_pressure_day_${i}_part2_record_2"].text =
                  element["controller_pressure_day_${i}_part2_record_2"];
              elementTmp["controller_sugar_day_${i}_record_2"].text =
                  element["controller_sugar_day_${i}_record_2"];
            }
          });
        } else if ((element
            .containsKey("controller_pressure_day_${i}_part1_record_3"))) {
          records.forEach((elementTmp) {
            if (elementTmp
                .containsKey("controller_pressure_day_${i}_part1_record_3")) {
              elementTmp["controller_pressure_day_${i}_part1_record_3"].text =
                  element["controller_pressure_day_${i}_part1_record_3"];
              elementTmp["controller_pressure_day_${i}_part2_record_3"].text =
                  element["controller_pressure_day_${i}_part2_record_3"];
              elementTmp["controller_sugar_day_${i}_record_3"].text =
                  element["controller_sugar_day_${i}_record_3"];
            }
          });
        }
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ButtonTheme(
        minWidth: 100.0,
        child: MaterialButton(
          color: CustomColors.primary,
          padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
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
                  child: FaIcon(FontAwesomeIcons.save,
                      size: 12, color: Colors.white)),
              Flexible(
                child: Text(
                  "Guardar",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          onPressed: () {
            save();
          },
        ),
      ),
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
      body: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: ListView(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  constraints:
                      kIsWeb ? BoxConstraints(maxWidth: 600) : BoxConstraints(),
                  child: Column(
                    children: [
                      Text("Registro de presión arterial y glucosa",
                          style: TextStyle(
                            color: CustomColors.primary,
                            fontSize: 18.0,
                          )),
                      ResponsiveGridRow(children: [
                        ResponsiveGridCol(
                            lg: (checkFullStatus) ? 6 : 12,
                            xs: (checkFullStatus) ? 6 : 12,
                            md: (checkFullStatus) ? 6 : 12,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ButtonTheme(
                                minWidth: 100.0,
                                child: MaterialButton(
                                  color: CustomColors.primary,
                                  padding: EdgeInsets.fromLTRB(
                                      10.0, 10.0, 10.0, 10.0),
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
                                          child: FaIcon(FontAwesomeIcons.save,
                                              size: 12, color: Colors.white)),
                                      Flexible(
                                        child: Text(
                                          "Guardar",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    save();
                                  },
                                ),
                              ),
                            )),
                        ResponsiveGridCol(
                            lg: (checkFullStatus) ? 6 : 0,
                            xs: (checkFullStatus) ? 6 : 0,
                            md: (checkFullStatus) ? 6 : 0,
                            child: (checkFullStatus)
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ButtonTheme(
                                      minWidth: 100.0,
                                      child: MaterialButton(
                                        color: CustomColors.primary,
                                        padding: EdgeInsets.fromLTRB(
                                            10.0, 10.0, 10.0, 10.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          side: BorderSide.none,
                                        ),
                                        child: Row(
                                          // Replace with a Row for horizontal icon + text

                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(right: 8),
                                                child: FaIcon(FontAwesomeIcons.eraser,
                                                    size: 12,
                                                    color: Colors.white)),
                                            Flexible(
                                              child: Text(
                                                "Limpiar",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        onPressed: () {
                                          clean();
                                        },
                                      ),
                                    ),
                                  )
                                : Container())
                      ]),
                      Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(0),
                            border: Border.all(
                              color: Colors
                                  .grey, //                   <--- border color
                              width: 1.0,
                            ),
                          ),
                          child: (widgetsTable.length > 0)
                              ? Column(
                                  children: [widgetsTable[0], averageTable()],
                                )
                              : Container()),
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

  save() {
    simpleLoading(context, (BuildContext loadingContext) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      try {
        UserModel userUpdated = await WebService(context).saveRecords(
            jsonEncode(getResult()).toString(), provider.user.token ?? "");

        await provider.setUser(userUpdated);

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

  clean() {
    for (var day = 1; day < 8; day++) {
      records.forEach((element) {
        for (var record = 1; record < 4; record++) {
          if (element.containsKey(
              "controller_pressure_day_${day}_part1_record_${record}")) {
            element["controller_pressure_day_${day}_part1_record_${record}"]
                .text = "";

            element["controller_pressure_day_${day}_part2_record_${record}"]
                .text = "";
            element["controller_sugar_day_${day}_record_${record}"].text = "";
          }
        }
      });
    }
    setState(() {});
    save();
  }

  Widget dayTable(int day) {
    return Column(
      children: [
        ResponsiveGridRow(children: [
          ResponsiveGridCol(
              lg: 12,
              xs: 12,
              md: 12,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                    color: Colors.grey, //                   <--- border color
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: Text("Día ${day}")),
                ),
              )),
        ]),
        ResponsiveGridRow(children: [
          ResponsiveGridCol(
              lg: 6,
              xs: 6,
              md: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: CustomColors.primary,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                    color: Colors.grey, //                   <--- border color
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text(
                    "Presión",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
              )),
          ResponsiveGridCol(
              lg: 6,
              xs: 6,
              md: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: CustomColors.primary,
                  borderRadius: BorderRadius.circular(0),
                  border: Border.all(
                    color: Colors.grey, //                   <--- border color
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Text("Glucosa",
                          style: TextStyle(color: Colors.white))),
                ),
              )),
        ]),
        recordTable(day, 1),
        recordTable(day, 2),
        recordTable(day, 3),
      ],
    );
  }

  List<dynamic> records = [];
  List<dynamic> recordsValues = [];

  Widget averageTable() {
    return Column(children: [
      ResponsiveGridRow(children: [
        ResponsiveGridCol(
            lg: 12,
            xs: 12,
            md: 12,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                border: Border.all(
                  color: Colors.grey, //                   <--- border color
                  width: 1.0,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text("Promedio de 7 días")),
              ),
            )),
      ]),
      ResponsiveGridRow(children: [
        ResponsiveGridCol(
            lg: 6,
            xs: 6,
            md: 6,
            child: Container(
              decoration: BoxDecoration(
                color: CustomColors.primary,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(
                  color: Colors.grey, //                   <--- border color
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Text(
                  "Presión",
                  style: TextStyle(color: Colors.white),
                )),
              ),
            )),
        ResponsiveGridCol(
            lg: 6,
            xs: 6,
            md: 6,
            child: Container(
              decoration: BoxDecoration(
                color: CustomColors.primary,
                borderRadius: BorderRadius.circular(0),
                border: Border.all(
                  color: Colors.grey, //                   <--- border color
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child:
                        Text("Glucosa", style: TextStyle(color: Colors.white))),
              ),
            )),
      ]),
      (checkFullStatus)
          ? ResponsiveGridRow(children: [
              ResponsiveGridCol(
                  lg: 6,
                  xs: 6,
                  md: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color:
                            Colors.grey, //                   <--- border color
                        width: 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        "${promPressureMax}/${promPressureMin}",
                        style: TextStyle(color: CustomColors.primary),
                      )),
                    ),
                  )),
              ResponsiveGridCol(
                  lg: 6,
                  xs: 6,
                  md: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color:
                            Colors.grey, //                   <--- border color
                        width: 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text("${promSugar}",
                              style: TextStyle(color: CustomColors.primary))),
                    ),
                  )),
            ])
          : ResponsiveGridRow(children: [
              ResponsiveGridCol(
                  lg: 12,
                  xs: 12,
                  md: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      border: Border.all(
                        color:
                            Colors.grey, //                   <--- border color
                        width: 0.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                        "Agregue un registro de glucosa y presión en cada uno de los 7 días para calcular el promedio",
                        style: TextStyle(
                            color: CustomColors.primary,
                            fontWeight: FontWeight.bold),
                      )),
                    ),
                  ))
            ])
    ]);
  }

  bool checkFullStatus = false;
  Widget recordTable(int day, int record) {
    final pressure = TextEditingController();
    final pressure2 = TextEditingController();
    final sugar = TextEditingController();
    InputDecoration decoration = InputDecoration(
      contentPadding: EdgeInsets.all(2.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide(
          color: Colors.transparent,
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide(
          color: Colors.transparent,
          width: 0.5,
        ),
      ),
    );
    records.add({
      "controller_pressure_day_${day}_part1_record_${record}": pressure,
      "controller_pressure_day_${day}_part2_record_${record}": pressure2,
      "controller_sugar_day_${day}_record_${record}": sugar
    });

    return Container(
        child: ResponsiveGridRow(children: [
      ResponsiveGridCol(
          lg: 5,
          xs: 5,
          md: 5,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: TextFormField(
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                  readOnly: false,
                  onEditingComplete: () {},
                  onChanged: (val) {
                    bool full = checkFull();
                    if (full) {
                      calcProm();
                    } else {
                      setState(() {
                        promPressureMax = 0;
                        promPressureMin = 0;
                        promSugar = 0;
                        showProm = false;
                      });
                    }
                  },
                  controller: pressure,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    return requiredField(val ?? 0, context);
                  },
                  obscureText: false,
                  style: TextStyle(fontSize: 14.0),
                  //initialValue: Environment.localUsername(),
                  decoration: decoration,
                  onFieldSubmitted: (val) {},
                ),
              ),
              Flexible(child: Container(width: 6, child: Text("/"))),
              Expanded(
                child: TextFormField(
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.next,
                  readOnly: false,
                  onChanged: (val) {
                    bool full = checkFull();
                    if (full) {
                      calcProm();
                    } else {
                      setState(() {
                        promPressureMax = 0;
                        promPressureMin = 0;
                        promSugar = 0;
                        showProm = false;
                      });
                    }
                  },
                  controller: pressure2,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    return requiredField(val ?? 0, context);
                  },
                  obscureText: false,
                  style: TextStyle(fontSize: 14.0),
                  //initialValue: Environment.localUsername(),
                  decoration: decoration,
                  onFieldSubmitted: (val) {},
                ),
              ),
            ],
          )),
      ResponsiveGridCol(
          lg: 2,
          xs: 2,
          md: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: Colors.grey,
                width: 1,
                height: 40,
              )
            ],
          )),
      ResponsiveGridCol(
          lg: 5,
          xs: 5,
          md: 5,
          child: Container(
            child: TextFormField(
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.next,
              readOnly: false,
              onChanged: (val) {
                bool full = checkFull();
                if (full) {
                  calcProm();
                } else {
                  setState(() {
                    promPressureMax = 0;
                    promPressureMin = 0;
                    promSugar = 0;
                    showProm = false;
                  });
                }
              },
              controller: sugar,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (val) {
                return requiredField(val ?? 0, context);
              },
              obscureText: false,
              style: TextStyle(fontSize: 14.0),
              //initialValue: Environment.localUsername(),
              decoration: decoration.copyWith(labelText: ""),
              onFieldSubmitted: (val) {},
            ),
          )),
      ResponsiveGridCol(
          lg: 12,
          xs: 12,
          md: 12,
          child: Container(
            color: Colors.grey,
            height: 1,
          )),
    ]));
  }

  bool showProm = false;

  List<dynamic> getResult() {
    List<dynamic> tmpResults = [];

    for (var i = 1; i < 8; i++) {
      records.forEach((element) {
        if ((element
            .containsKey("controller_pressure_day_${i}_part1_record_1"))) {
          tmpResults.add({
            "controller_pressure_day_${i}_part1_record_1":
                element["controller_pressure_day_${i}_part1_record_1"].text,
            "controller_pressure_day_${i}_part2_record_1":
                element["controller_pressure_day_${i}_part2_record_1"].text,
            "controller_sugar_day_${i}_record_1":
                element["controller_sugar_day_${i}_record_1"].text,
          });
        } else if ((element
            .containsKey("controller_pressure_day_${i}_part1_record_2"))) {
          tmpResults.add({
            "controller_pressure_day_${i}_part1_record_2":
                element["controller_pressure_day_${i}_part1_record_2"].text,
            "controller_pressure_day_${i}_part2_record_2":
                element["controller_pressure_day_${i}_part2_record_2"].text,
            "controller_sugar_day_${i}_record_2":
                element["controller_sugar_day_${i}_record_2"].text,
          });
        } else if ((element
            .containsKey("controller_pressure_day_${i}_part1_record_3"))) {
          tmpResults.add({
            "controller_pressure_day_${i}_part1_record_3":
                element["controller_pressure_day_${i}_part1_record_3"].text,
            "controller_pressure_day_${i}_part2_record_3":
                element["controller_pressure_day_${i}_part2_record_3"].text,
            "controller_sugar_day_${i}_record_3":
                element["controller_sugar_day_${i}_record_3"].text,
          });
        }
      });
    }

    return tmpResults;
  }

  bool checkFull() {
    var flag = true;
    var flag2 = true;
    var flag3 = true;
    for (var i = 1; i < 8; i++) {
      records.forEach((element) {
        if ((element
            .containsKey("controller_pressure_day_${i}_part1_record_1"))) {
          if (checkEmptyCtrl(
                      element["controller_pressure_day_${i}_part1_record_1"]) ==
                  false ||
              checkEmptyCtrl(
                      element["controller_pressure_day_${i}_part2_record_1"]) ==
                  false ||
              checkEmptyCtrl(element["controller_sugar_day_${i}_record_1"]) ==
                  false) {
            flag = false;
          }
        }
        if ((element
            .containsKey("controller_pressure_day_${i}_part1_record_2"))) {
          if (checkEmptyCtrl(
                      element["controller_pressure_day_${i}_part1_record_2"]) ==
                  false ||
              checkEmptyCtrl(
                      element["controller_pressure_day_${i}_part2_record_2"]) ==
                  false ||
              checkEmptyCtrl(element["controller_sugar_day_${i}_record_2"]) ==
                  false) {
            flag2 = false;
          }
        }

        if ((element
            .containsKey("controller_pressure_day_${i}_part1_record_3"))) {
          if (checkEmptyCtrl(
                      element["controller_pressure_day_${i}_part1_record_3"]) ==
                  false ||
              checkEmptyCtrl(
                      element["controller_pressure_day_${i}_part2_record_3"]) ==
                  false ||
              checkEmptyCtrl(element["controller_sugar_day_${i}_record_3"]) ==
                  false) {
            flag3 = false;
          }
        }
      });
    }
    bool result = false;
    if (flag || flag2 || flag3) {
      result = true;
    } else {
      result = false;
    }
    setState(() {
      checkFullStatus = result;
    });
    return result;
  }

  num promPressureMin = 0;
  num promPressureMax = 0;
  num promSugar = 0;
  calcProm() {
    print("ENTRE A CALCULAR PROMEDIIO");
    num promPressureMinSum = 0;
    num promPressureMaxSum = 0;
    num promSugarSum = 0;

    for (var i = 1; i < 8; i++) {
      for (var r = 1; r < 4; r++) {
        records.forEach((element) {
          if (element
              .containsKey("controller_pressure_day_${i}_part1_record_${r}")) {
            promPressureMinSum += (checkEmptyCtrl(
                    element["controller_pressure_day_${i}_part1_record_${r}"]))
                ? double.parse(
                    element["controller_pressure_day_${i}_part1_record_${r}"]
                        .text)
                : 0;
            promPressureMaxSum += (checkEmptyCtrl(
                    element["controller_pressure_day_${i}_part2_record_${r}"]))
                ? double.parse(
                    element["controller_pressure_day_${i}_part2_record_${r}"]
                        .text)
                : 0;
            promSugarSum += (checkEmptyCtrl(
                    element["controller_sugar_day_${i}_record_${r}"]))
                ? double.parse(
                    element["controller_sugar_day_${i}_record_${r}"].text)
                : 0;
          }
        });
      }
    }

    setState(() {
      promPressureMin = (promPressureMinSum / 21).toInt();
      promPressureMax = (promPressureMaxSum / 21).toInt();
      promSugar = (promSugarSum / 21).toInt();
      showProm = true;
    });
    print("promedio promPressureMin: ");
    print(promPressureMin);
  }

  bool checkEmptyCtrl(TextEditingController ctrl) {
    bool flag = false;
    dynamic val = ctrl.text;
    print("este es el val ");
    print(val);
    if (val != null) {
      if (isNumeric(val)) {
        flag = true;
      }
    }
    return flag;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}

