import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/address.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:editable/commons/math_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:snack/snack.dart';

import '../../components/map_selected.dart';
import '../../models/place.dart';
import '../../models/suggestion.dart';
import '../../streams/search_places_stream.dart';

class ClientAddAdress extends StatefulWidget {
  const ClientAddAdress({Key? key}) : super(key: key);

  @override
  State<ClientAddAdress> createState() => _ClientAddAdressState();
}

class _ClientAddAdressState extends State<ClientAddAdress> {
  final cZipCode = TextEditingController();
  final cStreet = TextEditingController();
  final cMunicipality = TextEditingController();
  final cState = TextEditingController();
  final cSuburb = TextEditingController();
  final cNumExt = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isDelivery = false;
  final cLocation = TextEditingController();
  dynamic locationFilter = null;
  String locationText = "";
  FocusNode _focus = new FocusNode();
  bool locationSearchHasFocus = false;
  late Place placeSelected;
  GlobalKey<dynamic> mapState = GlobalKey();
  bool placeSelectedStatus = false;
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);

    placeSelected = new Place(lat: provider.lat, lng: provider.long);
  }


bool cancelScroll=false;


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

    final zipCodeField = TextFormField(
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.next,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      controller: cZipCode,
      keyboardType: TextInputType.number,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      maxLength: 5,

      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration.copyWith(
          contentPadding: EdgeInsets.fromLTRB(4.0, 15.0, 2.0, 15.0)),
      onFieldSubmitted: (val) {},
    );

    final streetField = TextFormField(
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.next,
      controller: cStreet,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration.copyWith(
          contentPadding: EdgeInsets.fromLTRB(4.0, 15.0, 2.0, 15.0)),
      onFieldSubmitted: (val) {},
    );

    final stateField = TextFormField(
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.next,
      controller: cState,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration.copyWith(
          contentPadding: EdgeInsets.fromLTRB(4.0, 15.0, 2.0, 15.0)),
      onFieldSubmitted: (val) {},
    );

    final municipalityField = TextFormField(
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.next,
      controller: cMunicipality,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration.copyWith(
          contentPadding: EdgeInsets.fromLTRB(4.0, 15.0, 2.0, 15.0)),
      onFieldSubmitted: (val) {},
    );

    final suburbField = TextFormField(
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.next,
      controller: cSuburb,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration.copyWith(
          contentPadding: EdgeInsets.fromLTRB(4.0, 15.0, 2.0, 15.0)),
      onFieldSubmitted: (val) {},
    );

    final numExtField = TextFormField(
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.next,

      controller: cNumExt,
      keyboardType: TextInputType.number,
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      maxLength: 5,

      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: fieldsDecoration.copyWith(
          contentPadding: EdgeInsets.fromLTRB(4.0, 15.0, 2.0, 15.0)),
      onFieldSubmitted: (val) {},
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
        appBar: AppBar(
          title: Text(
            "Dirección",
            style: TextStyle(color: CustomColors.primary),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: CustomColors.primary),
            onPressed: () => Navigator.pop(context, false),
          ),
        ),
        body: ListView(
        
        physics: (cancelScroll)? NeverScrollableScrollPhysics() :null,
          children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Text("Código postal",
                            style: TextStyle(
                                color: CustomColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.normal)),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 0.0),
                          child: zipCodeField),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Text("Estado",
                            style: TextStyle(
                                color: CustomColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.normal)),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 0.0),
                          child: stateField),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Text("Municipio/Alcaldía",
                            style: TextStyle(
                                color: CustomColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.normal)),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 0.0),
                          child: municipalityField),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Text("Colonia",
                            style: TextStyle(
                                color: CustomColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.normal)),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 0.0),
                          child: suburbField),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Text("Calle",
                            style: TextStyle(
                                color: CustomColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.normal)),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 0.0),
                          child: streetField),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        child: Text("Número",
                            style: TextStyle(
                                color: CustomColors.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.normal)),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 0.0),
                          child: numExtField),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: locationField,
                      ),
                      MapSelected(placeSelected, selectPlace,(status){
          
                setState(() {
              cancelScroll=status;
                    });
                      }, key: mapState)
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isDelivery = !isDelivery;
                      });
                    },
                    child: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title:
                            const Text('¿Este será el domicilio de entrega?'),
                        leading: Checkbox(
                          checkColor: Colors.white,
                          fillColor:
                              MaterialStateProperty.resolveWith(getColor),
                          value: isDelivery,
                          onChanged: (bool? value) {
                            setState(() {
                              isDelivery = !isDelivery;
                            });
                          },
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 2,
                          backgroundColor: CustomColors.primary2,
                          shape: StadiumBorder()),
                      onPressed: () {
                        addAddress();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 35.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Agregar",
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
          )
          ],
        ));
  }

  var searchPlacesStream = new SearchPlacesStream();
  void searchPlace() {
    searchPlacesStream.searchPlacesByKeywordWhere(
        cLocation.text.isEmpty ? "" : cLocation.text, context, "es");
  }

  selectPlace(Place placeTmp) {
    setState(() {
      //  cLocation.text = placeTmp.formatted_address ?? "";
      placeSelectedStatus = true;
      placeSelected = placeTmp;
    });
  }

  addAddress() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      if (placeSelectedStatus == false) {
        showErrorsDialog(context, ["Seleccione el lugar en el mapa"]);
        return;
      }
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);
        try {
          List<AddressModel> addressess = await WebService(context)
              .addAddressUser(
                  cZipCode.text,
                  cStreet.text,
                  cMunicipality.text,
                  cState.text,
                  cSuburb.text,
                  (isDelivery) ? "true" : "false",
                  cNumExt.text,
                  (placeSelected != null && placeSelected is Place)
                      ? Place().toJson(placeSelected)
                      : "",
                  provider.user.token ?? "");
          provider.user.addresses = addressess;
          await provider.setUser(provider.user);
          Navigator.pop(loadingContext);

          SnackBar(
                  content: Text("Se ha guardado con éxito",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  elevation: 100,
                  duration: Duration(seconds: 2),
                  backgroundColor: CustomColors.primary)
              .show(context);
          Navigator.pop(context);
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
                                        placeSelectedStatus = true;
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
