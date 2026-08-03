import 'package:app/helpers/helpers.dart';

class Place {
  String? place_id;
  String? formatted_address;
  String? written_address;
  String? city;
  dynamic num;
  String? name;
  double? lat;
  double? lng;

  Place({
    this.place_id,
    this.formatted_address,
    this.written_address,
    this.city,
    this.num,
    this.name,
    this.lat,
    this.lng,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      place_id: json["place_id"],
      formatted_address: json["formatted_address"],
      written_address:
          (json.containsKey("written_address")) ? json["written_address"] : "",
      city: (json.containsKey("city")) ? json["city"] : "",
      num: (json.containsKey("num")) ? json["num"] : "",
      name: (json.containsKey("name")) ? json["name"] : "",
      lat: json["geometry"]["location"]["lat"],
      lng: json["geometry"]["location"]["lng"],
    );
  }

  factory Place.fromJsonServer(Map<String, dynamic> json) {
    return Place(
      place_id: json["place_id"],
      formatted_address: json["formatted_address"],
      written_address:
          (json.containsKey("written_address")) ? json["written_address"] : "",
      city: (json.containsKey("city")) ? json["city"] : "",
      num: (json.containsKey("num")) ? json["num"] : "",
      name: checkEmpty(json["name"]) ? json["name"] : "",
      lat: json["lat"],
      lng: json["lng"],
    );
  }

  Map<String, dynamic> toJson(Place item) {
    return {
      'place_id': item.place_id,
      'formatted_address': item.formatted_address,
      'written_address': item.written_address,
      'city': item.city,
      'num': item.num,
      'name': item.name,
      'lat': item.lat,
      'lng': item.lng
    };
  }
}
