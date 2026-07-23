import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/models/pictogram.dart';

/// Renders a pictogram image from the right source: a local file for owned
/// classeur pictograms, the ARASAAC network image otherwise.
class PictogramImage extends StatelessWidget {
  const PictogramImage({
    required this.pictogram,
    this.size = 300,
    this.placeholder,
    this.errorWidget,
    super.key,
  });

  final Pictogram pictogram;
  final int size;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final fallbackError =
        errorWidget ?? const Icon(Icons.image_not_supported_outlined);

    if (pictogram.isLocal) {
      return Image.file(
        File(pictogram.localImagePath!),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => fallbackError,
      );
    }

    return CachedNetworkImage(
      imageUrl: pictogram.imageUrl(size: size),
      fit: BoxFit.contain,
      placeholder: (_, _) => placeholder ?? const SizedBox.shrink(),
      errorWidget: (_, _, _) => fallbackError,
    );
  }
}
