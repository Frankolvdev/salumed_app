import 'package:app/constants/colors.dart';
import 'package:app/models/order.dart';

import 'package:app/pages/hospital_admin/parts/hospital_admin_orders1.dart';
import 'package:app/pages/hospital_admin/parts/hospital_admin_orders2.dart';
import 'package:app/pages/hospital_admin/parts/hospital_admin_orders3.dart';
import 'package:app/pages/hospital_admin/parts/hospital_admin_orders4.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HospitalAdminOrders extends StatefulWidget {
  HospitalAdminOrders({Key? key}) : super(key: key);

  @override
  State<HospitalAdminOrders> createState() => _HospitalAdminOrdersState();
}

class _HospitalAdminOrdersState extends State<HospitalAdminOrders>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
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
              HospitalAdminOrders1(() {
                loadCounts();
              }),
              HospitalAdminOrders2(() {
                loadCounts();
              }),
              HospitalAdminOrders3(() {
                loadCounts();
              }),
              HospitalAdminOrders4(() {
                loadCounts();
              })
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
        id_user: provider.user.id ?? "",
        statuses: ["pendient", "budget_acceptance_pending"]);
    countOrders1 = ordersTmp1.length;
    List<OrderModel> ordersTmp2 = await WebService(context).getOrders(
        0, 0, context, provider.user.token ?? "",
        id_user: provider.user.id ?? "",
        statuses: [
          "waiting_delivery",
          "waiting_package",
          "delivery_assigned",
          "ready_in_store",
          "go_deliver"
        ]);
    countOrders2 = ordersTmp2.length;
    List<OrderModel> ordersTmp3 = await WebService(context).getOrders(
        0, 0, context, provider.user.token ?? "",
        id_user: provider.user.id ?? "", statuses: ["completed"]);
    countOrders3 = ordersTmp3.length;
    List<OrderModel> ordersTmp4 = await WebService(context).getOrders(
        0, 0, context, provider.user.token ?? "",
        id_user: provider.user.id ?? "", statuses: ["cancelled"]);
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
                                  "PROCESANDO (${countOrders2.toString()})",
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
                    icon: Text("PROCESANDO (${countOrders2.toString()})",
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
