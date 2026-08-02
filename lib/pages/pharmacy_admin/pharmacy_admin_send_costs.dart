import 'dart:typed_data';

import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/components/map_location.dart';
import 'package:app/components/map_selected.dart';
import 'package:app/components/override_date_picker.dart';
import 'package:app/components/search_select_medicines.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
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
import 'package:app/models/prescription.dart';
import 'package:app/models/suggestion.dart';
import 'package:app/models/user.dart';
import 'package:app/pages/pharmacy_admin/parts/row_table_medicine.dart';
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
import 'package:universal_io/io.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:editable/editable.dart';
import 'package:uuid/uuid.dart';

class PharmacyAdminSendCosts extends StatefulWidget {
  Function callBackBack;
  OrderModel order;
  PharmacyAdminSendCosts(this.callBackBack, this.order, {Key? key})
      : super(key: key);

  @override
  _PharmacyAdminSendCostsState createState() => _PharmacyAdminSendCostsState();
}

class _PharmacyAdminSendCostsState extends State<PharmacyAdminSendCosts> {
  final cLocation = TextEditingController();
  bool locationSearchHasFocus = false;
  String locationText = "";
  dynamic locationFilter = null;
  FocusNode _focus = new FocusNode();
  GlobalKey<dynamic> mapState = GlobalKey();

  final cShippingCost = TextEditingController();
  final cDrugCost = TextEditingController();
  final cOthersLabSts = TextEditingController();
  final formKey = new GlobalKey<FormState>();

  dynamic imageSelected = null;

  dynamic adminSelected = null;
  List<CategoryModel> categories = [];
  List<UserModel> admins = [];
  late Place placeSelected;

  late String rolSelected;

  bool showMap = false;

  List<RowTableMedicine> medicines = [];

  List<String> labSts = [];
  dynamic imageSelectedSt = null;

  bool showLabSt = false;

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

    dynamic lastBudget =
        (getMyLastBudget(o.budgets!, provider.user.pharmacy_assigned!));
    if (lastBudget != null) {
      BudgetModel budgetTmp = lastBudget;

      budgetTmp.medicines.forEach((element) {
        final _scaffoldKey = new GlobalKey<ScaffoldState>();
        medicines.add(RowTableMedicine(
          () {
            removeRowMedicine(_scaffoldKey);
          },
          element.cost ?? 0,
          element.quantity ?? 0,
          element.medicine ?? "",
          element.amount ?? 0,
          () {
            calcTotal();
          },
          {
            "medicine": element.medicine,
            "cost": element.cost ?? 0,
            "amount": element.amount ?? 0,
            "quantity": element.quantity ?? 0,
            "prescription": element.prescription ?? ""
          },
          false,
          key: _scaffoldKey,
        ));
      });

      cShippingCost.text = budgetTmp.cost_delivery ?? "";
    } else {
      o.prescription!.medicines!.forEach((element) {
        final _scaffoldKey = new GlobalKey<ScaffoldState>();
        medicines.add(RowTableMedicine(
          () {
            removeRowMedicine(_scaffoldKey);
          },
          (element["PRECIO_GRUPO_III"] ?? 0) * 2,
          element["cant"] ?? 0,
          element["SUSTANCIA"] + " - " + element["Descripción"],
          (element["PRECIO_GRUPO_III"] ?? 0) * 2,
          () {
            calcTotal();
          },
          {
            "medicine": element["SUSTANCIA"] + " - " + element["Descripción"],
            "cost": (element["PRECIO_GRUPO_III"] ?? 0) * 2,
            "amount": (element["PRECIO_GRUPO_III"] ?? 0) * 2,
            "quantity": element["cant"] ?? 0,
            "prescription": element["prescription"] ?? ""
          },
          false,
          key: _scaffoldKey,
        ));
      });
    }

    PrescriptionModel prescription = o.prescription!;
    cOthersLabSts.text = prescription.other_studies ?? "";

    if (prescription.medical_studies != null &&
        prescription.medical_studies is List) {
      labSts = prescription.medical_studies!.map((e) => e.toString()).toList();
    }

    if (prescription.picture_studies != null &&
        prescription.picture_studies is AssetModel) {
      imageSelectedSt = prescription.picture_studies;
    }

    if ((prescription.picture_studies != null &&
            prescription.picture_studies is AssetModel) ||
        (prescription.medical_studies != null &&
            prescription.medical_studies is List &&
            prescription.medical_studies!.length > 0) ||
        (prescription.other_studies != "" &&
            prescription.other_studies != null)) {
      showLabSt = true;
    }
    cLocation.text = (o.address != null && o.address is AddressModel)
        ? "${o.address!.zip_code} ${o.address!.street} - ${o.address!.state} - ${o.address!.municipality}"
        : "";

