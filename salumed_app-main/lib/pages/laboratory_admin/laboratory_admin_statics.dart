import 'package:app/components/dialog_select_date_range.dart';
import 'package:app/components/fade_animation.dart';
import 'package:app/constants/colors.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/budget.dart';
import 'package:app/models/order.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/app.dart';
import 'package:app/services/web_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:responsive_grid/responsive_grid.dart';

class LaboratoryAdminStatics extends StatefulWidget {
  const LaboratoryAdminStatics({Key? key}) : super(key: key);

  @override
  State<LaboratoryAdminStatics> createState() => _LaboratoryAdminStaticsState();
}

class _LaboratoryAdminStaticsState extends State<LaboratoryAdminStatics> {
  late List<OrdersData> _chartData;
  late TooltipBehavior _tooltipBehavior;

  DateTime timeMinOrders = DateTime.now().subtract(Duration(days: 30));
  DateTime timeMaxOrders = DateTime.now();

  final cMinOrders = TextEditingController();
  final cMaxOrders = TextEditingController();
  final cEmail = TextEditingController();
  @override
  void initState() {
    _chartData = getChartData();
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();

    loadCountsOrders();

    loadStatics();
  }

  num countOrders1 = 0;
  num countOrders2 = 0;
  num countOrders3 = 0;

  num totalOrders1 = 0;
  num totalOrders2 = 0;
  num totalOrders3 = 0;

/*
  if(status=="waiting_delivery"){
  return "Asigna un repartidor";
  }else if(status=="waiting_package"){
  return "Prepara el paquete";
  }else if(status=="delivery_assigned"){
  return "Esperando entrega por repartidor";
  }else if(status=="waiting_package"){
  return "Preparando el paquete";
  }else if(status=="ready_in_store"){
  return "Marcar como entregado";
  }else if(status=="go_deliver"){
  return "En proceso de entrega";
  }else if(status=="cancelled"){
  return "Cancelada";
  }else if(status=="completed"){
  return "Pedido entregado";
  }else{
  return "";
  }

*/
  Future loadCountsOrders() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    List<OrderModel> ordersTmp1 = await WebService(context).getOrders(
        0, 0, context, provider.user.token ?? "",
        id_pharmacy: provider.user.pharmacy_assigned!.id ?? "",
        statuses: [
          "waiting_package",
          "waiting_delivery",
          "delivery_assigned",
          "ready_in_store",
          "go_deliver"
        ],
        type_business: [
          "studies_without_prescription"
        ]);
    countOrders1 = ordersTmp1.length;
    List<OrderModel> ordersTmp2 = await WebService(context).getOrders(
        0, 0, context, provider.user.token ?? "",
        id_pharmacy: provider.user.pharmacy_assigned!.id ?? "",
        statuses: ["completed"],
        type_business: ["studies_without_prescription"]);
    countOrders2 = ordersTmp2.length;
    List<OrderModel> ordersTmp3 = await WebService(context).getOrders(
        0, 0, context, provider.user.token ?? "",
        id_pharmacy: provider.user.pharmacy_assigned!.id ?? "",
        statuses: ["cancelled"],
        type_business: ["studies_without_prescription"]);
    countOrders3 = ordersTmp3.length;

    ordersTmp1.forEach((order) {
      num costDelivery = 0;
      num contProducts = 0;
      if (order.budget_accepted != null &&
          order.budget_accepted!.cost_delivery != null &&
          order.budget_accepted!.cost_delivery != "")
        costDelivery = double.parse(order.budget_accepted!.cost_delivery!);
      if (order.budget_accepted != null &&
          order.budget_accepted!.cost_products != null &&
          order.budget_accepted!.cost_products != "")
        contProducts = double.parse(order.budget_accepted!.cost_products!);
      totalOrders1 += (costDelivery + contProducts);
    });

    ordersTmp2.forEach((order) {
      num costDelivery = 0;
      num contProducts = 0;
      if (order.budget_accepted != null &&
          order.budget_accepted!.cost_delivery != null &&
          order.budget_accepted!.cost_delivery != "")
        costDelivery = double.parse(order.budget_accepted!.cost_delivery!);
      if (order.budget_accepted != null &&
          order.budget_accepted!.cost_products != null &&
          order.budget_accepted!.cost_products != "")
        contProducts = double.parse(order.budget_accepted!.cost_products!);
      totalOrders2 += (costDelivery + contProducts);
    });

    ordersTmp3.forEach((order) {
      num costDelivery = 0;
      num contProducts = 0;
      if (order.budget_accepted != null &&
          order.budget_accepted!.cost_delivery != null &&
          order.budget_accepted!.cost_delivery != "")
        costDelivery = double.parse(order.budget_accepted!.cost_delivery!);
      if (order.budget_accepted != null &&
          order.budget_accepted!.cost_products != null &&
          order.budget_accepted!.cost_products != "")
        contProducts = double.parse(order.budget_accepted!.cost_products!);
      totalOrders3 += (costDelivery + contProducts);
    });

