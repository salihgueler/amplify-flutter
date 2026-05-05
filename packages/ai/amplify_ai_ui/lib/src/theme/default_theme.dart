// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'ai_theme_data.dart';

/// Creates the default AI theme based on Material 3 colors.
///
/// Supports both light and dark mode.
AIThemeData createDefaultAITheme(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final brightness = Theme.of(context).brightness;

  final isDark = brightness == Brightness.dark;

  return AIThemeData(
    primaryColor: colorScheme.primary,
    surfaceColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
    backgroundColor: isDark ? const Color(0xFF121220) : colorScheme.surface,
    userBubbleColor: colorScheme.primary,
    assistantBubbleColor: isDark
        ? const Color(0xFF2D2D44)
        : colorScheme.surfaceContainerHighest,
    userTextColor: colorScheme.onPrimary,
    assistantTextColor: isDark ? Colors.white : colorScheme.onSurface,
    inputBackgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
    inputFieldColor: isDark
        ? const Color(0xFF2D2D44)
        : colorScheme.surfaceContainerHighest,
    sendButtonColor: colorScheme.primary,
    sendButtonDisabledColor: isDark
        ? Colors.grey.shade700
        : Colors.grey.shade300,
    errorColor: colorScheme.error,
    toolCardColor: isDark
        ? const Color(0xFF252540)
        : colorScheme.surfaceContainerLow,
    toolResultCardColor: isDark
        ? const Color(0xFF1E3A2E)
        : colorScheme.surfaceContainerLow,
    typingIndicatorColor: isDark
        ? Colors.grey.shade400
        : colorScheme.onSurfaceVariant,
    userAvatarColor: colorScheme.primary,
    assistantAvatarColor: colorScheme.tertiary,
    messageTextStyle: TextStyle(
      fontSize: 15,
      height: 1.4,
      color: isDark ? Colors.white : colorScheme.onSurface,
    ),
    captionTextStyle: TextStyle(
      fontSize: 11,
      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
    ),
    bubbleBorderRadius: BorderRadius.circular(16),
    bubblePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    messageSpacing: 8.0,
    avatarSize: 32.0,
  );
}
