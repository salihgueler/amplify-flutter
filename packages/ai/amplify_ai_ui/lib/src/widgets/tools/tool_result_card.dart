// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:amplify_ai/amplify_ai.dart';
import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// A card that displays the result of a tool execution.
///
/// Shows the tool result content (text, JSON, images) in a formatted card.
///
/// ```dart
/// ToolResultCard(
///   toolResult: toolResultBlock,
///   toolName: 'getWeather',
/// )
/// ```
class ToolResultCard extends StatelessWidget {
  /// The tool result block data.
  final ToolResultBlock toolResult;

  /// Optional tool name for display.
  final String? toolName;

  /// Whether to show the result in an expanded view.
  final bool expanded;

  /// Optional callback when the card is tapped.
  final VoidCallback? onTap;

  const ToolResultCard({
    super.key,
    required this.toolResult,
    this.toolName,
    this.expanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);
    final isSuccess = toolResult.status != 'error';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          borderRadius: theme.cardBorderRadius,
          border: Border.all(
            color: isSuccess
                ? const Color(0xFF34A853).withValues(alpha: 0.3)
                : theme.errorColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme, isSuccess),
            _buildContent(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AIThemeData theme, bool isSuccess) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            size: 18,
            color: isSuccess ? const Color(0xFF34A853) : theme.errorColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              toolName != null ? '$toolName result' : 'Tool result',
              style: theme.messageTextStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (!expanded)
            Icon(
              Icons.expand_more,
              size: 18,
              color: theme.assistantTextColor.withValues(alpha: 0.5),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(AIThemeData theme) {
    if (toolResult.content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: toolResult.content.map((content) {
          if (content.text != null) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.codeBlockColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content.text!,
                style: theme.codeTextStyle.copyWith(
                  fontSize: 12,
                  color: theme.assistantTextColor,
                ),
                maxLines: expanded ? null : 8,
                overflow: expanded ? null : TextOverflow.ellipsis,
              ),
            );
          }
          if (content.jsonValue != null) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.codeBlockColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatJson(content.jsonValue!),
                style: theme.codeTextStyle.copyWith(
                  fontSize: 12,
                  color: theme.assistantTextColor,
                ),
                maxLines: expanded ? null : 8,
                overflow: expanded ? null : TextOverflow.ellipsis,
              ),
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    final entries = json.entries.map((e) => '  "${e.key}": ${e.value}');
    return '{\n${entries.join(',\n')}\n}';
  }
}
