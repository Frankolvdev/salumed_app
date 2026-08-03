import 'package:app/models/asset.dart';
import 'package:app/models/category.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/place.dart';
import 'package:app/models/user.dart';

class PromotionModel {
  String? id;
  String? title;
  String? code;
  String? type;
  String? amount;
  String? apply_to;
  num? limit_use;
  String? start;
  String? end;
  PharmacyModel? business;

  bool? monday;
  bool? tuesday;
  bool? wednesday;
  bool? thursday;
  bool? friday;
  bool? saturday;
  bool? sunday;

  String? created_at;
  String? updated_at;

  PromotionModel({
    this.id,
    this.title,
    this.code,
    this.type,
    this.amount,
    this.apply_to,
    this.limit_use,
    this.start,
    this.end,
    this.business,
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
    this.created_at,
    this.updated_at,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return PromotionModel();

    return PromotionModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        title: (json.containsKey("title")) ? json["title"] : null,
        code: (json.containsKey("code")) ? json["code"] : null,
        type: (json.containsKey("type")) ? json["type"] : null,
        amount: (json.containsKey("amount")) ? json["amount"] : null,
        apply_to: (json.containsKey("apply_to")) ? json["apply_to"] : null,
        limit_use: (json.containsKey("limit_use")) ? json["limit_use"] : 0,
        start: (json.containsKey("start")) ? json["start"] : null,
        end: (json.containsKey("end")) ? json["end"] : null,
        business: (json.containsKey("business"))
            ? PharmacyModel.fromJson(json["business"])
            : null,
        monday: (json.containsKey("monday")) ? json["monday"] : false,
        tuesday: (json.containsKey("tuesday")) ? json["tuesday"] : false,
        wednesday: (json.containsKey("wednesday")) ? json["wednesday"] : false,
        thursday: (json.containsKey("thursday")) ? json["thursday"] : false,
        friday: (json.containsKey("friday")) ? json["friday"] : false,
        saturday: (json.containsKey("saturday")) ? json["saturday"] : false,
        sunday: (json.containsKey("sunday")) ? json["sunday"] : false,
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }

  Map<String, dynamic> toJson(PromotionModel item) {
    return {};
  }
}
