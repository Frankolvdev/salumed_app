import 'package:app/models/address.dart';
import 'package:app/models/archive.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/qualification.dart';
import 'package:app/models/role.dart';
import 'package:app/models/subscription.dart';
import 'package:intl/date_symbols.dart';

class UserModel {
  String? id;
  String? email;
  String? name;
  AssetModel? picture;
  AssetModel? doc_id_front;
  AssetModel? doc_id_back;
  String? token_google;
  String? token_facebook;
  String? token_apple;

  bool? logged;
  String? status;
  String? token;
  String? birthdate;
  String? gender;
  String? phone;
  String? dial_code;
  String? one_signal_id;
  String? platform_one_signal;
  List<RoleModel> roles;
  String? city;
  String? address;
  String? confirm_email_token;

  bool? accept_doc1;
  bool? accept_doc2;
  bool? accept_doc3;
  bool? accept_doc4;
  bool? accept_doc5;
  bool? accept_doc6;

  String? enabled;
  String? verified_doctor;
  num? delivery_commission;
  String? professional_license;
  PharmacyModel? pharmacy_assigned;

  double? lat;
  double? long;
  String? push_id;

  String? years;
  String? blood_type;
  String? allergies;
  String? diseases;
  String? organ_donor;

  String? has_covid;
  num? count_vaccines;
  num? height;
  num? weight;
  num? imc;

  String? rfc;
  String? fiscal_address;
  String? request_invoice;
  List<dynamic>? records_pressure_sugar;

  List<AddressModel>? addresses;
  List<ArchiveModel>? archives;

  String? created_at;
  String? updated_at;

