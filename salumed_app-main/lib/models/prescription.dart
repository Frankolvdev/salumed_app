import 'package:app/models/asset.dart';
import 'package:app/models/category.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/place.dart';
import 'package:app/models/user.dart';

class PrescriptionModel {
  String? id;
  UserModel? patient;
  UserModel? doctor;

  String? diagnosis;
  String? prescription_text;
  String? evolution;
  AssetModel? prescription_picture;
  String? id_order;
  String? created_at;
  String? updated_at;
  List<dynamic>? medical_studies;
  String? other_studies;
  AssetModel? picture_studies;

  bool? requested_medications;
  String? type;
  List<dynamic>? medicines;

  PrescriptionModel({
    this.id,
    this.patient,
    this.doctor,
    this.diagnosis,
    this.prescription_text,
    this.evolution,
    this.prescription_picture,
    this.requested_medications,
    this.id_order,
    this.medical_studies,
    this.other_studies,
    this.picture_studies,
    this.type,
    this.medicines,
    this.created_at,
    this.updated_at,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return PrescriptionModel();
    print("doctor");
    print(json["doctor"]);

    return PrescriptionModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        patient: (json.containsKey("patient"))
            ? UserModel.fromJson(json["patient"])
            : json["patient"],
        doctor: (json.containsKey("doctor"))
            ? UserModel.fromJson(json["doctor"])
            : null,
        diagnosis: (json.containsKey("diagnosis")) ? json["diagnosis"] : "",
        prescription_text: (json.containsKey("prescription_text"))
            ? json["prescription_text"]
            : "",
        evolution: (json.containsKey("evolution")) ? json["evolution"] : "",
        prescription_picture: (json.containsKey("prescription_picture"))
            ? (json["prescription_picture"] != null)
                ? AssetModel.fromJson(json["prescription_picture"])
                : null
            : json["prescription_picture"],
        requested_medications: (json.containsKey("requested_medications"))
            ? json["requested_medications"]
            : false,
        id_order: (json.containsKey("id_order"))
            ? (json["id_order"] != "" && json["id_order"] != null)
                ? json["id_order"]
                : null
            : null,
        medical_studies: (json.containsKey("medical_studies"))
            ? json["medical_studies"]
            : [],
        other_studies:
            (json.containsKey("other_studies")) ? json["other_studies"] : "",
        picture_studies: (json.containsKey("picture_studies"))
            ? (json["picture_studies"] != null)
                ? AssetModel.fromJson(json["picture_studies"])
                : null
            : json["picture_studies"],
        type: (json.containsKey("type")) ? json["type"] : "normal",
        medicines: (json.containsKey("medicines")) ? json["medicines"] : [],
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }

  Map<String, dynamic> toJson(PrescriptionModel item) {
    return {};
  }
}
