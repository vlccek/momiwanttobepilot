import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:momiwillbepilot/services/question_service.dart';
import 'package:momiwillbepilot/services/platform_export_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _exportStatistics(BuildContext context) async {
    try {
      final exportedData = await QuestionService.exportAnsweredQuestionStatistics();
      final jsonString = json.encode(exportedData);
      
      await PlatformExportService.exportJson(jsonString, 'momiwillbepilot_statistics.json');
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statistiky úspěšně exportovány!'), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba při exportu: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _importStatistics(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        String jsonString;
        if (kIsWeb) {
          jsonString = utf8.decode(result.files.single.bytes!);
        } else {
          final file = File(result.files.single.path!);
          jsonString = await file.readAsString();
        }
        await QuestionService.importQuestionStatistics(jsonString);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statistiky úspěšně importovány!'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba při importu: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vymazat statistiky?'),
        content: const Text('Tato akce nenávratně odstraní veškerý váš pokrok v učení. Přejete si pokračovat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zrušit'),
          ),
          TextButton(
            onPressed: () async {
              await QuestionService.clearStatistics();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Statistiky byly vymazány.'), behavior: SnackBarBehavior.floating),
              );
            },
            child: Text('Vymazat', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavení'),
      ),
      body: ListView(
        children: [
          const _SettingsSectionTitle(title: 'Data a synchronizace'),
          _SettingsTile(
            icon: Icons.upload_file_outlined,
            title: 'Exportovat statistiky',
            subtitle: 'Uložte si svůj pokrok do souboru',
            onTap: () => _exportStatistics(context),
          ),
          _SettingsTile(
            icon: Icons.file_download_outlined,
            title: 'Importovat statistiky',
            subtitle: 'Nahrajte pokrok ze záložního souboru',
            onTap: () => _importStatistics(context),
          ),
          const Divider(),
          const _SettingsSectionTitle(title: 'Správa aplikace'),
          _SettingsTile(
            icon: Icons.delete_sweep_outlined,
            title: 'Vymazat statistiky',
            subtitle: 'Smazat veškerá data o učení',
            iconColor: Theme.of(context).colorScheme.error,
            onTap: () => _showClearDialog(context),
          ),
          const Divider(),
          const _SettingsSectionTitle(title: 'O aplikaci'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Momiwillbepilot'),
            subtitle: Text('Verze 1.0.0 (Beta)'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;
  const _SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
