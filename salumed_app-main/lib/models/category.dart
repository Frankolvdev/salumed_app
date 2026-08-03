import 'package:app/models/asset.dart';
import 'package:app/models/user.dart';

class CategoryModel {
  String? id;
  String? title;
  AssetModel? cover;
  String? created_at;
  String? updated_at;

  CategoryModel({
    this.id,
    this.title,
    this.cover,
    this.created_at,
    this.updated_at,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return CategoryModel();
    return CategoryModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        title: json["title"],
        cover: (json.containsKey("cover"))
            ? AssetModel.fromJson(json["cover"])
            : null,
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }
}
