import 'dart:typed_data';

import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/components/map_selected.dart';
import 'package:app/components/override_date_picker.dart';
import 'package:app/components/select_address_dialog.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/address.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/budget.dart';
import 'package:app/models/category.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/place.dart';
import 'package:app/models/prescription.dart';
import 'package:app/models/suggestion.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/client/client_edit_address.dart';
import 'package:app/pages/select_location.dart';
import 'package:app/pages/set_change_password.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/search_places_stream.dart';
import 'package:app/services/web_service.dart';
import 'package:app/streams/search_places_stream.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:app/compat/flutter_page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:snack/snack.dart';
import 'package:universal_io/io.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import '../../models/order.dart';

class ClientConfirmOrder extends StatefulWidget {
  Function callBackBack;
  PrescriptionModel prescription;
  BudgetModel budgetAccepted;
  OrderModel order;
  ClientConfirmOrder(
      this.callBackBack, this.prescription, this.budgetAccepted, this.order,
      {Key? key})
      : super(key: key);

  @override
  _ClientConfirmOrderState createState() => _ClientConfirmOrderState();
}

class _ClientConfirmOrderState extends State<ClientConfirmOrder> {
  final cLocation = TextEditingController();
  bool locationSearchHasFocus = false;
  String locationText = "";
  dynamic locationFilter = null;
  FocusNode _focus = new FocusNode();
  GlobalKey<dynamic> mapState = GlobalKey();

  final cPrescription = TextEditingController();
  final cDate = TextEditingController();
  final cComments = TextEditingController();
  final cAddress = TextEditingController();
  final formKey = new GlobalKey<FormState>();
  String typePaymentSelected = "cash";

  late Place placeSelected;

