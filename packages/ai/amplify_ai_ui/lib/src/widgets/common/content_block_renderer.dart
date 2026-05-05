// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../state/content_from_events.dart';
import '../tools/tool_use_card.dart';
import '../tools/tool_result_card.dart';
import 'code_block_view.dart';

/// Renders a single content block based on its type.
///
/// Routes to the appropriate widget for text, image, tool-use,
/// and tool-result blocks.
class ContentBlockRenderer extends StatelessWidget {
  /// Creates a [ContentBlockRenderer].
  const ContentBlockRenderer({
    super.key,
    required this.block,
    this.textColor,
  });

  /// The content block to render.
  final ContentBlock block;

  /// Text color override.
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case ContentBlockType.text:
        return _buildTextBlock(context);
      case ContentBlockType.image:
        return _buildImageBlock(context);
      case ContentBlockType.toolUse:
        return ToolUseCard(toolUse: block.toolUse!);
      case ContentBlockType.toolResult:
        return ToolResultCard(toolResult: block.toolResult!);
    }
  }

  Widget _buildTextBlock(BuildContext context) {
    final text = block.text ?? '';
    if (text.isEmpty) return const SizedBox.shrink();

    // Check if it looks like a code block
    if (text.startsWith('```')) {
      return CodeBlockView(code: text);
    }

    return SelectableText(
      text,
      style: TextStyle(color: textColor),
    );
  }

  Widget _buildImageBlock(BuildContext context) {
    final image = block.image;
    if (image == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Image.network(
          image.source,
          fit: BoxFit.contain,
          errorBuilder: (_, error, __) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.broken_image_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 4),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
