// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:amplify_ai/amplify_ai.dart';
import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';
import 'code_block_view.dart';

/// Renders a [ContentBlock] into the appropriate widget.
///
/// Handles text, image, tool use, tool result, and document content blocks,
/// rendering each with the appropriate visual presentation.
///
/// ```dart
/// ContentBlockRenderer(block: contentBlock)
/// ```
class ContentBlockRenderer extends StatelessWidget {
  /// The content block to render.
  final ContentBlock block;

  /// Whether this block is inside a user message.
  final bool isUser;

  const ContentBlockRenderer({
    super.key,
    required this.block,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    if (block.text != null) {
      return _buildTextContent(context, theme, block.text!);
    }
    if (block.image != null) {
      return _buildImageContent(context, theme, block.image!);
    }
    if (block.toolUse != null) {
      return _buildToolUseContent(context, theme, block.toolUse!);
    }
    if (block.toolResult != null) {
      return _buildToolResultContent(context, theme, block.toolResult!);
    }
    if (block.document != null) {
      return _buildDocumentContent(context, theme, block.document!);
    }
    return const SizedBox.shrink();
  }

  Widget _buildTextContent(
    BuildContext context,
    AIThemeData theme,
    String text,
  ) {
    // Check if text contains code blocks
    final codeBlockRegex = RegExp(r'```(\w*)\n([\s\S]*?)```');
    if (codeBlockRegex.hasMatch(text)) {
      return _buildMixedContent(context, theme, text, codeBlockRegex);
    }

    return SelectableText(
      text,
      style: theme.messageTextStyle.copyWith(
        color: isUser ? theme.userTextColor : theme.assistantTextColor,
      ),
    );
  }

  Widget _buildMixedContent(
    BuildContext context,
    AIThemeData theme,
    String text,
    RegExp codeBlockRegex,
  ) {
    final children = <Widget>[];
    var lastEnd = 0;

    for (final match in codeBlockRegex.allMatches(text)) {
      // Add text before code block
      if (match.start > lastEnd) {
        final beforeText = text.substring(lastEnd, match.start).trim();
        if (beforeText.isNotEmpty) {
          children.add(
            SelectableText(
              beforeText,
              style: theme.messageTextStyle.copyWith(
                color: isUser ? theme.userTextColor : theme.assistantTextColor,
              ),
            ),
          );
          children.add(const SizedBox(height: 8));
        }
      }

      // Add code block
      final language = match.group(1) ?? '';
      final code = match.group(2)?.trimRight() ?? '';
      children.add(CodeBlockView(code: code, language: language));
      children.add(const SizedBox(height: 8));

      lastEnd = match.end;
    }

    // Add text after last code block
    if (lastEnd < text.length) {
      final afterText = text.substring(lastEnd).trim();
      if (afterText.isNotEmpty) {
        children.add(
          SelectableText(
            afterText,
            style: theme.messageTextStyle.copyWith(
              color: isUser ? theme.userTextColor : theme.assistantTextColor,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildImageContent(
    BuildContext context,
    AIThemeData theme,
    ImageBlock image,
  ) {
    if (image.source.bytes == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.assistantBubbleColor,
          borderRadius: theme.cardBorderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image, color: theme.assistantTextColor, size: 20),
            const SizedBox(width: 8),
            Text('Image (${image.format})', style: theme.captionTextStyle),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: theme.cardBorderRadius,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
        child: Image.memory(
          Uri.parse(
            'data:image/${image.format};base64,${image.source.bytes!}',
          ).data!.contentAsBytes(),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            padding: const EdgeInsets.all(12),
            color: theme.assistantBubbleColor,
            child: const Icon(Icons.broken_image),
          ),
        ),
      ),
    );
  }

  Widget _buildToolUseContent(
    BuildContext context,
    AIThemeData theme,
    ToolUseBlock toolUse,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.toolCardColor,
        borderRadius: theme.cardBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.build, size: 16, color: theme.assistantTextColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Tool: ${toolUse.name}',
              style: theme.captionTextStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolResultContent(
    BuildContext context,
    AIThemeData theme,
    ToolResultBlock toolResult,
  ) {
    final textContent = toolResult.content
        .where((c) => c.text != null)
        .map((c) => c.text!)
        .join('\n');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.assistantBubbleColor,
        borderRadius: theme.cardBorderRadius,
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                'Tool Result',
                style: theme.captionTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          if (textContent.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(textContent, style: theme.messageTextStyle),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentContent(
    BuildContext context,
    AIThemeData theme,
    DocumentBlock document,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.assistantBubbleColor,
        borderRadius: theme.cardBorderRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description, size: 20, color: theme.primaryColor),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  style: theme.messageTextStyle.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  document.format.toUpperCase(),
                  style: theme.captionTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
