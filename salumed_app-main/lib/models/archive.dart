import 'package:app/models/address.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/qualification.dart';
import 'package:app/models/role.dart';
import 'package:app/models/subscription.dart';
import 'package:intl/date_symbols.dart';

class ArchiveModel {
  String? id;
  String? title;
  String? id_user;
  AssetModel? file;
  String? created_at;
  String? updated_at;

  ArchiveModel({
    this.id,
    this.title,
    this.file,
    this.id_user,
    this.created_at,
    this.updated_at,
  });

  factory ArchiveModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return ArchiveModel();

    return ArchiveModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        title: json["title"],
        id_user: json["id_user"],
        file: (json.containsKey("file"))
            ? (json["file"] != null)
                ? AssetModel.fromJson(json["file"])
                : null
            : json["file"],
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }

  Map<String, dynamic> toJson(ArchiveModel item) {
    return {
      'id': item.id,
      'title': item.title,
      'id_user': item.id_user,
      'file': (item.file != null) ? AssetModel().toJson(item.file!) : null,
      'createdAt': item.created_at,
      'updatedAt': item.updated_at,
    };
  }
}
