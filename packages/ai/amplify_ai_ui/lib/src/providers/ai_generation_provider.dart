// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../widgets/generation/ai_generation_controller.dart';

/// InheritedWidget that provides an [AIGenerationController] to descendants.
///
/// This allows deeply nested widgets to access the generation controller
/// without explicit parameter passing.
///
/// ```dart
/// AIGenerationProvider(
///   controller: myGenerationController,
///   child: MyCustomGenerationView(),
/// )
/// ```
class AIGenerationProvider extends InheritedWidget {
  /// The generation controller to provide.
  final AIGenerationController controller;

  const AIGenerationProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Retrieves the closest [AIGenerationController] from the widget tree.
  ///
  /// Throws if no [AIGenerationProvider] ancestor is found.
  static AIGenerationController of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AIGenerationProvider>();
    assert(
      provider != null,
      'No AIGenerationProvider found in the widget tree.',
    );
    return provider!.controller;
  }

  /// Retrieves the closest [AIGenerationController], or null if not found.
  static AIGenerationController? maybeOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<AIGenerationProvider>();
    return provider?.controller;
  }

  @override
  bool updateShouldNotify(AIGenerationProvider oldWidget) =>
      controller != oldWidget.controller;
}
