class DonationListModel {
  bool? status;
  String? message;
  List<DonationData>? data;

  DonationListModel({this.status, this.message, this.data});

  DonationListModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <DonationData>[];
      json['data'].forEach((v) {
        data!.add(DonationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DonationData {
  int? id;
  String? category;
  String? paymentMethod;
  String? date;
  dynamic amount;

  DonationData(
      {this.id, this.category, this.date, this.amount, this.paymentMethod});

  DonationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'];
    paymentMethod = json['payment_method'];
    date = json['date'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category'] = category;
    data['payment_method'] = paymentMethod;
    data['date'] = date;
    data['amount'] = amount;
    return data;
  }
}
