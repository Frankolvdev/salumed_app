

class SubscriptionModel {
  String? tag;
  String? next_payment;
  String? status;


  SubscriptionModel({
    this.tag,
    this.next_payment,
    this.status,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return SubscriptionModel();
    return SubscriptionModel(
        tag: json["tag"],
        next_payment: json["next_payment"],
        status: json["status"]);
  }

  Map<String, dynamic> toJson(SubscriptionModel item) {
    return {
      'tag': item.tag,
      'next_payment': item.next_payment,
      'status': item.status
    };
  }
}
