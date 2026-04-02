import 'dart:io';

class SystemUtils {
  static Future<String> getRouteTable() async {
    try {
      ProcessResult result;
      if (Platform.isWindows) {
        result = await Process.run('route', [
          'print',
        ]).timeout(const Duration(seconds: 10));
      } else if (Platform.isMacOS) {
        result = await Process.run('netstat', [
          '-rn',
        ]).timeout(const Duration(seconds: 10));
      } else if (Platform.isAndroid) {
        // Android sandbox prevents arbitrary process execution.
        // /proc/net/route is a kernel virtual file readable without root.
        // Hex fields: Iface Destination Gateway Flags RefCnt Use Metric Mask ...
        final lines = await File('/proc/net/route').readAsLines();
        if (lines.length <= 1) return '';
        final rows = <String>[];
        rows.add(
          'Iface           Destination     Gateway         Flags   Mask',
        );
        for (final line in lines.skip(1)) {
          final parts = line.trim().split(RegExp(r'\s+'));
          if (parts.length < 8) continue;
          String hexToIp(String hex) {
            final v = int.tryParse(hex, radix: 16) ?? 0;
            return '${v & 0xff}.${(v >> 8) & 0xff}.${(v >> 16) & 0xff}.${(v >> 24) & 0xff}';
          }

          final iface = parts[0].padRight(16);
          final dest = hexToIp(parts[1]).padRight(16);
          final gw = hexToIp(parts[2]).padRight(16);
          final flags = parts[3].padRight(8);
          final mask = hexToIp(parts[7]);
          rows.add('$iface$dest$gw$flags$mask');
        }
        return rows.join('\n');
      } else if (Platform.isLinux) {
        result = await Process.run('ip', [
          'route',
        ]).timeout(const Duration(seconds: 10));
      } else {
        // iOS: process spawning is not supported in the sandbox
        return '';
      }
      final out = result.stdout.toString().trim();
      final err = result.stderr.toString().trim();
      if (out.isNotEmpty) return out;
      if (err.isNotEmpty) return err;
      return '';
    } catch (err) {
      return err.toString();
    }
  }
}
