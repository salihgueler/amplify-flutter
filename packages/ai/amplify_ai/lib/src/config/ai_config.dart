// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Configuration parsing from amplify_outputs.json for AI Kit.

import 'package:meta/meta.dart';

/// Configuration for a conversation route.
@immutable
class ConversationRouteConfig {
  /// The route name (e.g., "pirateChat").
  final String name;

  /// The model name for the conversation DynamoDB table.
  final String conversationModelName;

  /// The model name for messages DynamoDB table.
  final String messageModelName;

  /// GraphQL field name for sending a message (mutation).
  final String sendMessageFieldName;

  /// GraphQL field name for subscribing to stream events.
  final String subscribeFieldName;

  /// GraphQL field name for listing messages.
  final String listMessagesFieldName;

  /// GraphQL field name for getting a conversation.
  final String getConversationFieldName;

  /// GraphQL field name for creating a conversation.
  final String createConversationFieldName;

  /// GraphQL field name for listing conversations.
  final String listConversationsFieldName;

  /// GraphQL field name for deleting a conversation.
  final String deleteConversationFieldName;

  /// GraphQL field name for updating a conversation.
  final String updateConversationFieldName;

  const ConversationRouteConfig({
    required this.name,
    required this.conversationModelName,
    required this.messageModelName,
    required this.sendMessageFieldName,
    required this.subscribeFieldName,
    required this.listMessagesFieldName,
    required this.getConversationFieldName,
    required this.createConversationFieldName,
    required this.listConversationsFieldName,
    required this.deleteConversationFieldName,
    required this.updateConversationFieldName,
  });

  /// Parses a conversation route config from the amplify_outputs model
  /// introspection schema.
  factory ConversationRouteConfig.fromJson(
      String routeName, Map<String, dynamic> json) {
    final message = json['message'] as Map<String, dynamic>? ?? {};
    final conversation = json['conversation'] as Map<String, dynamic>? ?? {};

    return ConversationRouteConfig(
      name: routeName,
      conversationModelName:
          conversation['modelName'] as String? ?? '${routeName}Conversation',
      messageModelName:
          message['modelName'] as String? ?? '${routeName}Message',
      sendMessageFieldName: message['send'] as String? ?? routeName,
      subscribeFieldName: message['subscribe'] as String? ??
          'onCreate${_capitalize(routeName)}Message',
      listMessagesFieldName:
          message['list'] as String? ?? 'list${_capitalize(routeName)}Messages',
      getConversationFieldName: conversation['get'] as String? ??
          'get${_capitalize(routeName)}Conversation',
      createConversationFieldName: conversation['create'] as String? ??
          'create${_capitalize(routeName)}Conversation',
      listConversationsFieldName: conversation['list'] as String? ??
          'list${_capitalize(routeName)}Conversations',
      deleteConversationFieldName: conversation['delete'] as String? ??
          'delete${_capitalize(routeName)}Conversation',
      updateConversationFieldName: conversation['update'] as String? ??
          'update${_capitalize(routeName)}Conversation',
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

/// Configuration for a generation route.
@immutable
class GenerationRouteConfig {
  /// The route name (e.g., "generateRecipe").
  final String name;

  /// The GraphQL field name for the generation query.
  final String queryFieldName;

  const GenerationRouteConfig({
    required this.name,
    required this.queryFieldName,
  });

  /// Parses a generation route config from the amplify_outputs model
  /// introspection schema.
  factory GenerationRouteConfig.fromJson(
      String routeName, Map<String, dynamic> json) {
    return GenerationRouteConfig(
      name: routeName,
      queryFieldName: json['queryFieldName'] as String? ?? routeName,
    );
  }
}

/// Top-level AI configuration parsed from amplify_outputs.json.
@immutable
class AmplifyAIConfig {
  /// Conversation route configurations keyed by route name.
  final Map<String, ConversationRouteConfig> conversations;

  /// Generation route configurations keyed by route name.
  final Map<String, GenerationRouteConfig> generations;

  const AmplifyAIConfig({
    required this.conversations,
    required this.generations,
  });

  /// Parses AI configuration from the amplify_outputs.json data structure.
  ///
  /// Expects the `data` section containing `model_introspection` with
  /// `conversations` and `generations` maps.
  factory AmplifyAIConfig.fromOutputs(Map<String, dynamic> outputs) {
    final data = outputs['data'] as Map<String, dynamic>? ?? {};
    final modelIntrospection =
        data['model_introspection'] as Map<String, dynamic>? ?? {};

    final conversationsJson =
        modelIntrospection['conversations'] as Map<String, dynamic>? ?? {};
    final generationsJson =
        modelIntrospection['generations'] as Map<String, dynamic>? ?? {};

    final conversations = <String, ConversationRouteConfig>{};
    for (final entry in conversationsJson.entries) {
      conversations[entry.key] = ConversationRouteConfig.fromJson(
        entry.key,
        entry.value as Map<String, dynamic>,
      );
    }

    final generations = <String, GenerationRouteConfig>{};
    for (final entry in generationsJson.entries) {
      generations[entry.key] = GenerationRouteConfig.fromJson(
        entry.key,
        entry.value as Map<String, dynamic>,
      );
    }

    return AmplifyAIConfig(
      conversations: conversations,
      generations: generations,
    );
  }
}
