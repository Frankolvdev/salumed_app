import 'package:app/models/address.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/budget.dart';
import 'package:app/models/category.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/place.dart';
import 'package:app/models/prescription.dart';
import 'package:app/models/user.dart';

class OrderModel {
  String? id;
  String? status;
  String? type_delivery;
  String? type_payment;
  String? comments;
  String? date_send;
  UserModel? patient;
  PrescriptionModel? prescription;
  num? lat;
  num? long;
  Place? place;
  List<BudgetModel>? budgets;
  BudgetModel? budget_accepted;
  UserModel? delivery_assigned;
  String? type;
  String? approval;
  String? created_at;
  String? updated_at;
  AddressModel? address;

  OrderModel({
    this.id,
    this.status,
    this.type_delivery,
    this.type_payment,
    this.comments,
    this.date_send,
    this.patient,
    this.prescription,
    this.lat,
    this.long,
    this.place,
    this.budgets,
    this.budget_accepted,
    this.delivery_assigned,
    this.type,
    this.approval,
    this.address,
    this.created_at,
    this.updated_at,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return OrderModel();

    return OrderModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        status: (json.containsKey("status")) ? json["status"] : "",
        type_delivery:
            (json.containsKey("type_delivery")) ? json["type_delivery"] : "",
        type_payment:
            (json.containsKey("type_payment")) ? json["type_payment"] : "",
        comments: (json.containsKey("comments")) ? json["comments"] : "",
        date_send: (json.containsKey("date_send")) ? json["date_send"] : "",
        patient: (json.containsKey("patient") && json["patient"] != null)
            ? UserModel.fromJson(json["patient"])
            : json["patient"],
        prescription: (json.containsKey("prescription"))
            ? PrescriptionModel.fromJson(json["prescription"])
            : json["prescription"],
        lat: (json.containsKey("location"))
            ? (json["location"]["coordinates"].length >= 2)
                ? json["location"]["coordinates"][1] ?? 0
                : null
            : null,
        long: (json.containsKey("location"))
            ? (json["location"]["coordinates"].length >= 2)
                ? json["location"]["coordinates"][0] ?? 0
                : null
            : null,
        place: (json.containsKey("place"))
            ? Place.fromJsonServer(json["place"])
            : null,
        budgets: (json.containsKey("budgets") && json["budgets"] is List)
            ? (json["budgets"] as List<dynamic>)
                .map((e) => BudgetModel.fromJson(e))
                .toList()
            : [],
        budget_accepted: (json.containsKey("budget_accepted"))
            ? BudgetModel.fromJson(json["budget_accepted"])
            : json["budget_accepted"],
        delivery_assigned: (json.containsKey("delivery_assigned") &&
                json["delivery_assigned"] != null)
            ? UserModel.fromJson(json["delivery_assigned"])
            : json["delivery_assigned"],
        type: (json.containsKey("type")) ? json["type"] : "normal",
        approval: (json.containsKey("approval")) ? json["approval"] : "pending",
        address: (json.containsKey("address"))
            ? AddressModel.fromJson(json["address"])
            : null,
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }

  Map<String, dynamic> toJson(OrderModel item) {
    return {};
  }
}
