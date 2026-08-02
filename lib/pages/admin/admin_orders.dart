import 'package:app/constants/colors.dart';
import 'package:app/models/order.dart';
import 'package:app/pages/admin/parts/admin_orders1.dart';
import 'package:app/pages/admin/parts/admin_orders2.dart';
import 'package:app/pages/admin/parts/admin_orders3.dart';
import 'package:app/pages/admin/parts/admin_orders4.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({Key? key}) : super(key: key);

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<String> type_business = [];
  @override
  void initState() {
    super.initState();

    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.user.pharmacy_assigned!.type == "pharmacy") {
      type_business = ["medicines_without_prescription", "normal"];
    } else {
      type_business = ["studies_without_prescription"];
    }
    _tabController = new TabController(vsync: this, length: 4);
    loadCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: getAppBar(),
          body: TabBarView(
            physics: (MediaQuery.of(context).size.width < 1000)
                ? const NeverScrollableScrollPhysics()
                : AlwaysScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              AdminOrders1(),
              AdminOrders2(),
              AdminOrders3(),
              AdminOrders4(),
            ],
          ),
        ),
      ),
    );
  }

  num countOrders1 = 0;
  num countOrders2 = 0;
  num countOrders3 = 0;
  num countOrders4 = 0;
  Future loadCounts() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    List<OrderModel> ordersTmp1 = await WebService(context).getOrders(
        0, 0, context, provider.user.token ?? "",
        statuses: ["pendient", "budget_acceptance_pending"],
        type_business: type_business);
    countOrders1 = ordersTmp1.length;
    List<OrderModel> ordersTmp2 = await WebService(context)
        .getOrders(0, 0, context, provider.user.token ?? "",
            id_pharmacy: provider.user.pharmacy_assigned!.id ?? "",
            statuses: [
              "waiting_package",
              "waiting_delivery",
              "delivery_assigned",
              "ready_in_store",
              "go_deliver"
            ],
            type_business: type_business);
    countOrders2 = ordersTmp2.length;
    List<OrderModel> ordersTmp3 = await WebService(context).getOrders(
        0, 0, context, provider.user.token ?? "",
        id_pharmacy: provider.user.pharmacy_assigned!.id ?? "",
        statuses: ["completed"],
        type_business: type_business);
    countOrders3 = ordersTmp3.length;
    List<OrderModel> ordersTmp4 = await WebService(context).getOrders(
        0, 0, context, provider.user.token ?? "",
        id_pharmacy: provider.user.pharmacy_assigned!.id ?? "",
        statuses: ["cancelled"],
        type_business: type_business);
    countOrders4 = ordersTmp4.length;
    setState(() {});
  }

  AppBar getAppBar() {
    return AppBar(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      elevation: 0,
      toolbarHeight: 80,
      flexibleSpace: (MediaQuery.of(context).size.width < 1000)
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _tabController.animateTo(0);
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: (_tabController.index == 0)
                                ? CustomColors.primary
                                : Colors.white,
                            border: Border(
                              left: BorderSide(
                                //                   <--- left side
                                color: CustomColors.primary,
                                width: 1.0,
                              ),
                              right: BorderSide(
                                //                    <--- top side
                                color: CustomColors.primary,
                                width: 0.5,
                              ),
                              top: BorderSide(
                                //                    <--- top side
                                color: CustomColors.primary,
                                width: 1.0,
                              ),
                            ),
                          ),
                          height: 40,
                          child: Center(
                              child: Text(
                                  "PENDIENTES (${countOrders1.toString()})",
                                  style: TextStyle(
                                      color: (_tabController.index == 0)
                                          ? Colors.white
                                          : CustomColors.primary,
                                      fontSize: (kIsWeb) ? 18 : 12))),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _tabController.animateTo(1);
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: (_tabController.index == 1)
                                ? CustomColors.primary
                                : Colors.white,
                            border: Border(
                              left: BorderSide(
                                //                   <--- left side
                                color: CustomColors.primary,
                                width: 0.5,
                              ),
                              right: BorderSide(
                                //                    <--- top side
                                color: CustomColors.primary,
                                width: 1.0,
                              ),
                              top: BorderSide(
                                //                    <--- top side
                                color: CustomColors.primary,
                                width: 1.0,
                              ),
                            ),
                          ),
                          height: 40,
                          child: Center(
                              child: Text(
                                  "POR ENTREGAR (${countOrders2.toString()})",
                                  style: TextStyle(
                                      color: (_tabController.index == 1)
                                          ? Colors.white
                                          : CustomColors.primary,
                                      fontSize: (kIsWeb) ? 18 : 12))),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _tabController.animateTo(2);
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: (_tabController.index == 2)
                                ? CustomColors.primary
                                : Colors.white,
                            border: Border(
                              left: BorderSide(
                                //                   <--- left side
                                color: CustomColors.primary,
                                width: 1.0,
                              ),
                              right: BorderSide(
                                //                    <--- top side
                                color: CustomColors.primary,
                                width: 0.5,
                              ),
                              top: BorderSide(
                                //                    <--- top side
                                color: CustomColors.primary,
                                width: 1.0,
                              ),
                              bottom: BorderSide(
                                //                    <--- top side
                                color: CustomColors.primary,
                                width: 1.0,
                              ),
                            ),
                          ),
                          height: 40,
                          child: Center(
                              child: Text(
                                  "ENTREGADOS (${countOrders3.toString()})",
                                  style: TextStyle(
                                      color: (_tabController.index == 2)
                                          ? Colors.white
                                          : CustomColors.primary,
                                      fontSize: (kIsWeb) ? 18 : 12))),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _tabController.animateTo(3);
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: (_tabController.index == 3)
                                ? CustomColors.primary
                                : Colors.white,
                            border: Border(
                                left: BorderSide(
                                  //                   <--- left side
                                  color: CustomColors.primary,
                                  width: 0.5,
                                ),
                                right: BorderSide(
                                  //                    <--- top side
                                  color: CustomColors.primary,
                                  width: 1.0,
                                ),
                                top: BorderSide(
                                  //                    <--- top side
                                  color: CustomColors.primary,
                                  width: 1.0,
                                ),
                                bottom: BorderSide(
                                  //                    <--- top side
                                  color: CustomColors.primary,
                                  width: 1.0,
                                )),
                          ),
                          height: 40,
                          child: Center(
                              child: Text(
                                  "CANCELADOS (${countOrders4.toString()})",
                                  style: TextStyle(
                                      color: (_tabController.index == 3)
                                          ? Colors.white
                                          : CustomColors.primary,
                                      fontSize: (kIsWeb) ? 18 : 12))),
                        ),
                      ),
                    )
                  ],
                )
              ],
            )
          : TabBar(
              controller: _tabController,
              indicatorPadding: EdgeInsets.only(right: 4, left: 4),
              padding: EdgeInsets.only(right: 4, left: 4),
              indicator: UnderlineTabIndicator(
                  borderSide:
                      BorderSide(width: 2.0, color: CustomColors.secondary),
                  insets: EdgeInsets.symmetric(horizontal: 2.0)),
              isScrollable: true,
              labelColor: CustomColors.primary,
              tabs: [
                Tab(
                    icon: Text("PENDIENTES (${countOrders1.toString()})",
                        style: TextStyle(
                            color: CustomColors.primary, fontSize: 18))),
                Tab(
                    icon: Text("POR ENTREGAR (${countOrders2.toString()})",
                        style: TextStyle(
                            color: CustomColors.primary, fontSize: 18))),
                Tab(
                    icon: Text("ENTREGADOS (${countOrders3.toString()})",
                        style: TextStyle(
                            color: CustomColors.primary, fontSize: 18))),
                Tab(
                    icon: Text("CANCELADOS (${countOrders4.toString()})",
                        style: TextStyle(
                            color: CustomColors.primary, fontSize: 18))),
              ],
            ),
    );
  }
}
