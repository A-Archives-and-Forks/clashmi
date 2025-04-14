import 'dart:io';

import 'package:clashmi/app/utils/convert_utils.dart';
import 'package:clashmi/app/utils/install_referrer_utils.dart';

class RemoteConfigChannel {
  String platform = "";
  String channel = "";
  String url = "";
  String rateUrl = "";

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'channel': channel,
        "url": url,
        "rate_url": rateUrl,
      };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    platform = map["platform"] ?? "";
    channel = map["channel"] ?? "";
    url = map["url"] ?? "";
    rateUrl = map["rate_url"] ?? "";
  }

  static RemoteConfigChannel fromJsonStatic(Map<String, dynamic>? map) {
    RemoteConfigChannel config = RemoteConfigChannel();
    config.fromJson(map);
    return config;
  }
}

class RemoteConfigGetProfile {
  String platform = "";
  List<String> region = [];
  String url = "";

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'region': region,
        'url': url,
      };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    platform = map["platform"] ?? "";
    region = ConvertUtils.getListStringFromDynamic(map["region"], true, [])!;
    url = map["url"] ?? "";
  }

  static RemoteConfigGetProfile fromJsonStatic(Map<String, dynamic>? map) {
    RemoteConfigGetProfile config = RemoteConfigGetProfile();
    config.fromJson(map);
    return config;
  }
}

class RemoteConfigDonate {
  String name = "";
  String url = "";
  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    name = map["name"] ?? "";
    url = map["url"] ?? "";
  }

  static RemoteConfigDonate fromJsonStatic(Map<String, dynamic>? map) {
    RemoteConfigDonate config = RemoteConfigDonate();
    config.fromJson(map);
    return config;
  }
}

class RemoteConfig {
  static const String kDefaultHost = "clashmi.app";
  static const String kDefaultNotice = "https://dot.$kDefaultHost/notice.json";
  static const String kDefaultConfig = "https://dot.$kDefaultHost/config.json";
  static const String kDefaultAutoUpdate =
      "https://dot.$kDefaultHost/autoupdate.json";
  static const String kDefaultOutpost = "https://outpost.$kDefaultHost/put";

  static const String kDefaultGetTranffic = "https://1.x31415926.top/";

  static const String kDefaultTutorial = "https://$kDefaultHost/quickstart/";
  static const String kDefaultFaq = "https://$kDefaultHost/faq/";

  static const String kDefaultDownload = "https://$kDefaultHost/download/";
  static const String kDefaultTelegram = "https://t.me/ClashMiApp";
  static const String kDefaultFollow = "https://github.com/KaringX/clashmi";

  String latestCheck = "";

  List<RemoteConfigGetProfile> getProfile = [];
  List<RemoteConfigChannel> channels = [];
  String host = kDefaultHost;
  String notice = kDefaultNotice;
  String config = kDefaultConfig;
  String autoUpdate = kDefaultAutoUpdate;
  String outpost = kDefaultOutpost;

  String getTranffic = kDefaultGetTranffic;

  String tutorial = kDefaultTutorial;
  String faq = kDefaultFaq;

  String download = kDefaultDownload;
  String telegram = kDefaultTelegram;
  String follow = kDefaultFollow;

  String donateUrl = "";

  Map<String, dynamic> toJson() {
    Map<String, dynamic> ret = {
      'latest_check': latestCheck,
      "get_profile": getProfile,
      "channel": channels,
    };

    if (getTranffic != kDefaultGetTranffic) {
      ret["get_tranffic"] = getTranffic;
    }

    if (tutorial != kDefaultTutorial) {
      ret["tutorial"] = tutorial;
    }
    if (faq != kDefaultFaq) {
      ret["faq"] = faq;
    }

    if (download != kDefaultDownload) {
      ret["download"] = download;
    }
    if (telegram != kDefaultTelegram) {
      ret["telegram"] = telegram;
    }
    if (follow != kDefaultFollow) {
      ret["follow"] = follow;
    }

    if (donateUrl.isNotEmpty) {
      ret["donate_url"] = donateUrl;
    }

    return ret;
  }

  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    latestCheck = map["latest_check"] ?? "";

    if (map["get_profile"] != null) {
      for (var i in map["get_profile"]) {
        RemoteConfigGetProfile ch = RemoteConfigGetProfile();
        ch.fromJson(i);
        getProfile.add(ch);
      }
    }

    if (map["channel"] != null) {
      for (var i in map["channel"]) {
        RemoteConfigChannel ch = RemoteConfigChannel();
        ch.fromJson(i);
        channels.add(ch);
      }
    }

    getTranffic = map["get_tranffic"] ?? kDefaultGetTranffic;
    tutorial = map["tutorial"] ?? kDefaultTutorial;
    faq = map["faq"] ?? kDefaultFaq;
    download = map["download"] ?? kDefaultDownload;
    telegram = map["telegram"] ?? kDefaultTelegram;
    follow = map["follow"] ?? kDefaultFollow;
    donateUrl = map["donate_url"] ?? "";
    if (!isSelfHost(donateUrl, host)) {
      donateUrl = "";
    }
  }

  static bool isSelfHost(String url, String host) {
    Uri? uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }
    if (uri.host == host || uri.host.contains(".$host")) {
      return true;
    }
    return false;
  }

  static RemoteConfig fromJsonStatic(Map<String, dynamic>? map) {
    RemoteConfig config = RemoteConfig();
    config.fromJson(map);
    return config;
  }

  Future<RemoteConfigChannel?> getCurrentChannel() async {
    if (channels.isNotEmpty) {
      return channels[0];
    }
    String channelName = await InstallReferrerUtils.getString();
    for (var cha in channels) {
      if (cha.platform == Platform.operatingSystem &&
          cha.channel == channelName) {
        return cha;
      }
    }
    return null;
  }

  RemoteConfigGetProfile? getProfileByRegionCode(String regionCode) {
    regionCode = regionCode.toLowerCase();
    for (var item in getProfile) {
      if (item.platform == Platform.operatingSystem) {
        if (item.region.contains("*") || item.region.contains(regionCode)) {
          if (item.url.isNotEmpty) {
            return item;
          }
        }
      }
    }
    return null;
  }
}
