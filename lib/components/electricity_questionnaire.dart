import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ElectricityQuestionnaire extends StatefulWidget {
  dynamic callback;
  dynamic questionnaire;
  bool onlyRead;
  bool edit;
  ElectricityQuestionnaire(
      {Key? key,
      this.callback = null,
      this.questionnaire = null,
      this.onlyRead = false,
      this.edit = false})
      : super(key: key);

  @override
  _ElectricityQuestionnaireState createState() =>
      _ElectricityQuestionnaireState();
}

class _ElectricityQuestionnaireState extends State<ElectricityQuestionnaire> {
  final cMeters = TextEditingController();
  final cNumTakes = TextEditingController();
  final cNumSwitches = TextEditingController();

  final formKey = new GlobalKey<FormState>();

  String answer1 = "";
  String answer2 = "";
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

      answer6 = q["answer1"];
      cMeters.text = q["answer2"];
      cNumTakes.text = q["answer3"];
      cNumSwitches.text = q["answer4"];
      answer1 = q["answer5"];
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
                basicQuestionOptions(
                    "¿Instalación entera o cambiar mecanismos?", [
                  btnSwitch("Instalación", answer6, () {
                    answer6 = "Instalación";
                  }),
                  btnSwitch("Cambio", answer6, () {
                    answer6 = "Cambio";
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
                          child: Text("Metros(m2) de la vivienda",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
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
                          child: Text("Número de tomas",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
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
                          child: Text("Número de interruptores",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
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
                          child: Text("Tipo mecanismo",
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
                                "Básico",
                                "Calidad media",
                                "Calidad alta"
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
                                        answer1 = val as String;
                                      });

                                      // do other stuff with _category
                                    },
                              value: answer1,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                                hintText: "Tipo mecanismo ",
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
    if (answer6 == "") {
      showErrorsDialog(
          context, ["Debe seleccionar si es instalación o cambio"]);
      return;
    }
    ;
    if (answer1 == "") {
      showErrorsDialog(context, ["Debe seleccionar el tipo de mecanismo"]);
      return;
    }
    ;
    if (form!.validate()) {
      form.save();

      Map<String, dynamic> q = {
        "answer1": answer6,
        "answer2": cMeters.text,
        "answer3": cNumTakes.text,
        "answer4": cNumSwitches.text,
        "answer5": answer1,
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

  Widget btnSwitch(String text, dynamic answer5, Function callback) {
    bool status = (answer5 == text);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(100, 10),
            fixedSize: Size(100, 25),
            backgroundColor: status ? CustomColors.primary : Colors.grey.shade100,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.all(0)),
        onPressed: () {
          setState(() {
            if (!readOnly) callback();
          });
        },
        child: Text(
          text,
          style: TextStyle(
              color: status ? Colors.white : Colors.grey, fontSize: 12.0),
        ),
      ),
    );
  }
}
