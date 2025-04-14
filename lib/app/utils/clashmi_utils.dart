// ignore_for_file: empty_catches, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';

import 'package:clashmi/app/local_services/vpn_service.dart';
import 'package:clashmi/app/modules/remote_config.dart';
import 'package:clashmi/app/modules/remote_config_manager.dart';
import 'package:clashmi/app/runtime/return_result.dart';
import 'package:clashmi/app/utils/http_utils.dart';
import 'package:clashmi/app/utils/log.dart';

class ClashMiAutoupdateItem {
  String platform = "";

  List<String> channels = [];

  List<String> abis = [];
  String version = "";
  String url = "";
  String fileName = "";
  List<String> updateChannel = []; //stable, beta
  bool force = false;
  void fromJson(Map<String, dynamic>? map) {
    if (map == null) {
      return;
    }
    platform = map["platform"] ?? "";

    var _channels = map["channels"] ?? [];
    for (var i in _channels) {
      channels.add(i as String);
    }

    var _abis = map["abis"] ?? [];
    for (var i in _abis) {
      abis.add(i as String);
    }
    version = map["version"] ?? "";
    url = map["url"] ?? "";
    fileName = map["file_name"] ?? "";
    var _versionChannel = map["version_channel"] ?? [];
    for (var i in _versionChannel) {
      updateChannel.add(i as String);
    }
    force = map["force"] ?? false;
  }
}

abstract final class ClashMiUtils {
  static Future<ReturnResult<List<ClashMiAutoupdateItem>>>
      getAutoupdate() async {
    String url = RemoteConfigManager.getConfig().autoUpdate;
    late ReturnResult<String> response;
    List<int?> ports = await VPNService.getPortsByPrefer(false);
    for (var port in ports) {
      response = await HttpUtils.httpGetRequest(
          url, port, null, const Duration(seconds: 10), null, null);
      if (response.error == null) {
        break;
      }
    }
    List<ClashMiAutoupdateItem> items = [];
    if (response.error != null) {
      return ReturnResult(error: response.error);
    }
    try {
      if (response.data!.isNotEmpty) {
        var decodedResponse = jsonDecode(response.data!);
        if (decodedResponse is List) {
          for (var i in decodedResponse) {
            ClashMiAutoupdateItem item = ClashMiAutoupdateItem();
            item.fromJson(i);
            if (item.platform == Platform.operatingSystem) {
              items.add(item);
            }
          }
        }
      }
    } catch (err, _) {
      Log.i('ClashMiUtils getAutoupdate exception ${err.toString()}');
    }
    return ReturnResult(data: items);
  }

  static Future<ReturnResult<RemoteConfig>> getRemoteConfig() async {
    RemoteConfig rc = RemoteConfig();
    String url = RemoteConfigManager.getConfig().config;
    late ReturnResult<String> response;
    List<int?> ports = await VPNService.getPortsByPrefer(false);
    for (var port in ports) {
      response = await HttpUtils.httpGetRequest(
          url, port, null, const Duration(seconds: 10), null, null);
      if (response.error == null) {
        break;
      }
    }

    if (response.error != null) {
      return ReturnResult(error: response.error);
    }
    try {
      if (response.data!.isNotEmpty) {
        var decodedResponse = jsonDecode(response.data!);
        rc.fromJson(decodedResponse);
      }
    } catch (err, _) {
      Log.i('ClashMiUtils getRemoteConfig exception ${err.toString()}');
    }
    return ReturnResult(data: rc);
  }
}
