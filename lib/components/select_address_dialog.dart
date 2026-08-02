import 'package:app/components/override_date_picker.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/pages/client/client_add_address.dart';
import 'package:app/providers/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class SelectAddress extends StatefulWidget {
  Function callBackBtn;

  SelectAddress(this.callBackBtn);
  @override
  _SelectAddressState createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  dynamic date = null;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    return Dialog(
      insetPadding: getDialogInsetPaddin(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context, provider),
    );
  }

  dialogContent(BuildContext context, AppProvider provider) {
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
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Text(
              "Seleccione una dirección de entrega",
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            (provider.user.addresses!.length > 0)
                ? Container(
                    height: MediaQuery.of(context).size.height * .60,
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Column(
                                children:
                                    provider.user.addresses!.map((address) {
                                  return InkWell(
                                    onTap: () {
                                      // Navigator.of(context).pop();
                                      widget.callBackBtn(address);
                                    },
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    Icons.check,
                                                    color: (address
                                                                .is_delivery ==
                                                            "true")
                                                        ? Colors.blue
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                                Flexible(
                                                    child: Text(
                                                        address.street ?? "")),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Icon(
                                                    FontAwesomeIcons
                                                        .chevronRight,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                      "Código postal ${address.street} - ${address.state} - ${address.municipality}"),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              Center(
                                  child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        elevation: 2,
                                        primary: CustomColors.primary,
                                        shape: StadiumBorder()),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              child: ClientAddAdress(),
                                              type:
                                                  PageTransitionType.slideInUp,
                                              duration:
                                                  Duration(milliseconds: 250)));
                                    },
                                    child: Container(
                                      width: 130,
                                      height: 35.0,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Agregar Dirección",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                : Center(
                    child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 2,
                            primary: CustomColors.primary,
                            shape: StadiumBorder()),
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  child: ClientAddAdress(),
                                  type: PageTransitionType.slideInUp,
                                  duration: Duration(milliseconds: 250)));
                        },
                        child: Container(
                          width: 130,
                          height: 35.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Agregar Dirección",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
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
                        child: Text("Cancelar")),
                  )
                ],
              ),
            )
          ]),
        ),
      ],
    );
  }
}
