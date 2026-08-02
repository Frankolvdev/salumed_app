import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlumbingQuestionnaire extends StatefulWidget {
  //FONTANERÍA
  dynamic callback;
  dynamic questionnaire;
  bool onlyRead;
  bool edit;
  PlumbingQuestionnaire(
      {Key? key,
      this.callback = null,
      this.questionnaire = null,
      this.onlyRead = false,
      this.edit = false})
      : super(key: key);

  @override
  _PlumbingQuestionnaireState createState() => _PlumbingQuestionnaireState();
}

class _PlumbingQuestionnaireState extends State<PlumbingQuestionnaire> {
  final cMeters = TextEditingController();
  final cNumRadiators = TextEditingController();
  final cBoiler = TextEditingController();
  final cTypeBoiler = TextEditingController();
  final formKey = new GlobalKey<FormState>();

  List<String> works = ["", "Calefacción", "Baño", "Cocina", "Termo", "Otro"];

  List<String> materials = ["", "Cobre", "Plástico", "Wirsbo"];

  String answer1 = "";
  String answer2 = "";
  String answer3 = "";
  String answer4 = "";
  String answer5 = "";
  bool readOnly = false;
  @override
  void initState() {
    super.initState();
    readOnly = widget.onlyRead;
    if (widget.questionnaire != null) {
      Map<String, dynamic> q = widget.questionnaire;
      answer1 = q["answer1"];
      answer2 = q["answer2"];
      cMeters.text = q["answer3"];
      answer3 = q["answer4"];
      answer4 = q["answer5"];
      cNumRadiators.text = q["answer6"];
      answer5 = q["answer7"];
      cTypeBoiler.text = q["answer8"];
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

    final metersField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: cMeters,
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

    final numRadiatorsField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      controller: cNumRadiators,
      keyboardType: TextInputType.number,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration,
      onFieldSubmitted: (val) {},
    );

    final typeBolierField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cTypeBoiler,
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
                basicQuestionOptions("¿Instalación o reparación?", [
                  btnSwitch("Instalación", answer1, () {
                    answer1 = "Instalación";
                  }),
                  btnSwitch("Reparación", answer1, () {
                    answer1 = "Reparación";
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
                          child: Text("Tipo de trabajo",
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
                              items: works.map((String val) {
                                return new DropdownMenuItem(
                                    value: val,
                                    child: Text(val,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1));
                              }).toList(),
                              onChanged: (readOnly)
                                  ? null
                                  : (val) {
                                      setState(() {
                                        answer2 = val as String;
                                      });

                                      // do other stuff with _category
                                    },
                              value: answer2,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                                hintText: "Tipo de trabajo",
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
                          child: Text("Metros(m2)",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: metersField,
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
                          child: Text("Material utilizado",
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
                              items: materials.map((String val) {
                                return new DropdownMenuItem(
                                    value: val,
                                    child: Text(val,
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
                                contentPadding:
                                    EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                                hintText: "Material utilizado",
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
                (answer2 == "Baño")
                    ? basicQuestionOptions("¿Instalación de sanitarios?", [
                        btnSwitch("Sí", answer4, () {
                          answer4 = "Sí";
                        }),
                        btnSwitch("No", answer4, () {
                          answer4 = "No";
                        }),
                      ])
                    : Container(),
                (answer2 == "Calefacción")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Text("Número de radiadores",
                                  style: TextStyle(
                                      color: CustomColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: numRadiatorsField,
                            )
                          ],
                        )))
                    : Container(),
                (answer2 == "Calefacción")
                    ? basicQuestionOptions("¿Caldera o placas solares? ", [
                        btnSwitch("Caldera", answer5, () {
                          answer5 = "Caldera";
                        }),
                        btnSwitch("Placas", answer5, () {
                          answer5 = "Placas";
                        }),
                      ])
                    : Container(),
                (answer2 == "Calefacción" && answer5 == "Caldera")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Text("¿Tipo de caldera?",
                                  style: TextStyle(
                                      color: CustomColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: typeBolierField,
                            )
                          ],
                        )))
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
      showErrorsDialog(
          context, ["Debe seleccionar si es instalación o reparación"]);
      return;
    }
    ;
    if (answer2 == "") {
      showErrorsDialog(context, ["Debe seleccionar el tipo de trabajo"]);
      return;
    }
    ;
    if (answer3 == "") {
      showErrorsDialog(context, ["Debe seleccionar el material utilizado"]);
      return;
    }
    ;

    if (answer2 == "Baño" && answer4 == "") {
      showErrorsDialog(
          context, ["Debe seleccionar si es instalación de sanitarios"]);
      return;
    }
    ;

    if (answer2 == "Calefacción" && answer5 == "") {
      showErrorsDialog(
          context, ["Debe seleccionar si es caldera o placas solares"]);
      return;
    }
    ;

    if (form!.validate()) {
      form.save();
      Map<String, dynamic> q = {
        "answer1": answer1,
        "answer2": answer2,
        "answer3": cMeters.text,
        "answer4": answer3,
        "answer5": answer4,
        "answer6": cNumRadiators.text,
        "answer7": answer5,
        "answer8": cTypeBoiler.text,
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
