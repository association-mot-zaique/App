import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/models/local_category.dart';
import '../../data/models/local_pictogram.dart';
import '../../l10n/generated/app_localizations.dart';
import 'arasaac_import_screen.dart';
import 'local_classeur_controller.dart';

/// Aidant screen to manage the local classeur: create/rename/delete
/// categories (US-1.05) and reach each category's pictograms (US-1.06).
class ClasseurManagementScreen extends StatelessWidget {
  const ClasseurManagementScreen({
    required this.controller,
    required this.languageCode,
    super.key,
  });

  final LocalClasseurController controller;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.classeurManageTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addCategory(context),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: Text(l10n.addCategory),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final categories = controller.classeur.categoriesSorted;
          if (categories.isEmpty) {
            return _EmptyState(message: l10n.classeurEmpty);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final category = categories[index];
              final count =
                  controller.classeur.pictogramsIn(category.id).length;
              return ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(category.name),
                subtitle: Text('$count ${l10n.pictogramsWord}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'rename') {
                      _renameCategory(context, category);
                    } else if (value == 'delete') {
                      _deleteCategory(context, category);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'rename', child: Text(l10n.renameAction)),
                    PopupMenuItem(value: 'delete', child: Text(l10n.deleteAction)),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _CategoryPictogramsScreen(
                        controller: controller,
                        categoryId: category.id,
                        languageCode: languageCode,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addCategory(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final name = await _promptText(
      context,
      title: l10n.addCategory,
      label: l10n.categoryNameLabel,
    );
    if (name != null) {
      await controller.addCategory(name);
    }
  }

  Future<void> _renameCategory(
    BuildContext context,
    LocalCategory category,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = await _promptText(
      context,
      title: l10n.renameAction,
      label: l10n.categoryNameLabel,
      initialValue: category.name,
    );
    if (name != null) {
      await controller.renameCategory(category.id, name);
    }
  }

  Future<void> _deleteCategory(
    BuildContext context,
    LocalCategory category,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirmDelete(context, l10n.deleteCategoryConfirm);
    if (confirmed) {
      await controller.deleteCategory(category.id);
    }
  }
}

class _CategoryPictogramsScreen extends StatelessWidget {
  const _CategoryPictogramsScreen({
    required this.controller,
    required this.categoryId,
    required this.languageCode,
  });

  final LocalClasseurController controller;
  final int categoryId;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ArasaacImportScreen(
                controller: controller,
                categoryId: categoryId,
                languageCode: languageCode,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: Text(l10n.addPictogram),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final category = controller.classeur.categoriesSorted
              .where((c) => c.id == categoryId)
              .toList();
          final title = category.isEmpty ? '' : category.single.name;
          final pictograms = controller.classeur.pictogramsIn(categoryId);

          return CustomScrollView(
            slivers: [
              SliverAppBar(title: Text(title), pinned: true),
              if (pictograms.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(message: l10n.categoryEmptyPictograms),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 160,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _PictogramTile(
                        controller: controller,
                        pictogram: pictograms[index],
                      ),
                      childCount: pictograms.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PictogramTile extends StatelessWidget {
  const _PictogramTile({required this.controller, required this.pictogram});

  final LocalClasseurController controller;
  final LocalPictogram pictogram;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.file(
              File(controller.absoluteImagePath(pictogram.imagePath)),
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.broken_image_outlined),
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pictogram.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'rename') {
                    _rename(context);
                  } else if (value == 'delete') {
                    _delete(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'rename', child: Text(l10n.renameAction)),
                  PopupMenuItem(value: 'delete', child: Text(l10n.deleteAction)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _rename(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final label = await _promptText(
      context,
      title: l10n.renameAction,
      label: l10n.pictogramLabelLabel,
      initialValue: pictogram.label,
    );
    if (label != null) {
      await controller.renamePictogram(pictogram.id, label);
    }
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirmDelete(context, l10n.deletePictogramConfirm);
    if (confirmed) {
      await controller.deletePictogram(pictogram.id);
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

/// Shared dialog returning the trimmed text, or null when cancelled/empty.
Future<String?> _promptText(
  BuildContext context, {
  required String title,
  required String label,
  String initialValue = '',
}) async {
  final controller = TextEditingController(text: initialValue);
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  controller.dispose();
  if (result == null || result.isEmpty) {
    return null;
  }
  return result;
}

Future<bool> _confirmDelete(BuildContext context, String message) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message),
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
  );
  return confirmed ?? false;
}
