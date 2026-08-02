import 'package:app/components/override_date_picker.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DialogSelectDateRange extends StatefulWidget {
  final String buttonText;
  final bool useBtnCancel;
  DateTime maxDate;
  DateTime minDate;
  Function callBackBtn;

  DialogSelectDateRange(
      this.minDate, this.maxDate, this.buttonText, this.callBackBtn,
      {this.useBtnCancel = false});
  @override
  _DialogSelectDateRangeState createState() => _DialogSelectDateRangeState();
}

class _DialogSelectDateRangeState extends State<DialogSelectDateRange> {
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
          padding: EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
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
                "Desde",
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 16.0,
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
                      Text(getDateFromStringFormat(widget.minDate.toString()),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))
                    ],
                  ),
                  onPressed: () {
                    OverrideDatePicker.showDatePicker(context,
                        theme: LegacyDatePickerTheme(),
                        maxTime: DateTime.now(),
                        showTitleActions: true,
                        onChanged: (date) {}, onConfirm: (dateNew) {
                      setState(() {
                        widget.minDate = dateNew;
                        if (widget.maxDate.compareTo(dateNew) < 0) {
                          widget.maxDate = dateNew;
                        }
                      });
                    }, currentTime: widget.minDate, locale: LocaleType.es);
                  },
                ),
              ),
              Text(
                "Al",
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 16.0,
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
                      Text(getDateFromStringFormat(widget.maxDate.toString()),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))
                    ],
                  ),
                  onPressed: () {
                    OverrideDatePicker.showDatePicker(context,
                        theme: LegacyDatePickerTheme(),
                        maxTime: DateTime.now(),
                        showTitleActions: true,
                        onChanged: (date) {}, onConfirm: (dateNew) {
                      setState(() {
                        widget.maxDate = dateNew;
                        if (widget.minDate.compareTo(dateNew) > 0) {
                          widget.minDate = dateNew;
                        }
                      });
                    }, currentTime: widget.maxDate, locale: LocaleType.es);
                  },
                ),
              ),
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
                                  widget.callBackBtn(
                                      widget.minDate, widget.maxDate);
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
                            widget.callBackBtn(widget.minDate, widget.maxDate);
                          },
                          child: Text(widget.buttonText)),
                    )
            ],
          ),
        )
      ],
    );
  }

  selectRangeDate(DateTime from, DateTime max, Function callback) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return DialogSelectDateRange(
            from,
            max,
            "Filtrar",
            (dynamic dateMin, dynamic dateMax) {
              callback(dateMin, dateMax);
            },
            useBtnCancel: true,
          );
        });
  }
}
