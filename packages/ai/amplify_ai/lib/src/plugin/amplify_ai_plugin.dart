// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Amplify AI Plugin for registering AI capabilities with Amplify Flutter.

import '../clients/conversation_client.dart';
import '../clients/generation_client.dart';
import '../clients/graphql_api_provider.dart';
import '../config/ai_config.dart';

/// The Amplify AI Plugin provides AI conversation and generation capabilities.
///
/// Register this plugin to access AI features through the Amplify framework.
///
/// Example:
/// ```dart
/// final aiPlugin = AmplifyAIPlugin(
///   config: AmplifyAIConfig.fromOutputs(amplifyOutputs),
///   apiProvider: myGraphQLProvider,
/// );
///
/// // Access conversation clients
/// final chatClient = aiPlugin.conversations['pirateChat']!;
///
/// // Access generation clients
/// final genClient = aiPlugin.generations['generateRecipe']!;
/// ```
class AmplifyAIPlugin {
  /// The AI configuration parsed from amplify_outputs.json.
  final AmplifyAIConfig config;

  /// The GraphQL API provider for executing operations.
  final GraphQLAPIProvider apiProvider;

  /// Conversation clients keyed by route name.
  late final Map<String, ConversationClient> conversations;

  /// Generation clients keyed by route name.
  late final Map<String, GenerationClient> generations;

  /// Creates an Amplify AI Plugin instance.
  AmplifyAIPlugin({
    required this.config,
    required this.apiProvider,
  }) {
    conversations = _buildConversationClients();
    generations = _buildGenerationClients();
  }

  /// Gets a conversation client by route name.
  ///
  /// Throws [ArgumentError] if the route does not exist.
  ConversationClient getConversationClient(String routeName) {
    final client = conversations[routeName];
    if (client == null) {
      throw ArgumentError(
        'No conversation route found with name "$routeName". '
        'Available routes: ${conversations.keys.join(", ")}',
      );
    }
    return client;
  }

  /// Gets a generation client by route name.
  ///
  /// Throws [ArgumentError] if the route does not exist.
  GenerationClient getGenerationClient(String routeName) {
    final client = generations[routeName];
    if (client == null) {
      throw ArgumentError(
        'No generation route found with name "$routeName". '
        'Available routes: ${generations.keys.join(", ")}',
      );
    }
    return client;
  }

  Map<String, ConversationClient> _buildConversationClients() {
    return config.conversations.map(
      (name, routeConfig) => MapEntry(
        name,
        ConversationClient(config: routeConfig, api: apiProvider),
      ),
    );
  }

  Map<String, GenerationClient> _buildGenerationClients() {
    return config.generations.map(
      (name, routeConfig) => MapEntry(
        name,
        GenerationClient(config: routeConfig, api: apiProvider),
      ),
    );
  }
}
