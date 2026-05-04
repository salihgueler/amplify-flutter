// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import 'ai_theme_data.dart';
import 'default_theme.dart';

/// InheritedWidget providing AI theme to descendant widgets.
///
/// Equivalent to the theming context in @aws-amplify/ui-react-ai.
class AITheme extends InheritedWidget {
  /// The theme data.
  final AIThemeData themeData;

  const AITheme({
    super.key,
    required this.themeData,
    required super.child,
  });

  /// Gets the AI theme from the current context.
  ///
  /// If no [AITheme] is found in the widget tree, returns a default theme
  /// based on the Material Theme.
  static AIThemeData of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<AITheme>();
    if (widget != null) return widget.themeData;
    return createDefaultAITheme(context);
  }

  @override
  bool updateShouldNotify(AITheme oldWidget) {
    return themeData != oldWidget.themeData;
  }
}
