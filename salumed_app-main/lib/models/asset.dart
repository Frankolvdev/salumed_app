class AssetModel {
  String? id;
  String? name;
  String? type;
  String? created_at;
  String? updated_at;

  AssetModel({
    this.id,
    this.name,
    this.type,
    this.created_at,
    this.updated_at,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    if(json==null)return AssetModel();
    return AssetModel(
        id: ( json.containsKey("_id")) ? json["_id"] : json["id"],
        name: json["name"],
        type: json["type"],
        created_at: json["createdAt"],
        updated_at: json["updatedAt"]);
  }

  Map<String, dynamic> toJson(AssetModel item) {
    return {
      'id': item.id,
      'name': item.name,
      'type': item.type,
      'createdAt': item.created_at,
      'updatedAt': item.updated_at,
    };
  }
}
