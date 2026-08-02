import 'package:app/models/asset.dart';
import 'package:app/models/user.dart';

class MessageModel {
  String? id;
  String? message;
  String? status;
  UserModel? transmitter;
  UserModel? receiver;
  String? advert_id;
  List<AssetModel>? assets;
  String? created_at;
  String? updated_at;

  MessageModel({
    this.id,
    this.message,
    this.status,
    this.transmitter,
    this.receiver,
    this.advert_id,
    this.assets,
    this.created_at,
    this.updated_at,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return MessageModel();
    return MessageModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        message: json["message"],
        status: json["status"],
        transmitter: (json.containsKey("transmitter"))
            ? UserModel.fromJson(json["transmitter"])
            : json["transmitter"],
        receiver: (json.containsKey("receiver"))
            ? UserModel.fromJson(json["receiver"])
            : json["receiver"],
        advert_id: json["advert_id"],
        assets: (json.containsKey("assets"))
            ? (json["assets"]).map<AssetModel>((asset) {
                return AssetModel.fromJson(asset);
              }).toList()
            : [],
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }
}
