import 'package:app/components/override_date_picker.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DialogSelectDate extends StatefulWidget {
  final String title, description, buttonText;
  final String image;
  final bool useBtnCancel;
  Function callBackBtn;

  DialogSelectDate(
      this.title, this.description, this.buttonText, this.callBackBtn,
      {this.useBtnCancel = false, this.image = ""});
  @override
  _DialogSelectDateState createState() => _DialogSelectDateState();
}

class _DialogSelectDateState extends State<DialogSelectDate> {
  dynamic date = null;
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
              SizedBox(
                height: 24.0,
              ),
              ButtonTheme(
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
                      Text("Seleccionar",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))
                    ],
                  ),
                  onPressed: () {
                    OverrideDatePicker.showDatePicker(context,
                        theme: DatePickerTheme(),
                        showTitleActions: true,
                        onChanged: (date) {}, onConfirm: (dateNew) {
                      setState(() {
                        date = dateNew;
                      });
                    }, currentTime: DateTime.now(), locale: LocaleType.es);
                  },
                ),
              ),
              (date != null && date is DateTime)
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(getDateFromStringFormat(date.toString())),
                    )
                  : Container(),
              (widget.useBtnCancel)
                  ? Container(
                      height: 50,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: MaterialButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Text("Cancelar")),
                          ),
                          Expanded(
                            child: MaterialButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  widget.callBackBtn(date);
                                },
                                child: Text(widget.buttonText)),
                          )
                        ],
                      ),
                    )
                  : Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            widget.callBackBtn(date);
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
                child: ClipOval(
                  child: Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Image.asset(
                        (checkEmpty(widget.image)
                            ? widget.image
                            : "assets/images/warning1.gif"),
                        fit: BoxFit.contain),
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
