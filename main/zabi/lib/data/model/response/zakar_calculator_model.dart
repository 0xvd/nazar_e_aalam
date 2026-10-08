class ZakarCalculatorModel {
  int? id;
  String? amount;
  dynamic mosqueId;
  dynamic desc;
  dynamic userId;
  String? createdAt;
  String? updatedAt;

  ZakarCalculatorModel(
      {this.id,
      this.amount,
      this.mosqueId,
      this.desc,
      this.userId,
      this.createdAt,
      this.updatedAt});

  ZakarCalculatorModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    mosqueId = json['mosque_id'];
    desc = json['desc'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['amount'] = amount;
    data['mosque_id'] = mosqueId;
    data['desc'] = desc;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
