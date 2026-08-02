import 'package:app/models/user.dart';

class BidModel {
  String? id;
  UserModel? user;
  bool? weekend_only;
  String? proposed_date;
  num? amount;
  String? status;
  String? explanation;
  String? created_at;
  String? updated_at;

  BidModel({
    this.id,
    this.user,
    this.weekend_only,
    this.proposed_date,
    this.amount,
    this.status,
    this.explanation,
    this.created_at,
    this.updated_at,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return BidModel();
    return BidModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        user: (json.containsKey("user"))
            ? UserModel.fromJson(json["user"])
            : json["user"],
        weekend_only: json["weekend_only"],
        proposed_date: json["proposed_date"],
        amount: json["amount"],
        status: json["status"],
        explanation:
            (json.containsKey("explanation")) ? json["explanation"] : "",
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }
}
