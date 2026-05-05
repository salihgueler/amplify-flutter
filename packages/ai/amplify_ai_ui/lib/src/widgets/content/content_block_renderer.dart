// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../state/content_from_events.dart';
import '../tools/tool_use_card.dart';
import '../tools/tool_result_card.dart';
import '../common/code_block_view.dart';

/// Content block renderer for the content widgets directory.
///
/// Re-exports the common content block renderer functionality
/// with additional content-specific rendering options.
class ContentRenderer extends StatelessWidget {
  /// Creates a [ContentRenderer].
  const ContentRenderer({
    super.key,
    required this.blocks,
    this.textStyle,
  });

  /// The content blocks to render.
  final List<ContentBlock> blocks;

  /// Optional text style for text blocks.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) => _renderBlock(context, block)).toList(),
    );
  }

  Widget _renderBlock(BuildContext context, ContentBlock block) {
    switch (block.type) {
      case ContentBlockType.text:
        final text = block.text ?? '';
        if (text.isEmpty) return const SizedBox.shrink();
        if (text.startsWith('```')) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: CodeBlockView(code: text),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SelectableText(text, style: textStyle),
        );
      case ContentBlockType.image:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ImageContentView(image: block.image!),
        );
      case ContentBlockType.toolUse:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ToolUseCard(toolUse: block.toolUse!),
        );
      case ContentBlockType.toolResult:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ToolResultCard(toolResult: block.toolResult!),
        );
    }
  }
}

/// Widget for rendering image content blocks.
class ImageContentView extends StatelessWidget {
  /// Creates an [ImageContentView].
  const ImageContentView({
    super.key,
    required this.image,
  });

  /// The image content to render.
  final ImageContent image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300, maxWidth: 400),
        child: Image.network(
          image.source,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: 100,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.broken_image_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
