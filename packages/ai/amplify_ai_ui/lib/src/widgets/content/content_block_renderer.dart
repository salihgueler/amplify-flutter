// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:amplify_ai/amplify_ai.dart';
import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';
import 'image_content_view.dart';
import 'code_block_view.dart';
import '../tools/tool_use_card.dart';
import '../tools/tool_result_card.dart';

/// Renders a [ContentBlock] as the appropriate widget.
///
/// Handles text, images, code detection, tool use, and tool result blocks
/// with proper styling and layout.
///
/// ```dart
/// ContentBlockRenderer(
///   block: contentBlock,
///   textColor: Colors.black,
/// )
/// ```
class ContentBlockRenderer extends StatelessWidget {
  /// The content block to render.
  final ContentBlock block;

  /// Text color for rendering text content.
  final Color? textColor;

  /// Text style for rendering text content.
  final TextStyle? textStyle;

  /// Optional callback when a tool use card is tapped.
  final void Function(ToolUseBlock toolUse)? onToolUseTap;

  /// Optional callback when a tool result card is tapped.
  final void Function(ToolResultBlock toolResult)? onToolResultTap;

  const ContentBlockRenderer({
    super.key,
    required this.block,
    this.textColor,
    this.textStyle,
    this.onToolUseTap,
    this.onToolResultTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    // Text content
    if (block.text != null) {
      return _renderText(context, theme, block.text!);
    }

    // Image content
    if (block.image != null) {
      return ImageContentView(image: block.image!);
    }

    // Tool use content
    if (block.toolUse != null) {
      return ToolUseCard(
        toolUse: block.toolUse!,
        onTap: onToolUseTap != null
            ? () => onToolUseTap!(block.toolUse!)
            : null,
      );
    }

    // Tool result content
    if (block.toolResult != null) {
      return ToolResultCard(
        toolResult: block.toolResult!,
        onTap: onToolResultTap != null
            ? () => onToolResultTap!(block.toolResult!)
            : null,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _renderText(BuildContext context, AIThemeData theme, String text) {
    // Detect code blocks (```...```)
    final codeBlockPattern = RegExp(r'```(\w*)\n?([\s\S]*?)```');
    final matches = codeBlockPattern.allMatches(text);

    if (matches.isEmpty) {
      // Plain text
      return Text(
        text,
        style: (textStyle ?? theme.messageTextStyle).copyWith(
          color: textColor ?? theme.assistantTextColor,
        ),
      );
    }

    // Mixed content with code blocks
    final widgets = <Widget>[];
    var lastEnd = 0;

    for (final match in matches) {
      // Text before code block
      if (match.start > lastEnd) {
        final preText = text.substring(lastEnd, match.start).trim();
        if (preText.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                preText,
                style: (textStyle ?? theme.messageTextStyle).copyWith(
                  color: textColor ?? theme.assistantTextColor,
                ),
              ),
            ),
          );
        }
      }

      // Code block
      final language = match.group(1) ?? '';
      final code = match.group(2) ?? '';
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CodeBlockView(code: code.trimRight(), language: language),
        ),
      );

      lastEnd = match.end;
    }

    // Text after last code block
    if (lastEnd < text.length) {
      final postText = text.substring(lastEnd).trim();
      if (postText.isNotEmpty) {
        widgets.add(
          Text(
            postText,
            style: (textStyle ?? theme.messageTextStyle).copyWith(
              color: textColor ?? theme.assistantTextColor,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
