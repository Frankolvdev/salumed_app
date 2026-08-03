import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/material.dart';

class CustomDialogPayment extends StatefulWidget {
  final String title, description, buttonText;
  final String image;
  final String textBtnCancel;
  final bool useBtnCancel;
  final String textLink;
  Function callBackBtn;

  dynamic callBackBtnCancel;

  CustomDialogPayment(this.title, this.description, this.buttonText, this.callBackBtn,
      {this.useBtnCancel = false,
      this.textBtnCancel = "Cancelar",
      this.image = "",
      this.callBackBtnCancel = null,
      this.textLink = ""});
  @override
  _CustomDialogPaymentState createState() => _CustomDialogPaymentState();
}

class _CustomDialogPaymentState extends State<CustomDialogPayment> {
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
              Align(
                  alignment: Alignment.center,
                  child: Text(widget.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0))),
              (widget.textLink != "")
                  ? InkWell(
                      onTap: () {
                        launchUrl(context, widget.textLink);
                      },
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(widget.textLink,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16.0,
                                color: CustomColors.primary,
                                decoration: TextDecoration.underline)),
                      ))
                  : Container(),
              SizedBox(
                height: 24.0,
              ),

 InkWell(
  onTap: (){
    widget.callBackBtn("paypal");
    
  },
   child: Image.asset("assets/images/paypal.webp",
                          fit: BoxFit.contain),
 ),
 SizedBox(height: 15,),

//  InkWell(
//   onTap: (){
//     widget.callBackBtn("mercadopago");
//   },
//    child: Image.asset("assets/images/mercadopago.webp",
//                           fit: BoxFit.contain),
//  ),
         Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                          onPressed: () {
                           Navigator.of(context, rootNavigator: true).pop();
                            
                          },
                          child: Text(widget.buttonText)),
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
