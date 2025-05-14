// import 'dart:ui';

import '../core.dart';

class Setting {
  Color? bgColor = Colors.black;
  Color? accentColor = Colors.white;
  Color? textColor = Colors.white;
  Color? buttonColor = Colors.white;
  Color? buttonTextColor = Colors.white;
  Color? inactiveButtonColor = Colors.white;
  Color? inactiveButtonTextColor = Colors.white;
  Color? senderMsgColor = Colors.white;
  Color? senderMsgTextColor = Colors.white;
  Color? myMsgColor = Colors.white;
  Color? myMsgTextColor = Colors.white;
  Color? headingColor = Colors.white;
  Color? subHeadingColor = Colors.white;
  Color? iconColor = Colors.white;
  Color? dashboardIconColor = Colors.white;
  Color? gridItemBorderColor = Colors.white;
  double gridBorderRadius = 10;
  Color? dividerColor = Colors.white;
  Color? dpBorderColor = Colors.white;
  Color? appbarColor = Colors.white;
  Color? navBgColor = Colors.white;
  Color? bgShade = Colors.white;
  String geminiApiKey = "";
  List<String> videoTimeLimits = [];
  bool fetched = false;
  bool live = true;
  String liveType = "A";
  String liveServerRoot = "";
  String agoraAppId = "";
  String agoraAppCertificate = "";
  String agoraToken = "";
  List<AppLanguage> languages = [];
  int minimumWithdrawLimit = 0;
  // List<String> productIds = <String>['coins_100', 'coins_500', 'coins_1000', 'coins_5000', 'coins_10000'];
  List<String> productIds = [];
  Map<String, Map<String, String>> translations = {};

  bool enableGift = false;
  Setting();
  Setting.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      print("jsonMap['translations'] ${jsonMap['translations']}");
      bgColor = CommonHelper.getColor(jsonMap['bgColor'] ?? '#000000');
      accentColor = CommonHelper.getColor(jsonMap['accentColor'] ?? '#cecece');
      textColor = CommonHelper.getColor(jsonMap['textColor'] ?? '#fafafa');
      buttonColor = CommonHelper.getColor(jsonMap['buttonColor'] ?? '#e91e63');
      buttonTextColor = CommonHelper.getColor(jsonMap['buttonTextColor'] ?? '#ffffff');
      inactiveButtonColor = CommonHelper.getColor(jsonMap['buttonColor'] ?? '#e91e63');
      inactiveButtonTextColor = CommonHelper.getColor(jsonMap['buttonTextColor'] ?? '#ffffff');
      senderMsgColor = CommonHelper.getColor(jsonMap['senderMsgColor'] ?? '#9e0202');
      senderMsgTextColor = CommonHelper.getColor(jsonMap['senderMsgTextColor'] ?? '#ffe5e5');
      myMsgColor = CommonHelper.getColor(jsonMap['myMsgColor'] ?? '#a4dded');
      myMsgTextColor = CommonHelper.getColor(jsonMap['myMsgTextColor'] ?? '#ffffff');
      headingColor = CommonHelper.getColor(jsonMap['headingColor'] ?? '#e25822');
      subHeadingColor = CommonHelper.getColor(jsonMap['subHeadingColor'] ?? '#ffffff');
      iconColor = CommonHelper.getColor(jsonMap['iconColor'] ?? '#ffc0cb');
      dashboardIconColor = CommonHelper.getColor(jsonMap['dashboardIconColor'] ?? '#fc9797');
      gridItemBorderColor = CommonHelper.getColor(jsonMap['gridItemBorderColor'] ?? '#6cf58e');
      gridBorderRadius = jsonMap['gridBorderRadius'] == null ? 0 : double.parse(jsonMap['gridBorderRadius']);
      dividerColor = CommonHelper.getColor(jsonMap['dividerColor'] ?? '#70ff94');
      dpBorderColor = CommonHelper.getColor(jsonMap['dpBorderColor'] ?? '#ffffff');
      appbarColor = CommonHelper.getColor(jsonMap['headerBgColor'] ?? '#ffffff');
      navBgColor = CommonHelper.getColor(jsonMap['bottomNav'] ?? '#ffffff');
      bgShade = CommonHelper.getColor(jsonMap['bgShade'] ?? '#ffffff');
      videoTimeLimits = jsonMap['videoTimeLimits'] != null ? jsonMap['videoTimeLimits'].split(',') : ["15", "30", "60"];
      live = jsonMap['live'] != null
          ? jsonMap['live'] == 1
              ? true
              : false
          : true;
      enableGift = jsonMap['enable_gift'] != null
          ? jsonMap['enable_gift'] == 1
              ? true
              : false
          : true;
      liveType = jsonMap['live_type'] ?? "A";
      liveServerRoot = jsonMap['live_server_root'] ?? "";
      minimumWithdrawLimit = jsonMap['minimum_withdraw_coins'] ?? 500;
      agoraAppId = jsonMap['app_id'] ?? "3ee00139b2a34c4a8c63216e464c0b94"; //"7eabe19614c54bf495e97526023c0deb";
      agoraAppCertificate = jsonMap['app_certificate'] ?? "f8f052cde8fb4eb7a4f9b168eb46b790"; //"""a0c4e0cc8b154a57a7143c12229e6821";
      geminiApiKey = jsonMap['gemini_api_key'] ?? "AIzaSyBuzsxC-Lfr4NEWhKSPu8bcma4hkgBBGrM"; //"""a0c4e0cc8b154a57a7143c12229e6821";
      languages = jsonMap['languages'] != null ? AppLanguage.parseLanguages(jsonMap['languages']) : [];
      translations = TranslationsMap.fromJson(jsonMap['translations']).translations;
      productIds = jsonMap['productIds'] != null ? jsonMap['productIds'].split(',') : [];
      fetched = true;
    } catch (e, s) {
      print("error in fetching settings $e $s");
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["bgColor"] = bgColor = Colors.white;
    map["accentColor"] = accentColor = Colors.white;
    map["textColor"] = textColor = Colors.white;
    map["buttonColor"] = buttonColor = Colors.white;
    map["buttonTextColor"] = buttonTextColor = Colors.white;
    map["inactiveButtonColor"] = inactiveButtonColor = Colors.white;
    map["inactiveButtonTextColor"] = inactiveButtonTextColor = Colors.white;
    map["senderMsgColor"] = senderMsgColor = Colors.white;
    map["senderMsgTextColor"] = senderMsgTextColor = Colors.white;
    map["myMsgColor"] = myMsgColor = Colors.white;
    map["myMsgTextColor"] = myMsgTextColor = Colors.white;
    map["headingColor"] = headingColor = Colors.white;
    map["subHeadingColor"] = subHeadingColor = Colors.white;
    map["iconColor"] = iconColor = Colors.white;
    map["dashboardIconColor"] = dashboardIconColor = Colors.white;
    map["gridItemBorderColor"] = gridItemBorderColor = Colors.white;
    map["gridBorderRadiusColor"] = gridBorderRadius;
    map["dividerColor"] = dividerColor = Colors.white;
    map["dpBorderColor"] = dpBorderColor = Colors.white;
    map["videoTimeLimit"] = videoTimeLimits.join(',');
    return map;
  }
}

class TranslationsMap {
  final Map<String, Map<String, String>> translations;

  TranslationsMap({required this.translations});

  factory TranslationsMap.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, String>> translations = {};
    json.forEach((language, value) {
      translations[language] = Map<String, String>.from(value);
    });
    return TranslationsMap(translations: translations);
  }
}
