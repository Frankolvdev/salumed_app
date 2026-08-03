import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/providers/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class DoesWork extends StatelessWidget {
  const DoesWork({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    return Scaffold(
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
        body: ListView(children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: (getTypeUser(context) == "client")
                  ? itemClient()
                  : itemProfessional())
        ]));
  }

  Widget itemClient() {
    return Column(
      children: [
        Text(
          "¿Cómo funciona Chapú?",
          style: TextStyle(
              color: CustomColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        //____________________________
        Image.asset(
          "assets/images/como-funciona-cliente.png",
          width: 110,
        ),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Text(
            "¿Cuéntanos que chapú tienes?.",
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 18,
        ),
        getCircleTime("1"),
        Text(
          "Publica tu tarea en",
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
        Text(
          "3 minutos",
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 18,
        ),
        getCircleTime("2"),
        Text(
          "Responde todas las dudas del profesional antes de la subasta.",
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 18,
        ),
        getCircleTime("3"),
        Text(
          "Disfruta ver como chapú vale cada vez menos en tiempo de subasta.",
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 18,
        ),
        getCircleTime("4"),
        Image.asset(
          "assets/images/como-funciona-compara.png",
          width: 110,
        ),
        Text(
          "COMPARA Y ELIGE.",
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ". Profesional",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            Text(
              ". Presupuesto",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            Text(
              ". Tiempo",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            Text(
              ". Valoraciones",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        SizedBox(
          height: 18,
        ),
        getCircleTime("5"),
        Image.asset(
          "assets/images/chat-btn2.png",
          width: 110,
        ),
        Text(
          "Chatea con el profesional después de aceptar el presupuesto.",
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 18,
        ),
        getCircleTime("6"),
        Image.asset(
          "assets/images/como-funciona-paga.png",
          width: 110,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Acuerda con el profesional la forma de pago.",
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "El dinero se le dará al profesional finalizado el trabajo.",
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 18,
        ),
        getCircleTime("7"),
        Image.asset(
          "assets/images/como-funciona-cuando-mejor-valorado.png",
          width: 110,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "VALORACIONES",
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Valora al profesional finalizado el Chapú",
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget getCircleTime(String text) {
    return Container(
        width: 45,
        height: 45,
        decoration: new BoxDecoration(
            color: CustomColors.primary,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(45.0),
              topRight: const Radius.circular(45.0),
              bottomLeft: const Radius.circular(45.0),
              bottomRight: const Radius.circular(45.0),
            )),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
            child: Text(text,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 28),
                textAlign: TextAlign.center),
          ),
        ));
  }

  Widget itemProfessional() {
    return Column(
      children: [
        //____________________________
        Text(
          "¿Cómo funciona Chapú?",
          style: TextStyle(
              color: CustomColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Image.asset(
          "assets/images/como-funciona-pregunta.png",
          width: 110,
        ),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Text(
            "Pregunta al cliente antes de la subasta, para dar un presupuesto acertado.",
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
        ),
        //____________________________
        Image.asset(
          "assets/images/como-funciona-presupuesto.png",
          width: 110,
        ),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Text(
            "Ofrece un presupuesto posible para convencer al cliente.",
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
        ),
        //____________________________
        Image.asset(
          "assets/images/como-funciona-envia-fotos.png",
          width: 110,
        ),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Text(
            "Sube tus fotos de la obra finalizada para que tengamos tus trabajos realizados en la plataforma.",
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
        ),
        //____________________________
        Image.asset(
          "assets/images/como-funciona-pagos.png",
          width: 110,
        ),
        Text(
          "PAGOS.",
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Text(
            "Finaliza la obra y cobra el trabajo.",
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
        ),
        //____________________________
        Image.asset(
          "assets/images/como-funciona-valora-tu-cliente.png",
          width: 110,
        ),
        Text(
          "VALORA AL CLIENTE.",
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Text(
            "Después de finalizar el trabajo.",
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
        Divider(
          color: Colors.grey.shade700,
        ),
        Image.asset(
          "assets/images/como-funciona-recuerda.png",
          width: 110,
        ),
        Text(
          "RECUERDA.",
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.normal),
          textAlign: TextAlign.center,
        ),
        Image.asset(
          "assets/images/como-funciona-cuando-mejor-valorado.png",
          width: 110,
        ),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Text(
            "Cuando mejor valorado estés, más trabajos conseguirás.",
            style: TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.normal),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

