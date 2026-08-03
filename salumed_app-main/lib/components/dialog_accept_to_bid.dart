import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/app_preferences.dart';
import 'package:flutter/material.dart';

class DialogAcceptToBid extends StatefulWidget {
  final String title, description, buttonText;
  final String image;
  final String textBtnCancel;
  final bool useBtnCancel;
  final String textLink;
  Function callBackBtn;

  dynamic callBackBtnCancel;

  DialogAcceptToBid(
      this.title, this.description, this.buttonText, this.callBackBtn,
      {this.useBtnCancel = false,
      this.textBtnCancel = "Cancelar",
      this.image = "",
      this.callBackBtnCancel = null,
      this.textLink = ""});
  @override
  _DialogAcceptToBidState createState() => _DialogAcceptToBidState();
}

class _DialogAcceptToBidState extends State<DialogAcceptToBid> {
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
    return Stack(
      children: <Widget>[
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 16.0,
              ),
              InkWell(
                onTap: () {
                  launchUrl(context, widget.textLink);
                },
                child: Align(
                    alignment: Alignment.center,
                    child: Text(widget.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16.0, color: CustomColors.primary))),
              ),
              SizedBox(
                height: 24.0,
              ),
              Container(
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: MaterialButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          child: Text(widget.textBtnCancel)),
                    ),
                    Expanded(
                      child: MaterialButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            widget.callBackBtn();
                          },
                          child: Text(widget.buttonText)),
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: MaterialButton(
                    onPressed: () async {
                      Navigator.of(context, rootNavigator: true).pop();
                      await AppPreferences().setAcceptToBid("true");
                      widget.callBackBtn();
                    },
                    child: Text("Aceptar y no volver a mostrar este mensaje",
                        style: TextStyle(
                            fontSize: 12, color: CustomColors.primary),
                        textAlign: TextAlign.center)),
              )
            ],
          ),
        ),
        Positioned(
            top: 0,
            left: 16,
            right: 16,
            child: Visibility(
              visible: checkEmpty(widget.image),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50,
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Image(
                    width: 40,
                    image: AssetImage((checkEmpty(widget.image)
                        ? widget.image
                        : "assets/images/warning1.gif")),
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
