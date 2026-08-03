import 'package:app/components/dialog_avoid_bottom.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/budget.dart';
import 'package:app/models/order.dart';
import 'package:flutter/material.dart';

import '../pages/pharmacy_admin/parts/row_table_medicine.dart';

class TableMedicines extends StatefulWidget {
  BudgetModel budget;
  OrderModel order;
  bool isPatient;
  TableMedicines(this.budget, this.order, {Key? key, this.isPatient = false})
      : super(key: key);

  @override
  State<TableMedicines> createState() => _TableMedicinesState();
}

class _TableMedicinesState extends State<TableMedicines> {
  final topController = ScrollController();

  List<RowTableMedicine> medicines = [];

  @override
  void initState() {
    super.initState();

    BudgetModel budgetTmp = widget.budget;
    budgetTmp.medicines.forEach((element) {
      final _scaffoldKey = new GlobalKey<ScaffoldState>();

      if (widget.isPatient) {
        if (checkEmpty(element.prescription)) {
          medicines.add(RowTableMedicine(
            () {},
            element.cost ?? 0,
            element.quantity ?? 0,
            (element.medicine)! +
                " Prescripción: " +
                (element.prescription ?? ""),
            element.amount ?? 0,
            () {
              calcTotal();
            },
            {
              "medicine": (element.medicine)! +
                  " Prescripción: " +
                  (element.prescription ?? ""),
              "cost": element.cost ?? 0,
              "amount": element.amount ?? 0,
              "quantity": element.quantity ?? 0
            },
            true,
            key: _scaffoldKey,
          ));
        } else {
          medicines.add(RowTableMedicine(
            () {},
            element.cost ?? 0,
            element.quantity ?? 0,
            element.medicine ?? "",
            element.amount ?? 0,
            () {
              calcTotal();
            },
            {
              "medicine": element.medicine,
              "cost": element.cost ?? 0,
              "amount": element.amount ?? 0,
              "quantity": element.quantity ?? 0
            },
            true,
            key: _scaffoldKey,
          ));
        }
      } else {
        medicines.add(RowTableMedicine(
          () {},
          element.cost ?? 0,
          element.quantity ?? 0,
          element.medicine ?? "",
          element.amount ?? 0,
          () {
            calcTotal();
          },
          {
            "medicine": element.medicine,
            "cost": element.cost ?? 0,
            "amount": element.amount ?? 0,
            "quantity": element.quantity ?? 0
          },
          true,
          key: _scaffoldKey,
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DialogAvoidBottom(
        content: StatefulBuilder(builder: (context, setStateT) {
      return Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
            margin: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Container(
                    height: (MediaQuery.of(context).size.height * .50),
                    child: ListView(
                      children: [
                        Scrollbar(
                          controller: topController,
                          //thumbVisibility: true,
                          scrollbarOrientation: ScrollbarOrientation.bottom,
                          child: SingleChildScrollView(
                            controller: topController,
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              child: Container(
                                width: (MediaQuery.of(context).size.width >=
                                        (breakPointDesktop))
                                    ? MediaQuery.of(context).size.width - 95
                                    : 500,
                                child: getTable(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            child: Text("Cerrar")),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      );
    }));
  }

  num total = 0;

  calcTotal() {
    num totalTmp = 0;

    medicines.forEach((row) {
      totalTmp += row.values["amount"];
    });

    setState(() {
      total = totalTmp;
    });
  }

  Widget getTable() {
    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                    flex: 5,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text((widget.order.type !=
                                          "studies_without_prescription")
                                      ? "Medicamento"
                                      : "Estudio"),
                                )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text("Costo"),
                                )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text("Cántidad"),
                                )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text("Importe"),
                                )))
                      ],
                    )),
              ],
            )
          ],
        ),
        Column(
          children: medicines.asMap().entries.map((e) {
            int idx = e.key;
            RowTableMedicine row = e.value;
            return row;
          }).toList(),
        ),
        Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                    flex: 5,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 11.0, horizontal: 11.0),
                          child: Text(""),
                        )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 11.0, horizontal: 11.0),
                          child: Text(""),
                        )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text("Total"),
                                )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text(total.toString()),
                                )))
                      ],
                    )),
              ],
            )
          ],
        ),
      ],
    );
  }
}
