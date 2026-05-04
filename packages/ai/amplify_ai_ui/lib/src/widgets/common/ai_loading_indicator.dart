// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// A loading indicator for AI operations.
///
/// Displays an animated loading state with an optional message,
/// suitable for use during message sending, generation, or
/// conversation loading.
///
/// ```dart
/// AILoadingIndicator(message: 'Generating response...')
/// ```
class AILoadingIndicator extends StatelessWidget {
  /// Optional message to display below the indicator.
  final String? message;

  /// Size of the circular progress indicator.
  final double size;

  /// Stroke width of the progress indicator.
  final double strokeWidth;

  const AILoadingIndicator({
    super.key,
    this.message,
    this.size = 24,
    this.strokeWidth = 2.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: theme.captionTextStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
