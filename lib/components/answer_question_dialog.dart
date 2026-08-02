import 'dart:typed_data';

import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/question.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart';

class AnswerQuestionDialog extends StatefulWidget {
  final QuestionModel question;
  final String image;
  final bool useBtnCancel;
  Function callBackBtn;

  AnswerQuestionDialog(this.question, this.callBackBtn,
      {this.useBtnCancel = true, this.image = ""});
  @override
  _AnswerQuestionDialogState createState() => _AnswerQuestionDialogState();
}

class _AnswerQuestionDialogState extends State<AnswerQuestionDialog> {
  final cAnswer = TextEditingController();
  final formKey = new GlobalKey<FormState>();
  dynamic imageSelected = null;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: getDialogInsetPaddin(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    var fieldsDecoration = InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      hintText: "Escribe una respuesta",
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
    final answerField = TextFormField(
      maxLines: null,
      textInputAction: TextInputAction.done,
      controller: cAnswer,
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
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: (checkEmpty(widget.image)) ? 100 : 16,
                  bottom: 16,
                  left: 16,
                  right: 16),
              margin: EdgeInsets.only(top: 16),
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
              child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        "",
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Text(widget.question.question ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16.0))),
                      SizedBox(
                        height: 24.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsetsDirectional.all(4.0),
                                elevation: 2,
                                backgroundColor: CustomColors.primary,
                                shape: StadiumBorder()),
                            onPressed: () {
                              showTakePicture();
                            },
                            child: Container(
                              height: 15,
                              width: 78,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Text("Adjuntar foto",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.0),
                                          textAlign: TextAlign.center),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      (imageSelected != null)
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.all(
                                      Radius.circular(10.0)),
                                  image: (imageSelected is Uint8List)
                                      ? DecorationImage(
                                          image: MemoryImage(imageSelected),
                                          fit: BoxFit.cover,
                                        )
                                      : DecorationImage(
                                          image: FileImage(imageSelected)),
                                ),
                              ),
                            )
                          : Container(),
                      answerField,
                      SizedBox(
                        height: 24.0,
                      ),
                      (widget.useBtnCancel)
                          ? Container(
                              height: 50,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                        },
                                        child: Text("Cancelar")),
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                        onPressed: () {
                                          final form = formKey.currentState;

                                          if (form!.validate()) {
                                            form.save();

                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();

                                            widget.callBackBtn(
                                                cAnswer.text, imageSelected);
                                          }
                                        },
                                        child: Text(
                                          "Enviar respuesta",
                                          style: TextStyle(
                                              color: CustomColors.primary),
                                          textAlign: TextAlign.center,
                                        )),
                                  )
                                ],
                              ),
                            )
                          : Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                  onPressed: () {
                                    final form = formKey.currentState;

                                    if (form!.validate()) {
                                      form.save();
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();

                                      widget.callBackBtn(
                                          cAnswer.text, imageSelected);
                                    }
                                  },
                                  child: Text("Enviar respuesta")),
                            )
                    ],
                  )),
            ),
          ],
        )
      ],
    );
  }

  showTakePicture() async {
    if (kIsWeb) {
      selectPictureWeb(context, (dynamic imageFile) {
        setState(() {
          this.imageSelected = imageFile;
        });
      });
    } else {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SelectPictureDialogWec(
              "Seleccionar imagen",
              (contextDialogd, image) {
                Navigator.pop(contextDialog);
                callbackShowTakePicture(contextDialogd, image);
              },
              useBtnCancel: true,
            );
          });
    }
  }

  Future callbackShowTakePicture(contextDialog, image) async {
    if (image == null) return;
    try {
      final XFile? imageFile = await ImagePicker().pickImage(
          source:
              (image == "camera") ? ImageSource.camera : ImageSource.gallery);
      if (imageFile != null) {
        File file = await File(imageFile.path);
        setState(() {
          this.imageSelected = file;
        });
      }
      Navigator.pop(contextDialog);
    } catch (e) {
      Navigator.pop(contextDialog);
    }
  }
}
