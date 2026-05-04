// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'ai_theme_data.dart';

/// Provides Material 3 default theme values for AI Kit widgets.
///
/// Use [DefaultAITheme] to wrap your widget tree and automatically
/// derive AI theme colors from the current Material theme.
///
/// ```dart
/// DefaultAITheme(
///   child: AmplifyAIConversation(controller: controller),
/// )
/// ```
class DefaultAITheme extends StatelessWidget {
  /// The child widget tree.
  final Widget child;

  const DefaultAITheme({super.key, required this.child});

  /// Creates the default [AIThemeData] from a [BuildContext]'s Material theme.
  static AIThemeData defaultThemeOf(BuildContext context) {
    return AIThemeData.fromMaterialTheme(Theme.of(context));
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Default color constants used when no theme is provided.
abstract class AIDefaultColors {
  /// Primary blue used for user bubbles and accents (light mode).
  static const Color primaryLight = Color(0xFF1A73E8);

  /// Primary blue used for user bubbles and accents (dark mode).
  static const Color primaryDark = Color(0xFF4A90D9);

  /// Assistant bubble background (light mode).
  static const Color assistantBubbleLight = Color(0xFFF1F3F4);

  /// Assistant bubble background (dark mode).
  static const Color assistantBubbleDark = Color(0xFF2D2D2D);

  /// Code block background.
  static const Color codeBlockBackground = Color(0xFF263238);

  /// Error red (light mode).
  static const Color errorLight = Color(0xFFD93025);

  /// Error red (dark mode).
  static const Color errorDark = Color(0xFFF28B82);

  /// Tool card background (light mode).
  static const Color toolCardLight = Color(0xFFFFF8E1);

  /// Tool card background (dark mode).
  static const Color toolCardDark = Color(0xFF3E3517);
}

/// Default spacing values for AI Kit widgets.
abstract class AIDefaultSpacing {
  /// Standard message spacing.
  static const double messageSpacing = 8.0;

  /// Standard bubble padding.
  static const EdgeInsets bubblePadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );

  /// Standard card padding.
  static const EdgeInsets cardPadding = EdgeInsets.all(12);

  /// Standard bubble border radius.
  static const double bubbleRadius = 18.0;

  /// Standard card border radius.
  static const double cardRadius = 12.0;
}
