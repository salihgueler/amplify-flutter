// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'ai_theme_data.dart';

/// InheritedWidget that provides [AIThemeData] to descendant widgets.
///
/// Wrap your widget tree (or just the AI conversation area) with [AITheme]
/// to customize colors, typography, and spacing of AI Kit widgets.
///
/// ```dart
/// AITheme(
///   data: AIThemeData.dark(),
///   child: AmplifyAIConversation(controller: controller),
/// )
/// ```
class AITheme extends InheritedWidget {
  /// The theme data to provide to descendants.
  final AIThemeData data;

  const AITheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// Retrieves the closest [AIThemeData] from the widget tree.
  ///
  /// If no [AITheme] ancestor is found, returns a default light theme
  /// derived from the current [Theme].
  static AIThemeData of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<AITheme>();
    if (inherited != null) return inherited.data;
    return AIThemeData.fromBrightness(Theme.of(context).brightness);
  }

  @override
  bool updateShouldNotify(AITheme oldWidget) => data != oldWidget.data;
}
