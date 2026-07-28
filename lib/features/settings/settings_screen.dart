import 'package:flutter/material.dart';

import '../../data/models/app_settings.dart';
import '../../data/services/local_backup_service.dart';
import '../../data/services/pictogram_search_service.dart';
import '../../data/services/search_cache_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../classeur/classeur_management_screen.dart';
import '../classeur/local_classeur_controller.dart';
import '../profiles/profile_controller.dart';
import 'credits_screen.dart';
import 'legal_content.dart';
import 'legal_text_screen.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.settingsController,
    required this.classeurController,
    required this.profileController,
    required this.searchService,
    required this.searchCacheRepository,
    required this.localBackupService,
    required this.onBackupRestored,
    super.key,
  });

  final SettingsController settingsController;
  final LocalClasseurController classeurController;
  final ProfileController profileController;
  final PictogramSearchService searchService;
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
          // Language actually displayed: the manual choice, or the locale
          // Flutter resolved from the system when set to automatic.
          final effectiveLocaleCode = settings.isAutomaticLocale
              ? Localizations.localeOf(context).languageCode
              : settings.localeCode;

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
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder_special_outlined),
                    title: Text(l10n.classeurManageTitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ClasseurManagementScreen(
                            controller: widget.classeurController,
                            searchService: widget.searchService,
                            settingsController: widget.settingsController,
                            languageCode: effectiveLocaleCode,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
                _ProfilesSection(controller: widget.profileController),
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
                Text(
                  l10n.speechRate,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Slider(
                  min: 0.2,
                  max: 0.8,
                  divisions: 12,
                  value: settings.speechRate.clamp(0.2, 0.8),
                  label: settings.speechRate.toStringAsFixed(2),
                  onChanged: (value) =>
                      widget.settingsController.updateSpeechRate(value),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.pictogramsPerScreen,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  initialValue: settings.gridColumns,
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text(l10n.automaticOption),
                    ),
                    for (final count in const [2, 3, 4, 5, 6])
                      DropdownMenuItem(value: count, child: Text('$count')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      widget.settingsController.updateGridColumns(value);
                    }
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.orientationTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                // Locked landscape by default (retour client) : a screen that
                // rotates on its own is disorienting for the end user.
                SegmentedButton<OrientationMode>(
                  segments: [
                    ButtonSegment(
                      value: OrientationMode.landscape,
                      icon: const Icon(Icons.stay_current_landscape_rounded),
                      label: Text(l10n.orientationLandscape),
                    ),
                    ButtonSegment(
                      value: OrientationMode.portrait,
                      icon: const Icon(Icons.stay_current_portrait_rounded),
                      label: Text(l10n.orientationPortrait),
                    ),
                    ButtonSegment(
                      value: OrientationMode.automatic,
                      icon: const Icon(Icons.screen_rotation_rounded),
                      label: Text(l10n.automaticOption),
                    ),
                  ],
                  selected: {settings.orientationMode},
                  onSelectionChanged: (selection) => widget.settingsController
                      .updateOrientationMode(selection.first),
                ),
                const SizedBox(height: 6),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.showPictogramLabel),
                  value: settings.showPictogramLabel,
                  onChanged: widget.settingsController.updateShowPictogramLabel,
                ),
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
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.savedPhrasesToggle),
                  value: settings.savedPhrasesEnabled,
                  onChanged:
                      widget.settingsController.updateSavedPhrasesEnabled,
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
                      value: '',
                      child: Text(l10n.languageAutomatic),
                    ),
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
                // The "minimum downloads" slider used to sit here. It is gone:
                // ARASAAC reports 0 downloads for every pictogram, so any
                // positive value silently emptied the whole communication
                // screen. See AppSettings.minDownloads.
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
                                  effectiveLocaleCode,
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
                                  effectiveLocaleCode,
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

/// Profiles (A-11 / US-3.03): switch, add, rename, delete. Each profile owns
/// its classeur and its settings; only the aidant reaches this screen.
class _ProfilesSection extends StatelessWidget {
  const _ProfilesSection({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    l10n.profilesSection,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                RadioGroup<String>(
                  groupValue: controller.activeId,
                  onChanged: (id) {
                    if (id != null) {
                      controller.switchTo(id);
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final profile in controller.profiles)
                        RadioListTile<String>(
                          value: profile.id,
                          title: Text(profile.name),
                          secondary: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'rename') {
                                _rename(context, profile.id, profile.name);
                              } else if (value == 'delete') {
                                _delete(context, profile.id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text(l10n.renameAction),
                              ),
                              if (controller.profiles.length > 1)
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(l10n.deleteAction),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _add(context),
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      label: Text(l10n.addProfile),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _add(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final name = await _promptProfileName(context, title: l10n.addProfile);
    if (name == null) {
      return;
    }
    final added = await controller.addProfile(name);
    if (context.mounted && !added) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileExists)));
    }
  }

  Future<void> _rename(BuildContext context, String id, String current) async {
    final l10n = AppLocalizations.of(context);
    final name = await _promptProfileName(
      context,
      title: l10n.renameAction,
      initialValue: current,
    );
    if (name == null) {
      return;
    }
    final renamed = await controller.renameProfile(id, name);
    if (context.mounted && !renamed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileExists)));
    }
  }

  Future<void> _delete(BuildContext context, String id) async {
    final l10n = AppLocalizations.of(context);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(l10n.deleteProfileConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.deleteAction),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) {
      await controller.deleteProfile(id);
    }
  }
}

/// Small text dialog owning its controller (disposed with the route).
Future<String?> _promptProfileName(
  BuildContext context, {
  required String title,
  String initialValue = '',
}) async {
  final result = await showDialog<String>(
    context: context,
    builder: (_) =>
        _ProfileNameDialog(title: title, initialValue: initialValue),
  );
  if (result == null || result.isEmpty) {
    return null;
  }
  return result;
}

class _ProfileNameDialog extends StatefulWidget {
  const _ProfileNameDialog({required this.title, required this.initialValue});

  final String title;
  final String initialValue;

  @override
  State<_ProfileNameDialog> createState() => _ProfileNameDialogState();
}

class _ProfileNameDialogState extends State<_ProfileNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      // Scrollable: in landscape the keyboard leaves too little height for
      // the field, which otherwise overflows.
      scrollable: true,
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: l10n.profileNameLabel),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
