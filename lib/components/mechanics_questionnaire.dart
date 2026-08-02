import 'package:app/components/preview_asset_image.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';

class MechanicsQuestionnaire extends StatefulWidget {
  dynamic callback;
  dynamic questionnaire;
  bool onlyRead;
  bool edit;
  MechanicsQuestionnaire(
      {Key? key,
      this.callback = null,
      this.questionnaire = null,
      this.onlyRead = false,
      this.edit = false})
      : super(key: key);

  @override
  _MechanicsQuestionnaireState createState() => _MechanicsQuestionnaireState();
}

class _MechanicsQuestionnaireState extends State<MechanicsQuestionnaire> {
  final formKey = new GlobalKey<FormState>();

  final cModelYear = TextEditingController();
  final cTypeMotorCode = TextEditingController();
  final cNumBastidor = TextEditingController();
  final cTireMeasure = TextEditingController();

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
      answer1 = q["answer1"] ?? "";
      answer2 = q["answer2"];
      cModelYear.text = q["answer3"];
      cTypeMotorCode.text = q["answer4"];
      cNumBastidor.text = q["answer5"];
      cTireMeasure.text = q["answer6"];
      answer3 = q["answer7"];
      answer6 = q["answer8"];
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

    final modelYearField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cModelYear,
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

    final typeMotorCodeField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cTypeMotorCode,
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

    final numBastidorField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cNumBastidor,
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

    final tireMeasureField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cTireMeasure,
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

    List<String> changes = [""];

    if (answer1 == "Coche") changes.add("Kit de distribución");
    changes.add("Frenos");
    changes.add("Neumáticos");

    changes.add("Cambio de aceite/filtros");

    changes.add("Batería");
    changes.add("Bombillas");
    if (answer1 == "Coche") changes.add("Recarga de aire acondicionado");
    changes.add("Solo diagnosis");
    if (answer1 == "Moto")
      changes.add("kit de arrastre(cadena,piñón y corona)");
    changes.add("Cambio de líquido refrigerante");
    if (answer1 == "Moto") changes.add("Cambio líquido de freno");
    changes.add("Revisión pre-ITV");
    changes.add("Otro");

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
                basicQuestionOptions("¿Qué tipo de vehículo tienes? ", [
                  btnSwitch("Coche", answer1, () {
                    answer2 = "";
                    answer1 = "Coche";
                  }),
                  btnSwitch("Moto", answer1, () {
                    answer2 = "";
                    answer1 = "Moto";
                  }),
                ]),
                (answer1 != "")
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
                                    "¿Qué necesitas cambiar o reparar en tu ${answer1.toLowerCase()}? ",
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
                                    items: changes.map((String type) {
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
                                      contentPadding: EdgeInsets.fromLTRB(
                                          16.0, 0.0, 0.0, 0.0),
                                      hintText:
                                          "¿Qué necesitas cambiar o reparar en tu coche/moto?",
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
                (answer2 == "Neumáticos")
                    ? basicQuestionOptions("¿Típo?", [
                        btnSwitch("Nuevos", answer6, () {
                          answer6 = "Nuevos";
                        }),
                        btnSwitch("Seminuevos", answer6, () {
                          answer6 = "Seminuevos";
                        }),
                      ])
                    : Container(),
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
                          child: modelYearField,
                        )
                      ],
                    ))),
                (answer2 != "Neumáticos")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    child: Text(
                                        "Tipo de motor, código de identificación de motor (ficha técnica)",
                                        style: TextStyle(
                                            color: CustomColors.primary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: Size(20, 20),
                                      primary: CustomColors.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      padding: EdgeInsets.all(0)),
                                  onPressed: () {
                                    previewImageAsset(
                                        "motor-bastidor.png", context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(
                                      Icons.help,
                                      size: 23,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: typeMotorCodeField,
                            )
                          ],
                        )))
                    : Container(),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 5.0),
                                child: Text("Número bastidor (ficha técnica)",
                                    style: TextStyle(
                                        color: CustomColors.primary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(20, 20),
                                  primary: CustomColors.primary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                  padding: EdgeInsets.all(0)),
                              onPressed: () {
                                previewImageAsset(
                                    "motor-bastidor.png", context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Icon(
                                  Icons.help,
                                  size: 23,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 5.0),
                          child: numBastidorField,
                        )
                      ],
                    ))),
                (answer2 == "Neumáticos")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    child: Text(
                                        "Medida neumático (ficha técnica)",
                                        style: TextStyle(
                                            color: CustomColors.primary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      minimumSize: Size(20, 20),
                                      primary: CustomColors.primary,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      padding: EdgeInsets.all(0)),
                                  onPressed: () {
                                    previewImageAsset(
                                        "neumaticos.png", context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(
                                      Icons.help,
                                      size: 23,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: tireMeasureField,
                            )
                          ],
                        )))
                    : Container(),
                basicQuestionOptions("¿Puedes desplazarte?", [
                  btnSwitch("Sí", answer3, () {
                    answer3 = "Sí";
                  }),
                  btnSwitch("No", answer3, () {
                    answer3 = "No";
                  }),
                ]),
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
      showErrorsDialog(context, ["Debe seleccionar el tipo de vehículo"]);
      return;
    }
    ;
    if (answer2 == "") {
      showErrorsDialog(
          context, ["Debe seleccionar que necesitas cambiar o reparar"]);
      return;
    }
    ;
    if (answer3 == "") {
      showErrorsDialog(context, ["Debe seleccionar si puedes desplazarte"]);
      return;
    }
    ;
    if (answer2 == "Neumáticos" && answer6 == "") {
      showErrorsDialog(context,
          ["Debe seleccionar el tipo de neumáticos a reparar o cambiar"]);
      return;
    }
    ;

    if (form!.validate()) {
      form.save();
      Map<String, dynamic> q = {
        "answer1": answer1,
        "answer2": answer2,
        "answer3": cModelYear.text,
        "answer4": cTypeMotorCode.text,
        "answer5": cNumBastidor.text,
        "answer6": cTireMeasure.text,
        "answer7": answer3,
        "answer8": answer6
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
            primary: status ? CustomColors.primary : Colors.grey.shade100,
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
