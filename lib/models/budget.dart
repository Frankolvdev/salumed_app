import 'dart:convert';

import 'package:app/models/asset.dart';
import 'package:app/models/medicine.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/user.dart';

class BudgetModel {
  String? id;
  String? cost_delivery;
  String? cost_products;
  PharmacyModel? pharmacy;
  String? status;
  List<MedicineModel> medicines;

  BudgetModel(
      {this.id,
      this.cost_delivery,
      this.cost_products,
      this.pharmacy,
      this.status,
      required this.medicines});

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return BudgetModel(medicines: []);
    return BudgetModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        cost_delivery: json["cost_delivery"],
        cost_products: json["cost_products"],
        pharmacy: (json.containsKey("pharmacy"))
            ? PharmacyModel.fromJson(json["pharmacy"])
            : null,
        medicines: (json.containsKey("medicines") && json["medicines"] is List)
            ? (json["medicines"] as List<dynamic>)
                .map((e) => MedicineModel.fromJson(e))
                .toList()
            : [],
        status: json["status"]);
  }
}
