// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:amplify_ai/amplify_ai.dart';
import 'package:flutter/material.dart';

import '../providers/ai_conversation_provider.dart';
import '../providers/ai_generation_provider.dart';
import '../widgets/conversation/ai_conversation_controller.dart';
import '../widgets/generation/ai_generation_controller.dart';

/// Factory for creating AI provider widgets wrapping conversation
/// and generation controllers.
///
/// ```dart
/// final providers = createAIProviders(
///   conversationClient: aiPlugin.getConversationClient('myRoute'),
///   generationCallback: (input) => generationClient.generate(arguments: input),
///   child: MyAppContent(),
/// );
/// ```
Widget createAIProviders({
  required ConversationClient conversationClient,
  Future<Map<String, dynamic>?> Function(Map<String, dynamic> input)?
  generationCallback,
  required Widget child,
}) {
  final conversationController = AIConversationController(
    conversationClient: conversationClient,
  );

  Widget result = AIConversationProvider(
    controller: conversationController,
    child: child,
  );

  if (generationCallback != null) {
    final generationController = AIGenerationController(
      onGenerate: generationCallback,
    );
    result = AIGenerationProvider(
      controller: generationController,
      child: result,
    );
  }

  return result;
}
