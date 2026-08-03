import 'package:app/models/asset.dart';
import 'package:app/models/user.dart';

class QuestionModel {
  String? id;
  UserModel? user;
  String? question;
  String? answer;
  AssetModel? picture;
  String? created_at;
  String? updated_at;

  QuestionModel({
    this.id,
    this.user,
    this.question,
    this.answer,
    this.picture,
    this.created_at,
    this.updated_at,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return QuestionModel();
    return QuestionModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        user: (json.containsKey("user"))
            ? UserModel.fromJson(json["user"])
            : json["user"],
        question: json["question"],
        answer: json["answer"],
        picture: (json.containsKey("picture"))
            ? AssetModel.fromJson(json["picture"])
            : null,
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }
}
