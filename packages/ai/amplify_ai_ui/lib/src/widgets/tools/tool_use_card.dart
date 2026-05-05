// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';

import 'package:flutter/material.dart';

import '../../state/content_from_events.dart';
import '../../theme/ai_theme.dart';

/// Displays a tool-use request card showing the tool name, input, and
/// a loading spinner while the tool is executing.
///
/// Mirrors the ToolUseCard component in @aws-amplify/ui-react-ai.
class ToolUseCard extends StatelessWidget {
  /// Creates a [ToolUseCard].
  const ToolUseCard({
    super.key,
    required this.toolUse,
    this.isExecuting = false,
  });

  /// The tool use content to display.
  final ToolUseContent toolUse;

  /// Whether the tool is currently executing.
  final bool isExecuting;

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: theme.toolCardColor ?? colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with tool name and status
            Row(
              children: [
                Icon(
                  Icons.build_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    toolUse.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isExecuting)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),

            // Tool input
            if (toolUse.input.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatInput(toolUse.input),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatInput(Map<String, dynamic> input) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(input);
    } catch (_) {
      return input.toString();
    }
  }
}
