import 'dart:typed_data';

import 'package:app/components/custom_dialog.dart';
import 'package:app/components/map_selected.dart';
import 'package:app/components/override_date_picker.dart';
import 'package:app/components/select_picture_dialog_wec.dart';
import 'package:app/constants/colors.dart';
import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/category.dart';
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
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:snack/snack.dart';
import 'package:universal_io/io.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class AdminEditPharmacy extends StatefulWidget {
  Function callBackBack;
  PharmacyModel pharmacy;
  AdminEditPharmacy(this.callBackBack, this.pharmacy, {Key? key})
      : super(key: key);

  @override
  _AdminEditPharmacyState createState() => _AdminEditPharmacyState();
}

class _AdminEditPharmacyState extends State<AdminEditPharmacy> {
  final cLocation = TextEditingController();
  bool locationSearchHasFocus = false;
  String locationText = "";
  dynamic locationFilter = null;
  FocusNode _focus = new FocusNode();
  GlobalKey<dynamic> mapState = GlobalKey();

  final cEmail = TextEditingController();
  final cTitle = TextEditingController();
  final cTaxIdentifier = TextEditingController();
  final cDescription = TextEditingController();
  final cTel = TextEditingController();
  final cCommissionStore = TextEditingController();
  final cCommissionDelivery = TextEditingController();
  final ckmDelivery = TextEditingController();

  final cDeliveryCommission = TextEditingController();
  final cProfessionalLicense = TextEditingController();

  final cBirdate = TextEditingController();
  final cPass = TextEditingController();
  final cPassRepeat = TextEditingController();
  bool passwordVisible = true;
  bool passwordVisibleRepeat = true;

  final formKey = new GlobalKey<FormState>();

  dynamic imageSelected = null;
  dynamic birdate = null;
  String verifiedDoctor = "no";
  String typeCommissionStore = "percent";
  String typeCommissionDelivery = "percent";
  String deliveryAssignment = "automatic";
  String codeTel = "";

  String cashPayment = "disabled";
  String tjPayment = "disabled";

  dynamic categorySelected = null;
  dynamic adminSelected = null;
  List<CategoryModel> categories = [];
  List<UserModel> admins = [];
  late Place placeSelected;

