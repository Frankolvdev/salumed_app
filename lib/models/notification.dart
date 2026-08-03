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

  factory NotificationModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return NotificationModel();
    }

    final dynamic imageJson = json["image"];
    final dynamic userJson = json["user"];

    return NotificationModel(
      id: json["_id"] ?? json["id"],
      title: json["title"]?.toString(),
      content: json["content"]?.toString(),
      data: json["data"],
      link: json["link"]?.toString(),
      image: imageJson is Map<String, dynamic>
          ? AssetModel.fromJson(imageJson)
          : null,
      user: userJson is Map<String, dynamic>
          ? UserModel.fromJson(userJson)
          : null,
      status: json["status"]?.toString(),
      created_at: json["createdAt"]?.toString(),
      updated_at: json["updatedAt"]?.toString(),
    );
  }
}
