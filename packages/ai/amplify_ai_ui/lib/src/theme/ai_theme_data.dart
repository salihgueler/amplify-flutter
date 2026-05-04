// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

/// Theme data for AI Kit UI components.
///
/// Defines colors, typography, spacing, and shapes used throughout
/// the AI conversation widgets. Supports Material 3 and dark mode.
class AIThemeData {
  /// Background color for user message bubbles.
  final Color userBubbleColor;

  /// Background color for assistant message bubbles.
  final Color assistantBubbleColor;

  /// Text color for user messages.
  final Color userTextColor;

  /// Text color for assistant messages.
  final Color assistantTextColor;

  /// Background color of the message input area.
  final Color inputBackgroundColor;

  /// Color of the send button when active.
  final Color sendButtonColor;

  /// Color of the send button when disabled.
  final Color sendButtonDisabledColor;

  /// Background color for tool use cards.
  final Color toolCardColor;

  /// Background color for code blocks.
  final Color codeBlockColor;

  /// Text style for message body text.
  final TextStyle messageTextStyle;

  /// Text style for timestamps and captions.
  final TextStyle captionTextStyle;

  /// Text style for code blocks.
  final TextStyle codeTextStyle;

  /// Border radius for message bubbles.
  final BorderRadius bubbleBorderRadius;

  /// Padding inside message bubbles.
  final EdgeInsets bubblePadding;

  /// Vertical spacing between messages.
  final double messageSpacing;

  /// Border radius for cards (tools, code, images).
  final BorderRadius cardBorderRadius;

  /// Primary accent color.
  final Color primaryColor;

  /// Error color for failed states.
  final Color errorColor;

  /// Surface color for backgrounds.
  final Color surfaceColor;

  /// The overall brightness (light or dark).
  final Brightness brightness;

  const AIThemeData({
    required this.userBubbleColor,
    required this.assistantBubbleColor,
    required this.userTextColor,
    required this.assistantTextColor,
    required this.inputBackgroundColor,
    required this.sendButtonColor,
    required this.sendButtonDisabledColor,
    required this.toolCardColor,
    required this.codeBlockColor,
    required this.messageTextStyle,
    required this.captionTextStyle,
    required this.codeTextStyle,
    required this.bubbleBorderRadius,
    required this.bubblePadding,
    required this.messageSpacing,
    required this.cardBorderRadius,
    required this.primaryColor,
    required this.errorColor,
    required this.surfaceColor,
    required this.brightness,
  });

  /// Creates a light theme.
  factory AIThemeData.light() => AIThemeData.fromBrightness(Brightness.light);

  /// Creates a dark theme.
  factory AIThemeData.dark() => AIThemeData.fromBrightness(Brightness.dark);

