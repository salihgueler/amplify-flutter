// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'ai_conversation_provider.dart';
import 'ai_generation_provider.dart';

/// Factory for creating typed AI providers from configuration.
///
/// Mirrors createAIHooks from @aws-amplify/ui-react-ai which creates
/// typed hooks from AI route configuration.
///
/// Usage:
/// ```dart
/// final providers = AIProviders.create(
///   conversationRouteNames: ['chat', 'support'],
///   generationRouteNames: ['summarize', 'translate'],
/// );
///
/// final chatProvider = providers.conversation('chat');
/// final summarizeProvider = providers.generation<String>('summarize');
/// ```
class AIProviders {
  AIProviders._({
    required Map<String, AIConversationProvider> conversations,
    required Map<String, AIGenerationProvider> generations,
  })  : _conversations = conversations,
        _generations = generations;

  /// Creates [AIProviders] from route configuration.
  ///
  /// This mirrors createAIHooks which takes the AI configuration
  /// and produces typed hook creators for each route.
  factory AIProviders.create({
    List<String> conversationRouteNames = const [],
    List<String> generationRouteNames = const [],
    Map<String, Map<String, ToolHandler>> toolHandlers = const {},
  }) {
    final conversations = <String, AIConversationProvider>{};
    final generations = <String, AIGenerationProvider>{};

    for (final name in conversationRouteNames) {
      conversations[name] = AIConversationProvider(
        toolHandlers: toolHandlers[name] ?? {},
      );
    }

    for (final name in generationRouteNames) {
      generations[name] = AIGenerationProvider();
    }

    return AIProviders._(
      conversations: conversations,
      generations: generations,
    );
  }

  final Map<String, AIConversationProvider> _conversations;
  final Map<String, AIGenerationProvider> _generations;

  /// Gets the conversation provider for a given route name.
  AIConversationProvider conversation(String routeName) {
    final provider = _conversations[routeName];
    if (provider == null) {
      throw ArgumentError(
        'No conversation provider found for route "$routeName". '
        'Available routes: ${_conversations.keys.join(', ')}',
      );
    }
    return provider;
  }

  /// Gets the generation provider for a given route name.
  AIGenerationProvider<T> generation<T>(String routeName) {
    final provider = _generations[routeName];
    if (provider == null) {
      throw ArgumentError(
        'No generation provider found for route "$routeName". '
        'Available routes: ${_generations.keys.join(', ')}',
      );
    }
    return provider as AIGenerationProvider<T>;
  }

  /// Disposes all providers.
  void dispose() {
    for (final provider in _conversations.values) {
      provider.dispose();
    }
    for (final provider in _generations.values) {
      provider.dispose();
    }
  }
}
