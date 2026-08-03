import 'dart:async';
import 'dart:typed_data';

import 'package:app/models/user.dart';
import 'package:app/pages/admin/admin_view_order.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';

import '../../components/select_picture_dialog_wec.dart';
import '../../constants/colors.dart';
import '../../constants/globals.dart';
import '../../helpers/helpers.dart';
import '../../models/asset.dart';
import '../../models/budget.dart';
import '../../models/category.dart';
import '../../models/order.dart';
import '../../providers/app.dart';
import '../../services/web_service.dart';
import 'package:snack/snack.dart';

import 'admin_send_costs.dart';
import 'admin_view_order_approve.dart';

class AdminApproveOrder extends StatefulWidget {
  const AdminApproveOrder({Key? key}) : super(key: key);

  @override
  State<AdminApproveOrder> createState() => _AdminApproveOrderState();
}

class _AdminApproveOrderState extends State<AdminApproveOrder> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  var _controllerScroll = ScrollController();

  PageController _pageController = PageController(initialPage: 0);

  num limit = 30;
  bool noMore = false;
  bool loading = false;

  DateTime currentDate = DateTime.now().toUtc();

  List<OrderModel> orders = [];
  final cSearch = TextEditingController();

  String filterRol = "";

  bool addPrescription = false;

  dynamic viewOrder = null;
  dynamic viewOrderApprove = null;

  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);

    currentDate = DateTime.now().toUtc();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState!.show();
    });

    _controllerScroll.addListener(() {
      if (_controllerScroll.position.atEdge) {
        if (_controllerScroll.position.pixels == 0) {
        } else {
          setState(() {
            loading = true;
          });
          loadMore();
        }
      }
    });
  }

  void dispose() {
    super.dispose();
    _controllerScroll.dispose();
  }

  Future<Null> loadMore() {
    setState(() {
      loading = true;
    });
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getOrdersToApprove(
            limit, orders.length, context, provider.user.token ?? "",
            search: cSearch.text)
        .then((value) {
      if (value.length > 0) {
        if (mounted)
          setState(() {
            orders.addAll(value);
            noMore = false;
          });
      } else {
        noMore = true;
        print("entre a no hay más");
      }

      Timer(Duration(seconds: 1), () {
        WidgetsBinding.instance?.addPostFrameCallback((_) async {
          if (mounted)
            setState(() {
              loading = false;
            });
        });
      });
    }).catchError((e) {
      Timer(Duration(seconds: 1), () {
        if (mounted)
          setState(() {
            loading = false;
          });
      });
      showErrorsDialog(context, e);
    });
  }

  Future<Null> load() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    return WebService(context)
        .getOrdersToApprove(limit, 0, context, provider.user.token ?? "",
            search: cSearch.text)
        .then((value) {
      if (mounted)
        setState(() {
          orders = value;
        });
    }).catchError((e) {
      showErrorsDialog(context, e);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: true);
    UserModel user = provider.user;

    if (viewOrderApprove != null) {
      return AdminViewOrderApprove(() {
        setState(() {
          viewOrderApprove = null;
        });
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          _refreshIndicatorKey.currentState!.show();
        });
      }, viewOrderApprove);
    }

    double widthLeftMenu =
        (MediaQuery.of(context).size.width >= breakPointDesktop)
            ? desktopMenuLeftWidth
            : 0;

    List<ResponsiveGridCol> progressWidgets =
        orders.asMap().entries.map((order) {
      OrderModel oTmp = order.value;
      String created = getDateTimeFromStringFormat(
          DateTime.parse(oTmp.created_at!).toLocal().toString());

      return ResponsiveGridCol(
          lg: 4,
          xs: 12,
          md: 12,
          child: Visibility(
              visible: true,
              child: InkWell(
                onTap: () {
                  setState(() {
                    viewOrderApprove = oTmp;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 2.0),
                  child: Card(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4, left: 8.0, right: 8.0),
                                child: Text(
                                    ("Folio: " +
                                        (oTmp.id ?? "").substring(0, 8)),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: CustomColors.primary,
                                        fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 4, left: 8.0, right: 8.0),
                                child: Text(created,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1),
                              )
                            ],
                          ),
                        ),
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
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                              (oTmp.patient!.roles[0].name !=
                                                      "hospital_admin")
                                                  ? "Paciente: "
                                                  : "Hospital/Clínica: ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: CustomColors.primary,
                                                  fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3),
                                          Flexible(
                                            child: Text(
                                                oTmp.patient!.name ?? "",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.grey,
                                                    fontSize: 13),
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
                                          Text("Tipo: ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: CustomColors.primary,
                                                  fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3),
                                          Flexible(
                                            child: Text(
                                                getTypeOrder(oTmp.type ?? ""),
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Colors.grey,
                                                    fontSize: 13),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 3),
                                          ),
                                        ],
                                      ),
                                    ),
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
              )));
    }).toList();

    progressWidgets.add(ResponsiveGridCol(
        lg: 12,
        xs: 12,
        md: 12,
        child: Visibility(
          visible: loading,
          child: Container(
            width: 30,
            height: 30,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(CustomColors.primary)),
              ),
            ),
          ),
        )));

    if (noMore) {
      progressWidgets.add(ResponsiveGridCol(
          lg: 12,
          xs: 12,
          md: 12,
          child: Visibility(
            visible: !loading,
            child: Center(
              child: Container(
                  height: 30,
                  child: Text("No hay mas elementos para mostrar.")),
            ),
          )));
    }
    return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Stack(
          children: [
            Positioned.fill(
                top: (MediaQuery.of(context).padding.top) + 20,
                child: RefreshIndicator(
                    color: CustomColors.primary,
                    key: _refreshIndicatorKey,
                    displacement: MediaQuery.of(context).size.height * .40,
                    onRefresh: load,
                    child: SingleChildScrollView(
                      controller: _controllerScroll,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height,
                                maxHeight: double.infinity),
                            child: (orders.length <= 0)
                                ? Center(
                                    child: Column(
                                    children: [
                                      Text(
                                        "No hay ningún elemento para mostrar",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      ),
                                    ],
                                  ))
                                : Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            ResponsiveGridRow(
                                                children: progressWidgets)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    )))
          ],
        ));
  }
}
