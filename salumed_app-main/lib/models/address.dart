import 'dart:convert';

import 'package:app/models/asset.dart';
import 'package:app/models/pharmacy.dart';
import 'package:app/models/place.dart';
import 'package:app/models/user.dart';

class AddressModel {
  String? id;
  String? zip_code;
  String? street;
  String? municipality;
  String? state;
  String? suburb;
  String? num_ext;
  String? is_delivery;
  num? lat;
  num? long;
  Place? place;

  AddressModel(
      {this.id,
      this.zip_code,
      this.street,
      this.municipality,
      this.state,
      this.suburb,
      this.num_ext,
      this.is_delivery,
      this.lat,
      this.long,
      this.place});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
  
    
 
    if (json == null) return AddressModel();
    return AddressModel(
      id: (json.containsKey("_id")) ? json["_id"] : json["id"],
      zip_code: (json.containsKey("zip_code")) ? json["zip_code"] : "",
      street: (json.containsKey("street")) ? json["street"] : "",
      municipality:
          (json.containsKey("municipality")) ? json["municipality"] : "",
      state: (json.containsKey("state")) ? json["state"] : "",
      suburb: (json.containsKey("suburb")) ? json["suburb"] : "",
      num_ext: (json.containsKey("num_ext")) ? json["num_ext"] : "",
      is_delivery:
          (json.containsKey("is_delivery")) ? json["is_delivery"] : "false",
      lat: (json.containsKey("location"))
          ? (json["location"]["coordinates"].length >= 2)
              ? json["location"]["coordinates"][1] ?? 0
              : null
          : null,
      long: (json.containsKey("location"))
          ? (json["location"]["coordinates"].length >= 2)
              ? json["location"]["coordinates"][0] ?? 0
              : null
          : null,
      place: (json.containsKey("place") && json["place"] != null)
          ? Place.fromJsonServer(json["place"])
          : null,
    );
  }

  Map<String, dynamic> toJson(AddressModel item) {
    return {
      'id': item.id,
      'zip_code': (item.zip_code != null) ? item.zip_code : "",
      'street': (item.street != null) ? item.street : "",
      'municipality': (item.municipality != null) ? item.municipality : "",
      'state': (item.state != null) ? item.state : "",
      'suburb': (item.suburb != null) ? item.suburb : "",
      'num_ext': (item.num_ext != null) ? item.num_ext : "",
      'is_delivery': (item.is_delivery != null) ? item.is_delivery : "",
      'lat': (item.lat != null) ? item.lat : null,
      'long': (item.long != null) ? item.long : null,
      'place': (item.place != null) ? Place().toJson(item.place!) : null,
    };
  }
}