    setState(() {});
  }

  num countAllUsers = 0;
  num countAdminUsers = 0;
  num countSuperAdminUsers = 0;
  num countPharmacyAdminUsers = 0;
  num countClientUsers = 0;
  num countDeliveryUsers = 0;
  num countDoctorUsers = 0;

  num countPedidos = 0;
  Future loadStatics() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    dynamic res = await WebService(context).getStaticsOrder(
        timeMinOrders.toUtc().millisecondsSinceEpoch.toString(),
        timeMaxOrders
            .add(Duration(minutes: 1439))
            .toUtc()
            .millisecondsSinceEpoch
            .toString(),
        id_pharmacy: provider.user.pharmacy_assigned!.id ?? "");
    List<dynamic> items = res["ordenes_por_rango_fecha"];
    final List<OrdersData> chartData = [];

    for (var i = 0; i < items.length; i++) {
      String date = items[i]["_id"];
      double total = 0;
      for (var i2 = 0; i2 < items[i]["orders"].length; i2++) {
        if (items[i]["orders"][i2].containsKey("item")) {
          BudgetModel budgetTmp =
              BudgetModel.fromJson(items[i]["orders"][i2]["item"]);
          total += getTotalOrder(budgetTmp);
        }
      }
      countPedidos += items[i]["orders"].length;
      chartData.add(new OrdersData(date, total));
    }

    chartData.sort((a, b) {
      //DateTime aTmp= DateFormat('YYYY/mm/dd').parse(a.date);
      //DateTime bTmp= DateFormat('YYYY/mm/dd').parse(b.date);

      return a.date.compareTo(b.date);
    });

    setState(() {
      _chartData = chartData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text("Pedidos ${countPedidos}",
              style: TextStyle(fontSize: 25, color: CustomColors.primary)),
        ),
        InkWell(
          onTap: () {
            selectRangeDate(timeMinOrders, timeMaxOrders,
                (DateTime dateMin, DateTime dateMax) {
              setState(() {
                timeMinOrders = dateMin;
                timeMaxOrders = dateMax;
              });
              loadStatics();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.hourglassHalf,
                    size: 20, color: CustomColors.primary),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Text(
                    "",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Text(
                      getDateFromStringFormatResume(timeMinOrders.toString()),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Text(" a ", style: TextStyle(fontSize: 18)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: Text(
                      getDateFromStringFormatResume(timeMaxOrders.toString()),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FaIcon(FontAwesomeIcons.chevronDown,
                      size: 20, color: CustomColors.primary),
                ),
              ],
            ),
          ),
        ),
        Container(
          child: SfCartesianChart(
            title: ChartTitle(text: ""),
            legend: Legend(isVisible: false),
            tooltipBehavior: _tooltipBehavior,
            series: <CartesianSeries>[
              LineSeries<OrdersData, String>(
                  markerSettings: MarkerSettings(
                      color: CustomColors.secondary, isVisible: true),
                  color: CustomColors.primary,
                  width: 4,
                  name: 'Total ordenes',
                  dataSource: _chartData,
                  xValueMapper: (OrdersData sales, _) => sales.date,
                  yValueMapper: (OrdersData sales, _) => sales.sales,
                  dataLabelSettings: DataLabelSettings(isVisible: true))
            ],
            primaryXAxis:
                CategoryAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
            primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0)),
          ),
        ),
        FadeAnimation(
          1,
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ResponsiveGridRow(children: [
                  ResponsiveGridCol(
                    lg: 4,
                    xs: 12,
                    md: 12,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Pedidos Completados",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${countOrders2}",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "\$ ${totalOrders2}",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    lg: 4,
                    xs: 12,
                    md: 12,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Pedidos en Curso",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${countOrders1}",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "\$ ${totalOrders1}",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.yellow[800]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ResponsiveGridCol(
                    lg: 4,
                    xs: 12,
                    md: 12,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Pedidos Cancelados",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "${countOrders3}",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "\$  ${totalOrders3}",
                                style:
                                    TextStyle(fontSize: 25, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              )
            ],
          ),
          axis: AxisAnimation.y,
          negative: true,
        ),
      ],
    ));
  }

  List<OrdersData> getChartData() {
    final List<OrdersData> chartData = [];
    return chartData;
  }

  selectRangeDate(DateTime from, DateTime max, Function callback) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (contextDialog) {
          return DialogSelectDateRange(
            from,
            max,
            "Filtrar",
            (dynamic dateMin, dynamic dateMax) {
              callback(dateMin, dateMax);
            },
            useBtnCancel: true,
          );
        });
  }
}

class OrdersData {
  OrdersData(this.date, this.sales);
  final String date;
  final double sales;
}
