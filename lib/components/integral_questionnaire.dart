import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IntegralQuestionnaire extends StatefulWidget {
  dynamic callback;
  dynamic questionnaire;
  bool onlyRead;
  bool edit;
  IntegralQuestionnaire(
      {Key? key,
      this.callback = null,
      this.questionnaire = null,
      this.onlyRead = false,
      this.edit = false})
      : super(key: key);

  @override
  _IntegralQuestionnaireState createState() => _IntegralQuestionnaireState();
}

class _IntegralQuestionnaireState extends State<IntegralQuestionnaire> {
  final cSub = TextEditingController();

  final cMetters = TextEditingController();

  final formKey = new GlobalKey<FormState>();

  final cMettersPaper = TextEditingController();

  List<String> reform = ["", "Baño", "Cocina", "Total", "Otro"];

  String answer1 = "";
  List<dynamic> answer2 = [];

  String answer3 = "";
  String answer4 = "";
  String answer5 = "";

  String answer6 = "";

  bool readOnly = false;
  @override
  void initState() {
    super.initState();
    readOnly = widget.onlyRead;
    if (widget.questionnaire != null) {
      Map<String, dynamic> q = widget.questionnaire;

      answer1 = q["answer1"];
      answer2 = q["answer2"];
      cSub.text = answer2.join(", ");

      cMetters.text = q["answer3"];
      answer3 = q["answer3"];
      answer4 = q["answer4"];
      answer5 = q["answer5"];
      answer6 = q["answer6"];
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
    final subField = TextFormField(
      readOnly: true,
      textInputAction: TextInputAction.next,
      controller: cSub,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration,
      onTap: () {
        if (!readOnly) selectSub();
      },
    );

    final mettersField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: cMetters,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("Reforma",
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
                              items: reform.map((String type) {
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
                                        answer1 = val as String;
                                      });

                                      // do other stuff with _category
                                    },
                              value: answer1,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                                hintText: "Reforma",
                                hintStyle: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 14),
                                fillColor: Colors.white,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                filled: true,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0),
                                    borderRadius: BorderRadius.circular(6.0)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0),
                                    borderRadius: BorderRadius.circular(6.0)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1.0),
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
                            )),
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("¿Qué necesitas?",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: subField,
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
                          child: Text("Metros(m2)",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: mettersField,
                        )
                      ],
                    ))),
                (answer1 == "Baño")
                    ? basicQuestionOptions("¿Cambio de bañera o ducha?", [
                        btnSwitch("Sí", answer4, () {
                          answer4 = "Sí";
                        }),
                        btnSwitch("No", answer4, () {
                          answer4 = "No";
                        }),
                      ])
                    : Container(),
                (answer1 == "Baño")
                    ? basicQuestionOptions(
                        "¿Quieres incluir los sanitarios en el presupuesto?", [
                        btnSwitch("Sí", answer5, () {
                          answer5 = "Sí";
                        }),
                        btnSwitch("No", answer5, () {
                          answer5 = "No";
                        }),
                      ])
                    : Container(),
                (answer5 == "Sí" && answer1 == "Baño")
                    ? basicQuestionOptions("Calidad de sanitarios ", [
                        btnSwitch("Baja", answer6, () {
                          answer6 = "Baja";
                        }),
                        btnSwitch("Media", answer6, () {
                          answer6 = "Media";
                        }),
                        btnSwitch("Alta", answer6, () {
                          answer6 = "Alta";
                        }),
                      ])
                    : Container(),
                Visibility(
                  visible: readOnly == false && widget.edit == false,
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
      showErrorsDialog(context, ["Debe seleccionar el tipo de reforma"]);
      return;
    }
    ;
    if (answer2.length <= 0) {
      showErrorsDialog(context, ["Debe responder la pregunta ¿Qué necesitas?"]);
      return;
    }
    ;
    if (cMetters.text == "") {
      showErrorsDialog(context, ["Debe ingresar los m2"]);
      return;
    }
    ;

    if (answer1 == "Baño") {
      if (answer4 == "") {
        showErrorsDialog(
            context, ["Debe seleccionar si es cambio de bañera o ducha"]);
        return;
      }
      ;

      if (answer5 == "") {
        showErrorsDialog(context, [
          "Debe seleccionar si quieres incluir los sanitarios en el presupuesto"
        ]);
        return;
      }
      ;
      if (answer5 == "Sí") {
        if (answer6 == "") {
          showErrorsDialog(
              context, ["Debe seleccionar la calidad de sanitarios"]);
          return;
        }
        ;
      }
    }

    if (form!.validate()) {
      form.save();

      Map<String, dynamic> q = {
        "answer1": answer1,
        "answer2": answer2,
        "answer3": cMetters.text,
        "answer4": answer4,
        "answer5": answer5,
        "answer6": answer6
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
            backgroundColor: status ? CustomColors.primary : Colors.grey.shade100,
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

  var itemsNeed = [
    "Albañilería",
    "Fontanería",
    "Alicatado",
    "Electricidad",
    "Parquet",
    "Otro"
  ];

  selectSub() {
    late StateSetter _setState;
    showDialog<void>(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext contextd) {
        return StatefulBuilder(builder: (context, setStateD) {
          _setState = setState;
          return Dialog(
            insetPadding:
                getDialogInsetPaddin(context, customEdge: EdgeInsets.all(12.0)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Material(
              child: Container(
                  height: 400,
                  child: ListView(children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: itemsNeed
                          .where((element) => element.trim() != "")
                          .toList()
                          .asMap()
                          .entries
                          .map((e) {
                        return InkWell(
                          onTap: () {
                            addRemoveSub(setStateD, e.value);
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                      checkColor: Colors.white,
                                      fillColor:
                                          MaterialStateProperty.resolveWith(
                                              getColor),
                                      value: answer2.contains(e.value),
                                      onChanged: (value) {
                                        addRemoveSub(setStateD, e.value);
                                      }),
                                ),
                                Flexible(child: Text(e.value))
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 15.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 2,
                            backgroundColor: CustomColors.primary,
                            shape: StadiumBorder()),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 35.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Aceptar",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ])),
            ),
          );
        });
      },
    );
  }

  addRemoveSub(StateSetter setStateD, String value) {
    if (answer2.contains(value)) {
      setState(() {
        answer2.removeWhere((element) => element == value);
      });
      setStateD(() {});
    } else {
      setState(() {
        answer2.add(value);
      });
      setStateD(() {});
    }

    cSub.text = answer2.join(", ");
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
}
