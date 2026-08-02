import 'dart:typed_data';

import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/components/map_location.dart';
import 'package:app/components/map_selected.dart';
import 'package:app/components/override_date_picker.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
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

class DeliveryViewOrder extends StatefulWidget {
  Function callBackBack;
  OrderModel order;
  DeliveryViewOrder(this.callBackBack, this.order, {Key? key})
      : super(key: key);

  @override
  _DeliveryViewOrderState createState() => _DeliveryViewOrderState();
}

class _DeliveryViewOrderState extends State<DeliveryViewOrder> {
  final cLocation = TextEditingController();
  final cBusinessLocation = TextEditingController();
  bool locationSearchHasFocus = false;
  String locationText = "";
  dynamic locationFilter = null;
  FocusNode _focus = new FocusNode();
  GlobalKey<dynamic> mapState = GlobalKey();
  GlobalKey<dynamic> mapState2 = GlobalKey();

  final cShippingCost = TextEditingController();
  final cDrugCost = TextEditingController();

  final formKey = new GlobalKey<FormState>();

  dynamic imageSelected = null;

  List<CategoryModel> categories = [];
  List<UserModel> admins = [];
  late Place placeSelected;

  late String rolSelected;

  bool showMap = true;

  dynamic deliverySelected = null;
  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);
    OrderModel o = widget.order;
    imageSelected = o.prescription!.prescription_picture;

    placeSelected = o.place!;
    cLocation.text = o.place!.formatted_address ?? "";

    deliverySelected = widget.order.delivery_assigned ?? null;

    cBusinessLocation.text =
        o.budget_accepted!.pharmacy!.place!.formatted_address ?? "";
    BackButtonInterceptor.add(myInterceptor);
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

    final locationBusinessField = TextFormField(
      controller: cBusinessLocation,
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          openWhatsappTel(
                                              context,
                                              (oTmp.patient!.dial_code!) +
                                                  (oTmp.patient!.phone!));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(FontAwesomeIcons.whatsapp,
                                              color: Colors.green, size: 30),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            showMap = !showMap;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(Icons.location_pin,
                                              color: Colors.red, size: 30),
                                        ),
                                      )
                                    ],
                                  ),
                                  (oTmp.status == "delivery_assigned")
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2,
                                                backgroundColor: CustomColors.primary,
                                                shape: StadiumBorder()),
                                            onPressed: () {
                                              showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (contextDialog) {
                                                    return CustomDialog(
                                                      "",
                                                      "¿Realmente tengo el pedido listo para ir a entregar?",
                                                      "Sí",
                                                      () {
                                                        goDeliver();
                                                      },
                                                      useBtnCancel: true,
                                                      image: '',
                                                      textBtnCancel: "No",
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
                                                    "Tengo el pedido y quiero entregarlo ",
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
                                  (oTmp.status == "go_deliver")
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                elevation: 2,
                                                backgroundColor: Colors.green,
                                                shape: StadiumBorder()),
                                            onPressed: () {
                                              showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder: (contextDialog) {
                                                    return CustomDialog(
                                                      "",
                                                      "¿la persona a entregar el pedido es ${widget.order.patient!.name}?",
                                                      "Sí",
                                                      () {
                                                        completed();
                                                      },
                                                      useBtnCancel: true,
                                                      image: '',
                                                      textBtnCancel: "No",
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
                                                    "Entregue el pedido",
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
                                  (deliverySelected != null)
                                      ? Column(children: [
                                          SizedBox(height: 20),
                                          //
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Text("Recibe: ",
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
                                                      oTmp.patient!.name ?? "",
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
                                                Text("Entregar a más tardar: ",
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
                                                      (oTmp.date_send != null)
                                                          ? getDateTimeFromStringFormat(
                                                              DateTime.parse(oTmp
                                                                      .date_send!)
                                                                  .toLocal()
                                                                  .toString())
                                                          : "",
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
                                                Text("Tipo de entrega: ",
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
                                                      getTypeSend(
                                                          oTmp.type_delivery ??
                                                              ""),
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
                                                Text("Forma de pago: ",
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
                                                      getTypePayment(
                                                          oTmp.type_payment ??
                                                              ""),
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

                                          ///
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
                                                              provider.user.lat,
                                                              provider
                                                                  .user.long,
                                                              oTmp
                                                                  .budget_accepted!
                                                                  .pharmacy!
                                                                  .lat,
                                                              oTmp
                                                                  .budget_accepted!
                                                                  .pharmacy!
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
                                                              provider.user.lat,
                                                              provider
                                                                  .user.long,
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
                                        ])
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
                                                      "Costo de medicamentos: ",
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
                                            ),
                                            Divider(),
                                          ],
                                        )
                                      : Container(),
                                  (oTmp.status == "delivery_assigned")
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  "Recoge el paquete en:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          CustomColors.primary,
                                                      fontSize: 18),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3),
                                            ),
                                            Row(
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                        Icons.location_pin,
                                                        color: Colors.red,
                                                        size: 30),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 15.0),
                                                  child: locationBusinessField,
                                                ),
                                                new MapLocation(
                                                    oTmp.budget_accepted!
                                                        .pharmacy!.place!,
                                                    oTmp.budget_accepted!
                                                        .pharmacy!.title!,
                                                    key: mapState),
                                                SizedBox(height: 10)
                                              ],
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  (oTmp.status != "")
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text("Entregar en",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          CustomColors.primary,
                                                      fontSize: 18),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 3),
                                            ),
                                            Row(
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Icon(
                                                        Icons.location_pin,
                                                        color: Colors.blue,
                                                        size: 30),
                                                  ),
                                                )
                                              ],
                                            ),
                                            /////
                                            (showMap)
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10.0,
                                                                    vertical:
                                                                        5.0),
                                                            child: Text(
                                                                "Código postal",
                                                                style: TextStyle(
                                                                    color: CustomColors
                                                                        .primary,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal)),
                                                          ),
                                                          Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10.0,
                                                                  vertical:
                                                                      5.0),
                                                              child: Text(oTmp
                                                                      .address!
                                                                      .zip_code ??
                                                                  "")),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10.0,
                                                                    vertical:
                                                                        5.0),
                                                            child: Text(
                                                                "Estado",
                                                                style: TextStyle(
                                                                    color: CustomColors
                                                                        .primary,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal)),
                                                          ),
                                                          Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10.0,
                                                                  vertical:
                                                                      5.0),
                                                              child: Text(oTmp
                                                                      .address!
                                                                      .state ??
                                                                  "")),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10.0,
                                                                    vertical:
                                                                        5.0),
                                                            child: Text(
                                                                "Municipio/Alcaldía",
                                                                style: TextStyle(
                                                                    color: CustomColors
                                                                        .primary,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal)),
                                                          ),
                                                          Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10.0,
                                                                  vertical:
                                                                      5.0),
                                                              child: Text(oTmp
                                                                      .address!
                                                                      .municipality ??
                                                                  "")),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10.0,
                                                                    vertical:
                                                                        5.0),
                                                            child: Text(
                                                                "Colonia",
                                                                style: TextStyle(
                                                                    color: CustomColors
                                                                        .primary,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal)),
                                                          ),
                                                          Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10.0,
                                                                  vertical:
                                                                      5.0),
                                                              child: Text(oTmp
                                                                      .address!
                                                                      .suburb ??
                                                                  "")),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10.0,
                                                                    vertical:
                                                                        5.0),
                                                            child: Text("Calle",
                                                                style: TextStyle(
                                                                    color: CustomColors
                                                                        .primary,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal)),
                                                          ),
                                                          Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10.0,
                                                                  vertical:
                                                                      0.0),
                                                              child: Text(oTmp
                                                                      .address!
                                                                      .street ??
                                                                  "")),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10.0,
                                                                    vertical:
                                                                        5.0),
                                                            child: Text(
                                                                "Número",
                                                                style: TextStyle(
                                                                    color: CustomColors
                                                                        .primary,
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal)),
                                                          ),
                                                          Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      10.0,
                                                                  vertical:
                                                                      5.0),
                                                              child: Text(oTmp
                                                                      .address!
                                                                      .num_ext ??
                                                                  "")),
                                                        ],
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          new MapLocation(
                                                              oTmp.address!
                                                                  .place!,
                                                              oTmp.patient!
                                                                      .name ??
                                                                  "",
                                                              key: mapState2),
                                                          SizedBox(height: 10)
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : Container()

                                            ///
                                          ],
                                        )
                                      : Container()
                                ],
                              ),
                            ),
                          ),
                        ],
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

  goDeliver() async {
    simpleLoading(context, (BuildContext loadingContext) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      try {
        OrderModel orderTmp = await WebService(context)
            .goDeliver(widget.order.id ?? "", provider.user.token ?? "");

        Navigator.pop(loadingContext);

        SnackBar(
                content: Text("Dirígete a la ubicación de entrega",
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
}