    UserModel user = o.patient!;
    isHospital = (user.roles[0].name == "hospital_admin") ? true : false;
    requestInvoice = user.request_invoice == "yes" ? true : false;
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
    final otherslabStField = TextFormField(
      autofocus: false,
      autocorrect: false,
      readOnly: true,
      controller: cOthersLabSts,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Otros estudios',
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
    final shippingCostField = TextFormField(
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: cShippingCost,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText:
            'Costo de envío \$ (solo se cobrara al cliente si elige envío a domicilio)',
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
      onFieldSubmitted: (val) {},
    );

    final drugCostField = TextFormField(
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: cDrugCost,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Costo de medicamentos \$',
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

    final topController = ScrollController();
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
                                        Text(
                                            (isHospital)
                                                ? "Hospital/Clínica: "
                                                : "Paciente: ",
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
                                                  : "no definido",
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
                                                  oTmp.type_delivery ?? ""),
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
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0, right: 8.0),
                                    child: Row(
                                      children: [
                                        Text("Receta o prescripción: ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: CustomColors.primary,
                                                fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3),
                                      ],
                                    ),
                                  ),
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

                                  //------------------------------- laboratory studies
                                  SizedBox(
                                    height: 20,
                                  ),

                                  //------------------------------- end laboratory studies
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      (oTmp.type_delivery == "home" ||
                              oTmp.type_delivery == null ||
                              oTmp.type_delivery == "")
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: shippingCostField,
                            )
                          : Container(),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                      //   child: drugCostField,
                      // ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 2,
                                  primary: CustomColors.primary,
                                  shape: StadiumBorder()),
                              onPressed: () {
                                showSearchSelectMedicines();
                                return;
                                final _scaffoldKey =
                                    new GlobalKey<ScaffoldState>();
                                String uuid = Uuid().v1();
                                setState(() {
                                  medicines.add(RowTableMedicine(
                                    () {
                                      removeRowMedicine(_scaffoldKey);
                                    },
                                    0,
                                    1,
                                    "",
                                    0,
                                    () {
                                      calcTotal();
                                    },
                                    {
                                      "medicine": "",
                                      "cost": 0,
                                      "amount": 0,
                                      "quantity": 0
                                    },
                                    false,
                                    key: _scaffoldKey,
                                  ));
                                });
                              },
                              child: Container(
                                height: 35.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Agregar ",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15.0),
                                    ),
                                    Icon(Icons.add)
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      Scrollbar(
                        controller: topController,

                        // thumbVisibility: true,
                        scrollbarOrientation: ScrollbarOrientation.bottom,
                        child: SingleChildScrollView(
                          controller: topController,
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: Container(
                              width: (MediaQuery.of(context).size.width >=
                                      (breakPointDesktop))
                                  ? 900
                                  : 500,
                              child: getTable(),
                            ),
                          ),
                        ),
                      ),
                      //new
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              primary: CustomColors.primary,
                              shape: StadiumBorder()),
                          onPressed: () {
                            bool status = checkTable();
                            if (status) {
                              process();
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 35.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Enviar costos",
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

  Widget itemLabSt(String title, String val) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
                color: (checkItemLbSt(val))
                    ? CustomColors.primary
                    : Colors.transparent,
                border: Border.all(
                  width: 1.5,
                  color: CustomColors.primary,
                ),
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(title,
                style: TextStyle(color: Colors.grey[800], fontSize: 12)),
          )
        ],
      ),
    );
  }

  showSearchSelectMedicines() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return SearchSelectMedicines((dynamic medicine) {
            if (medicine == null) {
              final _scaffoldKey = new GlobalKey<ScaffoldState>();
              String uuid = Uuid().v1();
              setState(() {
                medicines.add(RowTableMedicine(
                  () {
                    removeRowMedicine(_scaffoldKey);
                  },
                  0,
                  1,
                  "",
                  0,
                  () {
                    calcTotal();
                  },
                  {"medicine": "", "cost": 0, "amount": 0, "quantity": 1},
                  false,
                  key: _scaffoldKey,
                ));
              });
            } else {
              final _scaffoldKey = new GlobalKey<ScaffoldState>();
              String uuid = Uuid().v1();
              setState(() {
                medicines.add(RowTableMedicine(
                  () {
                    removeRowMedicine(_scaffoldKey);
                  },
                  medicine["PRECIO_GRUPO_III"] * 2,
                  1,
                  medicine["SUSTANCIA"] + " - " + medicine["Descripción"],
                  medicine["PRECIO_GRUPO_III"] * 2,
                  () {
                    calcTotal();
                  },
                  {
                    "medicine":
                        medicine["SUSTANCIA"] + " - " + medicine["Descripción"],
                    "cost": medicine["PRECIO_GRUPO_III"] * 2,
                    "amount": medicine["PRECIO_GRUPO_III"] * 2,
                    "quantity": 1
                  },
                  false,
                  key: _scaffoldKey,
                ));
              });
            }
            Navigator.pop(contextDialog);
          });
        });
  }

  bool checkItemLbSt(String val) {
    bool found = false;
    for (var i = 0; i < labSts.length; i++) {
      if (labSts[i] == val) {
        found = true;
      }
    }
    return found;
  }

  Widget getTable() {
    return Column(
      children: [
        Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                    flex: 0,
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color.fromARGB(255, 171, 171, 171),
                            width:
                                0.5, //                   <--- border width here
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 11.0, horizontal: 23.5),
                          child: Text(""),
                        ))),
                Flexible(
                    flex: 5,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text("Medicamento"),
                                )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text("Costo"),
                                )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text("Cántidad"),
                                )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text("Importe"),
                                )))
                      ],
                    )),
              ],
            )
          ],
        ),
        Column(
          children: medicines.asMap().entries.map((e) {
            int idx = e.key;
            RowTableMedicine row = e.value;
            return row;
          }).toList(),
        ),
        Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                    flex: 0,
                    child: Container(
                        decoration: BoxDecoration(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 11.0, horizontal: 23.5),
                          child: Text(""),
                        ))),
                Flexible(
                    flex: 5,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 11.0, horizontal: 11.0),
                          child: Text(""),
                        )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 11.0, horizontal: 11.0),
                          child: Text(""),
                        )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text("Total"),
                                )))
                      ],
                    )),
                Flexible(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color.fromARGB(255, 171, 171, 171),
                                    width:
                                        0.5, //                   <--- border width here
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 11.0, horizontal: 11.0),
                                  child: Text(total.toString()),
                                )))
                      ],
                    )),
              ],
            )
          ],
        ),
      ],
    );
  }

  num total = 0;

  calcTotal() {
    num totalTmp = 0;

    medicines.forEach((row) {
      totalTmp += row.values["amount"];
    });

    setState(() {
      total = totalTmp;
    });
  }

  removeRowMedicine(GlobalKey id) {
    medicines.removeWhere((element) => element.key == id);
    calcTotal();
    setState(() {});
  }

  List<Map<String, dynamic>> getTableObject() {
    num totalTmp = 0;
    List<Map<String, dynamic>> medicinesTmp = [];

    medicines.forEach((row) {
      Map<String, dynamic> medicine = {};
      medicine = {
        "medicine": row.values["medicine"],
        "cost": row.values["cost"],
        "amount": row.values["amount"],
        "quantity": row.values["quantity"],
        "prescription": row.values["prescription"]
      };
      medicinesTmp.add(medicine);
    });

    return medicinesTmp;
  }

  bool checkTable() {
    bool flag = true;

    if (cShippingCost.text == null || cShippingCost.text.trim() == "") {
      flag = false;
      showErrorsDialog(context, ["Debe ingresar el costo de envío"]);
      return flag;
    }

    if (medicines.length <= 0) {
      flag = false;
      showErrorsDialog(context, ["Debe agregar al menos 1 medicamento"]);
      return flag;
    }
    medicines.forEach((row) {
      if (row.values["medicine"].trim() == "" ||
          row.values["medicine"].trim() == null) {
        flag = false;
      }
      if (row.values["cost"] <= 0 || row.values["cost"] == null) {
        flag = false;
      }
      if (row.values["amount"] <= 0 || row.values["amount"] == null) {
        flag = false;
      }
      if (row.values["quantity"] <= 0 || row.values["quantity"] == null) {
        flag = false;
      }
    });

    if (!flag) {
      showErrorsDialog(context, [
        "Verifique que el campo nombre de medicamento no este vacio",
        "Verifique que el campo cantidad y costo sea mayor a 0"
      ]);
    }
    return flag;
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

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return CustomColors.primary;
  }

  showTakePicture() async {
    if (kIsWeb) {
      selectPictureWeb(context, (dynamic imageFile) {
        setState(() {
          this.imageSelected = imageFile;
        });
      });
    } else {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SelectPictureDialogWec(
              "Seleccionar imagen",
              (contextDialogd, image) {
                Navigator.pop(contextDialog);
                callbackShowTakePicture(contextDialogd, image);
              },
              useBtnCancel: true,
            );
          });
    }
  }

  Future callbackShowTakePicture(contextDialog, image) async {
    if (image == null) return;
    try {
      final XFile? imageFile = await ImagePicker().pickImage(
          source:
              (image == "camera") ? ImageSource.camera : ImageSource.gallery);
      if (imageFile != null) {
        File file = await File(imageFile.path);
        setState(() {
          this.imageSelected = file;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  process() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);
        try {
          dynamic orderTmp = await WebService(context).sendCostsOrder(
              widget.order.id ?? "",
              cShippingCost.text,
              total.toString(),
              provider.user.pharmacy_assigned!.id ?? "",
              getTableObject(),
              provider.user.token ?? "");

          Navigator.pop(loadingContext);
          SnackBar(
                  content: Text("Se ha enviado con éxito",
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
}