  /// Creates a theme based on brightness.
  factory AIThemeData.fromBrightness(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return AIThemeData(
      brightness: brightness,
      userBubbleColor: isLight
          ? const Color(0xFF1A73E8)
          : const Color(0xFF4A90D9),
      assistantBubbleColor: isLight
          ? const Color(0xFFF1F3F4)
          : const Color(0xFF2D2D2D),
      userTextColor: Colors.white,
      assistantTextColor: isLight
          ? const Color(0xFF202124)
          : const Color(0xFFE8EAED),
      inputBackgroundColor: isLight
          ? const Color(0xFFF8F9FA)
          : const Color(0xFF1E1E1E),
      sendButtonColor: isLight
          ? const Color(0xFF1A73E8)
          : const Color(0xFF4A90D9),
      sendButtonDisabledColor: isLight
          ? const Color(0xFFDADCE0)
          : const Color(0xFF5F6368),
      toolCardColor: isLight
          ? const Color(0xFFFFF8E1)
          : const Color(0xFF3E3517),
      codeBlockColor: isLight
          ? const Color(0xFF263238)
          : const Color(0xFF1E1E1E),
      messageTextStyle: TextStyle(
        fontSize: 15,
        height: 1.4,
        color: isLight ? const Color(0xFF202124) : const Color(0xFFE8EAED),
      ),
      captionTextStyle: TextStyle(
        fontSize: 12,
        height: 1.3,
        color: isLight ? const Color(0xFF5F6368) : const Color(0xFF9AA0A6),
      ),
      codeTextStyle: TextStyle(
        fontSize: 13,
        height: 1.5,
        fontFamily: 'monospace',
        color: isLight ? const Color(0xFFCFD8DC) : const Color(0xFFCFD8DC),
      ),
      bubbleBorderRadius: BorderRadius.circular(18),
      bubblePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      messageSpacing: 8,
      cardBorderRadius: BorderRadius.circular(12),
      primaryColor: isLight ? const Color(0xFF1A73E8) : const Color(0xFF4A90D9),
      errorColor: isLight ? const Color(0xFFD93025) : const Color(0xFFF28B82),
      surfaceColor: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF121212),
    );
  }

  /// Creates a theme from an existing Material [ThemeData].
  factory AIThemeData.fromMaterialTheme(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    return AIThemeData(
      brightness: theme.brightness,
      userBubbleColor: colorScheme.primary,
      assistantBubbleColor: colorScheme.surfaceContainerHighest,
      userTextColor: colorScheme.onPrimary,
      assistantTextColor: colorScheme.onSurface,
      inputBackgroundColor: colorScheme.surfaceContainerLow,
      sendButtonColor: colorScheme.primary,
      sendButtonDisabledColor: colorScheme.onSurface.withValues(alpha: 0.38),
      toolCardColor: colorScheme.tertiaryContainer,
      codeBlockColor: isLight
          ? const Color(0xFF263238)
          : colorScheme.surfaceContainerHighest,
      messageTextStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
      captionTextStyle: theme.textTheme.bodySmall ?? const TextStyle(),
      codeTextStyle: TextStyle(
        fontSize: 13,
        height: 1.5,
        fontFamily: 'monospace',
        color: isLight ? const Color(0xFFCFD8DC) : const Color(0xFFCFD8DC),
      ),
      bubbleBorderRadius: BorderRadius.circular(18),
      bubblePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      messageSpacing: 8,
      cardBorderRadius: BorderRadius.circular(12),
      primaryColor: colorScheme.primary,
      errorColor: colorScheme.error,
      surfaceColor: colorScheme.surface,
    );
  }

  /// Creates a copy of this theme with the specified overrides.
  AIThemeData copyWith({
    Color? userBubbleColor,
    Color? assistantBubbleColor,
    Color? userTextColor,
    Color? assistantTextColor,
    Color? inputBackgroundColor,
    Color? sendButtonColor,
    Color? sendButtonDisabledColor,
    Color? toolCardColor,
    Color? codeBlockColor,
    TextStyle? messageTextStyle,
    TextStyle? captionTextStyle,
    TextStyle? codeTextStyle,
    BorderRadius? bubbleBorderRadius,
    EdgeInsets? bubblePadding,
    double? messageSpacing,
    BorderRadius? cardBorderRadius,
    Color? primaryColor,
    Color? errorColor,
    Color? surfaceColor,
    Brightness? brightness,
  }) {
    return AIThemeData(
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      assistantBubbleColor: assistantBubbleColor ?? this.assistantBubbleColor,
      userTextColor: userTextColor ?? this.userTextColor,
      assistantTextColor: assistantTextColor ?? this.assistantTextColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      sendButtonDisabledColor:
          sendButtonDisabledColor ?? this.sendButtonDisabledColor,
      toolCardColor: toolCardColor ?? this.toolCardColor,
      codeBlockColor: codeBlockColor ?? this.codeBlockColor,
      messageTextStyle: messageTextStyle ?? this.messageTextStyle,
      captionTextStyle: captionTextStyle ?? this.captionTextStyle,
      codeTextStyle: codeTextStyle ?? this.codeTextStyle,
      bubbleBorderRadius: bubbleBorderRadius ?? this.bubbleBorderRadius,
      bubblePadding: bubblePadding ?? this.bubblePadding,
      messageSpacing: messageSpacing ?? this.messageSpacing,
      cardBorderRadius: cardBorderRadius ?? this.cardBorderRadius,
      primaryColor: primaryColor ?? this.primaryColor,
      errorColor: errorColor ?? this.errorColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      brightness: brightness ?? this.brightness,
    );
  }
}
