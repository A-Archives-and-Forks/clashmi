// ignore_for_file: unused_catch_stack
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:clashmi/app/runtime/return_result.dart';
import 'package:webdav_plus/webdav_plus.dart';
// ignore: implementation_imports
import 'package:webdav_plus/src/impl/http_webdav_client.dart';

class WebdavUtils {
  static const String _prefix = "clashmi/";
  static bool isInnerError(WebDAVException exception) {
    return exception.isHttpError ||
        exception.isClientError ||
        exception.isServerError ||
        exception.isNotFoundError;
  }

  static String convertInnerError(WebDAVException exception) {
    if (exception.statusCode == 401) {
      return "Authentication failed: ${exception.toString()}";
    }
    if (exception.statusCode == 403) {
      return "Access forbidden: ${exception.toString()}";
    }
    if (exception.statusCode == 404) {
      return "Resource not found: ${exception.toString()}";
    }
    if (exception.statusCode == 409) {
      return "Conflict (e.g., locked resource): ${exception.toString()}";
    }
    return exception.toString();
  }

  static String getNotContinue() {
    return "!continue:";
  }

  static Future<ReturnResult<WebdavClient>> connect(
    int? proxyPort,
    String url,
    String username,
    String password,
  ) async {
    HttpClient httpClient = HttpClient();
    if (proxyPort != null && proxyPort != 0) {
      httpClient.findProxy = (uri) {
        return "PROXY 127.0.0.1:$proxyPort";
      };
    }
    httpClient.connectionTimeout = Duration(seconds: 8);
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    final http = IOClient(httpClient);
    var webdavClient = HttpWebdavClient.withClient(http);
    webdavClient.setCredentials(
      username.trim(),
      password.trim(),
      isPreemptive: true,
    );
    webdavClient.setBaseUrl(url.trim());
    try {
      if (!await webdavClient.exists(_prefix)) {
        await webdavClient.createDirectory(_prefix);
      }
    } on WebDAVException catch (err, stacktrace) {
      if (isInnerError(err)) {
        return ReturnResult(
          error: ReturnResultError(getNotContinue() + convertInnerError(err)),
        );
      }
      return ReturnResult(error: ReturnResultError(err.toString()));
    } catch (err, stacktrace) {
      return ReturnResult(error: ReturnResultError(err.toString()));
    }
    return ReturnResult(data: webdavClient);
  }

  static Future<ReturnResult<List<String>>> list(WebdavClient client) async {
    try {
      final list = await client.list(_prefix);
      final names = <String>[];
      for (final item in list) {
        if (item.isDirectory) {
          continue;
        }
        names.add(item.name);
      }
      return ReturnResult(data: names);
    } catch (err, stacktrace) {
      return ReturnResult(error: ReturnResultError(err.toString()));
    }
  }

  static Future<ReturnResultError?> upload(
    WebdavClient client, {
    required String relativePath,
    required String localPath,
  }) async {
    try {
      final file = File(localPath);
      await client.putFileStream(
        _prefix + relativePath,
        file,
        onProgress: (sent, total) {
          // print('Upload progress: ${(sent / total * 100).toStringAsFixed(1)}%');
        },
      );
    } catch (err, stacktrace) {
      return ReturnResultError(err.toString());
    }
    return null;
  }

  static Future<ReturnResultError?> delete(
    WebdavClient client,
    String relativePath,
  ) async {
    try {
      await client.delete(_prefix + relativePath);
    } catch (err, stacktrace) {
      return ReturnResultError(err.toString());
    }
    return null;
  }

  static Future<ReturnResultError?> download(
    WebdavClient client, {
    required String relativePath,
    required String localPath,
  }) async {
    try {
      await client.downloadToFile(_prefix + relativePath, localPath);
    } catch (err, stacktrace) {
      return ReturnResultError(err.toString());
    }
    return null;
  }
}
