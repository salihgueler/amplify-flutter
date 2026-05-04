// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// A progress indicator for tool execution.
///
/// Shows a linear progress bar with optional label and percentage.
/// Use this to indicate long-running tool operations.
///
/// ```dart
/// ToolProgressIndicator(
///   toolName: 'searchDatabase',
///   progress: 0.6,
///   statusMessage: 'Querying records...',
/// )
/// ```
class ToolProgressIndicator extends StatelessWidget {
  /// The name of the tool being executed.
  final String toolName;

  /// Progress value from 0.0 to 1.0. Null shows indeterminate progress.
  final double? progress;

  /// Optional status message below the progress bar.
  final String? statusMessage;

  /// Whether the operation has completed.
  final bool isComplete;

  /// Whether the operation has failed.
  final bool hasFailed;

  const ToolProgressIndicator({
    super.key,
    required this.toolName,
    this.progress,
    this.statusMessage,
    this.isComplete = false,
    this.hasFailed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.toolCardColor.withValues(alpha: 0.5),
        borderRadius: theme.cardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildIcon(theme),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  toolName,
                  style: theme.captionTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (progress != null && !isComplete && !hasFailed)
                Text(
                  '${(progress! * 100).toInt()}%',
                  style: theme.captionTextStyle,
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: _buildProgressBar(theme),
          ),
          if (statusMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              statusMessage!,
              style: theme.captionTextStyle.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(AIThemeData theme) {
    if (isComplete) {
      return const Icon(Icons.check_circle, size: 16, color: Color(0xFF34A853));
    }
    if (hasFailed) {
      return Icon(Icons.error, size: 16, color: theme.errorColor);
    }
    return Icon(Icons.settings, size: 16, color: theme.primaryColor);
  }

  Widget _buildProgressBar(AIThemeData theme) {
    final color = hasFailed
        ? theme.errorColor
        : isComplete
            ? const Color(0xFF34A853)
            : theme.primaryColor;

    if (progress != null) {
      return LinearProgressIndicator(
        value: isComplete ? 1.0 : progress,
        backgroundColor: color.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 4,
      );
    }

    return LinearProgressIndicator(
      backgroundColor: color.withValues(alpha: 0.15),
      valueColor: AlwaysStoppedAnimation<Color>(color),
      minHeight: 4,
    );
  }
}
