import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/pictogram.dart';
import '../../features/settings/settings_controller.dart';
import '../../l10n/generated/app_localizations.dart';
import 'favorites_controller.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    required this.favoritesController,
    required this.settingsController,
    super.key,
  });

  final FavoritesController favoritesController;
  final SettingsController settingsController;

  int _columnsForWidth(double width) {
    if (width >= 1200) {
      return 6;
    }
    if (width >= 900) {
      return 5;
    }
    if (width >= 700) {
      return 4;
    }
    if (width >= 500) {
      return 3;
    }
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: AnimatedBuilder(
        animation: Listenable.merge([favoritesController, settingsController]),
        builder: (context, _) {
          final favorites = favoritesController.favorites;
          final settings = settingsController.settings;

          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = _columnsForWidth(constraints.maxWidth);

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.favoritesTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.favoritesSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (settings.offlineOnly) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          avatar: const Icon(
                            Icons.wifi_off_rounded,
                            size: 18,
                          ),
                          label: Text(l10n.offlineModeChip),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Expanded(
                      child: favorites.isEmpty
                          ? _EmptyFavoritesView(
                              title: l10n.noFavoritesTitle,
                              subtitle: l10n.noFavoritesSubtitle,
                            )
                          : GridView.builder(
                              itemCount: favorites.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 0.75,
                                  ),
                              itemBuilder: (context, index) {
                                final pictogram = favorites[index];
                                return _FavoriteCard(
                                  pictogram: pictogram,
                                  scale: settings.pictogramScale,
                                  removeLabel: l10n.removeFavorite,
                                  onRemove: () => favoritesController
                                      .removeById(pictogram.id),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.pictogram,
    required this.scale,
    required this.removeLabel,
    required this.onRemove,
  });

  final Pictogram pictogram;
  final double scale;
  final String removeLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.all(8 * scale.clamp(0.9, 1.8)),
                  child: CachedNetworkImage(
                    imageUrl: pictogram.imageUrl(),
                    fit: BoxFit.contain,
                    placeholder: (_, _) => const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, _, _) => Icon(
                      Icons.image_not_supported_outlined,
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pictogram.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 14 * scale.clamp(0.9, 1.4),
              ),
            ),
            const SizedBox(height: 6),
            FilledButton.tonalIcon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(removeLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavoritesView extends StatelessWidget {
  const _EmptyFavoritesView({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 44,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
