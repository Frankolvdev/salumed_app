import 'package:app/models/asset.dart';

class RoleModel {
  String? id;
  String? name;
  String? created_at;
  String? updated_at;

  RoleModel({
    this.id,
    this.name,
    this.created_at,
    this.updated_at,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return RoleModel();
    return RoleModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        name: json["name"],
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }

  Map<String, dynamic> toJson(RoleModel item) {
    return {
      'id': item.id,
      'name': item.name,
      'createdAt': item.created_at,
      'updatedAt': item.updated_at,
    };
  }
}
