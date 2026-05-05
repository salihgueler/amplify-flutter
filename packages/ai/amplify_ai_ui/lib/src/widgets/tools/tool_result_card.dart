// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:flutter/material.dart';

import '../../state/content_from_events.dart';
import '../../theme/ai_theme.dart';

/// Displays a tool result card showing the formatted tool output.
///
/// Mirrors the ToolResultCard component in @aws-amplify/ui-react-ai.
class ToolResultCard extends StatelessWidget {
  /// Creates a [ToolResultCard].
  const ToolResultCard({
    super.key,
    required this.toolResult,
  });

  /// The tool result content to display.
  final ToolResultContent toolResult;

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isError = toolResult.status == ToolResultStatus.error;

    return Card(
      elevation: 0,
      color: isError
          ? colorScheme.errorContainer.withOpacity(0.3)
          : theme.toolResultCardColor ?? colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isError ? colorScheme.error.withOpacity(0.3) : colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with status icon
            Row(
              children: [
                Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  size: 16,
                  color: isError ? colorScheme.error : colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  isError ? 'Tool Error' : 'Tool Result',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isError ? colorScheme.error : colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            // Result content
            if (toolResult.content != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatContent(toolResult.content),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: isError
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatContent(dynamic content) {
    if (content is String) return content;
    if (content is Map || content is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(content);
      } catch (_) {
        return content.toString();
      }
    }
    return content.toString();
  }
}
