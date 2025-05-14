class AppLanguage {
  int id = 0;
  String language = "";
  String languageCode = "";
  bool active = false;

  String flag = "";
  AppLanguage.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'] ?? 0;
      language = jsonMap['name'] ?? "";
      languageCode = jsonMap['code'] ?? "";
      flag = jsonMap['flag'] ?? "";
      active = jsonMap['active'] != null
          ? jsonMap['active'] == 1
              ? true
              : false
          : false;
    } catch (e, s) {
      print("error in Languages $e $s");
    }
  }
  static List<AppLanguage> parseLanguages(attributesJson) {
    List list = attributesJson;
    List<AppLanguage> attrList = list.map((data) => AppLanguage.fromJSON(data)).toList();
    return attrList;
  }
}
