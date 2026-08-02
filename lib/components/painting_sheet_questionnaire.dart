import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PaintingSheetQuestionnaire extends StatefulWidget {
  dynamic callback;
  dynamic questionnaire;
  bool onlyRead;
  bool edit;
  PaintingSheetQuestionnaire(
      {Key? key,
      this.callback = null,
      this.questionnaire = null,
      this.onlyRead = false,
      this.edit = false})
      : super(key: key);

  @override
  _PaintingSheetQuestionnaireState createState() =>
      _PaintingSheetQuestionnaireState();
}

class _PaintingSheetQuestionnaireState
    extends State<PaintingSheetQuestionnaire> {
  final cYearModel = TextEditingController();
  final cCurrentColor = TextEditingController();
  final cNewColor = TextEditingController();
  final cNewTypePaint = TextEditingController();
  final cPartsToPaint = TextEditingController();

  final formKey = new GlobalKey<FormState>();

  String answer1 = "";
  String answer2 = "";

  String answer3 = "";
  String answer4 = "";

  bool readOnly = false;
  @override
  void initState() {
    super.initState();
    readOnly = widget.onlyRead;
    if (widget.questionnaire != null) {
      Map<String, dynamic> q = widget.questionnaire;

      answer1 = q["answer1"];
      answer2 = q["answer2"];

      cYearModel.text = q["answer3"];
      cCurrentColor.text = q["answer4"];
      cNewColor.text = q["answer5"];
      cNewTypePaint.text = q["answer6"];
      cPartsToPaint.text = q["answer7"];

      if (answer1 == "Moto") {
        answer3 = q["answer8"];
        answer4 = q["answer9"];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    final yearModelField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cYearModel,
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

    final currentColorField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cCurrentColor,
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

    final newColorField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cNewColor,
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

    final newTypePaintField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cNewTypePaint,
      keyboardType: TextInputType.text,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration,
      onFieldSubmitted: (val) {},
    );

    final partsToPaintField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cPartsToPaint,
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

    return ListView(
        shrinkWrap: readOnly || widget.edit,
        physics: (readOnly || widget.edit)
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
        children: [
          Form(
            key: formKey,
            child: Column(
              children: [
                basicQuestionOptions("¿Tipo de vehículo?", [
                  btnSwitch("Coche", answer1, () {
                    answer1 = "Coche";
                  }),
                  btnSwitch("Moto", answer1, () {
                    answer1 = "Moto";
                  })
                ]),
                basicQuestionOptions("¿Tipo de trabajo?", [
                  btnSwitch("Pintura", answer2, () {
                    answer2 = "Pintura";
                  }),
                  btnSwitch("Arreglo y pintura", answer2, () {
                    answer2 = "Arreglo y pintura";
                  }),
                ]),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("Modelo y año",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: yearModelField,
                        )
                      ],
                    ))),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("¿Que color está pintado?",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: currentColorField,
                        )
                      ],
                    ))),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("¿Que color quiere pintarlo?",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: newColorField,
                        )
                      ],
                    ))),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("¿Que tipo de pintura quiere?",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: newTypePaintField,
                        )
                      ],
                    ))),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("¿Piezas a pintar y/o hacer arreglo?",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: partsToPaintField,
                        )
                      ],
                    ))),
                (answer1 == "Moto")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                child: Text("¿Necesitas arenar las piezas?",
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
                                    icon: (readOnly)
                                        ? Container()
                                        : Icon(
                                            Icons.keyboard_arrow_down_outlined,
                                            color: Colors.grey,
                                          ),
                                    iconSize: 42,
                                    items: [
                                      "",
                                      "Si",
                                      "No",
                                      "Solo algunas piezas",
                                      "No sé"
                                    ].map((String type) {
                                      return new DropdownMenuItem(
                                          value: type,
                                          child: Text(type,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1));
                                    }).toList(),
                                    onChanged: (readOnly)
                                        ? null
                                        : (val) {
                                            setState(() {
                                              answer3 = val as String;
                                            });

                                            // do other stuff with _category
                                          },
                                    value: answer3,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(
                                          16.0, 0.0, 0.0, 0.0),
                                      hintText: "¿Necesitas arenar las piezas?",
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 14),
                                      fillColor: Colors.white,
                                      focusColor: Colors.grey,
                                      hoverColor: Colors.grey,
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.red.shade300,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.red.shade300,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                (answer1 == "Moto")
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
                                    "¿Necesitas pintura resistente a la temperatura?",
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
                                    icon: (readOnly)
                                        ? Container()
                                        : Icon(
                                            Icons.keyboard_arrow_down_outlined,
                                            color: Colors.grey,
                                          ),
                                    iconSize: 42,
                                    items: [
                                      "",
                                      "Si",
                                      "No",
                                      "Solo algunas piezas",
                                      "No sé"
                                    ].map((String type) {
                                      return new DropdownMenuItem(
                                          value: type,
                                          child: Text(type,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1));
                                    }).toList(),
                                    onChanged: (readOnly)
                                        ? null
                                        : (val) {
                                            setState(() {
                                              answer4 = val as String;
                                            });

                                            // do other stuff with _category
                                          },
                                    value: answer4,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(
                                          16.0, 0.0, 0.0, 0.0),
                                      hintText:
                                          "¿Necesitas pintura resistente a la temperatura?",
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 14),
                                      fillColor: Colors.white,
                                      focusColor: Colors.grey,
                                      hoverColor: Colors.grey,
                                      filled: true,
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.red.shade300,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.red.shade300,
                                              width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(6.0)),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                Visibility(
                  visible: readOnly == false && widget.edit == false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * .10,
                        vertical: 15),
                    child: ButtonTheme(
                      minWidth: 230.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primary,
                            padding:
                                EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide.none,
                            )),
                        child: Row(
                          // Replace with a Row for horizontal icon + text

                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              "Siguiente",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(FontAwesomeIcons.arrowRight,
                                    size: 12, color: Colors.white)),
                          ],
                        ),
                        onPressed: () {
                          next();
                        },
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.edit,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * .10,
                        vertical: 15),
                    child: ButtonTheme(
                      minWidth: 230.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColors.primary,
                            padding:
                                EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              side: BorderSide.none,
                            )),
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
                                "Guardar cuestionarios",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
              ],
            ),
          )
        ]);
  }

  next() {
    final form = formKey.currentState;
    List<String> errors = [];

    if (answer1 == "") {
      showErrorsDialog(context, ["Debe seleccionar el tipo de vehiculo"]);
      return;
    }
    ;
    if (answer2 == "") {
      showErrorsDialog(context, ["Debe seleccionar el tipo de trabajo"]);
      return;
    }
    ;
    if (answer1 == "Moto" && answer3 == "") {
      showErrorsDialog(
          context, ["Debe seleccionar si necesita arenar las piezas"]);
      return;
    }
    ;
    if (answer1 == "Moto" && answer4 == "") {
      showErrorsDialog(context,
          ["Debe seleccionar si necesita pintura resistente a la temperatura"]);
      return;
    }
    ;

    if (form!.validate()) {
      form.save();

      Map<String, dynamic> q = {
        "answer1": answer1,
        "answer2": answer2,
        "answer3": cYearModel.text,
        "answer4": cCurrentColor.text,
        "answer5": cNewColor.text,
        "answer6": cNewTypePaint.text,
        "answer7": cPartsToPaint.text,
        "answer8": answer3,
        "answer9": answer4,
      };

      widget.callback(q);
    }
  }

  Widget basicQuestionOptions(String text, List<Widget> optionBtns) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Text(text,
                  style: TextStyle(
                      color: CustomColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: optionBtns,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget btnSwitch(String text, dynamic answer, Function callback) {
    bool status = (answer == text);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: status ? CustomColors.primary : Colors.grey.shade100,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.all(0)),
        onPressed: () {
          setState(() {
            if (!readOnly) callback();
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            text,
            style: TextStyle(
                color: status ? Colors.white : Colors.grey, fontSize: 12.0),
          ),
        ),
      ),
    );
  }
}
