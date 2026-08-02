import 'dart:typed_data';

import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/components/map_location.dart';
import 'package:app/components/map_selected.dart';
import 'package:app/components/override_date_picker.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/components/table_medicines.dart';
import 'package:app/components/view_full_map.dart';
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
import 'package:app/pages/client/client_confirm_order.dart';
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

class ClientViewOrder extends StatefulWidget {
  Function callBackBack;
  OrderModel order;
  ClientViewOrder(this.callBackBack, this.order, {Key? key}) : super(key: key);

  @override
  _ClientViewOrderState createState() => _ClientViewOrderState();
}

class _ClientViewOrderState extends State<ClientViewOrder> {
  final cLocation = TextEditingController();
  final cLocationReady = TextEditingController();
  bool locationSearchHasFocus = false;
  String locationText = "";
  dynamic locationFilter = null;
  FocusNode _focus = new FocusNode();
  GlobalKey<dynamic> mapState = GlobalKey();

  final cShippingCost = TextEditingController();
  final cDrugCost = TextEditingController();

  final formKey = new GlobalKey<FormState>();

  dynamic imageSelected = null;

  dynamic adminSelected = null;
  List<CategoryModel> categories = [];
  List<UserModel> admins = [];
  late Place placeSelected;
  dynamic placeBusiness;
  late String rolSelected;

  bool showMap = false;

  dynamic confirmPrescription = null;
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

    try {
      cLocationReady.text =
          o.budget_accepted!.pharmacy!.place!.formatted_address ?? "";
      placeBusiness = o.budget_accepted!.pharmacy!.place;
    } catch (e) {}
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

