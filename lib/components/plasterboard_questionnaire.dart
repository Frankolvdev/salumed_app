import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlasterboardQuestionnaire extends StatefulWidget {
  dynamic callback;
  dynamic questionnaire;
  bool onlyRead;
  bool edit;
  PlasterboardQuestionnaire(
      {Key? key,
      this.callback = null,
      this.questionnaire = null,
      this.onlyRead = false,
      this.edit = false})
      : super(key: key);

  @override
  _PlasterboardQuestionnaireState createState() =>
      _PlasterboardQuestionnaireState();
}

class _PlasterboardQuestionnaireState extends State<PlasterboardQuestionnaire> {
  final cWhere = TextEditingController();
  final cMeters = TextEditingController();

  final formKey = new GlobalKey<FormState>();

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
      cWhere.text = q["answer2"];
      answer2 = q["answer3"];
      answer3 = q["answer4"];

      cMeters.text = q["answer5"];
      answer4 = q["answer6"];
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

    final whereField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cWhere,
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
                          child: Text("¿Qué tipo de pladur necesitas?",
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
                                "Normal",
                                "Resistente humedad(baño/cocina)"
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
                                hintText: "¿Qué tipo de pladur necesitas?",
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
                          child: Text(
                              "¿Dónde lo quieres? (paredes, techo creación de paredes, etc)",
                              style: TextStyle(
                                  color: CustomColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: whereField,
                        )
                      ],
                    ))),
                /*    Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Text("Rango de precio euro/m2",
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
                          icon:(readOnly)?Container(): Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: Colors.grey,
                          ),
                          iconSize: 42,
                          items: [
                            "",
                            "Menos de 10",
                            "10-15",
                            "15-20",
                            "20-25",
                            "25-30",
                            "30-35",
                            "más de 35"
                          ].map((String type) {
                            return new DropdownMenuItem(
                                value: type,
                                child: Text(type,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1));
                          }).toList(),
                          onChanged: (readOnly)?null: (val) {
                            setState(() {
                              answer4 = val as String;
                            });

                            // do other stuff with _category
                          },
                          value: answer4,
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                            hintText: "Rango de precio euro/m2",
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
                        )),
                  ],
                ),
              ),
            ),*/
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: Text("Grosor del pladur (mm)",
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
                                "6 mm",
                                "9.5 mm",
                                "12.5 mm",
                                "15 mm",
                                "18 mm",
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
                                        answer2 = val as String;
                                      });

                                      // do other stuff with _category
                                    },
                              value: answer2,
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                                hintText: "Grosor del pladur (mm)",
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
                basicQuestionOptions("¿Necesitas aislamiento acústico?", [
                  btnSwitch("Sí", answer3, () {
                    answer3 = "Sí";
                  }),
                  btnSwitch("No", answer3, () {
                    answer3 = "No";
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
          context, ["Debe seleccionar el tipo de pladur que necesitas"]);
      return;
    }
    ;
    if (answer2 == "") {
      showErrorsDialog(context, ["Debe seleccionar el grosor de pladur"]);
      return;
    }
    ;
    if (answer3 == "") {
      showErrorsDialog(
          context, ["Debe seleccionar si necesita aislamiento acústico"]);
      return;
    }
    ;
    //if (answer4 == "") {showErrorsDialog(context, ["Debe seleccionar el rango de precio euro/m2"]);return;};

    if (form!.validate()) {
      form.save();
      Map<String, dynamic> q = {
        "answer1": answer1,
        "answer2": cWhere.text,
        "answer3": answer2,
        "answer4": answer3,
        "answer5": cMeters.text,
        "answer6": answer4
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
