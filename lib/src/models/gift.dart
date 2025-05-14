class Gift {
  int id = 0;
  String name = "";
  String icon = "";
  int coins = 0;
  Gift();
  Gift.fromJSON(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    icon = json["icon"];
    coins = json["coins"];
  }
  static List<Gift> parseGifts(attributesJson) {
    List list = attributesJson;
    List<Gift> attrList = list.map((data) => Gift.fromJSON(data)).toList();
    return attrList;
  }
}
