


import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:momiwillbepilot/services/question_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<void> exportStatistics() async {
      try {
        final exportedData = await QuestionService.exportAnsweredQuestionStatistics();
        final jsonString = json.encode(exportedData);

        if (kIsWeb) {
          // Web-specific export
          final bytes = utf8.encode(jsonString);
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', 'momiwillbepilot_statistics.json')
            ..click();
          html.Url.revokeObjectUrl(url);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Statistics exported successfully!')),
          );
        } else {
          // Mobile/Desktop export
          String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'Export Statistics',
            fileName: 'momiwillbepilot_statistics.json',
            type: FileType.custom,
            allowedExtensions: ['json'],
          );

          if (outputFile != null) {
            final file = File(outputFile);
            await file.writeAsString(jsonString);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Statistics exported successfully!')),
            );
          }
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export statistics: $e')),
        );
      }
    }

    Future<void> importStatistics() async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );

        if (result != null && result.files.single.path != null) {
          String jsonString;
          if (kIsWeb) {
            // Web-specific import
            jsonString = utf8.decode(result.files.single.bytes!); // Use bytes for web
          } else {
            // Mobile/Desktop import
            final file = File(result.files.single.path!);
            jsonString = await file.readAsString();
          }
          await QuestionService.importQuestionStatistics(jsonString);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Statistics imported successfully!')),
          );
        }
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import statistics: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: exportStatistics,
              child: const Text('Export Statistics'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: importStatistics,
              child: const Text('Import Statistics'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await QuestionService.clearStatistics();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Statistics cleared!')),
                );
              },
              child: const Text('Clear Statistics'),
            ),
          ],
        ),
      ),
    );
  }
}
