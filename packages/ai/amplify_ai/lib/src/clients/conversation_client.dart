// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Conversation client for managing AI conversations.
///
/// Provides CRUD operations for conversations and access to
/// individual conversation instances for messaging.

import 'dart:convert';

import '../config/ai_config.dart';
import '../graphql/documents.dart' as docs;
import '../types/conversation.dart';
import '../types/conversation_message.dart';
import '../types/conversation_stream_event.dart';
import 'graphql_api_provider.dart';

/// Client for managing conversations on a specific route.
///
/// Use this to create, get, list, update, and delete conversations.
/// Each conversation returned provides methods for sending messages
/// and subscribing to stream events.
class ConversationClient {
  final ConversationRouteConfig _config;
  final GraphQLAPIProvider _api;

  /// Creates a conversation client for the given route configuration.
  ConversationClient({
    required ConversationRouteConfig config,
    required GraphQLAPIProvider api,
  })  : _config = config,
        _api = api;

  /// The route name for this conversation client.
  String get routeName => _config.name;

  /// Creates a new conversation.
  Future<SingleResult<Conversation>> create({
    String? name,
    Map<String, dynamic>? metadata,
  }) async {
    final input = <String, dynamic>{};
    if (name != null) input['name'] = name;
    if (metadata != null) input['metadata'] = json.encode(metadata);

    final response = await _api.mutate(
      document:
          docs.createConversationDocument(_config.createConversationFieldName),
      variables: {'input': input},
    );

    return _parseSingleConversation(
        response, _config.createConversationFieldName);
  }

  /// Gets an existing conversation by ID.
  Future<SingleResult<Conversation>> get({required String id}) async {
    final response = await _api.query(
      document: docs.getConversationDocument(_config.getConversationFieldName),
      variables: {'id': id},
    );

    return _parseSingleConversation(response, _config.getConversationFieldName);
  }

  /// Lists conversations with optional pagination.
  Future<PaginatedResult<Conversation>> list({
    int? limit,
    String? nextToken,
  }) async {
    final variables = <String, dynamic>{};
    if (limit != null) variables['limit'] = limit;
    if (nextToken != null) variables['nextToken'] = nextToken;

    final response = await _api.query(
      document:
          docs.listConversationsDocument(_config.listConversationsFieldName),
      variables: variables,
    );

    if (response.data == null) {
      return const PaginatedResult(items: []);
    }

    final listData = response.data![_config.listConversationsFieldName]
        as Map<String, dynamic>?;
    if (listData == null) {
      return const PaginatedResult(items: []);
    }

    final items = (listData['items'] as List<dynamic>?)
            ?.map((e) => _conversationFromSummary(
                ConversationSummary.fromJson(e as Map<String, dynamic>)))
            .toList() ??
        [];

    return PaginatedResult(
      items: items,
      nextToken: listData['nextToken'] as String?,
    );
  }

  /// Deletes a conversation by ID.
  Future<SingleResult<Conversation>> delete({required String id}) async {
    final response = await _api.mutate(
      document:
          docs.deleteConversationDocument(_config.deleteConversationFieldName),
      variables: {
        'input': {'id': id}
      },
    );

    return _parseSingleConversation(
        response, _config.deleteConversationFieldName);
  }

  /// Updates a conversation.
  Future<SingleResult<Conversation>> update({
    required String id,
    String? name,
    Map<String, dynamic>? metadata,
  }) async {
    final input = <String, dynamic>{'id': id};
    if (name != null) input['name'] = name;
    if (metadata != null) input['metadata'] = json.encode(metadata);

    final response = await _api.mutate(
      document:
          docs.updateConversationDocument(_config.updateConversationFieldName),
      variables: {'input': input},
    );

    return _parseSingleConversation(
        response, _config.updateConversationFieldName);
  }

  SingleResult<Conversation> _parseSingleConversation(
    GraphQLResponse<Map<String, dynamic>> response,
    String fieldName,
  ) {
    if (response.hasErrors) {
      return SingleResult(
        errors: response.errors!
            .map((e) => GraphQLResponseError.fromJson(e))
            .toList(),
      );
    }

    final data = response.data?[fieldName] as Map<String, dynamic>?;
    if (data == null) {
      return const SingleResult();
    }

    final summary = ConversationSummary.fromJson(data);
    return SingleResult(data: _conversationFromSummary(summary));
  }

