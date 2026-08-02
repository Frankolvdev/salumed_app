import 'dart:typed_data';

import 'package:app/components/bottom_sheet_pictures.dart';
import 'package:app/components/custom_dialog.dart';
import 'package:app/components/dialog_avoid_bottom.dart';
import 'package:app/components/map_location.dart';
import 'package:app/components/map_selected.dart';
import 'package:app/components/override_date_picker.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/components/studies_selection.dart';
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
import 'package:app/models/prescription.dart';
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

class AdminViewOrderApprove extends StatefulWidget {
  Function callBackBack;
  OrderModel order;
  AdminViewOrderApprove(this.callBackBack, this.order, {Key? key})
      : super(key: key);

  @override
  _AdminViewOrderApproveState createState() => _AdminViewOrderApproveState();
}

class _AdminViewOrderApproveState extends State<AdminViewOrderApprove> {
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

  List<CategoryModel> categories = [];
  List<UserModel> admins = [];
  late Place placeSelected;

  late String rolSelected;

  bool showMap = true;
  dynamic imageSelectedSt = null;

  bool showLabSt = false;

  StudiesSelectionController studiesSelectionController =
      new StudiesSelectionController();

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);
    OrderModel o = widget.order;
    imageSelected = o.prescription!.prescription_picture;

    PrescriptionModel prescription = o.prescription!;
    cOthersLabSts.text = prescription.other_studies ?? "";

    if (prescription.medical_studies != null &&
        prescription.medical_studies is List) {
      studiesSelectionController.labSts =
          prescription.medical_studies!.map((e) => e.toString()).toList();
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
                                            /*MapLocation(placeSelected,
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
                                  (oTmp.prescription!.prescription_text != "")
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
                                  (oTmp.prescription!.prescription_text != "")
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
                                  (oTmp.prescription!.medicines is List)
                                      ? Column(
                                          children: oTmp
                                              .prescription!.medicines!
                                              .map((e) {
                                            return Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                  flex: 8,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(e["SUSTANCIA"] +
                                                        " - " +
                                                        e["Descripción"]),
                                                  ),
                                                ),
                                                Container(
                                                    width: 30,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        e["cant"].toString(),
                                                      ),
                                                    ))
                                              ],
                                            );
                                          }).toList(),
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
                                  (showLabSt)
                                      ? Column(
                                          children: [
                                            StudiesSelection(
                                              controller:
                                                  studiesSelectionController,
                                              preventSelect: true,
                                            ),
                                            (widget.order.prescription!
                                                        .other_studies !=
                                                    "")
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 8.0),
                                                    child: otherslabStField,
                                                  )
                                                : Container(),
                                            ResponsiveGridRow(children: [
                                              ResponsiveGridCol(
                                                  lg: 12,
                                                  xs: 12,
                                                  md: 12,
                                                  child:

                                                      /// front
                                                      Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      children: [
                                                        (imageSelectedSt !=
                                                                null)
                                                            ? Container(
                                                                height: 160,
                                                                child: Stack(
                                                                  children: [
                                                                    Positioned
                                                                        .fill(
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            160,
                                                                        width:
                                                                            160,
                                                                        decoration:
                                                                            new BoxDecoration(
                                                                          color:
                                                                              Colors.transparent,
                                                                          borderRadius:
                                                                              new BorderRadius.all(Radius.circular(10.0)),
                                                                        ),
                                                                        child: FadeInImage
                                                                            .assetNetwork(
                                                                          placeholder:
                                                                              "assets/images/loading-image1.gif",
                                                                          image:
                                                                              getImageUrl(imageSelectedSt!),
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned
                                                                        .fill(
                                                                            child:
                                                                                InkWell(
                                                                      onTap:
                                                                          () {
                                                                        BottomSheetPictures(
                                                                            context,
                                                                            0, [
                                                                          imageSelectedSt
                                                                        ]).showBottomSheetPictures();
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            160,
                                                                        height:
                                                                            160,
                                                                        decoration: new BoxDecoration(
                                                                            color: (imageSelectedSt != null)
                                                                                ? Colors.transparent
                                                                                : Colors.black.withAlpha(80),
                                                                            borderRadius: new BorderRadius.all(Radius.circular(10.0))),
                                                                        child:
                                                                            Align(
                                                                          alignment:
                                                                              Alignment.bottomRight,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                ((imageSelectedSt != null))
                                                                                    ? InkWell(
                                                                                        onTap: () {
                                                                                          BottomSheetPictures(context, 0, [
                                                                                            imageSelectedSt
                                                                                          ]).showBottomSheetPictures();
                                                                                        },
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.all(8.0),
                                                                                          child: Icon(
                                                                                            FontAwesomeIcons.expandArrowsAlt,
                                                                                            color: Colors.grey,
                                                                                            size: 25,
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : Container(),
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
                                                  )),
                                            ]),
                                          ],
                                        )
                                      : Container(),
                                ],
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
                              primary: Colors.red,
                              shape: StadiumBorder()),
                          onPressed: () {
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (contextDialog) {
                                  return CustomDialog(
                                    "",
                                    "¿Realmente desea rechazar el pedido?",
                                    "Rechazar",
                                    () {
                                      approvedStatus("rejected");
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
                                  "Rechazar pedido",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              primary: Colors.green,
                              shape: StadiumBorder()),
                          onPressed: () {
                            approvedStatus("approved");
                          },
                          child: Container(
                            width: double.infinity,
                            height: 35.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Aprobar pedido",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
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

  approvedStatus(String status) async {
    simpleLoading(context, (BuildContext loadingContext) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      try {
        dynamic orderTmp = await WebService(context).approveOrder(
            widget.order.id ?? "", status, provider.user.token ?? "");

        Navigator.pop(loadingContext);
        SnackBar(
                content: Text("Se ha guardado con éxito",
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
