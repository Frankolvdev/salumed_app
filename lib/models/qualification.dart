import 'package:app/models/user.dart';

class QualificationModel {
  String? id;
  String? user;
  String? advert;
  num? qualification;
  String? comment;
  String? created_at;
  String? updated_at;

  QualificationModel({
    this.id,
    this.user,
    this.advert,
    this.qualification,
    this.comment,
    this.created_at,
    this.updated_at,
  });

  factory QualificationModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return QualificationModel();
    return QualificationModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        user: json["user"],
        advert: json["advert"],
        qualification: json["qualification"],
        comment: json["comment"],
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }

  Map<String, dynamic> toJson(QualificationModel item) {
    return {
      'id': item.id,
      'user': item.user,
      'advert': item.advert,
      'qualification': item.qualification,
      'comment': item.comment,
      'createdAt': item.created_at,
      'updatedAt': item.updated_at,
    };
  }
}