  Conversation _conversationFromSummary(ConversationSummary summary) {
    return Conversation(
      summary: summary,
      config: _config,
      api: _api,
    );
  }
}

/// An active conversation instance.
///
/// Provides methods to send messages, list message history,
/// and subscribe to streaming events.
class Conversation {
  /// The conversation summary with metadata.
  final ConversationSummary summary;

  final ConversationRouteConfig _config;
  final GraphQLAPIProvider _api;

  /// Creates a conversation instance.
  Conversation({
    required this.summary,
    required ConversationRouteConfig config,
    required GraphQLAPIProvider api,
  })  : _config = config,
        _api = api;

  /// The conversation ID.
  String get id => summary.id;

  /// The conversation name.
  String? get name => summary.name;

  /// When the conversation was created.
  String get createdAt => summary.createdAt;

  /// When the conversation was last updated.
  String get updatedAt => summary.updatedAt;

  /// Sends a message in this conversation.
  ///
  /// For a simple text message:
  /// ```dart
  /// await conversation.sendMessage(SendMessageInput.text('Hello!'));
  /// ```
  ///
  /// For a message with tool configuration or AI context:
  /// ```dart
  /// await conversation.sendMessage(SendMessageInput(
  ///   content: [ContentBlock.text('What is the weather?')],
  ///   toolConfiguration: { ... },
  /// ));
  /// ```
  Future<SingleResult<ConversationMessage>> sendMessage(
      SendMessageInput input) async {
    final variables = <String, dynamic>{
      'conversationId': id,
      'content': input.content.map((c) => c.toJson()).toList(),
    };

    if (input.aiContext != null) {
      variables['aiContext'] = json.encode(input.aiContext);
    }
    if (input.toolConfiguration != null) {
      variables['toolConfiguration'] = input.toolConfiguration;
    }

    final response = await _api.mutate(
      document: docs.sendMessageDocument(_config.sendMessageFieldName),
      variables: variables,
    );

    if (response.hasErrors) {
      return SingleResult(
        errors: response.errors!
            .map((e) => GraphQLResponseError.fromJson(e))
            .toList(),
      );
    }

    final data =
        response.data?[_config.sendMessageFieldName] as Map<String, dynamic>?;
    if (data == null) {
      return const SingleResult();
    }

    return SingleResult(data: ConversationMessage.fromJson(data));
  }

  /// Lists messages in this conversation with optional pagination.
  Future<PaginatedResult<ConversationMessage>> listMessages({
    int? limit,
    String? nextToken,
  }) async {
    final variables = <String, dynamic>{
      'conversationId': id,
    };
    if (limit != null) variables['limit'] = limit;
    if (nextToken != null) variables['nextToken'] = nextToken;

    final response = await _api.query(
      document: docs.listMessagesDocument(_config.listMessagesFieldName),
      variables: variables,
    );

    if (response.data == null) {
      return const PaginatedResult(items: []);
    }

    final listData =
        response.data![_config.listMessagesFieldName] as Map<String, dynamic>?;
    if (listData == null) {
      return const PaginatedResult(items: []);
    }

    final items = (listData['items'] as List<dynamic>?)
            ?.map(
                (e) => ConversationMessage.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PaginatedResult(
      items: items,
      nextToken: listData['nextToken'] as String?,
    );
  }

  /// Lists all messages by exhaustively paginating through all pages.
  Future<List<ConversationMessage>> listAllMessages() async {
    final allMessages = <ConversationMessage>[];
    String? nextToken;

    do {
      final result = await listMessages(nextToken: nextToken);
      allMessages.addAll(result.items);
      nextToken = result.nextToken;
    } while (nextToken != null);

    return allMessages;
  }

  /// Subscribes to streaming events for this conversation.
  ///
  /// Returns a stream of [ConversationStreamEvent] objects that can be
  /// fed to a [StreamReassembler] to build complete content blocks.
  Stream<ConversationStreamEvent> onStreamEvent() {
    final responseStream = _api.subscribe(
      document: docs.onStreamEventDocument(_config.subscribeFieldName),
      variables: {'conversationId': id},
    );

    return responseStream.where((r) => r.data != null).map((response) {
      final eventData =
          response.data![_config.subscribeFieldName] as Map<String, dynamic>;
      return ConversationStreamEvent.fromJson(eventData);
    });
  }
}
