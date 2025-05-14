class MyGiftsModel {
  List<MyGift> data = [];
  int totalRecords = 0;
  int totalWalletAmount = 0;
  int newUserCoin = 0;
  MyGiftsModel();

  MyGiftsModel.fromJSON(Map<String, dynamic> json) {
    data = json['data'] != null ? parseData(json['data']) : [];
    totalRecords = json['total'] ?? 0;
    totalWalletAmount = json['wallet_amount'] ?? 0;
    newUserCoin = json['new_user_coin'] ?? 0;
  }

  static List<MyGift> parseData(attributesJson) {
    List list = attributesJson;
    List<MyGift> attrList = list.map((data) => MyGift.fromJSON(data)).toList();
    return attrList;
  }
}

class MyGift {
  int id = 0;
  int fromId = 0;
  int toId = 0;
  int postId = 0;
  int giftId = 0;
  String createdAt = "";
  String updatedAt = "";
  int coins = 0;
  String file = "";
  String title = "";
  String addedOn = "";
  String type = "";
  String username = "";
  String profilePic = "";
  String giftIcon = "";

  MyGift({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.postId,
    required this.giftId,
    required this.createdAt,
    required this.updatedAt,
    required this.coins,
    required this.file,
    required this.title,
    required this.addedOn,
    required this.type,
    required this.username,
    required this.profilePic,
    required this.giftIcon,
  });

  MyGift.fromJSON(Map<String, dynamic> json) {
    id = json["id"];
    fromId = json["from_id"];
    toId = json["to_id"];
    postId = json["post_id"] ?? 0;
    giftId = json["gift_id"];
    createdAt = json["created_at"] ?? "";
    updatedAt = json["updated_at"] ?? "";
    coins = json["coins"];
    file = json["file"];
    title = json["title"] ?? "";
    addedOn = json["added_on"] ?? "";
    type = json["type"];
    username = json["username"];
    profilePic = json["profile_pic"];
    giftIcon = json["gift_icon"];
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "from_id": fromId,
        "to_id": toId,
        "post_id": postId,
        "gift_id": giftId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "coins": coins,
        "file": file,
        "title": title,
        "added_on": addedOn,
        "type": type,
        "username": username,
        "profile_pic": profilePic,
      };
}
