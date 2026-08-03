import 'dart:convert';

import 'package:app/constants/globals.dart';
import 'package:app/helpers/helpers.dart';
import 'package:app/models/address.dart';
import 'package:app/models/advert.dart';
import 'package:app/models/archive.dart';
import 'package:app/models/asset.dart';
import 'package:app/models/category.dart';
import 'package:app/models/message.dart';
import 'package:app/models/notification.dart';
import 'package:app/models/order.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/place.dart';
import 'package:app/models/prescription.dart';
import 'package:app/models/promotion.dart';
import 'package:app/models/suggestion.dart';
import 'package:app/models/user.dart';
import 'package:app/providers/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class WebService {
  Dio dio = Dio();
  BuildContext context;
  WebService(this.context) {
    dio = Dio();
  }

  Future<UserModel> signUp(
      String email, String name, String password, String rol,
      {String type_business = ""}) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    String baseURL = apiUrl + "auth/signup";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "email": email,
            "name": name,
            "password": password,
            "rol": rol,
            "type_business": type_business
          }));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> contact(String comments, String matter, String email,
      String name, String phone, String typeUser) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    String baseURL = apiUrl + "user/contact";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "comments": comments,
            "matter": matter,
            "email": email,
            "name": name,
            "phone": phone,
            "type_user": typeUser,
          }));
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> paymentIntent(String typePayment, String token,
      {String idAdvert = ""}) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/payment-intent";
    try {
      dynamic response = await dio.post(baseURL,
          data:
              jsonEncode({"type_payment": typePayment, "id_advert": idAdvert}));
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> signIn(String email, String password) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    String baseURL = apiUrl + "auth/signin";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({"email": email, "password": password}));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error login");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> updatePlan(String plan, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/update-plan";

    try {
      dynamic response =
          await dio.put(baseURL, data: jsonEncode({"plan": plan}));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        print("error1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error login");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> signInAuth(String token, String name, String email,
      String provider, String phone, String picture) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    String baseURL = apiUrl + "auth/signin-auth";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "token": token,
            "name": name,
            "email": email,
            "provider": provider,
            "phone": phone,
            "picture": picture
          }));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        print("error1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> updateTokenPushUser(
      String platformDevice, String oneSignalId, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/update";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "platform_one_signal": platformDevice,
            "one_signal_id": oneSignalId
          }));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en updateTokenPushUser ");
      print(e);
      print((e as DioError).message);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> updateTokenWebPushUser(String push_id, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/update";
    try {
      dynamic response =
          await dio.post(baseURL, data: jsonEncode({"push_id": push_id}));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en updateTokenPushUser ");
      print(e);
      print((e as DioError).message);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> updateLocationUser(
      String id, double lat, double long, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/update";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({"id": id, "lat": lat, "long": long}));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<String> sendPasswordResetLink(String email) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    String baseURL = apiUrl + "auth/send-password-reset-link";
    try {
      dynamic response =
          await dio.post(baseURL, data: jsonEncode({"email": email}));
      if (response.statusCode == 200) {
        return response.data["message"];
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> getUser(String idUser, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/by_id";
    try {
      dynamic response =
          await dio.get(baseURL, queryParameters: {"id_user": idUser});
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        return UserModel.fromJson(userJson);
      } else {
        print("error1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error2 get user");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> updateUser(
    String id,
    String email,
    String name,
    String picture,
    String birthdate,
    String gender,
    String phone,
    String dial_code,
    String role,
    String professional_license,
    String doc_id_front,
    String doc_id_back,
    String years,
    String blood_type,
    String allergies,
    String diseases,
    String organ_donor,
    String has_covid,
    String count_vaccines,
    String height,
    String weight,
    String imc,
    String token, {
    String rfc = "",
    String fiscal_address = "",
    String request_invoice = "no",
  }) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/update";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "id": id,
            "email": email,
            "name": name,
            "picture": picture,
            "birthdate": birthdate,
            "gender": gender,
            "phone": phone,
            "dial_code": dial_code,
            "professional_license": professional_license,
            "doc_id_front": doc_id_front,
            "doc_id_back": doc_id_back,
            "years": years,
            "blood_type": blood_type,
            "allergies": allergies,
            "diseases": diseases,
            "organ_donor": organ_donor,
            "rol": role,
            "has_covid": has_covid,
            "count_vaccines": count_vaccines,
            "height": height,
            "weight": weight,
            "imc": imc,
            "rfc": rfc,
            "fiscal_address": fiscal_address,
            "request_invoice": request_invoice,
          }));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        print("error en updateUser1");

        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en updateUser2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> createAdvert(
      String category,
      List<String> assetsIds,
      Map<String, dynamic> generic_questionnaire,
      Map<String, dynamic> category_questionnaire,
      num minutes_to_end,
      DateTime start,
      DateTime end,
      Place location,
      String confirm_number,
      String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/";

    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "category": category,
            "pictures": assetsIds,
            "generic_questionnaire": jsonEncode(generic_questionnaire),
            "category_questionnaire": jsonEncode(category_questionnaire),
            "minutes_to_end": minutes_to_end.toString(),
            "start": start.toUtc().millisecondsSinceEpoch.toString(),
            "end": end.toUtc().millisecondsSinceEpoch.toString(),
            "location": jsonEncode(Place().toJson(location)),
            "confirm_number": confirm_number
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> setPublicAssets(
      List<String> assetsIds, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/set-public-assets";

    try {
      dynamic response =
          await dio.put(baseURL, data: jsonEncode({"pictures": assetsIds}));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> createHire(
      String category,
      List<String> assetsIds,
      Map<String, dynamic> generic_questionnaire,
      Map<String, dynamic> category_questionnaire,
      num budget,
      DateTime start,
      DateTime end,
      Place location,
      String confirm_number,
      String professionalInWork,
      String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/hire";

    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "category": category,
            "budget": budget.toString(),
            "pictures": assetsIds,
            "professional_in_work": professionalInWork,
            "generic_questionnaire": jsonEncode(generic_questionnaire),
            "category_questionnaire": jsonEncode(category_questionnaire),
            "start": start.toUtc().millisecondsSinceEpoch.toString(),
            "end": end.toUtc().millisecondsSinceEpoch.toString(),
            "location": jsonEncode(Place().toJson(location)),
            "confirm_number": confirm_number
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];

        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> updateAdvert(
      String idAdvert,
      String category,
      List<String> assetsIds,
      Map<String, dynamic> generic_questionnaire,
      Map<String, dynamic> category_questionnaire,
      num minutes_to_end,
      DateTime start,
      DateTime end,
      Place location,
      String confirm_number,
      List<String> removePictures,
      String token,
      {bool isNew = false}) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
            "category": category,
            "pictures": assetsIds,
            "remove_pictures": removePictures,
            "generic_questionnaire": jsonEncode(generic_questionnaire),
            "category_questionnaire": jsonEncode(category_questionnaire),
            "minutes_to_end": minutes_to_end.toString(),
            "start": start.toUtc().millisecondsSinceEpoch.toString(),
            "end": end.toUtc().millisecondsSinceEpoch.toString(),
            "location": jsonEncode(Place().toJson(location)),
            "confirm_number": confirm_number,
            "is_new": (isNew) ? "true" : ""
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];

        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> professionalFinishWork(
      String idAdvert, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/professional-finish-work";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> notifyProfessionalCategoryNecessary(
      String category, String idProfessonal, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/notify-professional-category-necessary";

    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode(
              {"category": category, "id_professonal": idProfessonal}));
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> clientFinishWork(String idAdvert, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/client-finish-work";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> acceptHiring(String idAdvert, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/professional-accept-hiring";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<bool> rejectHiring(String idAdvert, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/professional-reject-hiring";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
          }));
      if (response.statusCode == 200) {
        return true;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> professionalCancelAdvert(
      String idAdvert, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/professional-cancel-advert";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> professionalPaymentComission(
      String idAdvert, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/professional-payment-comission";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> setShowAllBids(
      String idAdvert, String amount, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/set-showallbids";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
            "amount": amount,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> clientCancelAdvert(String idAdvert, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/client-cancel-advert";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> updateMessagesToRead(
      String idUser, String idAdvert, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "message/messages_to_read";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({"id_user": idUser, "id_advert": idAdvert}));
      if (response.statusCode == 200) {
        return response.data["status"];
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<MessageModel>> getMessages(
      num limit, num skip, String idUser, String idAdvert, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "message";

    try {
      final response = await dio.get(baseURL, queryParameters: {
        "limit": limit,
        "skip": skip,
        "id_user": idUser,
        "id_advert": idAdvert
      });

      if (response.statusCode == 200) {
        return response.data["messages"].map<MessageModel>((message) {
          return MessageModel.fromJson(message);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> getConfig() async {
    dio.options.headers["Accept"] = "application/json";
    String baseURL = apiUrl + "config";

    try {
      final response = await dio.get(baseURL, queryParameters: {});

      if (response.statusCode == 200) {
        return response.data["config"];
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getConfig");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> getStaticsOrder(String min, String max,
      {String id_pharmacy = ""}) async {
    dio.options.headers["Accept"] = "application/json";
    String baseURL = apiUrl + "order/statics";

    try {
      final response = await dio.get(baseURL, queryParameters: {
        "min": min,
        "max": max,
        "id_pharmacy": id_pharmacy
      });

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<OrderModel>> getEarnings(String min, String max,
      {String id_pharmacy = "", String id_lab = ""}) async {
    dio.options.headers["Accept"] = "application/json";
    String baseURL = apiUrl + "order/earnings";

    try {
      final response = await dio.get(baseURL, queryParameters: {
        "min": min,
        "max": max,
        "id_pharmacy": id_pharmacy,
        "id_lab": id_lab
      });

      if (response.statusCode == 200) {
        return response.data["orders"].map<OrderModel>((item) {
          return OrderModel.fromJson(item);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> updateConfig(
      String email_support,
      String phone,
      String dial_code,
      bool enable_register_pharmacy,
      bool enable_mandatory_identification,
      String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "config";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "email_support": email_support,
            "phone": phone,
            "dial_code": dial_code,
            "enable_register_pharmacy": enable_register_pharmacy,
            "enable_mandatory_identification": enable_mandatory_identification,
          }));
      if (response.statusCode == 200) {
        return response.data["config"];
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<MessageModel> sendMessage(
    String message,
    String idUser,
    List<String> assets,
    String idAdvert,
    String token,
  ) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "message";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "message": message,
            "id_user": idUser,
            "id_advert": idAdvert,
            "assets": assets
          }));
      if (response.statusCode == 200) {
        dynamic postJson = response.data["message"];
        return MessageModel.fromJson(postJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> updateMessagesToReceived(String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "message/messages_to_received";
    try {
      dynamic response = await dio.put(baseURL, data: jsonEncode({}));
      if (response.statusCode == 200) {
        return response.data["status"];
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> updatePicturesFinishWork(String idAdvert,
      List<String> assetsIds, List<String> removePictures, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/update-pictures-finish-work";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
            "pictures": assetsIds,
            "remove_pictures": removePictures,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];

        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<bool> deleteAdvert(String idAdvert, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/";

    try {
      dynamic response =
          await dio.delete(baseURL, data: jsonEncode({"id": idAdvert}));
      if (response.statusCode == 200) {
        return true;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<bool> deleteNotification(String id, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "notification/";
    try {
      dynamic response =
          await dio.delete(baseURL, data: jsonEncode({"id": id}));
      if (response.statusCode == 200) {
        return true;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AssetModel> uploadAsset(
      String type, dynamic asset, String token) async {
    if (kIsWeb) {
      String baseURL = apiUrl + "asset/upload-image";
      if (type == "image") baseURL = apiUrl + "asset/upload-image";
      if (type == "pdf") baseURL = apiUrl + "asset/upload-pdf";
      try {
        var request = http.MultipartRequest("POST", Uri.parse(baseURL));
        if (asset is Uint8List?) {
          request.files.add(await http.MultipartFile.fromBytes(
              "asset", asset ?? [],
              filename: "file_up"));
        } else {
          request.files.add(await http.MultipartFile.fromBytes("asset", asset,
              filename: "file_up"));
        }

        request.headers.addAll(
          {
            r'Accept': 'application/json',
            r'x-access-token': token,
          },
        );

        var streamedResponse = await request.send();
        http.Response _result =
            await http.Response.fromStream(streamedResponse);

        if (_result.statusCode == 200) {
          return AssetModel.fromJson(jsonDecode(_result.body));
        } else {
          return Future.error(checkErrors(_result.body));
        }
      } catch (e) {
        print(e);
        if (e is DioError)
          return Future.error(checkErrors((e as DioError).response));
        return Future.error(
            ['Ocurrió un error desconocido, intenté de nuevo.']);
      }
    } else {
      dio.options.headers["Accept"] = "application/json";
      dio.options.headers["x-access-token"] = token;
      String baseURL = apiUrl + "asset/upload-image";
      if (type == "image") baseURL = apiUrl + "asset/upload-image";
      if (type == "pdf") baseURL = apiUrl + "asset/upload-pdf";
      try {
        FormData formData = new FormData.fromMap({});
        formData.files.add(MapEntry(
            "asset",
            await MultipartFile.fromFile(asset.path,
                filename: asset.path.split('/').last)));
        dio.options.extra = {"path_file": asset.path};
        final response = await dio.post(baseURL, data: formData);

        if (response.statusCode == 200) {
          return AssetModel.fromJson(response.data);
        } else {
          return Future.error(checkErrors(response.data));
        }
      } catch (e) {
        print(e);
        if (e is DioError)
          return Future.error(checkErrors((e as DioError).response));
        return Future.error(
            ['Ocurrió un error desconocido, intenté de nuevo.']);
      }
    }
  }

  Future<List<AdvertModel>> getAdverts(num limit, num skip, String token,
      {filter_type = "",
      filter_color = "",
      filter_category = "",
      filter_city = "",
      filter_color_work_in_progress = ""}) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost";

    try {
      final response = await dio.get(baseURL, queryParameters: {
        "limit": limit,
        "skip": skip,
        "filter_type": filter_type,
        "filter_color": filter_color,
        "filter_category": filter_category,
        "filter_city": filter_city,
        "filter_color_work_in_progress": filter_color_work_in_progress
      });

      if (response.statusCode == 200) {
        return response.data["adverts"].map<AdvertModel>((advert) {
          return AdvertModel.fromJson(advert);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getAdverts ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<NotificationModel>> getNotifications(
      num limit, num skip, BuildContext context, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "notification";

    try {
      final response = await dio
          .get(baseURL, queryParameters: {"limit": limit, "skip": skip});

      if (response.statusCode == 200) {
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.setNotificationsUnread(response.data["notifications_unread"]);
        return response.data["notifications"]
            .map<NotificationModel>((notification) {
          return NotificationModel.fromJson(notification);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getNotifications ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<NotificationModel> getNotificationsById(
      String id, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "notification/by_id";

    try {
      final response = await dio.get(baseURL, queryParameters: {"id": id});

      if (response.statusCode == 200) {
        dynamic json = response.data["notification"];
        return NotificationModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getNotificationsById ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<NotificationModel> readNotification(
      String id, BuildContext context, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "notification/read";

    try {
      dynamic response = await dio.put(baseURL, data: jsonEncode({"id": id}));

      if (response.statusCode == 200) {
        dynamic json = response.data["notification"];
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.setNotificationsUnread(response.data["notifications_unread"]);

        return NotificationModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en readNotification ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<bool> getHasPassword(String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/check-has-password";

    try {
      final response = await dio.get(baseURL, queryParameters: {});
      if (response.statusCode == 200) {
        return response.data["hasPassword"];
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> changePassword(
      String newPassword, String currentPassword, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/change-password";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "new_password": newPassword,
            "current_password": currentPassword
          }));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> answerQuestion(String idQuestion, String idAdvert,
      String answer, String picture, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/answer-question";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_question": idQuestion,
            "id_advert": idAdvert,
            "answer": answer,
            "picture": picture,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        print(json);
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> setPassword(String password, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/set-password";
    try {
      dynamic response =
          await dio.put(baseURL, data: jsonEncode({"password": password}));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> getAdvertById(String id, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/${id}";

    try {
      final response = await dio.get(baseURL);
      if (response.statusCode == 200) {
        return AdvertModel.fromJson(response.data["advert"]);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("errir en getAdvertById");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> createQuestion(
      String idAdvert, String question, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/add-question";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id": idAdvert,
            "question": question,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> createBid(String idAdvert, bool weekend_only, num amount,
      String proposed_date, String token, String explanation) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/add-bid";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id": idAdvert,
            "weekend_only": weekend_only,
            "amount": amount,
            "proposed_date": proposed_date,
            "explanation": explanation
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> acceptBid(
      String idAdvert, String idBid, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/accept-bid";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
            "id_bid": idBid,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> rateUser(String idAdvert, String idUser,
      num qualification, String type, String token,
      {String comment = ""}) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/rate";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_advert": idAdvert,
            "id_user": idUser,
            "qualification": qualification.toString(),
            "type": type,
            "comment": comment
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> addRemoveLikeAdvert(String idAdvert, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/add-remove-like";
    try {
      dynamic response =
          await dio.put(baseURL, data: jsonEncode({"id_advert": idAdvert}));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<Place>> searchPlace(String search, String lat, String lng) async {
    print("Entre a api place client");
    final String baseURL =
        'https://maps.googleapis.com/maps/api/place/textsearch/json';
    String type = '(regions)';
    String PLACES_API_KEY = googleApiKey;
    String request = '';
    if (checkEmpty(lat) && checkEmpty(lng)) {
      request =
          '$baseURL?input=$search&language=es&inputtype=textquery&fields=formatted_address,name,geometry,place_id&location=$lat, $lng&key=$PLACES_API_KEY';
    } else {
      request =
          '$baseURL?input=$search&language=es&inputtype=textquery&fields=formatted_address,name,geometry,place_id&key=$PLACES_API_KEY';
    }

    try {
      final response = await dio.get(request);

      List<Place> list = [];
      if (response.data["status"] == "OK") {
        list = response.data["results"]
            .map<Place>((json) => Place.fromJson(json))
            .toList();
      }

      return list;
    } catch (e) {
      print(e);
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<Place>> searchPlaceWeb(
      String search, String lat, String lng, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/search-place";

    try {
      dynamic response = await dio.get(baseURL,
          queryParameters: {"search": search, "lat": lat, "lng": lng});

      if (response.statusCode == 200) {
        List<Place> list = [];
        if (response.data["status"] == "OK") {
          list = response.data["results"]
              .map<Place>((json) => Place.fromJson(json))
              .toList();
        }
        return list;
      } else {
        print("error1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error2 get user");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<Place>> reverseGeocode(String lat, String lng) async {
    final String baseURL = 'https://maps.googleapis.com/maps/api/geocode/json';
    String PLACES_API_KEY = googleApiKey;
    String request = '';

    request = '$baseURL?latlng=$lat, $lng&language=es&key=$PLACES_API_KEY';

    try {
      final response = await dio.get(request);

      List<Place> list = [];
      if (response.data["status"] == "OK") {
        list = response.data["results"]
            .map<Place>((json) => Place.fromJson(json))
            .toList();
      }

      return list;
    } catch (e) {
      print(e);
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<String>> getMedals(String userId, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/medals";

    try {
      final response =
          await dio.get(baseURL, queryParameters: {"id_user": userId});
      if (response.statusCode == 200) {
        return response.data["medals"].map<String>((medal) {
          return medal.toString();
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> generateContract(
      String idAdvert, String date, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/generate-contract";

    try {
      final response = await dio.post(baseURL,
          data:
              jsonEncode({"id_advert": idAdvert.trim(), "date_create": date}));
      if (response.statusCode == 200) {
        return response.data["message"];
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getAdverts ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<AdvertModel> editQuestion(
      String idQuestion, String idAdvert, String question, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "elementpost/edit-question";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode(
              {"id": idQuestion, "question": question, "advert": idAdvert}));
      if (response.statusCode == 200) {
        dynamic json = response.data["advert"];
        return AdvertModel.fromJson(json);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> denounce(String type, String id, String comment, String token,
      String id_advert) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "complaint";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "type": type,
            "id": id,
            "comment": comment,
            "id_advert": id_advert
          }));
      if (response.statusCode == 200) {
        return response.data["complaint"];
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<bool> deleteAccount(String token, String comments) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/delete-account";
    try {
      dynamic response =
          await dio.post(baseURL, data: jsonEncode({"comments": comments}));
      if (response.statusCode == 200) {
        return true;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> acceptLegalDocs(String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/accept-legal-docs";

    try {
      dynamic response = await dio.post(baseURL, data: jsonEncode({}));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        print("error1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error login");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  //categories
  Future<List<CategoryModel>> getCategories(
      num limit, num skip, BuildContext context, String token,
      {String search = ""}) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "category";

    try {
      final response = await dio.get(baseURL,
          queryParameters: {"limit": limit, "skip": skip, "search": search});

      if (response.statusCode == 200) {
        final provider = Provider.of<AppProvider>(context, listen: false);

        return response.data["categories"].map<CategoryModel>((item) {
          return CategoryModel.fromJson(item);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getCategories ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<CategoryModel> createCategory(
      String title, String cover, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "category";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({"title": title, "cover": cover}));
      if (response.statusCode == 200) {
        return CategoryModel.fromJson(response.data["category"]);
      } else {
        print("error createCategory 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error createCategory 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<bool> deleteCategory(String idCategory, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "category/";

    try {
      dynamic response =
          await dio.delete(baseURL, data: jsonEncode({"id": idCategory}));
      if (response.statusCode == 200) {
        return true;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<CategoryModel> editCategory(
      String title, String cover, String id, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "category";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({"id": id, "title": title, "cover": cover}));
      if (response.statusCode == 200) {
        return CategoryModel.fromJson(response.data["category"]);
      } else {
        print("error createCategory 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error createCategory 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  //users
  Future<List<UserModel>> getUsers(
      num limit, num skip, BuildContext context, String token,
      {String search = "", String filter_rol = ""}) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user";

    try {
      final response = await dio.get(baseURL, queryParameters: {
        "limit": limit,
        "skip": skip,
        "search": search,
        "filter_rol": filter_rol
      });

      if (response.statusCode == 200) {
        final provider = Provider.of<AppProvider>(context, listen: false);

        return response.data["users"].map<UserModel>((user) {
          return UserModel.fromJson(user);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getUsers ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<bool> deleteUser(String token, String id) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/by-admin";
    try {
      dynamic response =
          await dio.delete(baseURL, data: jsonEncode({"id": id}));
      if (response.statusCode == 200) {
        return true;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<bool> deleteArchive(String token, String id) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/delete-archive";
    try {
      dynamic response =
          await dio.delete(baseURL, data: jsonEncode({"id": id}));
      if (response.statusCode == 200) {
        return true;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> createUser(
    String email,
    String name,
    String picture,
    String birthdate,
    String phone,
    String dial_code,
    String rol,
    String password,
    String confirm_password,
    String enabled,
    String verified_doctor,
    String delivery_commission,
    String professional_license,
    String years,
    String token,
  ) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "email": email,
            "name": name,
            "picture": picture,
            "birthdate": birthdate,
            "phone": phone,
            "dial_code": dial_code,
            "rol": rol,
            "password": password,
            "confirm_password": confirm_password,
            "enabled": enabled,
            "verified_doctor": verified_doctor,
            "delivery_commission": delivery_commission,
            "professional_license": professional_license,
            "years": years
          }));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        return UserModel.fromJson(userJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> updateUserAdmin(
    String id_user,
    String email,
    String name,
    String picture,
    String birthdate,
    String phone,
    String dial_code,
    String rol,
    String password,
    String confirm_password,
    String enabled,
    String verified_doctor,
    String delivery_commission,
    String professional_license,
    String doc_id_front,
    String doc_id_back,
    String years,
    String token, {
    String rfc = "",
    String fiscal_address = "",
    String request_invoice = "no",
  }) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/update-by-admin";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "id_user": id_user,
            "email": email,
            "name": name,
            "picture": picture,
            "birthdate": birthdate,
            "phone": phone,
            "dial_code": dial_code,
            "rol": rol,
            "password": password,
            "confirm_password": confirm_password,
            "enabled": enabled,
            "verified_doctor": verified_doctor,
            "delivery_commission": delivery_commission,
            "professional_license": professional_license,
            "doc_id_front": doc_id_front,
            "doc_id_back": doc_id_back,
            "years": years,
            "rfc": rfc,
            "fiscal_address": fiscal_address,
            "request_invoice": request_invoice
          }));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        return UserModel.fromJson(userJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  //pharmacy
  Future<PharmacyModel> createPharmacy(String title, String cover,
      String category_id, String type, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "pharmacy";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "title": title,
            "cover": cover,
            "category_id": category_id,
            "type": type
          }));
      if (response.statusCode == 200) {
        return PharmacyModel.fromJson(response.data["pharmacy"]);
      } else {
        print("error createPharmacy 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error createPharmacy 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<PharmacyModel>> getPharmacies(
      num limit, num skip, BuildContext context, String token,
      {String search = "", String type = ""}) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "pharmacy";

    try {
      final response = await dio.get(baseURL, queryParameters: {
        "limit": limit,
        "skip": skip,
        "search": search,
        "type": type
      });

      if (response.statusCode == 200) {
        final provider = Provider.of<AppProvider>(context, listen: false);

        return response.data["pharmacies"].map<PharmacyModel>((item) {
          return PharmacyModel.fromJson(item);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getPharmacies ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<PharmacyModel> updatePharmacy(
    String id,
    String title,
    String category_id,
    String cover,
    String approved,
    String tax_identifier,
    String description,
    String phone,
    String dial_code,
    String admin,
    String type_commission_store,
    String commission_store,
    String type_commission_delivery,
    String commission_delivery,
    String delivery_assignment,
    String km_delivery,
    String cash_payment,
    String tj_payment,
    double lat,
    double long,
    dynamic place,
    String token,
  ) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "pharmacy";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id": id,
            "title": title,
            "category_id": category_id,
            "cover": cover,
            "approved": approved,
            "tax_identifier": tax_identifier,
            "description": description,
            "phone": phone,
            "dial_code": dial_code,
            "admin": admin,
            "type_commission_store": type_commission_store,
            "commission_store": commission_store,
            "type_commission_delivery": type_commission_delivery,
            "commission_delivery": commission_delivery,
            "km_delivery": km_delivery,
            "cash_payment": cash_payment,
            "tj_payment": tj_payment,
            "lat": lat,
            "long": long,
            "place": place,
            "delivery_assignment": delivery_assignment
          }));
      if (response.statusCode == 200) {
        return PharmacyModel.fromJson(response.data["pharmacy"]);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("updatePharmacy");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<PharmacyModel> updateApprovedPharmacy(
    String id,
    String token,
  ) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "pharmacy/approved";
    try {
      dynamic response = await dio.put(baseURL, data: jsonEncode({"id": id}));
      if (response.statusCode == 200) {
        return PharmacyModel.fromJson(response.data["pharmacy"]);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("updatePharmacy");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<bool> deletePharmacy(String token, String id) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "pharmacy";
    try {
      dynamic response =
          await dio.delete(baseURL, data: jsonEncode({"id": id}));
      if (response.statusCode == 200) {
        return true;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  //google maps
  Future<List<Suggestion>> getSuggestions(String input, String lang) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    String sessionToken = Uuid().v4();
    String baseURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&key=$googleApiKey&sessiontoken=$sessionToken';
    try {
      dynamic response = await dio.get(baseURL, queryParameters: {});
      if (response.statusCode == 200) {
        print(response.data);
        dynamic json = response.data["predictions"];
        return json.map<Suggestion>((p) {
          print(p);
          return Suggestion(p['place_id'], p['description']);
        }).toList();
      } else {
        print("error1 getSuggestions");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error2 getSuggestions");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<Suggestion>> getSuggestionsWeb(
      String input, String lang, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;

    String sessionToken = Uuid().v4();
    String baseURL = apiUrl + "user/search-place";

    try {
      dynamic response = await dio.get(baseURL, queryParameters: {
        "input": input,
        "lang": lang,
        "sessionToken": sessionToken
      });

      if (response.statusCode == 200) {
        dynamic json = response.data["predictions"];

        return json.map<Suggestion>((p) {
          return Suggestion(p['place_id'], p['description']);
        }).toList();
      } else {
        print("error1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error2 get user");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<Place> reverseGeocodeFromPlace(String placeId) async {
    final String baseURL =
        'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=$googleApiKey';
    try {
      final response = await dio.get(baseURL);

      if (response.data["status"] == "OK") {
        print(response.data["result"]);
        return Place.fromJson(response.data["result"]);
      } else {
        return Future.error(
            ['Ocurrió un error desconocido, intenté de nuevo.']);
      }
    } catch (e) {
      print(e);
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<Place> reverseGeocodeFromPlaceWeb(String placeId, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;

    String baseURL = apiUrl + "user/reverse-geocode-from-place";

    try {
      dynamic response =
          await dio.get(baseURL, queryParameters: {"placeId": placeId});

      if (response.statusCode == 200) {
     
        print(response.data);
        return Place.fromJson(response.data["result"]);
      } else {
        print("error1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error2 get user");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

//promotions
  Future<PromotionModel> createPromotion(
      String title,
      String code,
      String type,
      double amount,
      String apply_to,
      int limit_use,
      String start,
      String end,
      String business,
      bool monday,
      bool tuesday,
      bool wednesday,
      bool thursday,
      bool friday,
      bool saturday,
      bool sunday,
      String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "promotion";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "title": title,
            "code": code,
            "type": type,
            "amount": amount,
            "apply_to": apply_to,
            "limit_use": limit_use,
            "start": start,
            "end": end,
            "business": business,
            "monday": monday,
            "tuesday": tuesday,
            "wednesday": wednesday,
            "thursday": thursday,
            "friday": friday,
            "saturday": saturday,
            "sunday": sunday,
          }));
      if (response.statusCode == 200) {
        return PromotionModel.fromJson(response.data["promotion"]);
      } else {
        print("error createPromotion 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error createPromotion 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<PromotionModel>> getPromotions(
      num limit, num skip, BuildContext context, String token,
      {String search = ""}) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "promotion";

    try {
      final response = await dio.get(baseURL,
          queryParameters: {"limit": limit, "skip": skip, "search": search});

      if (response.statusCode == 200) {
        final provider = Provider.of<AppProvider>(context, listen: false);

        return response.data["promotions"].map<PromotionModel>((item) {
          return PromotionModel.fromJson(item);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getPromotions ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<PromotionModel> updatePromotion(
      String id,
      String title,
      String code,
      String type,
      double amount,
      String apply_to,
      int limit_use,
      String start,
      String end,
      String business,
      bool monday,
      bool tuesday,
      bool wednesday,
      bool thursday,
      bool friday,
      bool saturday,
      bool sunday,
      String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "promotion";
    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id": id,
            "title": title,
            "code": code,
            "type": type,
            "amount": amount,
            "apply_to": apply_to,
            "limit_use": limit_use,
            "start": start,
            "end": end,
            "business": business,
            "monday": monday,
            "tuesday": tuesday,
            "wednesday": wednesday,
            "thursday": thursday,
            "friday": friday,
            "saturday": saturday,
            "sunday": sunday,
          }));
      if (response.statusCode == 200) {
        return PromotionModel.fromJson(response.data["promotion"]);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("updatePromotion");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<bool> deletePromotion(String token, String id) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "promotion";
    try {
      dynamic response =
          await dio.delete(baseURL, data: jsonEncode({"id": id}));
      if (response.statusCode == 200) {
        return true;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

//promotions
  Future<PrescriptionModel> createPrescription(
      String patient,
      String doctor,
      String diagnosis,
      String evolution,
      String prescription_text,
      String prescription_picture,
      List<String> medical_studies,
      String other_studies,
      String picture_studies,
      String token,
      List<dynamic> medicines,
      {String email_doctor_guest = "",
      String name_doctor_guest = ""}) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "prescription";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "patient": patient,
            "doctor": doctor,
            "diagnosis": diagnosis,
            "evolution": evolution,
            "prescription_text": prescription_text,
            "prescription_picture": prescription_picture,
            "medical_studies": medical_studies,
            "other_studies": other_studies,
            "picture_studies": picture_studies,
            "email_doctor_guest": email_doctor_guest,
            "name_doctor_guest": name_doctor_guest,
            "medicines": medicines
          }));
          print("status code: ");
          print(response.statusCode);
      if (response.statusCode == 200) {
      
        return PrescriptionModel.fromJson(response.data["prescription"]);
     
      } else {
        print("error createPromotion 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error createPromotion 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<PrescriptionModel> createWithoutPrescription(
      String patient,
      String prescription_text,
      String prescription_picture,
      List<dynamic> medicines,
      String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "prescription/medicines";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "patient": patient,
            "prescription_text": prescription_text,
            "prescription_picture": prescription_picture,
            "medicines": medicines
          }));

      if (response.statusCode == 200) {
        return PrescriptionModel.fromJson(response.data["prescription"]);
      } else {
        print("error createPromotion 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error createPromotion 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<PrescriptionModel> createWithoutPrescriptionStudies(
      String patient,
      List<String> medical_studies,
      String other_studies,
      String picture_studies,
      String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "prescription/studies";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "patient": patient,
            "medical_studies": medical_studies,
            "other_studies": other_studies,
            "picture_studies": picture_studies
          }));
      if (response.statusCode == 200) {
        return PrescriptionModel.fromJson(response.data["prescription"]);
      } else {
        print("error createPromotion 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error createPromotion 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<PrescriptionModel>> getPrescription(
      num limit, num skip, BuildContext context, String token,
      {String search = "", String id_user = ""}) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "prescription";

    try {
      final response = await dio.get(baseURL, queryParameters: {
        "limit": limit,
        "skip": skip,
        "search": search,
        "id_user": id_user
      });

      if (response.statusCode == 200) {
        final provider = Provider.of<AppProvider>(context, listen: false);

        return response.data["prescriptions"].map<PrescriptionModel>((item) {
          return PrescriptionModel.fromJson(item);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getPrescription ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  //order

  Future<dynamic> createOrder(
      String type_delivery,
      String type_payment,
      String date_send,
      String patient,
      String prescription,
      dynamic place,
      String token,
      {String type = "normal",
      String approval = ""}) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/";

    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "type_delivery": type_delivery,
            "type_payment": type_payment,
            "date_send": date_send,
            "patient": patient,
            "prescription": prescription,
            "lat": (place != null && place is Place) ? place.lat : "",
            "long": (place != null && place is Place) ? place.lng : "",
            "place": place,
            "type": type,
            "approval": approval
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["order"];
        return json;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> editOrder(
      String type_delivery,
      String type_payment,
      String date_send,
      dynamic place,
      String id_order,
      dynamic address,
      String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/edit";

    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "id_order": id_order,
            "type_delivery": type_delivery,
            "type_payment": type_payment,
            "date_send": date_send,
            "lat": (place != null && place is Place) ? place.lat : "",
            "long": (place != null && place is Place) ? place.lng : "",
            "place": place,
            "address":
                (address != null && address is AddressModel) ? address.id : ""
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["order"];
        return json;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<OrderModel>> getOrders(
      num limit, num skip, BuildContext context, String token,
      {String search = "",
      String id_delivery = "",
      String id_user = "",
      String id_pharmacy = "",
      List<String> statuses = const [],
      String need_approval = "false",
      List<String> type_business = const []}) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order";

    try {
      final response = await dio.get(baseURL, queryParameters: {
        "limit": limit,
        "skip": skip,
        "search": search,
        "id_user": id_user,
        "statuses": statuses,
        "id_pharmacy": id_pharmacy,
        "id_delivery": id_delivery,
        "need_approval": need_approval,
        "type_business": type_business
      });

      if (response.statusCode == 200) {
        final provider = Provider.of<AppProvider>(context, listen: false);

        return response.data["orders"].map<OrderModel>((item) {
          return OrderModel.fromJson(item);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getOrders ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<OrderModel>> getOrdersToApprove(
    num limit,
    num skip,
    BuildContext context,
    String token, {
    String search = "",
  }) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/to_approve";

    try {
      final response = await dio.get(baseURL, queryParameters: {
        "limit": limit,
        "skip": skip,
        "search": search,
      });

      if (response.statusCode == 200) {
        final provider = Provider.of<AppProvider>(context, listen: false);

        return response.data["orders"].map<OrderModel>((item) {
          return OrderModel.fromJson(item);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getOrdersToApprove ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> sendCostsOrder(
    String id_order,
    String cost_delivery,
    String cost_products,
    String id_pharmacy,
    List<Map<String, dynamic>> medicines,
    String token,
  ) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/add_costs";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_order": id_order,
            "cost_delivery": cost_delivery,
            "cost_products": cost_products,
            "medicines": medicines,
            "id_pharmacy": id_pharmacy
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["order"];
        return json;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> approveOrder(
    String id_order,
    String status,
    String token,
  ) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/approve";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({"id_order": id_order, "status": status}));
      if (response.statusCode == 200) {
        dynamic json = response.data["order"];
        return json;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<OrderModel> acceptBudget(
      String id_order, String id_budget, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/accept_budget";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({"id_order": id_order, "id_budget": id_budget}));
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data["order"]);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<OrderModel> cancelOrder(String id_order, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/cancel";

    try {
      dynamic response =
          await dio.put(baseURL, data: jsonEncode({"id_order": id_order}));
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data["order"]);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<OrderModel> assignDelivery(
      String id_order, String id_delivery, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/assign-delivery";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({"id_order": id_order, "id_delivery": id_delivery}));
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data["order"]);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<OrderModel> orderReady(String id_order, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/set-ready";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_order": id_order,
          }));
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data["order"]);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<OrderModel> completeOrder(String id_order, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/complete";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_order": id_order,
          }));
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data["order"]);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<OrderModel> goDeliver(String id_order, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/go-deliver";

    try {
      dynamic response = await dio.put(baseURL,
          data: jsonEncode({
            "id_order": id_order,
          }));
      if (response.statusCode == 200) {
        return OrderModel.fromJson(response.data["order"]);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<bool> notify(
      String title,
      String message,
      String rol,
      String notification,
      String email,
      List<String> users,
      String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/notify";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "title": title,
            "message": message,
            "rol": rol,
            "notification": notification,
            "email": email,
            "users": users
          }));
      if (response.statusCode == 200) {
        return true;
      } else {
        print("error createPromotion 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error createPromotion 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<String> getLinkResetPassword(String email, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/generate_link_reset_password";
    try {
      dynamic response =
          await dio.post(baseURL, data: jsonEncode({"email": email}));
      if (response.statusCode == 200) {
        String link = response.data["link"];
        return link;
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error createPromotion 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

//promotions
  Future<UserModel> saveRecords(
      String records_pressure_sugar, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/save_records_pressure_sugar";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({"records_pressure_sugar": records_pressure_sugar}));
      if (response.statusCode == 200) {
        dynamic userJson = response.data["user"];
        userJson["token"] = response.data["token"];
        return UserModel.fromJson(userJson);
      } else {
        print("error createPromotion 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error createPromotion 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<UserModel> getGp(String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/get_gp";

    try {
      final response = await dio.get(baseURL, queryParameters: {});

      if (response.statusCode == 200) {
        print("doctor");
        print(response.data);
        dynamic userJson = response.data["doctor"];
        return UserModel.fromJson(userJson);
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<AddressModel>> addAddressUser(
      String zip_code,
      String street,
      String municipality,
      String state,
      String suburb,
      String is_delivery,
      String num_ext,
      dynamic place,
      String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/add-address-user";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "zip_code": zip_code,
            "street": street,
            "municipality": municipality,
            "state": state,
            "suburb": suburb,
            "is_delivery": is_delivery,
            "lat": (place != null && place is Place) ? place.lat : "",
            "long": (place != null && place is Place) ? place.lng : "",
            "place": place,
            "num_ext": num_ext
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["addresses"];
        print(json);

        return json.map<AddressModel>((item) {
          return AddressModel.fromJson(item);
        }).toList();
      } else {
        print("error addAddressUser 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error addAddressUser 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<AddressModel>> editAddressUser(
      String zip_code,
      String street,
      String municipality,
      String state,
      String suburb,
      String is_delivery,
      String num_ext,
      String id_address,
      dynamic place,
      String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/edit-address-user";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "id_address": id_address,
            "zip_code": zip_code,
            "street": street,
            "municipality": municipality,
            "state": state,
            "suburb": suburb,
            "is_delivery": is_delivery,
            "lat": (place != null && place is Place) ? place.lat : "",
            "long": (place != null && place is Place) ? place.lng : "",
            "place": place,
            "num_ext": num_ext
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["addresses"];

        return json.map<AddressModel>((item) {
          return AddressModel.fromJson(item);
        }).toList();
      } else {
        print("error editAddressUser 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error editAddressUser 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<AddressModel>> deleteAddressUser(
      String id_address, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/delete-address-user";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "id_address": id_address,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["addresses"];

        return json.map<AddressModel>((item) {
          return AddressModel.fromJson(item);
        }).toList();
      } else {
        print("error deleteAddressUser 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error deleteAddressUser 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<ArchiveModel>> addFileUser(
      String asset, String title, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/add-file-user";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({
            "title": title,
            "asset": asset,
          }));
      if (response.statusCode == 200) {
        dynamic json = response.data["archives"];

        return json.map<ArchiveModel>((item) {
          return ArchiveModel.fromJson(item);
        }).toList();
      } else {
        print("error addFileUser 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error addFileUser 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<ArchiveModel>> getArchives(
    num limit,
    num skip,
    BuildContext context,
    String id_user,
    String token, {
    String search = "",
  }) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "user/archives";

    try {
      final response = await dio.get(baseURL, queryParameters: {
        "limit": limit,
        "skip": skip,
        "id_user": id_user,
        "search": search
      });

      if (response.statusCode == 200) {
        final provider = Provider.of<AppProvider>(context, listen: false);

        return response.data["archives"].map<ArchiveModel>((archive) {
          return ArchiveModel.fromJson(archive);
        }).toList();
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getArchives");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<List<dynamic>> getMeidicinesPreload(
      num limit, num skip, BuildContext context, String token,
      {String search = ""}) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "order/medicines";

    try {
      final response = await dio.get(baseURL,
          queryParameters: {"limit": limit, "skip": skip, "search": search});

      if (response.statusCode == 200) {
        final provider = Provider.of<AppProvider>(context, listen: false);

        return response.data["medicines"];
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getMeidicinesPreload ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<String> generatePdfEstudiesLaboratory(
      String id_prescription, String token) async {
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "prescription/print";

    try {
      final response = await dio
          .get(baseURL, queryParameters: {"id_prescription": id_prescription});

      if (response.statusCode == 200) {
        return response.data["data"];
      } else {
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error en getPrescription ");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<String> guestPrescription(
      String email, String hours, String token) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";
    dio.options.headers["x-access-token"] = token;
    String baseURL = apiUrl + "prescription/guest";
    try {
      dynamic response = await dio.post(baseURL,
          data: jsonEncode({"email": email, "hours": hours}));
      if (response.statusCode == 200) {
        return response.data["token"];
      } else {
        print("error guestPrescription 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error guestPrescription 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }

  Future<dynamic> getGuestDoctorData(String token_guest) async {
    dio.options.headers["Content-type"] = "application/json";
    dio.options.headers["Accept"] = "application/json";

    String baseURL = apiUrl + "prescription/guest";
    try {
      dynamic response =
          await dio.get(baseURL, queryParameters: {"token_guest": token_guest});
      if (response.statusCode == 200) {
        dynamic doctorJson = response.data["doctor_guest"];
        doctorJson["token"] = response.data["token_doctor_guest"];

        dynamic patientJson = response.data["patient"];
        patientJson["token"] = "";

        return {
          "doctor_guest": UserModel.fromJson(doctorJson),
          "patient": UserModel.fromJson(patientJson),
          "email_guest": response.data["email_guest"]
        };
      } else {
        print("error getGuestDoctorData 1");
        return Future.error(checkErrors(response.data));
      }
    } catch (e) {
      print("error getGuestDoctorData 2");
      print(e);
      if (e is DioError)
        return Future.error(checkErrors((e as DioError).response));
      return Future.error(['Ocurrió un error desconocido, intenté de nuevo.']);
    }
  }


  //mercado pago

 
 //mercado pago

// Crear suscripción (nuevo: sin cardToken, devuelve init_point para redirigir)
Future<Map<String, dynamic>> createSubscription(
    String userId, String email, String token) async {
  dio.options.headers["x-access-token"] = token;
 try {
  final response = await dio.post(
   apiUrl+ "payment/subscription/create",
    data: jsonEncode({
      "user": {"_id": userId, "email": email},
    }),
  );

  if (response.statusCode == 200) {
    return {
      "success": true,
      "init_point": response.data["init_point"],
      "subscriptionId": response.data["subscriptionId"]
    };
  } else {
    return Future.error("Error del servidor");
  }

  }catch (e) {
    print("error createSubscription");
    print(e);
    if (e is DioError) {
      return Future.error(checkErrors((e as DioError).response));
    }
    return Future.error(["Ocurrió un error desconocido, intenté de nuevo."]);
  }
}

Future<Map<String, dynamic>> createPaypalSubscription(
  String userId,
  String email,
  String token,
) async {
  dio.options.headers["x-access-token"] = token;

  try {
    final response = await dio.post(
      apiUrl + "payment/subscription/paypal/create",
      data: jsonEncode({
        "user": {
          "_id": userId,
          "email": email,
        },
      }),
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
        "init_point": response.data["init_point"], // 👈 approvalUrl
        "subscriptionId": response.data["subscriptionId"],
      };
    } else {
      return Future.error("Error del servidor");
    }
  } catch (e) {
    print("❌ error createPaypalSubscription");
    print(e);

    if (e is DioError) {
      return Future.error(checkErrors(e.response));
    }

    return Future.error(
      ["Ocurrió un error desconocido, inténtalo de nuevo."],
    );
  }
}



// Consultar estado de la suscripción (sin cambios)
Future<Map<String, dynamic>> getUserSubscription(String userId, String token) async {
  dio.options.headers["Accept"] = "application/json";
  dio.options.headers["x-access-token"] = token;

  String baseURL = apiUrl + "payment/subscription/status";

  try {
    final response = await dio.get(baseURL,
        queryParameters: {"userId": userId}); // por si tu backend necesita id

    if (response.statusCode == 200) {
      return {
        "active": response.data["active"],
        "status": response.data["status"],
        "next_payment": response.data["next_payment"],
        "preapproval_id": response.data["preapproval_id"]
      };
    } else {
      return Future.error(checkErrors(response.data));
    }
  } catch (e) {
    print("error getUserSubscription");
    print(e);
    if (e is DioError) {
      return Future.error(checkErrors((e as DioError).response));
    }
    return Future.error(["Ocurrió un error desconocido, intenté de nuevo."]);
  }
}

// Cancelar suscripción (sin cambios)
Future<bool> cancelSubscription(String userId, String token) async {
  dio.options.headers["Content-type"] = "application/json";
  dio.options.headers["Accept"] = "application/json";
  dio.options.headers["x-access-token"] = token;

  String baseURL = apiUrl + "payment/subscription/cancel";

  try {
    final response = await dio.post(baseURL,
        data: jsonEncode({"userId": userId})); // enviar id por seguridad

    if (response.statusCode == 200) {
      return true;
    } else {
      return Future.error(checkErrors(response.data));
    }
  } catch (e) {
    print("error cancelSubscription");
    print(e);
    if (e is DioError) {
      return Future.error(checkErrors((e as DioError).response));
    }
    return Future.error(["Ocurrió un error desconocido, intenté de nuevo."]);
  }
}

}
