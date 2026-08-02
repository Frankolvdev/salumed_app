import 'dart:typed_data';

import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/components/dialog_avoid_bottom.dart';
import 'package:app/components/map_location.dart';
import 'package:app/components/map_selected.dart';
import 'package:app/components/override_date_picker.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/components/table_medicines.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/address.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/budget.dart';
import 'package:app/models/category.dart';
import 'package:app/models/order.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/place.dart';
import 'package:app/models/suggestion.dart';
import 'package:app/models/user.dart';
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
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:snack/snack.dart';
import 'package:timelines/timelines.dart';
import 'package:universal_io/io.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';

class AdminViewOrder extends StatefulWidget {
  Function callBackBack;
  OrderModel order;
  AdminViewOrder(this.callBackBack, this.order, {Key? key}) : super(key: key);

  @override
  _AdminViewOrderState createState() => _AdminViewOrderState();
}

class _AdminViewOrderState extends State<AdminViewOrder> {
  final cLocation = TextEditingController();
  bool locationSearchHasFocus = false;
  String locationText = "";
  dynamic locationFilter = null;
  FocusNode _focus = new FocusNode();
  GlobalKey<dynamic> mapState = GlobalKey();

  final cShippingCost = TextEditingController();
  final cDrugCost = TextEditingController();

  final formKey = new GlobalKey<FormState>();

  dynamic imageSelected = null;

  List<CategoryModel> categories = [];
  List<UserModel> admins = [];
  late Place placeSelected;

  bool showMap = true;
  bool isHospital = false;