    if (confirmPrescription != null && budgetSelected != null) {
      return ClientConfirmOrder((val) {
        setState(() {
          confirmPrescription = null;
          budgetSelected = null;
        });
        if (val == "to_orders") {
          widget.callBackBack();
        }
      }, confirmPrescription, budgetSelected, oTmp);
    } else {
      print("ENTRE A NO BUDGET ACCEPTED");
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
                                  (budgetAccepted != null &&
                                          budgetAccepted is BudgetModel)
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Divider(),
                                              (budgetAccepted.pharmacy != null)
                                                  ? Row(
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
                                                    )
                                                  : Container(),
                                              (widget.order.type_delivery ==
                                                      "home")
                                                  ? Row(
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
                                                    )
                                                  : Container(),
                                              Row(
                                                children: [
                                                  Text(
                                                      (widget.order.type !=
                                                              "studies_without_prescription")
                                                          ? "Costo de medicamentos: "
                                                          : "Costo de estudios: ",
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
                                              (widget.order.type ==
                                                      "studies_without_prescription")
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                              "Acude con tu identificación oficial y el número de folio de tu pedido",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  color: CustomColors
                                                                      .primary,
                                                                  fontSize: 16),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 3),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                              "Ubicación para realizar tus estudios: ",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  color: CustomColors
                                                                      .primary,
                                                                  fontSize: 16),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 3),
                                                        ),
                                                        MapLocation(
                                                            placeBusiness,
                                                            "Aquí puedes realizar tus estudios",
                                                            key: mapState,
                                                            subtitleMarker: (widget
                                                                        .order
                                                                        .budget_accepted !=
                                                                    null)
                                                                ? (widget
                                                                        .order
                                                                        .budget_accepted!
                                                                        .pharmacy!
                                                                        .title ??
                                                                    "")
                                                                : ""),
                                                        SizedBox(height: 10)
                                                      ],
                                                    )
                                                  : Container(),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15.0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          elevation: 2,
                                                          primary: CustomColors
                                                              .primary2,
                                                          shape:
                                                              StadiumBorder()),
                                                  onPressed: () {
                                                    showDialog(
                                                        barrierDismissible:
                                                            true,
                                                        context: context,
                                                        builder:
                                                            (contextDialog) {
                                                          return TableMedicines(
                                                              budgetAccepted,
                                                              widget.order,
                                                              isPatient: true);
                                                        });
                                                  },
                                                  child: Container(
                                                    height: 35.0,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Ver tabla de costos",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 15.0),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Text("Total a pagar: ",
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
                                                        getTotalOrder(
                                                                    budgetAccepted)
                                                                .toString() +
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
                                              Divider(),
                                            ],
                                          ),
                                        )
                                      : Container(),
                                  getStep(),
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
                                  (showMap)
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
                                            /* MapLocation(placeSelected,
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
                                  (widget.order.type !=
                                          "studies_without_prescription")
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                    oTmp.prescription!
                                                            .prescription_text ??
                                                        "",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: Colors.grey,
                                                        fontSize: 16),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 500),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(),
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
                                          "Cancelar pedido",
                                          () {
                                            cancel();
                                          },
                                          useBtnCancel: true,
                                          textBtnCancel: "Cerrar",
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

  Widget getStep() {
    if (widget.order.status == "pendient") {
      return step_pending();
    } else if (widget.order.status == "budget_acceptance_pending") {
      return step_budget_acceptance_pending();
    } else if (widget.order.status == "waiting_delivery" ||
        widget.order.status == "waiting_package") {
      return step_waiting_delivery();
    } else if (widget.order.status == "delivery_assigned") {
      return step_delivery_assigned();
    } else if (widget.order.status == "ready_in_store") {
      return step_ready_in_store();
    } else if (widget.order.status == "completed") {
      return step_completed();
    } else if (widget.order.status == "go_deliver") {
      return step_go_deliver();
    } else if (widget.order.status == "cancelled") {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Orden cancelada",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget step_completed() {
    if (widget.order.type_delivery == "home") {
      return Stepper(
        physics: const NeverScrollableScrollPhysics(),
        steps: [
          Step(
              isActive: true,
              title: Text("Aceptar costos"),
              content: Container()),
          Step(
            isActive: true,
            title: Text("Tu pedido fue asignado a un repartidor"),
            content: Text(
              "Asignando repartidor",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Step(
            isActive: true,
            title: Text("Tu pedido esta en camino a tu domicilio"),
            content: Text("Ten a la mano el monto a pagar"),
          ),
          Step(
            isActive: true,
            title: Text(
              "Tu pedido fue entregado",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            content: Text(""),
          ),
        ],
        currentStep: 3,
        controlsBuilder: (context, details) {
          return Container();
        },
      );
    } else {
      return Stepper(
        physics: const NeverScrollableScrollPhysics(),
        steps: [
          Step(
              isActive: true,
              title: Text("Aceptar costos"),
              content: Container()),
          Step(
            isActive: true,
            title: (widget.order.type != "studies_without_prescription")
                ? Text("Puedes pasar a recoger tu pedido")
                : Text("Puedes pasar a recoger tus estudios"),
            content: Container(),
          ),
          Step(
            isActive: true,
            title: Text(
              "Tu pedido fue entregado",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            content: Container(),
          ),
        ],
        currentStep: 2,
        controlsBuilder: (context, details) {
          return Container();
        },
      );
    }
  }

  Widget step_budget_acceptance_pending() {
    if (widget.order.type_delivery == "home") {
      return Stepper(
        physics: const NeverScrollableScrollPhysics(),
        steps: [
          Step(
              isActive: true,
              title: Text("Aceptar costos"),
              content: Container(
                child: Column(
                    children: widget.order.budgets!.asMap().entries.map((e) {
                  BudgetModel budget = e.value;

                  OrderModel order = widget.order;
                  return Column(
                    children: [
                      ResponsiveGridRow(
                        children: [
                          ResponsiveGridCol(
                            lg: 7,
                            xs: 12,
                            md: 12,
                            child: Column(
                              children: [
                                (budget.pharmacy != null)
                                    ? Row(
                                        children: [
                                          Text("Por: ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: CustomColors.primary,
                                                  fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3),
                                          Flexible(
                                            child: Text(
                                                (budget.pharmacy!.title ?? ""),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.grey,
                                                    fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  PageTransition(
                                                      child: ViewFullMap(
                                                          budget.pharmacy!),
                                                      type: PageTransitionType
                                                          .slideInUp,
                                                      duration: Duration(
                                                          milliseconds: 250)));
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(Icons.location_pin,
                                                  color: Colors.red, size: 30),
                                            ),
                                          )
                                        ],
                                      )
                                    : Container(),
                                Row(
                                  children: [
                                    Text("Costo de envío: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: CustomColors.primary,
                                            fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3),
                                    Flexible(
                                      child: Text(
                                          (budget.cost_delivery ?? "") + "  \$",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey,
                                              fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        (widget.order.type !=
                                                "studies_without_prescription")
                                            ? "Costo de medicamentos: "
                                            : "Costo de estudios: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: CustomColors.primary,
                                            fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3),
                                    Flexible(
                                      child: Text(
                                          (budget.cost_products ?? "") + "  \$",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey,
                                              fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text("Total: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: CustomColors.primary,
                                            fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3),
                                    Flexible(
                                      child: Text(
                                          getTotalOrder(budget).toString() +
                                              "  \$",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey,
                                              fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ResponsiveGridCol(
                            lg: 5,
                            xs: 12,
                            md: 12,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 2,
                                    primary: CustomColors.primary2,
                                    shape: StadiumBorder()),
                                onPressed: () {
                                  //  acceptBudget(budget.id ?? "");

                                  setState(() {
                                    confirmPrescription =
                                        widget.order.prescription;

                                    budgetSelected = budget;
                                  });
                                },
                                child: Container(
                                  constraints: BoxConstraints(minWidth: 200),
                                  height: 35.0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Aceptar total de " +
                                            getTotalOrder(budget).toString() +
                                            "  \$",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider()
                    ],
                  );
                }).toList()),
              )),
          Step(
            title: Text("Tu pedido fue asignado a un repartidor"),
            content: Text(""),
          ),
          Step(
            title: Text("Tu pedido esta en camino a tu domicilio"),
            content: Text("Ten a la mano el monto a pagar"),
          ),
          Step(
            title: Text("Tu pedido fue entregado"),
            content: Text(""),
          ),
        ],
        currentStep: 0,
        controlsBuilder: (context, details) {
          return Container();
        },
      );
    } else {
      return Stepper(
        physics: const NeverScrollableScrollPhysics(),
        steps: [
          Step(
              isActive: true,
              title: Text("Aceptar costos"),
              content: Container(
                child: Column(
                    children: widget.order.budgets!.asMap().entries.map((e) {
                  BudgetModel budget = e.value;

                  OrderModel order = widget.order;
                  return Column(
                    children: [
                      ResponsiveGridRow(
                        children: [
                          ResponsiveGridCol(
                            lg: 7,
                            xs: 12,
                            md: 12,
                            child: Column(
                              children: [
                                (budget.pharmacy != null)
                                    ? Row(
                                        children: [
                                          Text("Por: ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: CustomColors.primary,
                                                  fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3),
                                          Flexible(
                                            child: Text(
                                                (budget.pharmacy!.title ?? ""),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.grey,
                                                    fontSize: 16),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                Row(
                                  children: [
                                    Text(
                                        (widget.order.type !=
                                                "studies_without_prescription")
                                            ? "Costo de medicamentos: "
                                            : "Costo de estudios: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: CustomColors.primary,
                                            fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3),
                                    Flexible(
                                      child: Text(
                                          (budget.cost_products ?? "") + "  \$",
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey,
                                              fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 3),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text("Total: ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: CustomColors.primary,
                                                fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3),
                                        Flexible(
                                          child: Text(
                                              getTotalOrderNoShipping(budget)
                                                      .toString() +
                                                  "  \$",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3),
                                        ),
                                      ],
                                    ),
                                    (widget.order.type !=
                                            "studies_without_prescription")
                                        ? Row(
                                            children: [
                                              Text("Total con envio: ",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color:
                                                          CustomColors.primary,
                                                      fontSize: 16),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3),
                                              Flexible(
                                                child: Text(
                                                    getTotalOrder(budget)
                                                            .toString() +
                                                        "  \$",
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
                                          )
                                        : Container(),
                                  ],
                                )
                              ],
                            ),
                          ),
                          ResponsiveGridCol(
                              lg: 5,
                              xs: 12,
                              md: 12,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 2,
                                            primary: CustomColors.primary2,
                                            shape: StadiumBorder()),
                                        onPressed: () {
                                          //  acceptBudget(budget.id ?? "");

                                          setState(() {
                                            confirmPrescription =
                                                widget.order.prescription;
                                            budgetSelected = budget;
                                          });
                                        },
                                        child: Container(
                                          constraints:
                                              BoxConstraints(minWidth: 200),
                                          height: 35.0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Aceptar",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15.0),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 2,
                                            primary: CustomColors.primary2,
                                            shape: StadiumBorder()),
                                        onPressed: () {
                                          showDialog(
                                              barrierDismissible: true,
                                              context: context,
                                              builder: (contextDialog) {
                                                return TableMedicines(
                                                  budget,
                                                  widget.order,
                                                  isPatient: true,
                                                );
                                              });
                                        },
                                        child: Container(
                                          constraints:
                                              BoxConstraints(minWidth: 200),
                                          height: 35.0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                  ],
                                ),
                              )),
                        ],
                      ),
                      Divider()
                    ],
                  );
                }).toList()),
              )),
          Step(
            title: (widget.order.type != "studies_without_prescription")
                ? Text("Puedes pasar a recoger tu pedido")
                : Text("Puedes pasar a recoger tus estudios"),
            content: Text(""),
          ),
          Step(
            title: Text("Tu pedido fue entregado"),
            content: Text(""),
          ),
        ],
        currentStep: 0,
        controlsBuilder: (context, details) {
          return Container();
        },
      );
    }
  }

  Widget step_pending() {
    if (widget.order.type_delivery == "home") {
      return Stepper(
        physics: const NeverScrollableScrollPhysics(),
        steps: [
          Step(
              isActive: false,
              title: Text("Aceptar costos"),
              content: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Aquí aparecerán los presupuestos de los medicamentos/productos de tu pedido",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Cuando aparezcan podrás elegir uno y seguir con tu pedido.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              )),
          Step(
            title: Text("Tu pedido fue asignado a un repartidor"),
            content: Text(""),
          ),
          Step(
            title: Text("Tu pedido esta en camino a tu domicilio"),
            content: Text("Ten a la mano el monto a pagar"),
          ),
          Step(
            title: Text("Tu pedido fue entregado"),
            content: Text(""),
          ),
        ],
        currentStep: 0,
        controlsBuilder: (context, details) {
          return Container();
        },
      );
    } else {
      return Stepper(
        physics: const NeverScrollableScrollPhysics(),
        steps: [
          Step(
              isActive: false,
              title: Text("Aceptar costos"),
              content: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Aquí aparecerán los presupuestos de los medicamentos/productos de tu pedido",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Cuando aparezcan podrás elegir uno y seguir con tu pedido.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              )),
          Step(
            title: (widget.order.type != "studies_without_prescription")
                ? Text("Puedes pasar a recoger tu pedido")
                : Text("Puedes pasar a recoger tus estudios"),
            content: Text(""),
          ),
          Step(
            title: Text("Tu pedido fue entregado"),
            content: Text(""),
          ),
        ],
        currentStep: 0,
        controlsBuilder: (context, details) {
          return Container();
        },
      );
    }
  }

  Widget step_delivery_assigned() {
    return Stepper(
      physics: const NeverScrollableScrollPhysics(),
      steps: [
        Step(
            isActive: true,
            title: Text("Aceptar costos"),
            content: Container()),
        Step(
          isActive: true,
          title: Text("Tu pedido fue asignado a un repartidor"),
          content: Container(),
        ),
        Step(
          title: Text("Tu pedido esta en camino a tu domicilio"),
          content: Text("Ten a la mano el monto a pagar"),
        ),
        Step(
          title: Text("Tu pedido fue entregado"),
          content: Text(""),
        ),
      ],
      currentStep: 1,
      controlsBuilder: (context, details) {
        return Container();
      },
    );
  }

  Widget step_ready_in_store() {
    final locationReadyField = TextFormField(
      controller: cLocationReady,
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

    return Stepper(
      physics: const NeverScrollableScrollPhysics(),
      steps: [
        Step(
            isActive: true,
            title: Text(
              "Aceptar costos",
              style: TextStyle(color: Colors.grey),
            ),
            content: Container()),
        Step(
          isActive: true,
          title: (widget.order.type != "studies_without_prescription")
              ? Text("Puedes pasar a recoger tu pedido")
              : Text("Puedes pasar a recoger tus estudios"),
          content: (placeBusiness != null)
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          "Acude con tu identificación oficial y el número de folio de tu pedido",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: CustomColors.primary,
                              fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Ubicación de entrega: ",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: CustomColors.primary,
                              fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: locationReadyField,
                    ),
                    MapLocation(placeBusiness, "Aquí puedes recojer tu paquete",
                        key: mapState,
                        subtitleMarker: (widget.order.budget_accepted != null)
                            ? (widget.order.budget_accepted!.pharmacy!.title ??
                                "")
                            : ""),
                    SizedBox(height: 10)
                  ],
                )
              : Container(),
        ),
        Step(
          title: Text("Tu pedido fue entregado"),
          content: Text(""),
        ),
      ],
      currentStep: 1,
      controlsBuilder: (context, details) {
        return Container();
      },
    );
  }

  Widget step_go_deliver() {
    return Stepper(
      physics: const NeverScrollableScrollPhysics(),
      steps: [
        Step(
            isActive: true,
            title: Text("Aceptar costos"),
            content: Container()),
        Step(
          isActive: true,
          title: Text("Tu pedido fue asignado a un repartidor"),
          content: Text(
            "Asignando repartidor",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Step(
          isActive: true,
          title: Text("Tu pedido esta en camino a tu domicilio"),
          content: Text("Ten preparado el total a pagar"),
        ),
        Step(
          title: Text("Tu pedido fue entregado"),
          content: Text(""),
        ),
      ],
      currentStep: 2,
      controlsBuilder: (context, details) {
        return Container();
      },
    );
  }

  Widget step_waiting_delivery() {
    if (widget.order.type_delivery == "home") {
      return Stepper(
        physics: const NeverScrollableScrollPhysics(),
        steps: [
          Step(
              isActive: true,
              title: Text("Aceptar costos"),
              content: Container()),
          Step(
            title: Text("Tu pedido fue asignado a un repartidor"),
            content: Text(
              "Asignando repartidor",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Step(
            title: Text("Tu pedido esta en camino a tu domicilio"),
            content: Text("Ten a la mano el monto a pagar"),
          ),
          Step(
            title: Text("Tu pedido fue entregado"),
            content: Text(""),
          ),
        ],
        currentStep: 1,
        controlsBuilder: (context, details) {
          return Container();
        },
      );
    } else {
      return Stepper(
        physics: const NeverScrollableScrollPhysics(),
        steps: [
          Step(
              isActive: true,
              title: Text(
                "Aceptar costos",
                style: TextStyle(color: Colors.grey),
              ),
              content: Container()),
          Step(
            title: (widget.order.type != "studies_without_prescription")
                ? Text("Puedes pasar a recoger tu pedido")
                : Text("Puedes pasar a recoger tus estudios"),
            content: (widget.order.type != "studies_without_prescription")
                ? Text("Preparando el paquete")
                : Text("Tus estudios estan listos"),
          ),
          Step(
            title: Text("Tu pedido fue entregado"),
            content: Text(""),
          ),
        ],
        currentStep: 1,
        controlsBuilder: (context, details) {
          return Container();
        },
      );
    }
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

  selectPlace(Place placeTmp) {
    setState(() {
      cLocation.text = placeTmp.formatted_address ?? "";
      placeSelected = placeTmp;
    });
  }

  selectDateTime(Function callback) {
    OverrideDatePicker.showDatePicker(context,
        theme: DatePickerTheme(),
        showTitleActions: true,
        maxTime: DateTime.now(),
        onChanged: (date) {}, onConfirm: (date) {
      setState(() {
        callback(date);
      });
    },
        currentTime: DateTime.now().subtract(Duration(days: 7300)),
        locale: LocaleType.es);
  }

  dynamic budgetSelected = null;
  selectBudget(BudgetModel budget) {
    setState(() {
      budgetSelected = budget;
    });
  }

  acceptBudget(String idBudget) async {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);
        try {
          OrderModel orderTmp = await WebService(context).acceptBudget(
              widget.order.id ?? "", idBudget, provider.user.token ?? "");

          Navigator.pop(loadingContext);

          SnackBar(
                  content: Text("Se ha aceptado con éxito",
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
        widget.callBackBack();
      } catch (e) {
        Navigator.pop(loadingContext);
        showErrorsDialog(context, e as dynamic);
      }
    });
  }
}
