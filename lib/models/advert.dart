import 'dart:convert';

import 'package:app/models/asset.dart';
import 'package:app/models/bid.dart';
import 'package:app/models/place.dart';
import 'package:app/models/question.dart';
import 'package:app/models/user.dart';

class AdvertModel {
  String? id;
  String? type;
  UserModel? user;
  String? category;
  String? status;
  List<AssetModel>? pictures;
  Map<String, dynamic>? generic_questionnaire;
  Map<String, dynamic>? category_questionnaire;
  String? end_auction;
  String? start;
  String? end;
  List<QuestionModel>? questions;
  List<UserModel>? likes;
  Place? location;
  String? confirm_number;
  List<BidModel>? bids;

  String? show_all_bids;
  String? work_status;

  UserModel? professional_in_work;
  List<AssetModel>? pictures_completed_work;
  num? budget;
  String? client_qualification;
  String? professional_qualification;
  String? status_professional_paid_commission;
  String? accepted;
  String? created_at;
  String? updated_at;

  AdvertModel({
    this.id,
    this.type,
    this.user,
    this.category,
    this.status,
    this.pictures,
    this.generic_questionnaire,
    this.category_questionnaire,
    this.end_auction,
    this.start,
    this.end,
    this.questions,
    this.likes,
    this.location,
    this.confirm_number,
    this.bids,
    this.show_all_bids,
    this.work_status,
    this.professional_in_work,
    this.pictures_completed_work,
    this.budget,
    this.client_qualification,
    this.professional_qualification,
    this.status_professional_paid_commission,
    this.accepted,
    this.created_at,
    this.updated_at,
  });

  factory AdvertModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return AdvertModel();

    return AdvertModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        type: json["type"],
        user: (json.containsKey("user"))
            ? UserModel.fromJson(json["user"])
            : json["user"],
        category: json["category"],
        status: json["status"],
        pictures: (json.containsKey("pictures"))
            ? (json["pictures"]).map<AssetModel>((asset) {
                return AssetModel.fromJson(asset);
              }).toList()
            : [],
        generic_questionnaire: jsonDecode(json["generic_questionnaire"]),
        category_questionnaire: jsonDecode(json["category_questionnaire"]),
        end_auction: (json.containsKey("end_auction"))
            ? DateTime.parse(json["end_auction"]).toLocal().toString()
            : null,
        start: DateTime.parse(json["start"]).toLocal().toString(),
        end: DateTime.parse(json["end"]).toLocal().toString(),
        questions: (json.containsKey("questions"))
            ? (json["questions"]).map<QuestionModel>((question) {
                return QuestionModel.fromJson(question);
              }).toList()
            : [],
        likes: (json.containsKey("likes"))
            ? (json["likes"]).map<UserModel>((like) {
                return UserModel.fromJson(like);
              }).toList()
            : [],
        location: (json.containsKey("location"))
            ? Place.fromJsonServer(json["location"])
            : json["location"],
        confirm_number: json["confirm_number"],
        bids: (json.containsKey("bids"))
            ? (json["bids"]).map<BidModel>((bid) {
                return BidModel.fromJson(bid);
              }).toList()
            : [],
        show_all_bids:
            (json.containsKey("show_all_bids")) ? json["show_all_bids"] : "",
        work_status:
            (json.containsKey("work_status")) ? json["work_status"] : "",
        professional_in_work: (json.containsKey("professional_in_work"))
            ? UserModel.fromJson(json["professional_in_work"])
            : json["professional_in_work"],
        pictures_completed_work: (json.containsKey("pictures_completed_work"))
            ? (json["pictures_completed_work"]).map<AssetModel>((asset) {
                return AssetModel.fromJson(asset);
              }).toList()
            : [],
        budget: (json.containsKey("budget")) ? json["budget"] : 0,
        client_qualification: (json.containsKey("client_qualification"))
            ? json["client_qualification"]
            : null,
        professional_qualification:
            (json.containsKey("professional_qualification"))
                ? json["professional_qualification"]
                : null,
        status_professional_paid_commission:
            (json.containsKey("status_professional_paid_commission"))
                ? json["status_professional_paid_commission"]
                : null,
        accepted: (json.containsKey("accepted")) ? json["accepted"] : null,
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }
}