  UserModel({
    this.id,
    this.email,
    this.name,
    this.picture,
    this.doc_id_front,
    this.doc_id_back,
    this.token_google,
    this.token_facebook,
    this.token_apple,
    this.logged,
    this.status,
    this.token,
    this.birthdate,
    this.gender,
    this.phone,
    this.dial_code,
    this.one_signal_id,
    this.platform_one_signal,
    required this.roles,
    this.city,
    this.address,
    this.confirm_email_token,
    this.accept_doc1,
    this.accept_doc2,
    this.accept_doc3,
    this.accept_doc4,
    this.accept_doc5,
    this.accept_doc6,
    this.enabled,
    this.verified_doctor,
    this.delivery_commission,
    this.professional_license,
    this.pharmacy_assigned,
    this.lat,
    this.long,
    this.push_id,
    this.years,
    this.blood_type,
    this.allergies,
    this.diseases,
    this.organ_donor,
    this.has_covid,
    this.count_vaccines,
    this.height,
    this.weight,
    this.imc,
    this.rfc,
    this.fiscal_address,
    this.request_invoice,
    this.records_pressure_sugar,
    this.addresses,
    this.archives,
    this.created_at,
    this.updated_at,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return UserModel(roles: []);

    return UserModel(
        id: (json.containsKey("_id")) ? json["_id"] : json["id"],
        email: json["email"],
        name: json["name"],
        picture: (json.containsKey("picture"))
            ? (json["picture"] != null)
                ? AssetModel.fromJson(json["picture"])
                : null
            : json["picture"],
        doc_id_front: (json.containsKey("doc_id_front"))
            ? (json["doc_id_front"] != null)
                ? AssetModel.fromJson(json["doc_id_front"])
                : null
            : json["doc_id_front"],
        doc_id_back: (json.containsKey("doc_id_back"))
            ? (json["doc_id_back"] != null)
                ? AssetModel.fromJson(json["doc_id_back"])
                : null
            : json["doc_id_back"],
        token_google: json["token_google"],
        token_facebook: json["token_facebook"],
        token_apple: json["token_apple"],
        logged: json["logged"],
        status: json["status"],
        token: json["token"],
        birthdate: json["birthdate"],
        gender: json["gender"],
        phone: json["phone"],
        dial_code: (json.containsKey("dial_code")) ? json["dial_code"] : null,
        delivery_commission: (json.containsKey("delivery_commission"))
            ? json["delivery_commission"]
            : null,
        one_signal_id: json["one_signal_id"],
        platform_one_signal: json["platform_one_signal"],
        roles: (json.containsKey("roles"))
            ? (json["roles"] as List<dynamic>)
                .map((e) => RoleModel.fromJson(e))
                .toList()
            : [],
        city: json["city"],
        address: (json.containsKey("address")) ? json["address"] : "",
        confirm_email_token: (json.containsKey("confirm_email_token"))
            ? json["confirm_email_token"]
            : null,
        accept_doc1:
            (json.containsKey("accept_doc1")) ? json["accept_doc1"] : false,
        accept_doc2:
            (json.containsKey("accept_doc2")) ? json["accept_doc2"] : false,
        accept_doc3:
            (json.containsKey("accept_doc3")) ? json["accept_doc3"] : false,
        accept_doc4:
            (json.containsKey("accept_doc4")) ? json["accept_doc4"] : false,
        accept_doc5:
            (json.containsKey("accept_doc5")) ? json["accept_doc5"] : false,
        accept_doc6:
            (json.containsKey("accept_doc6")) ? json["accept_doc6"] : false,
        enabled: (json.containsKey("enabled")) ? json["enabled"] : "no",
        verified_doctor: (json.containsKey("verified_doctor"))
            ? json["verified_doctor"]
            : "no",
        professional_license: (json.containsKey("professional_license"))
            ? json["professional_license"]
            : null,
        pharmacy_assigned: (json.containsKey("pharmacy_assigned"))
            ? (json["pharmacy_assigned"] != null &&
                    json["pharmacy_assigned"] is Map<String, dynamic>)
                ? PharmacyModel.fromJson(json["pharmacy_assigned"])
                : null
            : null,
        lat: (json.containsKey("location"))
            ? json["location"]["coordinates"][1]
            : null,
        long: (json.containsKey("location"))
            ? json["location"]["coordinates"][0]
            : null,
        push_id: json["push_id"],
        years: (json.containsKey("years")) ? json["years"] : "",
        blood_type: (json.containsKey("blood_type")) ? json["blood_type"] : "",
        allergies: (json.containsKey("allergies")) ? json["allergies"] : "",
        diseases: (json.containsKey("diseases")) ? json["diseases"] : "",
        organ_donor:
            (json.containsKey("organ_donor")) ? json["organ_donor"] : "",
        has_covid: (json.containsKey("has_covid")) ? json["has_covid"] : "",
        count_vaccines:
            (json.containsKey("count_vaccines")) ? json["count_vaccines"] : 0,
        height: (json.containsKey("height")) ? json["height"] : 0,
        weight: (json.containsKey("weight")) ? json["weight"] : 0,
        imc: (json.containsKey("imc")) ? json["imc"] : 0,
        rfc: (json.containsKey("rfc")) ? json["rfc"] : "",
        fiscal_address:
            (json.containsKey("fiscal_address")) ? json["fiscal_address"] : "",
        request_invoice: (json.containsKey("request_invoice"))
            ? json["request_invoice"]
            : "",
        records_pressure_sugar: (json.containsKey("records_pressure_sugar"))
            ? json["records_pressure_sugar"]
            : [],
        addresses: (json.containsKey("addresses"))
            ? (json["addresses"] as List<dynamic>)
                .map((e) => AddressModel.fromJson(e))
                .toList()
            : [],
        archives: (json.containsKey("archives"))
            ? (json["archives"] as List<dynamic>)
                .map((e) => ArchiveModel.fromJson(e))
                .toList()
            : [],
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }

  Map<String, dynamic> toJson(UserModel item) {
    return {
      'id': item.id,
      'email': item.email,
      'name': item.name,
      'picture':
          (item.picture != null) ? AssetModel().toJson(item.picture!) : null,
      'doc_id_front': (item.doc_id_front != null)
          ? AssetModel().toJson(item.doc_id_front!)
          : null,
      'doc_id_back': (item.doc_id_back != null)
          ? AssetModel().toJson(item.doc_id_back!)
          : null,
      'token_google': item.token_google,
      'token_facebook': item.token_facebook,
      'token_apple': item.token_apple,
      'logged': item.logged,
      'status': item.status,
      'token': item.token,
      'birthdate': item.birthdate,
      'gender': item.gender,
      'phone': item.phone,
      'dial_code': item.dial_code,
      'one_signal_id': item.one_signal_id,
      'platform_one_signal': item.platform_one_signal,
      'roles': item.roles.map((e) => RoleModel().toJson(e)).toList(),
      'city': item.city,
      'address': (item.address != null) ? item.address : "",
      'confirm_email_token':
          (item.confirm_email_token != null) ? item.confirm_email_token : null,
      'accept_doc1': (item.accept_doc1 != null) ? item.accept_doc1 : false,
      'accept_doc2': (item.accept_doc2 != null) ? item.accept_doc2 : false,
      'accept_doc3': (item.accept_doc3 != null) ? item.accept_doc3 : false,
      'accept_doc4': (item.accept_doc4 != null) ? item.accept_doc4 : false,
      'accept_doc5': (item.accept_doc5 != null) ? item.accept_doc5 : false,
      'accept_doc6': (item.accept_doc6 != null) ? item.accept_doc6 : false,
      'enabled': (item.enabled != null) ? item.enabled : "no",
      'verified_doctor':
          (item.verified_doctor != null) ? item.verified_doctor : "no",
      'professional_license': (item.professional_license != null)
          ? item.professional_license
          : null,
      'pharmacy_assigned': (item.pharmacy_assigned != null)
          ? PharmacyModel().toJson(item.pharmacy_assigned!)
          : null,
      'lat': item.lat,
      'long': item.long,
      'push_id': item.push_id,
      'years': item.years,
      'blood_type': item.blood_type,
      'allergies': item.allergies,
      'diseases': item.diseases,
      'organ_donor': item.organ_donor,
      'has_covid': item.has_covid,
      'count_vaccines': item.count_vaccines,
      'height': item.height,
      'weight': item.weight,
      'imc': item.imc,
      'rfc': item.rfc,
      'fiscal_address': item.fiscal_address,
      'request_invoice': item.request_invoice,
      'records_pressure_sugar': item.records_pressure_sugar,
      'addresses': (item.addresses != null)
          ? item.addresses!.map((e) => AddressModel().toJson(e)).toList()
          : [],
      'archives': (item.archives != null)
          ? item.archives!.map((e) => ArchiveModel().toJson(e)).toList()
          : [],
      'createdAt': item.created_at,
      'updatedAt': item.updated_at,
    };
  }
}
