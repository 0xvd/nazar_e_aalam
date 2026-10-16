class PaymentMethodModel {
  bool? result;
  String? message;
  List<PaymentData>? data;

  PaymentMethodModel({this.result, this.message, this.data});

  PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    result = json['result'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PaymentData>[];
      json['data'].forEach((v) {
        data!.add(PaymentData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['result'] = result;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentData {
  int? id;
  String? name;
  String? type;
  String? apiKey;
  String? apiSecret;
  String? paymentMode;

  PaymentData(
      {this.id,
      this.name,
      this.type,
      this.apiKey,
      this.apiSecret,
      this.paymentMode});

  PaymentData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    apiKey = json['api_key'];
    apiSecret = json['api_secret'];
    paymentMode = json['payment_mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['api_key'] = apiKey;
    data['api_secret'] = apiSecret;
    data['payment_mode'] = paymentMode;
    return data;
  }
}
