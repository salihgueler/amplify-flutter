// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:amplify_ai/amplify_ai.dart';
import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// Renders an image content block.
///
/// Decodes base64 image data and displays it with proper aspect ratio,
/// loading states, and error handling.
class ImageContentView extends StatelessWidget {
  /// The image block to render.
  final ImageBlock image;

  /// Maximum width for the image.
  final double maxWidth;

  /// Maximum height for the image.
  final double maxHeight;

  /// Border radius for the image container.
  final BorderRadius? borderRadius;

  const ImageContentView({
    super.key,
    required this.image,
    this.maxWidth = 300,
    this.maxHeight = 400,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);
    final radius = borderRadius ?? theme.cardBorderRadius;

    if (image.source.bytes == null || image.source.bytes!.isEmpty) {
      return _buildPlaceholder(theme, radius);
    }

    try {
      final bytes = base64Decode(image.source.bytes!);
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: ClipRRect(
          borderRadius: radius,
          child: Image.memory(
            bytes,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget(theme, radius);
            },
          ),
        ),
      );
    } catch (_) {
      return _buildErrorWidget(theme, radius);
    }
  }

  Widget _buildPlaceholder(AIThemeData theme, BorderRadius radius) {
    return Container(
      width: 200,
      height: 150,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.assistantBubbleColor,
        borderRadius: radius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 40,
            color: theme.assistantTextColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(image.format.toUpperCase(), style: theme.captionTextStyle),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(AIThemeData theme, BorderRadius radius) {
    return Container(
      width: 200,
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: theme.errorColor.withValues(alpha: 0.1),
        borderRadius: radius,
        border: Border.all(color: theme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 32, color: theme.errorColor),
          const SizedBox(height: 4),
          Text(
            'Failed to load image',
            style: theme.captionTextStyle.copyWith(color: theme.errorColor),
          ),
        ],
      ),
    );
  }
}
