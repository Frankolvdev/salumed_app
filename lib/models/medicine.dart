import 'dart:convert';

import 'package:app/models/asset.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/user.dart';

class MedicineModel {
  String? id;
  String? medicine;
  String? prescription;
  num? cost;
  num? amount;
  num? quantity;

  MedicineModel(
      {this.id,
      this.prescription,
      this.medicine,
      this.cost,
      this.amount,
      this.quantity});

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return MedicineModel();
    return MedicineModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        prescription:
            (json.containsKey("prescription")) ? json["prescription"] : "",
        medicine: json["medicine"],
        cost: json["cost"],
        amount: json["amount"],
        quantity: json["quantity"]);
  }
}
