// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// A widget that displays error information with an optional retry action.
///
/// Used throughout the AI UI to present errors in a consistent,
/// user-friendly format.
///
/// ```dart
/// AIErrorView(
///   message: 'Failed to load messages',
///   onRetry: () => controller.loadConversation(),
/// )
/// ```
class AIErrorView extends StatelessWidget {
  /// The error message to display.
  final String message;

  /// Optional retry callback. If provided, a retry button is shown.
  final VoidCallback? onRetry;

  /// Optional title above the error message.
  final String? title;

  /// Icon to display alongside the error.
  final IconData icon;

  const AIErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.errorColor),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: theme.messageTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: theme.captionTextStyle.copyWith(
                color: theme.assistantTextColor.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(color: theme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
