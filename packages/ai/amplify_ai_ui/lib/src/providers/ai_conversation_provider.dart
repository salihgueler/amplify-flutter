// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../widgets/conversation/ai_conversation_controller.dart';

/// InheritedWidget that provides an [AIConversationController] to descendants.
///
/// This allows deeply nested widgets to access the controller without
/// explicit parameter passing.
///
/// ```dart
/// AIConversationProvider(
///   controller: myController,
///   child: MyCustomChatView(),
/// )
/// ```
class AIConversationProvider extends InheritedWidget {
  /// The conversation controller to provide.
  final AIConversationController controller;

  const AIConversationProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Retrieves the closest [AIConversationController] from the widget tree.
  ///
  /// Throws if no [AIConversationProvider] ancestor is found.
  static AIConversationController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AIConversationProvider>();
    assert(provider != null,
        'No AIConversationProvider found in the widget tree.');
    return provider!.controller;
  }

  /// Retrieves the closest [AIConversationController], or null if not found.
  static AIConversationController? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AIConversationProvider>();
    return provider?.controller;
  }

  @override
  bool updateShouldNotify(AIConversationProvider oldWidget) =>
      controller != oldWidget.controller;
}
