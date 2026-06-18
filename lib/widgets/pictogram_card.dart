import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/models/pictogram.dart';

class PictogramCard extends StatelessWidget {
  const PictogramCard({
    required this.pictogram,
    required this.isFavorite,
    required this.onSelect,
    required this.onToggleFavorite,
    required this.scale,
    required this.reducedMotion,
    required this.phraseActionLabel,
    required this.saveFavoriteTooltip,
    required this.removeFavoriteTooltip,
    this.accentColor,
    this.highContrast = false,
    super.key,
  });

  final Pictogram pictogram;
  final bool isFavorite;
  final VoidCallback onSelect;
  final VoidCallback onToggleFavorite;
  final double scale;
  final bool reducedMotion;
  final String phraseActionLabel;
  final String saveFavoriteTooltip;
  final String removeFavoriteTooltip;
  final Color? accentColor;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final tint = highContrast ? null : accentColor;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: tint != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: tint.withValues(alpha: 0.5), width: 2),
            )
          : null,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: reducedMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 220),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
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
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 140;
                  final addButtonStyle =
                      (tint != null
                              ? FilledButton.styleFrom(
                                  backgroundColor: tint.withValues(alpha: 0.2),
                                  foregroundColor: HSLColor.fromColor(tint)
                                      .withLightness(0.25)
                                      .toColor(),
                                )
                              : FilledButton.styleFrom())
                          .copyWith(
                            visualDensity: VisualDensity.compact,
                            padding: WidgetStatePropertyAll(
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                            ),
                          );

                  return SizedBox(
                    height: 38,
                    child: Row(
                      children: [
                        Expanded(
                          child: compact
                              ? FilledButton(
                                  onPressed: onSelect,
                                  style: addButtonStyle,
                                  child: const Icon(
                                    Icons.add_rounded,
                                    size: 20,
                                  ),
                                )
                              : FilledButton.tonalIcon(
                                  onPressed: onSelect,
                                  style: addButtonStyle,
                                  icon: const Icon(
                                    Icons.add_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    phraseActionLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 38,
                          height: 38,
                          child: IconButton.filledTonal(
                            tooltip: isFavorite
                                ? removeFavoriteTooltip
                                : saveFavoriteTooltip,
                            onPressed: onToggleFavorite,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 20,
                              color: isFavorite
                                  ? const Color(0xFFDA6A6A)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
