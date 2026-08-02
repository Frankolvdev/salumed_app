import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PainQuestionnaire extends StatefulWidget {
  dynamic callback;
  dynamic questionnaire;
  bool onlyRead;
  bool edit;
  PainQuestionnaire(
      {Key? key,
      this.callback = null,
      this.questionnaire = null,
      this.onlyRead = false,
      this.edit = false})
      : super(key: key);

  @override
  _PainQuestionnaireState createState() => _PainQuestionnaireState();
}

class _PainQuestionnaireState extends State<PainQuestionnaire> {
  final cNumRooms = TextEditingController();
  final cNumColumns = TextEditingController();
  final cMaterialOverPaint = TextEditingController();
  final cSpecial = TextEditingController();
  final cColor = TextEditingController();
  final cCurrentColor = TextEditingController();
  final cTypePaint = TextEditingController();
  final cMetters = TextEditingController();
  final cMettersHumidity = TextEditingController();
  final formKey = new GlobalKey<FormState>();

  final cMettersPaper = TextEditingController();

  List<String> typePaint = [
    "",
    "Interior",
    "Exterior",
    "Especial",
    "Quitar Gotelé",
    "Papel pintado"
  ];

  String answer1 = "";
  String answer2 = "";
  String answer3 = "";
  String answer4 = "";
  String answer5 = "";

  String answer6 = "";
  String answer7 = "";

