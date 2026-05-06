import 'dart:async';

import '../content/content_block.dart';
import '../content/tool_configuration.dart';
import '../content/tool_use_handler.dart';
import '../graphql/ai_graphql_documents.dart';
import '../graphql/ai_graphql_request_factory.dart';
import '../graphql/ai_graphql_subscription_handler.dart';
import 'conversation.dart';
import 'conversation_message.dart';
import 'conversation_stream_event.dart';

/// A route for AI conversations. Provides methods to create, list,
/// get, delete conversations and send/stream messages.
/// Mirrors the JS AI Kit conversation route pattern.
class ConversationRoute {
  /// Creates a conversation route.
  ConversationRoute({
    required this.routeName,
    required this.graphqlRequestFactory,
    required this.subscriptionHandler,
    this.toolConfiguration,
    this.toolHandler,
  }) : _documents = AIGraphQLDocuments(routeName: routeName);

  /// The name of this conversation route from the AI config.
  final String routeName;

  /// The GraphQL request factory for making API calls.
  final AIGraphQLRequestFactory graphqlRequestFactory;

  /// The subscription handler for streaming events.
  final AIGraphQLSubscriptionHandler subscriptionHandler;

  /// Optional tool configuration for this route.
  final ToolConfiguration? toolConfiguration;

  /// Optional tool handler for processing tool use requests.
  final ToolUseHandler? toolHandler;

  final AIGraphQLDocuments _documents;

  /// Creates a new conversation.
  Future<Conversation> create({String? name}) async {
    final document = _documents.createConversation();
    final variables = <String, dynamic>{
      'input': {
        if (name != null) 'name': name,
      },
    };

    final response = await graphqlRequestFactory.mutate(
      document: document,
      variables: variables,
    );

    final fieldName = _documents.createConversationFieldName;
    return Conversation.fromJson(
      response['data']?[fieldName] as Map<String, dynamic>? ?? {},
    );
  }

  /// Gets a conversation by ID.
  Future<Conversation> get(String conversationId) async {
    final document = _documents.getConversation();
    final variables = <String, dynamic>{
      'id': conversationId,
    };

    final response = await graphqlRequestFactory.query(
      document: document,
      variables: variables,
    );

    final fieldName = _documents.getConversationFieldName;
    return Conversation.fromJson(
      response['data']?[fieldName] as Map<String, dynamic>? ?? {},
    );
  }

