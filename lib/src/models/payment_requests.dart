class PaymentRequestModel {
  List<PaymentRequest> data = [];
  int totalRecords = 0;
  PaymentRequestModel();

  PaymentRequestModel.fromJSON(Map<String, dynamic> json) {
    data = json['data'] != null ? PaymentRequest.parseData(json['data']) : [];
    totalRecords = json['total'] ?? 0;
  }
}

class PaymentRequest {
  int id = 0;
  int paymentTypeId = 0;
  String paymentId = "";
  int userId = 0;
  int coins = 0;
  double amount = 0.0;
  String currency = "";
  String status = "";
  String createdAt = "";
  String updatedAt = "";

  PaymentRequest();

  PaymentRequest.fromJSON(Map<String, dynamic> json) {
    id = json['id'];
    paymentTypeId = json['payment_type_id'];
    paymentId = json['payment_id'];
    userId = json['user_id'];
    coins = json['coins'];
    amount = double.parse(json['amount']);
    currency = json['currency'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  static List<PaymentRequest> parseData(attributesJson) {
    List list = attributesJson;
    List<PaymentRequest> attrList = list.map((data) => PaymentRequest.fromJSON(data)).toList();
    return attrList;
  }
}