  bool requestInvoice = false;
  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);
    OrderModel o = widget.order;
    imageSelected = o.prescription!.prescription_picture;

    if (o.place != null) {
      placeSelected = o.place!;
      cLocation.text = o.place!.formatted_address ?? "";
    } else {
      placeSelected = new Place(lat: provider.lat, lng: provider.long);
    }

    UserModel user = o.patient!;

    deliverySelected = widget.order.delivery_assigned ?? null;

    isHospital = (user.roles[0].name == "hospital_admin") ? true : false;
    requestInvoice = user.request_invoice == "yes" ? true : false;

    cLocation.text = (o.address != null && o.address is AddressModel)
        ? "${o.address!.zip_code} ${o.address!.street} - ${o.address!.state} - ${o.address!.municipality}"
        : "";
    BackButtonInterceptor.add(myInterceptor);
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
    widget.callBackBack();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    OrderModel pharmacy = widget.order;

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
    );

    OrderModel oTmp = widget.order;

    dynamic budgetAccepted = null;

    if (oTmp.budget_accepted != null) {
      budgetAccepted = oTmp.budget_accepted;
    }
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
                        widget.callBackBack()();
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, left: 8.0, right: 8.0),
                                    child: Text(
                                        ("Folio de pedido: " +
                                            (oTmp.id ?? "").substring(0, 8)),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: CustomColors.primary,
                                            fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1),
                                  ),
                                  (oTmp.patient != null &&
                                          oTmp.patient!.dial_code != null &&
                                          oTmp.patient!.phone != null &&
                                          oTmp.patient!.dial_code != "" &&
                                          oTmp.patient!.phone != "")
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                openWhatsappTel(
                                                    context,
                                                    (oTmp.patient!.dial_code!) +
                                                        (oTmp.patient!.phone!));
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Text((oTmp.patient!.roles[0]
                                                                .name !=
                                                            "hospital_admin")
                                                        ? "Paciente"
                                                        : "Hospital/Clínica"),
                                                    Icon(
                                                        FontAwesomeIcons
                                                            .whatsapp,
                                                        color: Colors.green,
                                                        size: 30)
                                                  ],
                                                ),
                                              ),
                                            ),
                                            (oTmp.delivery_assigned != null &&
                                                    oTmp.delivery_assigned!.dial_code !=
                                                        null &&
                                                    oTmp.delivery_assigned!
                                                            .phone !=
                                                        null &&
                                                    oTmp.delivery_assigned!
                                                            .dial_code !=
                                                        "" &&
                                                    oTmp.delivery_assigned!
                                                            .phone !=
                                                        "")
                                                ? InkWell(
                                                    onTap: () {
                                                      openWhatsappTel(
                                                          context,
                                                          (oTmp.delivery_assigned!
                                                                  .dial_code!) +
                                                              (oTmp
                                                                  .delivery_assigned!
                                                                  .phone!));
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: [
                                                          Text("Repartidor"),
                                                          Icon(
                                                              FontAwesomeIcons
                                                                  .whatsapp,
                                                              color:
                                                                  Colors.green,
                                                              size: 30)
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        )
                                      : Container(),
                                  (widget.order.status == "waiting_delivery" ||
                                          widget.order.status ==
                                              "delivery_assigned")
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2,
                                                primary: CustomColors.primary,
                                                shape: StadiumBorder()),
                                            onPressed: () {
                                              searchDeliveryDialog();
                                            },
                                            child: Container(
                                              width: (deliverySelected == null)
                                                  ? double.infinity
                                                  : 200,
                                              height: 35.0,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    (deliverySelected == null)
                                                        ? "Asignar repartidor"
                                                        : "Cambiar repartidor",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  (widget.order.status == "ready_in_store")
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2,
                                                primary: CustomColors.primary,
                                                shape: StadiumBorder()),
                                            onPressed: () {
                                              completed();
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              height: 35.0,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Marcar como entregado",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  (widget.order.status == "waiting_package")
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2,
                                                primary: CustomColors.primary,
                                                shape: StadiumBorder()),
                                            onPressed: () {
                                              orderReady();
                                            },
                                            child: Container(
                                              width: (deliverySelected == null)
                                                  ? double.infinity
                                                  : 200,
                                              height: 35.0,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    (widget.order.type !=
                                                            "studies_without_prescription")
                                                        ? "Confirmar pedido listo para entrega"
                                                        : "Confirmar estudios listos para entrega",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  (budgetAccepted != null &&
                                          budgetAccepted is BudgetModel)
                                      ? Column(
                                          children: [
                                            Divider(),
                                            (budgetAccepted.pharmacy != null)
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        Text("Por: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    CustomColors
                                                                        .primary,
                                                                fontSize: 16),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 3),
                                                        Flexible(
                                                          child: Text(
                                                              (budgetAccepted
                                                                      .pharmacy!
                                                                      .title ??
                                                                  ""),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 16),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 3),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                            (widget.order.type_delivery ==
                                                    "home")
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      children: [
                                                        Text("Costo de envío: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    CustomColors
                                                                        .primary,
                                                                fontSize: 16),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 3),
                                                        Flexible(
                                                          child: Text(
                                                              (budgetAccepted
                                                                          .cost_delivery ??
                                                                      "") +
                                                                  "  \$",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 16),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 3),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                      (widget.order.type !=
                                                              "studies_without_prescription")
                                                          ? "Costo de medicamentos: "
                                                          : "Costo de estudios",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: CustomColors
                                                              .primary,
                                                          fontSize: 16),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 3),
                                                  Flexible(
                                                    child: Text(
                                                        (budgetAccepted
                                                                    .cost_products ??
                                                                "") +
                                                            "  \$",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 16),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 3),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15.0),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    elevation: 2,
                                                    primary:
                                                        CustomColors.primary,
                                                    shape: StadiumBorder()),
                                                onPressed: () {
                                                  showDialog(
                                                      barrierDismissible: true,
                                                      context: context,
                                                      builder: (contextDialog) {
                                                        return TableMedicines(
                                                            budgetAccepted,
                                                            widget.order);
                                                      });
                                                },
                                                child: Container(
                                                  width:
                                                      (deliverySelected == null)
                                                          ? double.infinity
                                                          : 200,
                                                  height: 35.0,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Ver tabla de costos",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 15.0),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Divider(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Text("Total a cobrar: ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: CustomColors
                                                              .primary,
                                                          fontSize: 16),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 3),
                                                  Flexible(
                                                    child: Text(
                                                        (widget.order
                                                                    .type_delivery ==
                                                                "home")
                                                            ? getTotalOrder(
                                                                        budgetAccepted)
                                                                    .toString() +
                                                                "  \$"
                                                            : (getTotalOrderNoShipping(
                                                                        budgetAccepted)
                                                                    .toString() +
                                                                "  \$"),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.grey,
                                                            fontSize: 16),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 3),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Divider(),
                                          ],
                                        )
                                      : Container(),
                                  (deliverySelected != null)
                                      ? Column(children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Text("Repartidor: ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: CustomColors
                                                            .primary,
                                                        fontSize: 16),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3),
                                                Flexible(
                                                  child: Text(
                                                      deliverySelected.name ??
                                                          "",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.grey,
                                                          fontSize: 16),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 3),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Text("Km al negocio: ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: CustomColors
                                                            .primary,
                                                        fontSize: 16),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3),
                                                Flexible(
                                                  child: Text(
                                                      getDistanceKm(
                                                              (deliverySelected
                                                                      as UserModel)
                                                                  .lat,
                                                              (deliverySelected
                                                                      as UserModel)
                                                                  .long,
                                                              provider
                                                                  .user
                                                                  .pharmacy_assigned!
                                                                  .lat,
                                                              provider
                                                                  .user
                                                                  .pharmacy_assigned!
                                                                  .long,
                                                              formated: true) ??
                                                          "No calculable",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.grey,
                                                          fontSize: 16),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 3),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Text("Km al punto de entrega: ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: CustomColors
                                                            .primary,
                                                        fontSize: 16),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 3),
                                                Flexible(
                                                  child: Text(
                                                      getDistanceKm(
                                                              (deliverySelected
                                                                      as UserModel)
                                                                  .lat,
                                                              (deliverySelected
                                                                      as UserModel)
                                                                  .long,
                                                              widget.order.lat,
                                                              widget.order.long,
                                                              formated: true) ??
                                                          "No calculable",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Colors.grey,
                                                          fontSize: 16),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 3),
                                                ),
                                              ],
                                            ),
                                          ),
                                          (oTmp.status != "go_deliver" &&
                                                  oTmp.status != "completed")
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 15.0),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            elevation: 2,
                                                            primary:
                                                                CustomColors
                                                                    .secondary,
                                                            shape:
                                                                StadiumBorder()),
                                                    onPressed: () {
                                                      assignDelivery(
                                                          (deliverySelected
                                                                      as UserModel)
                                                                  .id ??
                                                              "");
                                                    },
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: 35.0,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "Confirmar repartidor",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 15.0),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container()
                                        ])
                                      : Container(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("Detalles del pedido",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: CustomColors.primary,
                                            fontSize: 18),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3),
                                  ),
                                  Divider(),
                                  (widget.order.type_delivery == "home")
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  showMap = !showMap;
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Icon(Icons.location_pin,
                                                    color: Colors.red,
                                                    size: 30),
                                              ),
                                            )
                                          ],
                                        )
                                      : Container(),
                                  (showMap &&
                                          widget.order.type_delivery == "home")
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  "Ubicación de entrega: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color:
                                                          CustomColors.primary,
                                                      fontSize: 16),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15.0),
                                              child: locationField,
                                            ),
                                            /*  MapLocation(placeSelected,
                                                "Ubicación de entrega",
                                                key: mapState),*/
                                            SizedBox(height: 10)
                                          ],
                                        )
                                      : Container(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text("Recibe: ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: CustomColors.primary,
                                                fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3),
                                        Flexible(
                                          child: Text(oTmp.patient!.name ?? "",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  (isHospital && requestInvoice)
                                      ? Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Text("RFC: ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: CustomColors
                                                              .primary,
                                                          fontSize: 16),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 3),
                                                  Flexible(
                                                    child: Text(
                                                        oTmp.patient!.rfc ?? "",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Colors.grey,
                                                            fontSize: 16),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 3),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Text("Dirección Fiscal: ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: CustomColors
                                                              .primary,
                                                          fontSize: 16),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 3),
                                                  Flexible(
                                                    child: Text(
                                                        oTmp.patient!
                                                                .fiscal_address ??
                                                            "",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Colors.grey,
                                                            fontSize: 16),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 3),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            ListTile(
                                                contentPadding:
                                                    EdgeInsets.all(0),
                                                title: const Text(
                                                    'Solicita factura'),
                                                leading: Checkbox(
                                                  checkColor: Colors.white,
                                                  fillColor:
                                                      MaterialStateProperty
                                                          .resolveWith(
                                                              getColor),
                                                  value: requestInvoice,
                                                  onChanged: (bool? value) {},
                                                )),
                                          ],
                                        )
                                      : Container(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text("Fecha de entrega: ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: CustomColors.primary,
                                                fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3),
                                        Flexible(
                                          child: Text(
                                              (oTmp.date_send != null)
                                                  ? getDateTimeFromStringFormat(
                                                      DateTime.parse(
                                                              oTmp.date_send!)
                                                          .toLocal()
                                                          .toString())
                                                  : "",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text("Tipo de entrega: ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: CustomColors.primary,
                                                fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3),
                                        Flexible(
                                          child: Text(
                                              getTypeSend(
                                                  oTmp.type_delivery ?? "",
                                                  order: oTmp),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text("Forma de pago: ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: CustomColors.primary,
                                                fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3),
                                        Flexible(
                                          child: Text(
                                              getTypePayment(
                                                  oTmp.type_payment ?? ""),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  (widget.order.type !=
                                          "studies_without_prescription")
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, top: 8.0, right: 8.0),
                                          child: Row(
                                            children: [
                                              Text("Receta o prescripción: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color:
                                                          CustomColors.primary,
                                                      fontSize: 16),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  (widget.order.type ==
                                          "studies_without_prescription")
                                      ? Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15.0),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    elevation: 2,
                                                    primary:
                                                        CustomColors.primary,
                                                    shape: StadiumBorder()),
                                                onPressed: () {
                                                  //launchUrl(context, url);

                                                  simpleLoading(context,
                                                      (BuildContext
                                                          loadingContext) {
                                                    final provider = Provider
                                                        .of<AppProvider>(
                                                            context,
                                                            listen: false);
                                                    WebService(context)
                                                        .generatePdfEstudiesLaboratory(
                                                            oTmp.prescription!
                                                                    .id ??
                                                                "",
                                                            provider.user
                                                                    .token ??
                                                                "")
                                                        .then((pdfName) async {
                                                      Navigator.pop(
                                                          loadingContext);
                                                      launchUrl(
                                                          context,
                                                          studiesLaboratoryPdf +
                                                              pdfName);
                                                    }).catchError((e) {
                                                      print(e);
                                                      Navigator.pop(
                                                          loadingContext);
                                                      showErrorsDialog(
                                                          context, e);
                                                    });
                                                  });
                                                },
                                                child: Container(
                                                  height: 35.0,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        FontAwesomeIcons
                                                            .filePdf,
                                                        size: 16,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0),
                                                        child: Text(
                                                          "PDF de estudios ",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12.0),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      : Container(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                              oTmp.prescription!
                                                      .prescription_text ??
                                                  "",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  (imageSelected != null)
                                      ? Container(
                                          height: 200,
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: Container(
                                                  height: 200,
                                                  decoration: new BoxDecoration(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        new BorderRadius.all(
                                                            Radius.circular(
                                                                10.0)),
                                                  ),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder:
                                                        "assets/images/loading-image1.gif",
                                                    image: getImageUrl(
                                                        imageSelected!),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                              Positioned.fill(
                                                  child: InkWell(
                                                onTap: () {
                                                  BottomSheetPictures(
                                                      context, 0, [
                                                    imageSelected
                                                  ]).showBottomSheetPictures();
                                                },
                                                child: Container(
                                                  height: 160,
                                                  decoration: new BoxDecoration(
                                                      color: Colors.transparent,
                                                      borderRadius:
                                                          new BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0))),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              BottomSheetPictures(
                                                                  context, 0, [
                                                                imageSelected
                                                              ]).showBottomSheetPictures();
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Icon(
                                                                FontAwesomeIcons
                                                                    .expandArrowsAlt,
                                                                color:
                                                                    Colors.grey,
                                                                size: 25,
                                                              ),
                                                            ),
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
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      //new
                      (widget.order.status != "cancelled" &&
                              widget.order.status != "completed")
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 2,
                                    primary: Colors.red,
                                    shape: StadiumBorder()),
                                onPressed: () {
                                  showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (contextDialog) {
                                        return CustomDialog(
                                          "",
                                          "¿Realmente desea cancelar el pedido?",
                                          "Cancelar",
                                          () {
                                            cancel();
                                          },
                                          useBtnCancel: true,
                                          image: '',
                                        );
                                      });
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 35.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Cancelar pedido",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container(),
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

  delete(PharmacyModel pharmacy) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return CustomDialog(
            "",
            "¿Realmente desea eliminar el elemento?",
            "Aceptar",
            () {
              simpleLoading(context, (BuildContext loadingContext) {
                final provider =
                    Provider.of<AppProvider>(context, listen: false);

                WebService(context)
                    .deletePharmacy(
                        provider.user.token ?? "", pharmacy.id ?? "")
                    .then((res) {
                  SnackBar(
                          content: Text("Se ha eliminado correctamente",
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          elevation: 100,
                          duration: Duration(seconds: 2),
                          backgroundColor: CustomColors.primary)
                      .show(context);
                  Navigator.pop(loadingContext);
                  widget.callBackBack();
                }).catchError((e) {
                  Navigator.pop(loadingContext);
                  showErrorsDialog(context, e);
                });
              });
            },
            useBtnCancel: true,
            image: '',
          );
        });
  }

  orderReady() async {
    simpleLoading(context, (BuildContext loadingContext) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      try {
        OrderModel orderTmp = await WebService(context)
            .orderReady(widget.order.id ?? "", provider.user.token ?? "");

        Navigator.pop(loadingContext);

        SnackBar(
                content: Text("El cliente ahora podrá pasar por su pedido",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                elevation: 100,
                duration: Duration(seconds: 5),
                backgroundColor: CustomColors.primary)
            .show(context);

        setState(() {
          widget.order = orderTmp;
        });
      } catch (e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e as dynamic);
      }
    });
  }

  completed() async {
    final form = formKey.currentState;

    simpleLoading(context, (BuildContext loadingContext) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      try {
        OrderModel orderTmp = await WebService(context)
            .completeOrder(widget.order.id ?? "", provider.user.token ?? "");

        Navigator.pop(loadingContext);

        SnackBar(
                content: Text("Se ha completado con éxito",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                elevation: 100,
                duration: Duration(seconds: 5),
                backgroundColor: CustomColors.primary)
            .show(context);

        setState(() {
          widget.order = orderTmp;
        });

        widget.callBackBack();
      } catch (e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e as dynamic);
      }
    });
  }

  assignDelivery(String id_delivery) async {
    final form = formKey.currentState;

    simpleLoading(context, (BuildContext loadingContext) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      try {
        OrderModel orderTmp = await WebService(context).assignDelivery(
            widget.order.id ?? "", id_delivery, provider.user.token ?? "");

        Navigator.pop(loadingContext);

        SnackBar(
                content: Text("Se ha asignado el repartidor con éxito",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                elevation: 100,
                duration: Duration(seconds: 5),
                backgroundColor: CustomColors.primary)
            .show(context);

        setState(() {
          widget.order = orderTmp;
        });
      } catch (e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e as dynamic);
      }
    });
  }

  cancel() async {
    simpleLoading(context, (BuildContext loadingContext) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      try {
        dynamic orderTmp = await WebService(context)
            .cancelOrder(widget.order.id ?? "", provider.user.token ?? "");

        Navigator.pop(loadingContext);
        SnackBar(
                content: Text("Se ha cancelado con éxito",
                    style: TextStyle(
                      color: Colors.white,
                    )),
                elevation: 100,
                duration: Duration(seconds: 5),
                backgroundColor: CustomColors.primary)
            .show(context);
      } catch (e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e as dynamic);
      }
    });
  }

  List<UserModel> dealersFind = [];
  String messageFound = "";
  searchDealer() {
    simpleLoading(context, (BuildContext contextDialog) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      return WebService(context)
          .getUsers(0, 0, context, provider.user.token ?? "",
              search: cSearch.text, filter_rol: "delivery")
          .then((value) {
        if (value.length <= 0) {
          messageFound = "No fue encontrado ningún repartidor";
        } else {
          messageFound = "";
        }

        setState(() {
          dealersFind = value;
        });

        try {
          _setStateDealers(() {});
        } catch (e) {}
        Navigator.pop(contextDialog);
      }).catchError((e) {
        Navigator.pop(contextDialog);
        showErrorsDialog(context, e);
      });
    });
  }

  final formKeysearchDelivery = new GlobalKey<FormState>();
  final cSearch = TextEditingController();
  late StateSetter _setStateDealers;

  dynamic deliverySelected = null;
  final cDelivery = TextEditingController();

  searchDeliveryDialog() {
    final provider = Provider.of<AppProvider>(context, listen: false);

    Widget searchField = TextField(
      autofocus: false,
      controller: cSearch,
      style: TextStyle(color: Colors.black),
      textInputAction: TextInputAction.search,
      //maxLength: 1,
      textAlign: TextAlign.left,

      //focusNode: myFocusNode1,
      decoration: InputDecoration(
          counterText: '',
          hintText: "Correo electrónico o nombre completo",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: InkWell(
            onTap: () {
              cSearch.text = "";
              //_refreshIndicatorKey.currentState!.show();
              searchDealer();
            },
            child: Icon(
              Icons.cancel,
              size: 20,
              color: CustomColors.primary,
            ),
          ),
          suffixIcon: InkWell(
            splashColor: CustomColors.primary,
            onTap: () {
              // _refreshIndicatorKey.currentState!.show();
              searchDealer();
            },
            child: Icon(
              Icons.search,
              size: 20,
              color: CustomColors.primary,
            ),
          ),
          //contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          contentPadding: const EdgeInsets.fromLTRB(45, 0, 0, 0),
          //contentPadding: EdgeInsets.zero,
          filled: true,
          isDense: true,
          fillColor: Colors.grey[300],
          focusColor: Colors.grey[200],
          hoverColor: Colors.grey[200],
          enabledBorder: OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Colors.transparent, width: 0.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: BorderSide(color: Colors.transparent, width: 0.0),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          border: InputBorder.none),
      onChanged: (valueSearch) {},
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(FocusNode());
        // _refreshIndicatorKey.currentState!.show();
        searchDealer();
      },
    );

    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (contextDialog) {
          return DialogAvoidBottom(
            content: StatefulBuilder(builder: (context, setStateT) {
              _setStateDealers = setStateT;
              return Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                        top: 16, bottom: 16, left: 16, right: 16),
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
                        key: formKeysearchDelivery,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 16.0,
                            ),
                            searchField,
                            (messageFound != "")
                                ? Center(
                                    child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(messageFound),
                                  ))
                                : Container(),
                            Container(
                              height:
                                  (MediaQuery.of(context).size.height * .50),
                              child: ListView(
                                children: [
                                  Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: dealersFind.map((delivery) {
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              deliverySelected = delivery;
                                              cDelivery.text =
                                                  delivery.name ?? "Sin nombre";
                                            });

                                            setStateT(() {});
                                            Navigator.pop(context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 8),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Column(children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            children: [
                                                              Text("Nombre: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: CustomColors
                                                                          .primary,
                                                                      fontSize:
                                                                          16),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 3),
                                                              Flexible(
                                                                child: Text(
                                                                    delivery.name ??
                                                                        "",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            16),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines:
                                                                        3),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                  "Km al negocio: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: CustomColors
                                                                          .primary,
                                                                      fontSize:
                                                                          16),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 3),
                                                              Flexible(
                                                                child: Text(
                                                                    getDistanceKm(
                                                                            (delivery as UserModel)
                                                                                .lat,
                                                                            (delivery as UserModel)
                                                                                .long,
                                                                            provider
                                                                                .user.pharmacy_assigned!.lat,
                                                                            provider
                                                                                .user.pharmacy_assigned!.long,
                                                                            formated:
                                                                                true) ??
                                                                        "No calculable",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            16),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines:
                                                                        3),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                  "Km al punto de entrega: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      color: CustomColors
                                                                          .primary,
                                                                      fontSize:
                                                                          16),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 3),
                                                              Flexible(
                                                                child: Text(
                                                                    getDistanceKm(
                                                                            (delivery as UserModel)
                                                                                .lat,
                                                                            (delivery as UserModel)
                                                                                .long,
                                                                            widget
                                                                                .order.lat,
                                                                            widget
                                                                                .order.long,
                                                                            formated:
                                                                                true) ??
                                                                        "No calculable",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            16),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines:
                                                                        3),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ]),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Icon(
                                                          FontAwesomeIcons
                                                              .chevronRight,
                                                          size: 25,
                                                          color: Colors.grey),
                                                    )
                                                  ],
                                                ),
                                                Divider(
                                                  height: 2,
                                                  color: CustomColors.primary,
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList())
                                ],
                              ),
                            ),
                            Container(
                              height: 50,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: MaterialButton(
                                        onPressed: () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                        },
                                        child: Text("Cancelar")),
                                  ),
                                  Expanded(
                                    child: MaterialButton(
                                        onPressed: () {
                                          searchDealer();
                                        },
                                        child: Text("Buscar")),
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
                  )
                ],
              );
            }),
          );
        });

    searchDealer();
  }
}