  bool readOnly = false;
  @override
  void initState() {
    super.initState();
    readOnly = widget.onlyRead;
    if (widget.questionnaire != null) {
      Map<String, dynamic> q = widget.questionnaire;

      answer1 = q["answer1"];
      cNumRooms.text = q["answer2"];
      cNumColumns.text = q["answer3"];
      cMaterialOverPaint.text = q["answer4"];
      cSpecial.text = q["answer5"];
      answer2 = q["answer6"];
      cColor.text = q["answer7"];
      cCurrentColor.text = q["answer8"];
      cTypePaint.text = q["answer9"];
      cMetters.text = q["answer10"];
      answer3 = q["answer11"];
      cMettersHumidity.text = q["answer12"];

      if (answer1 == "Papel pintado") {
        cMettersPaper.text = q["answer13"];
        answer6 = q["answer14"] ?? "";
      }

      if (answer1 == "Quitar Gotelé") {
        answer7 = q["answer15"] ?? "";
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
    final numRoomsField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      controller: cNumRooms,
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

    final numColumnsField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      controller: cNumColumns,
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

    final materialOverPaintField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cMaterialOverPaint,
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

    final specialField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cSpecial,
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

    final colorField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cColor,
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

    final typePaintField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      controller: cTypePaint,
      keyboardType: TextInputType.text,

      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration,
      onFieldSubmitted: (val) {},
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

    final mettersHumidityField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: cMettersHumidity,
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

    final mettersPaperField = TextFormField(
      readOnly: readOnly,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: cMettersPaper,
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
                          child: Text("Tipo",
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
                              items: typePaint.map((String type) {
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
                                hintText: "Tipo",
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
                (answer1 == "Papel pintado")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Text("Metros (m2) de papel pintado",
                                  style: TextStyle(
                                      color: CustomColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: mettersPaperField,
                            )
                          ],
                        )))
                    : Container(),
                (answer1 == "Papel pintado")
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
                                    "Rango de precios del papel pintado",
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
                                      "menos de 10",
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
                                    onChanged: (readOnly)
                                        ? null
                                        : (val) {
                                            setState(() {
                                              answer6 = val as String;
                                            });

                                            // do other stuff with _category
                                          },
                                    value: answer6,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.fromLTRB(
                                          16.0, 0.0, 0.0, 0.0),
                                      hintText:
                                          "Rango de precios del papel pintado",
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
                (answer1 == "Quitar Gotelé")
                    ? basicQuestionOptions("¿Que tipo de suelo tiene/tendrá?", [
                        btnSwitch("Alicatado", answer7, () {
                          answer7 = "Alicatado";
                        }),
                        btnSwitch("Tarima/paquet", answer7, () {
                          answer7 = "Tarima/paquet";
                        }),
                        btnSwitch("Otro", answer7, () {
                          answer7 = "Otro";
                        }),
                      ])
                    : Container(),
                (answer1 == "Interior")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Text("Número de habitaciones",
                                  style: TextStyle(
                                      color: CustomColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: numRoomsField,
                            )
                          ],
                        )))
                    : Container(),
                (answer1 == "Interior")
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
                                  "Número de columnas. En pared/aisladas",
                                  style: TextStyle(
                                      color: CustomColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: numColumnsField,
                            )
                          ],
                        )))
                    : Container(),
                (answer1 == "Exterior")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Text("Materiales donde se va a pintar",
                                  style: TextStyle(
                                      color: CustomColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: materialOverPaintField,
                            )
                          ],
                        )))
                    : Container(),
                (answer1 == "Especial")
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
                                  "Objeto(s) a pintar (puertas, rejas,…)",
                                  style: TextStyle(
                                      color: CustomColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: specialField,
                            )
                          ],
                        )))
                    : Container(),
                (answer1 == "Interior")
                    ? basicQuestionOptions("Tipo de pared", [
                        btnSwitch("Gotelé", answer2, () {
                          answer2 = "Gotelé";
                        }),
                        btnSwitch("Liso", answer2, () {
                          answer2 = "Liso";
                        }),
                      ])
                    : Container(),
                (answer1 != "Papel pintado")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Text("¿De qué color quieres pintar?",
                                  style: TextStyle(
                                      color: CustomColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: colorField,
                            )
                          ],
                        )))
                    : Container(),
                (answer1 != "Papel pintado")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Text("Color que está pintado",
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
                        )))
                    : Container(),
                (answer1 != "Papel pintado")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Text("Tipo de pintura que quiere",
                                  style: TextStyle(
                                      color: CustomColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: typePaintField,
                            )
                          ],
                        )))
                    : Container(),
                (answer1 != "Papel pintado")
                    ? Padding(
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
                        )))
                    : Container(),
                (answer1 != "Papel pintado")
                    ? basicQuestionOptions("¿Tiene humedades?", [
                        btnSwitch("Sí", answer3, () {
                          answer3 = "Sí";
                        }),
                        btnSwitch("No", answer3, () {
                          answer3 = "No";
                        }),
                      ])
                    : Container(),
                (answer1 != "Papel pintado" && answer3 == "Sí")
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: Text("Metros(m2) aproximados de humedad",
                                  style: TextStyle(
                                      color: CustomColors.primary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: mettersHumidityField,
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
      showErrorsDialog(context, ["Debe seleccionar el tipo"]);
      return;
    }
    ;
    if (answer1 != "Papel pintado" && answer3 == "") {
      showErrorsDialog(context, ["Debe seleccionar si tiene humedades"]);
      return;
    }
    ;

    if (answer1 == "Papel pintado") {
      if (cMettersPaper.text == "") {
        showErrorsDialog(
            context, ["Debe ingresar los metros de papel pintado"]);
        return;
      }
      ;
      if (answer6 == "") {
        showErrorsDialog(
            context, ["Debe seleccionar el rango de precios de papel pintado"]);
        return;
      }
      ;
    }

    if (answer1 == "Quitar Gotelé") {
      if (answer7 == "") {
        showErrorsDialog(
            context, ["Debe seleccionar que tipo de suelo tiene/tendrá"]);
        return;
      }
      ;
    }

    if (form!.validate()) {
      form.save();

      Map<String, dynamic> q = {
        "answer1": answer1,
        "answer2": cNumRooms.text,
        "answer3": cNumColumns.text,
        "answer4": cMaterialOverPaint.text,
        "answer5": cSpecial.text,
        "answer6": answer2,
        "answer7": cColor.text,
        "answer8": cCurrentColor.text,
        "answer9": cTypePaint.text ?? "",
        "answer10": cMetters.text,
        "answer11": answer3,
        "answer12": cMettersHumidity.text,
        "answer13": cMettersPaper.text,
        "answer14": answer6,
        "answer15": answer7,
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