  /// Lists all conversations for this route.
  Future<List<Conversation>> list({
    int? limit,
    String? nextToken,
  }) async {
    final document = _documents.listConversations();
    final variables = <String, dynamic>{
      if (limit != null) 'limit': limit,
      if (nextToken != null) 'nextToken': nextToken,
    };

    final response = await graphqlRequestFactory.query(
      document: document,
      variables: variables,
    );

    final fieldName = _documents.listConversationsFieldName;
    final items =
        response['data']?[fieldName]?['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Deletes a conversation by ID.
  Future<void> delete(String conversationId) async {
    final document = _documents.deleteConversation();
    final variables = <String, dynamic>{
      'input': {'id': conversationId},
    };

    await graphqlRequestFactory.mutate(
      document: document,
      variables: variables,
    );
  }

  /// Sends a message to a conversation and returns the assistant's response.
  /// Uses the conversation handler mutation (field name = route name).
  Future<ConversationMessage> sendMessage({
    required String conversationId,
    required List<ContentBlock> content,
    Map<String, dynamic>? aiContext,
    ToolConfiguration? toolConfiguration,
  }) async {
    final effectiveToolConfig = toolConfiguration ?? this.toolConfiguration;
    final document = _documents.sendMessage();
    final variables = <String, dynamic>{
      'conversationId': conversationId,
      'content': content.map((c) => c.toJson()).toList(),
      if (aiContext != null) 'aiContext': aiContext,
      if (effectiveToolConfig != null)
        'toolConfiguration': effectiveToolConfig.toJson(),
    };

    final response = await graphqlRequestFactory.mutate(
      document: document,
      variables: variables,
    );

    final fieldName = _documents.sendMessageFieldName;
    final messageData =
        response['data']?[fieldName] as Map<String, dynamic>? ?? {};
    return ConversationMessage.fromJson(messageData);
  }

  /// Sends a message and returns a stream of events.
  Stream<ConversationStreamEvent> streamMessage({
    required String conversationId,
    required List<ContentBlock> content,
    Map<String, dynamic>? aiContext,
    ToolConfiguration? toolConfiguration,
  }) {
    final effectiveToolConfig = toolConfiguration ?? this.toolConfiguration;
    final document = _documents.sendMessage();
    final subscriptionDocument = _documents.onStreamEvent();

    final variables = <String, dynamic>{
      'conversationId': conversationId,
      'content': content.map((c) => c.toJson()).toList(),
      if (aiContext != null) 'aiContext': aiContext,
      if (effectiveToolConfig != null)
        'toolConfiguration': effectiveToolConfig.toJson(),
    };

    final controller = StreamController<ConversationStreamEvent>();

    _handleStream(
      controller: controller,
      document: document,
      subscriptionDocument: subscriptionDocument,
      variables: variables,
      conversationId: conversationId,
    );

    return controller.stream;
  }

  Future<void> _handleStream({
    required StreamController<ConversationStreamEvent> controller,
    required String document,
    required String subscriptionDocument,
    required Map<String, dynamic> variables,
    required String conversationId,
  }) async {
    try {
      // Subscribe to stream events first
      final subscription = subscriptionHandler.subscribe(
        document: subscriptionDocument,
        variables: {'conversationId': conversationId},
      );

      // Send the mutation to trigger the stream
      await graphqlRequestFactory.mutate(
        document: document,
        variables: variables,
      );

      // Forward subscription events
      await for (final event in subscription) {
        // The subscription data is nested under the operation name
        final fieldName = _documents.onAssistantResponseFieldName;
        final eventData = event[fieldName] as Map<String, dynamic>? ?? event;
        final streamEvent = ConversationStreamEvent.fromJson(eventData);
        controller.add(streamEvent);

        // Handle tool use if handler is registered
        if (streamEvent is ConversationStreamTurnDoneEvent &&
            streamEvent.stopReason == 'tool_use' &&
            toolHandler != null) {
          await _handleToolUseInStream(
            controller: controller,
            conversationId: conversationId,
            event: streamEvent,
          );
        }

        if (streamEvent is ConversationStreamTurnDoneEvent &&
            streamEvent.stopReason != 'tool_use') {
          break;
        }
      }
    } catch (e) {
      controller.addError(e);
    } finally {
      await controller.close();
    }
  }

  Future<void> _handleToolUseInStream({
    required StreamController<ConversationStreamEvent> controller,
    required String conversationId,
    required ConversationStreamTurnDoneEvent event,
  }) async {
    if (toolHandler == null || event.message == null) return;

    final messageContent = event.message!['content'] as List<dynamic>? ?? [];
    final contentBlocks = messageContent
        .map((c) => ContentBlock.fromJson(c as Map<String, dynamic>))
        .toList();

    final toolResults = await toolHandler!.handleToolUses(contentBlocks);

    if (toolResults.isNotEmpty) {
      // Send tool results back as a new message
      final resultContent = toolResults.map((r) => r as ContentBlock).toList();

      final responseStream = streamMessage(
        conversationId: conversationId,
        content: resultContent,
      );

      await for (final responseEvent in responseStream) {
        controller.add(responseEvent);
      }
    }
  }

  /// Lists message history for a conversation.
  Future<List<ConversationMessage>> listMessages(
    String conversationId, {
    int? limit,
    String? nextToken,
  }) async {
    final document = _documents.listMessages();
    final variables = <String, dynamic>{
      'filter': {
        'conversationId': {'eq': conversationId},
      },
      if (limit != null) 'limit': limit,
      if (nextToken != null) 'nextToken': nextToken,
    };

    final response = await graphqlRequestFactory.query(
      document: document,
      variables: variables,
    );

    final fieldName = _documents.listMessagesFieldName;
    final items =
        response['data']?[fieldName]?['items'] as List<dynamic>? ?? [];
    return items
        .map((item) =>
            ConversationMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
