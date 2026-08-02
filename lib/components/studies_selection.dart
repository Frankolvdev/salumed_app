import 'package:app/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_grid/responsive_grid.dart';

class StudiesSelection extends StatefulWidget {
  StudiesSelection(
      {required this.controller, required this.preventSelect, Key? key})
      : super(key: key);

  final StudiesSelectionController controller;
  final bool preventSelect;
  @override
  State<StudiesSelection> createState() => _StudiesSelectionState();
}

class _StudiesSelectionState extends State<StudiesSelection> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveGridRow(children: [
      ResponsiveGridCol(
          lg: 6,
          xs: 12,
          md: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text("ESTUDIOS BASICOS:",
                  style: TextStyle(
                      color: CustomColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              SizedBox(
                height: 20,
              ),
              itemLabSt("BIOMETRIA HEMATICA COMPLETA", "1"),
              itemLabSt("QUIMICA SANGUINEA DE (6) (18), (28), (32), (35)", "2"),
              itemLabSt("TIEMPOS DE COAGUILACION (TP) (TPT)", "3"),
              itemLabSt("REACCIONES FEBRILES", "4"),
              itemLabSt("AMIBA EN FRESCO", "5"),
              itemLabSt("COPRO (1) (3)", "6"),
              itemLabSt("COPROCULTIVO", "7"),
              itemLabSt("SANGRE OCULTA EN HECES (1) (3)", "8"),
              itemLabSt("GENERAL DE ORINA", "9"),
            ],
          )),
      ResponsiveGridCol(
          lg: 6,
          xs: 12,
          md: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
              ),
              Text("ESTUDIOS ESPECIALES:",
                  style: TextStyle(
                      color: CustomColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              SizedBox(
                height: 20,
              ),
              itemLabSt("SERIE ESOFAGOGASTRODUODENAL", "10"),
              itemLabSt("TRANSITO INTESTINAL", "11"),
              itemLabSt("TAC ABDOMEN COMPLETO SIMPLE Y CONTRASTADA", "12"),
              itemLabSt("TAC DE ABDOMEN SIMPLE", "13"),
              itemLabSt("COLON POR ENEMA", "14"),
              itemLabSt("PRUEBA EN SANGRE PARA H. PILORY", "15"),
              itemLabSt("Ac ANTI TRANSGLUTAMINASA TISULAR (IgA e IgG)", "16"),
              itemLabSt("ULTRASONIDO ABDOMEN SUPERIOR", "17"),
              itemLabSt("UILTRASONIDO ABDOMEN COMPLETO", "18"),
              itemLabSt("ULTRASONIDO DE HÍGADO Y VÍA BILIAR", "19"),
              itemLabSt("ULTRASONIDO DE VESÍCULA CON PRUEBA DE BOYDEN", "20"),
            ],
          )),
      ResponsiveGridCol(
          lg: 12,
          xs: 12,
          md: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Text("ESTUDIOS POR PAQUETE:",
                  style: TextStyle(
                      color: CustomColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              SizedBox(
                height: 20,
              )
            ],
          )),
      ResponsiveGridCol(
          lg: 6,
          xs: 12,
          md: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              itemLabSt("QUÍMICA SANGUÍNEA 28 ELEMENTOS", "21"),
              itemLabSt("QUÍMICA SANGUÍNEA 35 ELEMENTOS", "22"),
              itemLabSt("QUÍMICA SANGUÍNEA 43 ELEMENTOS", "23"),
              itemLabSt("CHECK UP 30 ELEMENTOS", "24"),
              itemLabSt("CHECK UP 37 ELEMENTOS", "25"),
              itemLabSt("CHECK UP 45 ELEMENTOS", "26"),
              itemLabSt("PANEL BACTERIANO GASTROINTESTINAL", "27"),
              itemLabSt("PANEL VIRAL GASTROINTESTINAL", "28"),
              itemLabSt("PANEL RESPIRATORIO VIRAL", "29"),
              itemLabSt("AC ANTI TIROIDEOS", "30"),
              itemLabSt("CLIMATERIO", "31"),
              itemLabSt("PERFIL COVID SEGUIMIENTO 2", "32"),
              itemLabSt("DIABETICO CONTROL", "33"),
              itemLabSt("DROGAS DE ABUSO 1", "34"),
              itemLabSt("FILTRADO GLOMERULAR", "35"),
              itemLabSt("HEPATICO", "36"),
              itemLabSt("HEPATITIS VIRAL A + B", "37"),
              itemLabSt("HEPATITIS VIRAL A + B + C + D", "38"),
              itemLabSt("HERPES (Ac Anti-Virus Herpes 1 y 2 IgG e IgM)", "39"),
              itemLabSt("HIERRO CINETICA", "40"),
              itemLabSt("HORMONAL 1", "41"),
              itemLabSt("HORMONAL 2", "42"),
            ],
          )),
      ResponsiveGridCol(
          lg: 6,
          xs: 12,
          md: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              itemLabSt("HORMONAL 3", "43"),
              itemLabSt("HORMONAL MASCULINO BASICO", "44"),
              itemLabSt("NMUNOGLOBULINAS", "45"),
              itemLabSt("PROSTATICO CHEQUEO", "45"),
              itemLabSt("REUMATICO 1", "46"),
              itemLabSt("REUMATICO 2", "47"),
              itemLabSt("TIROIDEO 1", "48"),
              itemLabSt("TIROIDEO BASICO", "49"),
              itemLabSt("TRANSMISION SEXUAL 1", "50"),
              itemLabSt("TRANSMISION SEXUAL 3", "51"),
              itemLabSt("ANDROGENICO", "52"),
              itemLabSt("PERFIL COVID SEGUIMIENTO 1", "53"),
              itemLabSt("DIABETICO", "54"),
              itemLabSt("DIABETICO DETECCION", "55"),
              itemLabSt("DROGAS DE ABUSO 2", "56"),
              itemLabSt("ESTROGENICO", "57"),
              itemLabSt("HEMOSTASIS", "58"),
              itemLabSt("HEPATITIS VIRAL A", "59"),
              itemLabSt("HEPATITIS VIRAL B", "60"),
              itemLabSt("HEPATITIS VIRAL A + B + C", "61"),
              itemLabSt("HIERRO 1 (ANEMIAS)", "62"),
              itemLabSt("HIERRO 2", "63"),
            ],
          )),
      ResponsiveGridCol(
          lg: 6,
          xs: 12,
          md: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              itemLabSt("HIPOFISIARIO 1", "64"),
              itemLabSt("HIPOFISIARIO 2", "65"),
              itemLabSt("HORMONAL 4", "66"),
              itemLabSt("HORMONAL 5", "67"),
              itemLabSt("HORMONAL MASCULINO", "68"),
              itemLabSt("INDICE DE RESISTENCIA A LA INSULINA-HOMA", "69"),
              itemLabSt("LIPIDOS 3", "70"),
              itemLabSt("PANCREATICO", "71"),
              itemLabSt("PRENATAL", "72"),
              itemLabSt("PRENATAL BASICO", "73"),
              itemLabSt("PREOPERATORIO 1", "74"),
            ],
          )),
      ResponsiveGridCol(
          lg: 6,
          xs: 12,
          md: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              itemLabSt("PREOPERATORIO 2", "75"),
              itemLabSt("RENAL", "76"),
              itemLabSt("TIROIDEO 3", "77"),
              itemLabSt("PERFIL TRANSMISION SEXUAL 2", "78"),
              itemLabSt("RAYOS X", "79"),
              itemLabSt("TOMOGRAFÍAS", "80"),
              itemLabSt("ULTRASONIDO", "81"),
            ],
          )),
    ]);
  }

  Widget itemLabSt(String title, String val) {
    return InkWell(
      onTap: () {
        if (widget.preventSelect == true) return;

        dynamic found = "";
        dynamic foundIndex = null;
        for (var i = 0; i < widget.controller.labSts.length; i++) {
          if (widget.controller.labSts[i] == val) {
            found = widget.controller.labSts[i];
            foundIndex = i;
          }
        }
        if (foundIndex != null) {
          widget.controller.labSts.removeAt(foundIndex);
        } else {
          widget.controller.labSts.add(val);
        }
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                  color: (checkItemLbSt(val))
                      ? CustomColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    width: 1.5,
                    color: CustomColors.primary,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(title,
                  style: TextStyle(color: Colors.grey[800], fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }

  bool checkItemLbSt(String val) {
    bool found = false;
    for (var i = 0; i < widget.controller.labSts.length; i++) {
      if (widget.controller.labSts[i] == val) {
        found = true;
      }
    }
    return found;
  }
}

class StudiesSelectionController extends ChangeNotifier {
  List<String> labSts = [];
  List<String> getLabSts() {
    return labSts;
  }
}
