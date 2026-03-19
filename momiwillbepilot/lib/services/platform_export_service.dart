import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';
import 'platform_export_stub.dart' if (dart.library.js_interop) 'platform_export_web.dart' as web_helper;

class PlatformExportService {
  static Future<void> exportJson(String jsonString, String fileName) async {
    if (kIsWeb) {
      await web_helper.downloadJsonWeb(jsonString, fileName);
    } else {
      // Mobile/Desktop approach
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);
      
      final XFile xFile = XFile(file.path, mimeType: 'application/json');
      await Share.shareXFiles([xFile], subject: 'Export dat');
    }
  }

  static Future<String?> importJson() async {
    // This could also be abstracted here if needed, 
    // but the issue was specifically the js_interop in screens.
    return null; // For now, we'll keep the FilePicker in screens but fix the imports.
  }
}
