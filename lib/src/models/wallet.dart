class WalletModel {
  List<WalletItem> data = [];
  int totalRecords = 0;
  int totalWalletAmount = 0;
  int newUserCoin = 0;
  WalletModel();

  WalletModel.fromJSON(Map<String, dynamic> json) {
    data = json['data'] != null ? parseData(json['data']) : [];
    totalRecords = json['total'] ?? 0;
    totalWalletAmount = json['wallet_amount'] ?? 0;
    newUserCoin = json['new_user_coin'] ?? 0;
  }

  static List<WalletItem> parseData(attributesJson) {
    List list = attributesJson;
    List<WalletItem> attrList = list.map((data) => WalletItem.fromJSON(data)).toList();
    return attrList;
  }
}

class WalletItem {
  int id = 0;
  String type = '';
  String status = '';
  int coins = 0;
  String createdDate = '';
  String rowAmount = '';
  WalletItem();
  WalletItem.fromJSON(Map<String, dynamic> json) {
    id = json["id"] ?? 0;
    type = json["type"] ?? '';
    status = json["status"] ?? '';
    coins = json["coins"] ?? 0;
    createdDate = json["created_at"] ?? '';
    rowAmount = json["raw_amount"] ?? '';
  }
}
