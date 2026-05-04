// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:amplify_ai/amplify_ai.dart';
import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// A card that displays a tool use request from the AI model.
///
/// Shows the tool name, input parameters, and current execution status.
/// Used when the AI model requests a client-side tool invocation.
///
/// ```dart
/// ToolUseCard(
///   toolUse: toolUseBlock,
///   status: ToolExecutionStatus.running,
/// )
/// ```
class ToolUseCard extends StatelessWidget {
  /// The tool use block data.
  final ToolUseBlock toolUse;

  /// Current execution status of the tool.
  final ToolExecutionStatus status;

  /// Optional callback when the user taps the card for details.
  final VoidCallback? onTap;

  /// Whether to show the input parameters.
  final bool showInput;

  const ToolUseCard({
    super.key,
    required this.toolUse,
    this.status = ToolExecutionStatus.pending,
    this.onTap,
    this.showInput = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.toolCardColor,
          borderRadius: theme.cardBorderRadius,
          border: Border.all(color: _statusColor(theme).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            if (showInput && toolUse.input.isNotEmpty)
              _buildInputSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AIThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildStatusIcon(theme),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toolUse.name,
                  style: theme.messageTextStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusLabel,
                  style: theme.captionTextStyle.copyWith(
                    color: _statusColor(theme),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.build_circle_outlined,
            size: 20,
            color: theme.assistantTextColor.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(AIThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.codeBlockColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _formatInput(toolUse.input),
          style: theme.codeTextStyle.copyWith(
            fontSize: 11,
            color: theme.assistantTextColor.withValues(alpha: 0.8),
          ),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildStatusIcon(AIThemeData theme) {
    switch (status) {
      case ToolExecutionStatus.pending:
        return Icon(Icons.schedule, size: 18, color: _statusColor(theme));
      case ToolExecutionStatus.running:
        return SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(_statusColor(theme)),
          ),
        );
      case ToolExecutionStatus.completed:
        return Icon(Icons.check_circle, size: 18, color: _statusColor(theme));
      case ToolExecutionStatus.failed:
        return Icon(Icons.error, size: 18, color: _statusColor(theme));
    }
  }

  Color _statusColor(AIThemeData theme) {
    switch (status) {
      case ToolExecutionStatus.pending:
        return theme.assistantTextColor.withValues(alpha: 0.5);
      case ToolExecutionStatus.running:
        return theme.primaryColor;
      case ToolExecutionStatus.completed:
        return const Color(0xFF34A853);
      case ToolExecutionStatus.failed:
        return theme.errorColor;
    }
  }

  String get _statusLabel {
    switch (status) {
      case ToolExecutionStatus.pending:
        return 'Waiting to execute...';
      case ToolExecutionStatus.running:
        return 'Executing...';
      case ToolExecutionStatus.completed:
        return 'Completed';
      case ToolExecutionStatus.failed:
        return 'Failed';
    }
  }

  String _formatInput(Map<String, dynamic> input) {
    final entries = input.entries.take(5).map((e) => '${e.key}: ${e.value}');
    final result = entries.join('\n');
    if (input.length > 5) return '$result\n... (${input.length - 5} more)';
    return result;
  }
}

/// Execution status of a tool invocation.
enum ToolExecutionStatus {
  /// Waiting to be executed.
  pending,

  /// Currently running.
  running,

  /// Completed successfully.
  completed,

  /// Failed with an error.
  failed,
}
