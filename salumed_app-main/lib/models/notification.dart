import 'package:app/models/asset.dart';
import 'package:app/models/user.dart';

class NotificationModel {
  String? id;
  String? title;
  String? content;
  dynamic data;
  String? link;
  AssetModel? image;
  UserModel? user;
  String? status;
  String? created_at;
  String? updated_at;

  NotificationModel({
    this.id,
    this.title,
    this.content,
    this.data,
    this.link,
    this.image,
    this.user,
    this.status,
    this.created_at,
    this.updated_at,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return NotificationModel();
    return NotificationModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        title: json["title"],
        content: json["content"],
        data: json["data"],
        link: json["link"],
        image: (json.containsKey("image"))
            ? AssetModel.fromJson(json["image"])
            : null,
        user: (json.containsKey("user"))
            ? UserModel.fromJson(json["user"])
            : null,
        status: json["status"],
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }
}