  dynamic typeDeliverySelected = "home";
  dynamic imageSelected = null;
  dynamic dateSelected = null;
  dynamic addressSelected = null;
  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);
    PrescriptionModel p = widget.prescription;
    cPrescription.text = p.prescription_text ?? "";
    placeSelected = new Place(lat: provider.lat, lng: provider.long);
    imageSelected = p.prescription_picture;

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      searchLocation(LatLng(provider.lat, provider.long));
    });

    if (widget.order.type == "studies_without_prescription") {
      typeDeliverySelected = "store";
    }
    BackButtonInterceptor.add(myInterceptor);
  }

  void searchLocation(LatLng position) {
    simpleLoading(context, (BuildContext contextDialog) {
      try {
        WebService(context)
            .reverseGeocode(
                position.latitude.toString(), position.longitude.toString())
            .then((List<Place> places) {
          if (places.length > 0) {
            Navigator.pop(contextDialog);

            setState(() {
              places[0].lat = position.latitude;
              places[0].lng = position.longitude;
              placeSelected = places[0];
              cLocation.text = placeSelected.formatted_address ?? "";
            });
          } else {
            Navigator.pop(contextDialog);
          }
        }).catchError((e) {
          Navigator.pop(contextDialog);
          print(e);
        });
      } catch (e) {
        Navigator.pop(contextDialog);
        print(e);
      }
    });
  }

  void _onFocusChange() {
    if (mounted)
      setState(() {
        locationSearchHasFocus = _focus.hasFocus;
      });
  }

  var searchPlacesStream = new SearchPlacesStream();
  void searchPlace() {
    searchPlacesStream.searchPlacesByKeywordWhere(
        cLocation.text.isEmpty ? "" : cLocation.text, context, "es");
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    widget.callBackBack("");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    PrescriptionModel pharmacy = widget.prescription;

    final prescriptionField = TextFormField(
      autofocus: false,
      autocorrect: false,
      readOnly: true,
      controller: cPrescription,
      keyboardType: TextInputType.multiline,
      maxLines: null,

      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Receta que recibirá la farmacia',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CustomColors.primary),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );

    final dateField = TextFormField(
      autofocus: false,
      autocorrect: false,
      readOnly: true,
      controller: cDate,
      keyboardType: TextInputType.text,
      onTap: () {
        selectDateTime((DateTime date) {
          setState(() {
            cDate.text = getDateTimeFromStringFormat(date.toString());
            dateSelected = date;
          });
        });
      },
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: '¿En qué momento te enviaremos/entregaremos el pedido?',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CustomColors.primary),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );

    final commentsField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cComments,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Comentarios del pedido',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CustomColors.primary),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );

    final addressField = TextFormField(
      autofocus: false,
      autocorrect: false,
      readOnly: true,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      onTap: () {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (contextDialog) {
              return SelectAddress(
                (AddressModel address) {
                  if (address.place != null) {
                    setState(() {
                      addressSelected = address;
                      cAddress.text =
                          "${address.zip_code} ${address.street} - ${address.state} - ${address.municipality}";
                    });
                    Navigator.pop(contextDialog);
                  } else {
                    Navigator.pop(contextDialog);

                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (contextDialog) {
                          return WillPopScope(
                              child: CustomDialog(
                                "",
                                "La direccion seleccionada no tiene un lugar seleccionado, antes de seleccionarla debe seleccionar un lugar en el mapa para está dirección",
                                "Seleccionar lugar",
                                () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          child: ClientEditAdress(address),
                                          type: PageTransitionType.slideInUp,
                                          duration:
                                              Duration(milliseconds: 250)));
                                },
                                useBtnCancel: true,
                                image: '',
                              ),
                              onWillPop: () async {
                                return true;
                              });
                        });
                  }
                },
              );
            });
      },
      controller: cAddress,
      keyboardType: TextInputType.text,
      maxLines: null,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Dirección de entrega',
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: CustomColors.primary),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );

    final locationField = TextFormField(
        controller: cLocation,
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
        readOnly: true,
        obscureText: false,
        style: TextStyle(fontSize: 18.0),
        //initialValue: Environment.localUsername(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 18.0),
          hintText: "Ubicación",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          fillColor: Colors.white,
          focusColor: Colors.grey,
          hoverColor: Colors.grey,
          filled: true,
          prefixIcon: Icon(
            Icons.location_pin,
            size: 20,
            color: CustomColors.primary,
          ),
          suffixIcon: InkWell(
            onTap: () {
              cLocation.text = "";
              searchPlace();

              setState(() {
                locationFilter = null;
                locationText = "";
              });
              FocusScope.of(context).unfocus();
            },
            child: Icon(
              FontAwesomeIcons.times,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
              borderRadius: BorderRadius.circular(10.0)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
              borderRadius: BorderRadius.circular(10.0)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
              borderRadius: BorderRadius.circular(10.0)),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.0),
              borderRadius: BorderRadius.circular(10.0)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.0),
              borderRadius: BorderRadius.circular(10.0)),
        ),
        onTap: () async {
          showSearchPlaceDialog();
        });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () {
                        widget.callBackBack("")();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Icon(FontAwesomeIcons.arrowLeft,
                            size: 20, color: CustomColors.primary),
                      ))
                ],
              ),
            ),
            Center(
              child: Container(
                constraints:
                    kIsWeb ? BoxConstraints(maxWidth: 1000) : BoxConstraints(),
                child: Padding(
                  padding: (kIsWeb)
                      ? const EdgeInsets.only(
                          left: 35.0,
                          right: 35.0,
                        )
                      : const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                        ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),

                      ((widget.order.type != "studies_without_prescription"))
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: prescriptionField,
                            )
                          : Container(),

                      SizedBox(
                        height: 20,
                      ),

                      ((widget.order.type != "studies_without_prescription"))
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: DropdownButtonFormField(
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: Colors.grey,
                                ),
                                iconSize: 42,
                                items: types_delivery.map((dynamic type) {
                                  return new DropdownMenuItem(
                                      value: type["tag"],
                                      child: Text(type["es"],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1));
                                }).toList(),
                                onChanged: (type) {
                                  setState(() {
                                    typeDeliverySelected = type ?? "";
                                  });

                                  // do other stuff with _category
                                },
                                value: typeDeliverySelected,
                                decoration: InputDecoration(
                                  labelText: 'Tipo de entrega',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: CustomColors.primary),
                                  ),
                                  border: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            )
                          : Container(),

                      (typeDeliverySelected == "home")
                          ? /*Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  child: locationField,
                                ),
                                MapSelected(placeSelected, selectPlace,
                                    key: mapState)
                              ],
                            )*/
                          Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: addressField,
                            )
                          : Container(),

                      ((widget.order.type != "studies_without_prescription"))
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: dateField,
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: commentsField,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Medios de pago",
                              style: TextStyle(
                                  color: CustomColors.primary, fontSize: 15)),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                typePaymentSelected = "cash";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Efectivo'),
                              leading: Radio<String>(
                                value: "cash",
                                groupValue: typePaymentSelected,
                                onChanged: (String? value) {
                                  setState(() {
                                    typePaymentSelected = value ?? "cash";
                                  });
                                },
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                //  typePaymentSelected = "tj";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Tarjeta (próximamente)',
                                  style: TextStyle(color: Colors.grey)),
                              leading: Radio<String>(
                                value: "tj",
                                toggleable: false,
                                groupValue: typePaymentSelected,
                                onChanged: (String? value) {
                                  setState(() {
                                    //   typePaymentSelected = value??"tj";
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      //new

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              primary: CustomColors.primary2,
                              shape: StadiumBorder()),
                          onPressed: () {
                            if (typeDeliverySelected == "home" &&
                                addressSelected is AddressModel) {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (contextDialog) {
                                    return CustomDialog(
                                      "Confirma que el pedido se enviará a la dirección:",
                                      "${addressSelected.zip_code} ${addressSelected.street} - ${addressSelected.state} - ${addressSelected.municipality}",
                                      "Confirmar",
                                      () {
                                        processConfirm();
                                      },
                                      useBtnCancel: true,
                                      image: '',
                                    );
                                  });
                            } else {
                              processConfirm();
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 35.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Confirmar",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  selectPlace(Place placeTmp) {
    setState(() {
      cLocation.text = placeTmp.formatted_address ?? "";
      placeSelected = placeTmp;
    });
  }

  selectDateTime(Function callback) {
    OverrideDatePicker.showDateTimePicker(context,
        theme: DatePickerTheme(),
        showTitleActions: true,
        minTime: DateTime.now().add(Duration(hours: 1)),
        maxTime: DateTime.now().add(Duration(days: 30)),
        onChanged: (date) {}, onConfirm: (date) {
      setState(() {
        callback(date);
      });
    },
        currentTime: DateTime.now().add(Duration(hours: 1)),
        locale: LocaleType.es);
  }

  processConfirm() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        try {
          final provider = Provider.of<AppProvider>(context, listen: false);
          dynamic orderTmp4 = await WebService(context).editOrder(
              typeDeliverySelected,
              typePaymentSelected,
              ((widget.order.type != "studies_without_prescription"))
                  ? (dateSelected as DateTime)
                      .toUtc()
                      .millisecondsSinceEpoch
                      .toString()
                  : "",
              (placeSelected != null && placeSelected is Place)
                  ? Place().toJson(placeSelected)
                  : "",
              widget.order.id ?? "",
              addressSelected,
              provider.user.token ?? "");

          OrderModel orderTmp = await WebService(context).acceptBudget(
              widget.order.id ?? "",
              widget.budgetAccepted.id ?? "",
              provider.user.token ?? "");

          Navigator.pop(loadingContext);
          SnackBar(
                  content: Text("Se ha aceptado con éxito",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  elevation: 100,
                  duration: Duration(seconds: 2),
                  backgroundColor: CustomColors.primary)
              .show(context);
          widget.callBackBack("to_orders");
        } catch (e) {
          Navigator.pop(loadingContext);
          showErrorsDialog(context, e as dynamic);
        }
      });
    }
  }

  showSearchPlaceDialog() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (contextDialog) {
          final locationField = TextFormField(
            focusNode: _focus,
            autofocus: true,
            textInputAction: TextInputAction.search,
            controller: cLocation,
            keyboardType: TextInputType.text,
            readOnly: false,
            obscureText: false,
            style: TextStyle(fontSize: 18.0),
            //initialValue: Environment.localUsername(),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 18.0),
              hintText: "Buscar",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              fillColor: Colors.white,
              focusColor: Colors.grey,
              hoverColor: Colors.grey,
              filled: true,
              prefixIcon: Icon(
                Icons.location_pin,
                size: 20,
                color: CustomColors.primary,
              ),
              suffixIcon: InkWell(
                onTap: () {
                  cLocation.text = "";
                  searchPlace();

                  setState(() {
                    locationFilter = null;
                    locationText = "";
                  });
                  FocusScope.of(context).unfocus();
                },
                child: Icon(
                  FontAwesomeIcons.times,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ),
              border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.grey.shade400, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0)),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.grey.shade400, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0)),
              enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.grey.shade400, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0)),
              errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.red.shade400, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0)),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.red.shade400, width: 1.0),
                  borderRadius: BorderRadius.circular(10.0)),
            ),

            onTap: () async {},
            onChanged: (value) {
              searchPlace();
            },
          );

          return Dialog(
            insetPadding: EdgeInsets.all(
                (MediaQuery.of(context).size.width >= 1025)
                    ? (MediaQuery.of(context).size.width * .20)
                    : 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            backgroundColor: Colors.white,
            child: ListView(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Icon(FontAwesomeIcons.times,
                          color: CustomColors.primary, size: 30),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: locationField,
              ),
              Container(
                child: StreamBuilder<dynamic>(
                    stream: searchPlacesStream.searchPlacesStreamWhere,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        if (snapshot.data == "searching") {
                          return Container(
                            height: 4,
                            child: LinearProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  CustomColors.primary),
                              backgroundColor: Colors.white,
                            ),
                          );
                        }

                        if ((snapshot.data as List<Suggestion>).length <= 0) {
                          if (locationSearchHasFocus &&
                              cLocation.text.trim() != "") {
                            return Container(
                                height: 20,
                                child: Center(
                                  child: Text("Ningún lugar encontrado"),
                                ));
                          } else {
                            return Container();
                          }
                        }

                        List<Suggestion> places = snapshot.data;
                        return Column(
                          children: places.map((suggestion) {
                            return InkWell(
                              onTap: () {
                                simpleLoading(context,
                                    (BuildContext loadingContext) async {
                                  dynamic place = null;
                                  try {
                                    final provider = Provider.of<AppProvider>(
                                        context,
                                        listen: false);
                                    if (kIsWeb) {
                                      place = await WebService(context)
                                          .reverseGeocodeFromPlaceWeb(
                                              suggestion.placeId,
                                              provider.user.token ?? "");
                                    } else {
                                      place = await WebService(context)
                                          .reverseGeocodeFromPlace(
                                              suggestion.placeId);
                                    }

                                    Navigator.pop(loadingContext);
                                    if (place != null && place is Place) {
                                      searchPlacesStream
                                          .searchPlacesByKeywordWhere(
                                              "", context, "es");
                                      cLocation.text = suggestion.description
                                          .replaceAll("\n", " ");

                                      setState(() {
                                        locationText = suggestion.description;
                                        locationFilter = place;
                                        placeSelected = place;
                                      });
                                      try {
                                        mapState.currentState
                                            .updatePositionMarker(place);
                                      } catch (e) {}
                                      Navigator.pop(context);
                                    } else {
                                      Navigator.pop(loadingContext);
                                      showErrorsDialog(context, [
                                        "Ocurrió un error desconocido, intente de nuevo"
                                      ]);
                                      setState(() {
                                        locationText = "";
                                        locationFilter = null;
                                      });
                                    }
                                  } catch (e) {
                                    print(e);
                                    Navigator.pop(loadingContext);
                                    showErrorsDialog(context,
                                        ["Ocurrió un error desconocido"]);
                                    setState(() {
                                      locationText = "";
                                      locationFilter = null;
                                    });
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Icon(Icons.location_on, size: 20),
                                    ),
                                    Flexible(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            suggestion.description,
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ))
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        if (locationSearchHasFocus &&
                            cLocation.text.trim() != "") {
                          return Container(
                              height: 20,
                              child: Center(
                                child: Text("Ningún lugar encontrado"),
                              ));
                        } else {
                          return Container();
                        }
                      }
                    }),
              )
            ]),
          );
        });
  }
}
