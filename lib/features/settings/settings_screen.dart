import 'package:flutter/material.dart';

import '../../data/services/local_backup_service.dart';
import '../../data/services/search_cache_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import 'credits_screen.dart';
import 'legal_content.dart';
import 'legal_text_screen.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.settingsController,
    required this.searchCacheRepository,
    required this.localBackupService,
    required this.onBackupRestored,
    super.key,
  });

  final SettingsController settingsController;
  final SearchCacheRepository searchCacheRepository;
  final LocalBackupService localBackupService;
  final Future<void> Function() onBackupRestored;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _cacheCount;
  String? _backupPath;

  @override
  void initState() {
    super.initState();
    _cacheCount = widget.searchCacheRepository.cachedQueriesCount();
    _loadBackupPath();
  }

  Future<void> _loadBackupPath() async {
    final path = await widget.localBackupService.backupPath();
    if (!mounted) {
      return;
    }
    setState(() {
      _backupPath = path;
    });
  }

  Future<void> _clearCache() async {
    final l10n = AppLocalizations.of(context);
    await widget.searchCacheRepository.clear();
    if (!mounted) {
      return;
    }

    setState(() {
      _cacheCount = 0;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.cacheCleared)));
  }

  Future<void> _exportBackup() async {
    final l10n = AppLocalizations.of(context);
    final path = await widget.localBackupService.exportBackup();
    if (!mounted) {
      return;
    }

    setState(() {
      _backupPath = path;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.backupExported)));
  }

  Future<void> _restoreBackup() async {
    final l10n = AppLocalizations.of(context);
    final restored = await widget.localBackupService.restoreBackup();
    if (!mounted) {
      return;
    }

    if (!restored) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.backupMissing)));
      return;
    }

    await widget.onBackupRestored();
    if (!mounted) {
      return;
    }
    setState(() {
      _cacheCount = widget.searchCacheRepository.cachedQueriesCount();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: AnimatedBuilder(
        animation: widget.settingsController,
        builder: (context, _) {
          final settings = widget.settingsController.settings;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: ListView(
              children: [
                Text(
                  l10n.settingsAction,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.pictogramSize,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Slider(
                  min: 0.9,
                  max: 1.6,
                  divisions: 7,
                  value: settings.pictogramScale,
                  label: settings.pictogramScale.toStringAsFixed(1),
                  onChanged: (value) =>
                      widget.settingsController.updateScale(value),
                ),
                const SizedBox(height: 6),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.highContrast),
                  value: settings.highContrast,
                  onChanged: widget.settingsController.updateHighContrast,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.reducedMotion),
                  value: settings.reducedMotion,
                  onChanged: widget.settingsController.updateReducedMotion,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.offlineOnly),
                  value: settings.offlineOnly,
                  onChanged: widget.settingsController.updateOfflineOnly,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: settings.localeCode,
                  items: [
                    DropdownMenuItem(
                      value: 'es',
                      child: Text(l10n.languageSpanish),
                    ),
                    DropdownMenuItem(
                      value: 'fr',
                      child: Text(l10n.languageFrench),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(l10n.languageEnglish),
                    ),
                    DropdownMenuItem(
                      value: 'de',
                      child: Text(l10n.languageGerman),
                    ),
                    DropdownMenuItem(
                      value: 'it',
                      child: Text(l10n.languageItalian),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      widget.settingsController.updateLocaleCode(value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.qualityFilters,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.onlyAacFilter),
                  value: settings.onlyAacPictograms,
                  onChanged: widget.settingsController.updateOnlyAacPictograms,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.onlySchematicFilter),
                  value: settings.onlySchematicPictograms,
                  onChanged:
                      widget.settingsController.updateOnlySchematicPictograms,
                ),
                Text(
                  '${l10n.minDownloadsFilter}: ${settings.minDownloads}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Slider(
                  min: 0,
                  max: 300,
                  divisions: 12,
                  value: settings.minDownloads.toDouble(),
                  label: settings.minDownloads.toString(),
                  onChanged: (value) => widget.settingsController
                      .updateMinDownloads(value.toInt()),
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.cacheData,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(l10n.cacheCount(_cacheCount)),
                            ],
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: _clearCache,
                          child: Text(l10n.clearCache),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.backupSection,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.backupPathLabel}: ${_backupPath ?? '-'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: _exportBackup,
                              icon: const Icon(Icons.save_outlined),
                              label: Text(l10n.exportBackup),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: _restoreBackup,
                              icon: const Icon(Icons.restore_rounded),
                              label: Text(l10n.restoreBackup),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.legalSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(l10n.termsOfUse),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LegalTextScreen(
                                title: l10n.termsOfUse,
                                content: LegalContent.termsOfUse(
                                  settings.localeCode,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(l10n.privacyPolicy),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LegalTextScreen(
                                title: l10n.privacyPolicy,
                                content: LegalContent.privacyPolicy(
                                  settings.localeCode,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info_outline_rounded),
                        title: Text(l10n.creditsTitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const CreditsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
