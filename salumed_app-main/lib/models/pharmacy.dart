import 'package:app/models/asset.dart';
import 'package:app/models/category.dart';
import 'package:app/models/place.dart';
import 'package:app/models/user.dart';

class PharmacyModel {
  String? id;
  AssetModel? cover;
  String? title;
  String? approved;
  String? tax_identifier;
  String? description;
  String? phone;
  String? dial_code;
  UserModel? admin;
  CategoryModel? category;
  String? type_commission_store;
  num? commission_store;
  String? type_commission_delivery;
  num? commission_delivery;
  String? delivery_assignment;
  num? km_delivery;
  String? cash_payment;
  String? tj_payment;

  num? lat;
  num? long;
  Place? place;
  String? type;
  String? created_at;
  String? updated_at;

  PharmacyModel({
    this.id,
    this.cover,
    this.title,
    this.approved,
    this.tax_identifier,
    this.description,
    this.phone,
    this.dial_code,
    this.admin,
    this.category,
    this.type_commission_store,
    this.commission_store,
    this.type_commission_delivery,
    this.commission_delivery,
    this.delivery_assignment,
    this.km_delivery,
    this.cash_payment,
    this.tj_payment,
    this.lat,
    this.long,
    this.place,
    this.type,
    this.created_at,
    this.updated_at,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return PharmacyModel();
    return PharmacyModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        cover: (json.containsKey("cover"))
            ? AssetModel.fromJson(json["cover"])
            : json["cover"],
        title: json["title"],
        approved: json["approved"],
        tax_identifier: json["tax_identifier"],
        description: json["description"],
        phone: json["phone"],
        dial_code: json["dial_code"],
        admin: (json.containsKey("admin"))
            ? (json["admin"] != null)
                ? UserModel.fromJson(json["admin"])
                : null
            : json["admin"],
        category: (json.containsKey("category"))
            ? (json["category"] != null)
                ? CategoryModel.fromJson(json["category"])
                : null
            : json["category"],
        type_commission_store: json["type_commission_store"],
        commission_store: json["commission_store"],
        type_commission_delivery: json["type_commission_delivery"],
        commission_delivery: json["commission_delivery"],
        delivery_assignment: json["delivery_assignment"],
        km_delivery: json["km_delivery"],
        cash_payment: json["cash_payment"],
        tj_payment: json["tj_payment"],
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
        type: (json.containsKey("type")) ? json["type"] : "",
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }

  Map<String, dynamic> toJson(PharmacyModel item) {
    return {};
  }
}