  late String rolSelected;


bool cancelScroll=false;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);
    PharmacyModel p = widget.pharmacy;
    cTitle.text = p.title ?? "";
    if (p.category != null)
      categorySelected = (p.category != null) ? p.category!.id : null;
    imageSelected = p.cover ?? null;
    cTaxIdentifier.text = p.tax_identifier ?? "";
    cDescription.text = p.description ?? "";
    cTel.text = p.phone ?? "";
    codeTel = p.dial_code ?? "";
    if (p.admin != null) adminSelected = (p.admin != null) ? p.admin!.id : null;
    typeCommissionStore = p.type_commission_store ?? "";
    cCommissionStore.text = p.commission_store.toString();
    typeCommissionDelivery = p.type_commission_delivery ?? "";
    cCommissionDelivery.text = p.commission_delivery.toString();
    ckmDelivery.text = p.km_delivery.toString();
    cashPayment = p.cash_payment ?? "disabled";
    tjPayment = p.tj_payment ?? "disabled";
    if (p.place != null) {
      placeSelected = p.place!;
      cLocation.text = p.place!.formatted_address ?? "";
    } else {
      placeSelected = new Place(lat: provider.lat, lng: provider.long);
    }
    loadCategories();
    loadAdmins();
    BackButtonInterceptor.add(myInterceptor);
  }

  loadCategories() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getCategories(0, 0, context, provider.user.token ?? "", search: "")
        .then((value) {
      if (mounted)
        setState(() {
          categories = value;
        });
    }).catchError((e) {
      showErrorsDialog(context, e);
    });
  }

  loadAdmins() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getUsers(0, 0, context, provider.user.token ?? "",
            search: "", filter_rol: "pharmacy_admin")
        .then((value) {
      if (mounted)
        setState(() {
          admins = value;
        });
    }).catchError((e) {
      showErrorsDialog(context, e);
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
    widget.callBackBack();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    PharmacyModel pharmacy = widget.pharmacy;

    final passwordField = TextFormField(
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('[ ]')),
      ],
      textInputAction: TextInputAction.next,
      validator: (val) {
        return null;
      },
      controller: cPass,
      obscureText: passwordVisible,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localPassword(),
      decoration: InputDecoration(
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
          labelText: "Nueva contraseña",
          prefixIcon: Icon(
            FontAwesomeIcons.lock,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              // Based on passwordVisible state choose the icon
              passwordVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              // Update the state i.e. toogle the state of passwordVisible variable
              setState(() {
                passwordVisible = !passwordVisible;
              });
            },
          )),
    );

    final repeatPasswordField = TextFormField(
      style: TextStyle(fontSize: 18.0),
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp('[ ]')),
      ],
      validator: (val) {
        return null;
      },
      controller: cPassRepeat,
      obscureText: passwordVisibleRepeat,
      //initialValue: Environment.localPassword(),
      decoration: InputDecoration(
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
          labelText: "Confirmar nueva contraseña",
          prefixIcon: Icon(
            FontAwesomeIcons.lock,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              // Based on passwordVisible state choose the icon
              passwordVisibleRepeat ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              // Update the state i.e. toogle the state of passwordVisible variable
              setState(() {
                passwordVisibleRepeat = !passwordVisibleRepeat;
              });
            },
          )),
    );

    final deliveryCommissionField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cDeliveryCommission,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Comisión del repartidor',
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

    final titleField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cTitle,
      keyboardType: TextInputType.text,
      validator: (val) {
        return requiredField(val ?? "", context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Nombre del negocio',
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

    final taxIdentifierField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cTaxIdentifier,
      keyboardType: TextInputType.text,

      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Identificador fiscal',
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

    final descriptionField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cDescription,
      keyboardType: TextInputType.text,

      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Descripción',
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

    final commissionStoreField = TextFormField(
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: cCommissionStore,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Valor de comisión',
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

    final commissionDeliveryField = TextFormField(
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: cCommissionDelivery,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Valor de comisión',
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

    final kmDeliveryField = TextFormField(
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      controller: ckmDelivery,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (val) {
        return requiredField(val ?? 0, context);
      },
      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Kilómetros de distancia delivery',
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

    final telField = TextFormField(
      autofocus: false,
      autocorrect: false,
      controller: cTel,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ],
      maxLength: 10,

      obscureText: false,
      style: TextStyle(fontSize: 18.0),
      //initialValue: Environment.localUsername(),
      decoration: InputDecoration(
        labelText: 'Teléfono',
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
    String localeCode = "mx";
    if (!kIsWeb) localeCode = Platform.localeName.split("_")[1];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: formKey,
        child: ListView(
               physics: (cancelScroll)? NeverScrollableScrollPhysics() :null,
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
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: (pharmacy.approved == "approved")
                                ? Container(
                                    color: Colors.green,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("Negocio aprobado",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15)),
                                    ),
                                  )
                                : Container(
                                    color: Colors.amber,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "Negocio en revisión o desactivado, completa todos los datos",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15)),
                                    ),
                                  ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        width: 160,
                        height: 160,
                        child: Stack(
                          children: [
                            Positioned.fill(
                                child: (imageSelected != null)
                                    ? Container(
                                        width: 160,
                                        height: 160,
                                        decoration: BoxDecoration(
                                          borderRadius: new BorderRadius.all(
                                              Radius.circular(10.0)),
                                          image: (imageSelected is Uint8List)
                                              ? DecorationImage(
                                                  image: MemoryImage(
                                                      imageSelected),
                                                  fit: BoxFit.cover,
                                                )
                                              : (imageSelected is AssetModel)
                                                  ? DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                          getImageUrl(
                                                              imageSelected)))
                                                  : DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: FileImage(
                                                          imageSelected)),
                                        ),
                                      )
                                    : Container()),
                            Positioned.fill(
                                child: InkWell(
                              onTap: () {
                                showTakePicture();
                              },
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: new BoxDecoration(
                                    color: (imageSelected != null)
                                        ? Colors.transparent
                                        : Colors.black.withAlpha(80),
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(10.0))),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      FontAwesomeIcons.camera,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: titleField,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: taxIdentifierField,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: descriptionField,
                      ),

                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                                flex: 2,
                                child: CountryCodePicker(
                                  padding: EdgeInsets.only(top: 18),
                                  onInit: (code) {
                                    if (mounted) {
                                      WidgetsBinding.instance
                                          ?.addPostFrameCallback((_) {
                                        setState(() {
                                          codeTel = code.toString();
                                        });
                                      });
                                    }
                                  },
                                  onChanged: (code) {
                                    setState(() {
                                      codeTel = code.dialCode.toString();
                                    });
                                  },
                                  // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                  initialSelection:
                                      (codeTel != "" && codeTel != null)
                                          ? codeTel
                                          : localeCode,

                                  // optional. Shows only country name and flag
                                  showCountryOnly: false,
                                  // optional. Shows only country name and flag when popup is closed.
                                  showOnlyCountryWhenClosed: false,
                                  // optional. aligns the flag and the Text left
                                  alignLeft: false,
                                )),
                            Flexible(flex: 5, child: telField)
                          ]),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: Colors.grey,
                          ),
                          iconSize: 42,
                          items: categories.map((CategoryModel cat) {
                            return new DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.title ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1));
                          }).toList(),
                          onChanged: (cat) {
                            setState(() {
                              categorySelected = cat ?? "";
                            });

                            // do other stuff with _category
                          },
                          value: categorySelected,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: DropdownButtonFormField(
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_outlined,
                            color: Colors.grey,
                          ),
                          iconSize: 42,
                          items: admins.map((UserModel admin) {
                            return new DropdownMenuItem(
                                value: admin.id ?? "",
                                child: Text(admin.name ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1));
                          }).toList(),
                          onChanged: (admin) {
                            setState(() {
                              adminSelected = admin ?? "";
                            });

                            // do other stuff with _category
                          },
                          value: adminSelected,
                          decoration: InputDecoration(
                            labelText: 'Administrador',
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
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Comisiones de pedidos en tienda",
                              style: TextStyle(
                                  color: CustomColors.primary, fontSize: 15)),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                typeCommissionStore = "percent";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Porcentaje'),
                              leading: Radio<String>(
                                value: "percent",
                                groupValue: typeCommissionStore,
                                onChanged: (String? value) {
                                  setState(() {
                                    typeCommissionStore = value ?? "percent";
                                  });
                                },
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                typeCommissionStore = "permanent";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Fijo'),
                              leading: Radio<String>(
                                value: "permanent",
                                groupValue: typeCommissionStore,
                                onChanged: (String? value) {
                                  setState(() {
                                    typeCommissionStore = value ?? "permanent";
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: commissionStoreField,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Comisiones de pedidos a domicilio",
                              style: TextStyle(
                                  color: CustomColors.primary, fontSize: 15)),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                typeCommissionDelivery = "percent";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Porcentaje'),
                              leading: Radio<String>(
                                value: "percent",
                                groupValue: typeCommissionDelivery,
                                onChanged: (String? value) {
                                  setState(() {
                                    typeCommissionDelivery = value ?? "percent";
                                  });
                                },
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                typeCommissionDelivery = "permanent";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Fijo'),
                              leading: Radio<String>(
                                value: "permanent",
                                groupValue: typeCommissionDelivery,
                                onChanged: (String? value) {
                                  setState(() {
                                    typeCommissionDelivery =
                                        value ?? "permanent";
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: commissionDeliveryField,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Asignación de delivery",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15)),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                deliveryAssignment = "automatic";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Asignación automática'),
                              leading: Radio<String>(
                                value: "automatic",
                                groupValue: deliveryAssignment,
                                onChanged: (String? value) {
                                  setState(() {
                                    deliveryAssignment = value ?? "automatic";
                                  });
                                },
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                deliveryAssignment = "manual";
                              });
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),
                              title: const Text('Asignación manual'),
                              leading: Radio<String>(
                                value: "manual",
                                groupValue: deliveryAssignment,
                                onChanged: (String? value) {
                                  setState(() {
                                    deliveryAssignment = value ?? "manual";
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: kmDeliveryField,
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Acepta pago con",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15)),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                cashPayment = (cashPayment == "disabled")
                                    ? "enabled"
                                    : "disabled";
                              });
                            },
                            child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: const Text('Pago en efectivo'),
                                leading: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value:
                                      cashPayment == "enabled" ? true : false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      cashPayment = (value ?? false)
                                          ? "enabled"
                                          : "disabled";
                                    });
                                  },
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                tjPayment = (tjPayment == "disabled")
                                    ? "enabled"
                                    : "disabled";
                              });
                            },
                            child: ListTile(
                                contentPadding: EdgeInsets.all(0),
                                title: const Text('Pago con tarjeta'),
                                leading: Checkbox(
                                  checkColor: Colors.white,
                                  fillColor: MaterialStateProperty.resolveWith(
                                      getColor),
                                  value: tjPayment == "enabled" ? true : false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      tjPayment = (value ?? false)
                                          ? "enabled"
                                          : "disabled";
                                    });
                                  },
                                )),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: locationField,
                      ),

                      MapSelected(placeSelected, selectPlace,(status){
                                setState(() {
              cancelScroll=status;
                    });
                      }, key: mapState),
                      //new
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 2,
                              backgroundColor: CustomColors.primary,
                              shape: StadiumBorder()),
                          onPressed: () {
                            delete(pharmacy);
                          },
                          child: Container(
                            width: double.infinity,
                            height: 35.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Eliminar",
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
                              backgroundColor: CustomColors.primary,
                              shape: StadiumBorder()),
                          onPressed: () {
                            processEdit();
                          },
                          child: Container(
                            width: double.infinity,
                            height: 35.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Guardar",
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

  processEdit() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      simpleLoading(context, (BuildContext loadingContext) async {
        final provider = Provider.of<AppProvider>(context, listen: false);
        try {
          dynamic asset = null;
          if (imageSelected != null && !(imageSelected is AssetModel))
            asset = await WebService(context)
                .uploadAsset("image", imageSelected, provider.user.token ?? "");

          PharmacyModel pharmacyTmp = await WebService(context).updatePharmacy(
              widget.pharmacy.id ?? "",
              cTitle.text,
              categorySelected,
              (asset != null && asset is AssetModel) ? asset.id ?? "" : "",
              "",
              cTaxIdentifier.text,
              cDescription.text,
              cTel.text,
              codeTel,
              adminSelected,
              typeCommissionStore,
              cCommissionStore.text,
              typeCommissionDelivery,
              cCommissionDelivery.text,
              deliveryAssignment,
              ckmDelivery.text,
              cashPayment,
              tjPayment,
              (placeSelected != null && placeSelected is Place)
                  ? placeSelected.lat ?? 0
                  : 0,
              (placeSelected != null && placeSelected is Place)
                  ? placeSelected.lng ?? 0
                  : 0,
              (placeSelected != null && placeSelected is Place)
                  ? Place().toJson(placeSelected)
                  : "",
              provider.user.token ?? "");

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
          widget.callBackBack();
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
