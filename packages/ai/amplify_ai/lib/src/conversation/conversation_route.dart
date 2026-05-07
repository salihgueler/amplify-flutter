import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';

import '../content/content_block.dart';
import '../content/tool_configuration.dart';
import '../content/tool_use_handler.dart';
import '../graphql/ai_graphql_documents.dart';
import 'conversation.dart';
import 'conversation_message.dart';
import 'conversation_stream_event.dart';

/// A route for AI conversations. Uses Amplify.API directly — no manual wiring needed.
///
/// Usage:
/// ```dart
/// final chat = ConversationRoute(routeName: 'chat');
/// final conversation = await chat.create();
/// ```
class ConversationRoute {
  /// Creates a conversation route that uses Amplify.API directly.
  ConversationRoute({
    required this.routeName,
    this.toolConfiguration,
    this.toolHandler,
  }) : _documents = AIGraphQLDocuments(routeName: routeName);

  /// The name of this conversation route from the AI config.
  final String routeName;

  /// Optional default tool configuration for this route.
  /// Can be overridden per-message in [sendMessage].
  final ToolConfiguration? toolConfiguration;

  /// Optional tool handler for processing tool use requests.
  final ToolUseHandler? toolHandler;

  final AIGraphQLDocuments _documents;

  /// Creates a new conversation.
  Future<Conversation> create({String? name}) async {
    final document = _documents.createConversation();
    final request = GraphQLRequest<String>(
      document: document,
      variables: {
        'input': {if (name != null) 'name': name},
      },
    );

    final response = await Amplify.API.mutate(request: request).response;
    if (response.errors.isNotEmpty) {
      throw Exception(
        'GraphQL errors: ${response.errors.map((e) => e.message).join(', ')}',
      );
    }

    final data = response.data != null
        ? jsonDecode(response.data!) as Map<String, dynamic>
        : <String, dynamic>{};
    final fieldName = _documents.createConversationFieldName;
    return Conversation.fromJson(
      data['data']?[fieldName] as Map<String, dynamic>? ??
          data[fieldName] as Map<String, dynamic>? ??
          {},
    );
  }

  /// Lists all conversations.
  Future<List<Conversation>> list() async {
    final document = _documents.listConversations();
    final request = GraphQLRequest<String>(document: document);

    final response = await Amplify.API.query(request: request).response;
    if (response.errors.isNotEmpty) {
      throw Exception(
        'GraphQL errors: ${response.errors.map((e) => e.message).join(', ')}',
      );
    }

    final data = response.data != null
        ? jsonDecode(response.data!) as Map<String, dynamic>
        : <String, dynamic>{};
    final fieldName = _documents.listConversationsFieldName;
    final items =
        (data['data']?[fieldName]?['items'] ?? data[fieldName]?['items'] ?? [])
            as List;
    return items
        .map((item) => Conversation.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Gets a conversation by ID.
  Future<Conversation> get(String conversationId) async {
    final document = _documents.getConversation();
    final request = GraphQLRequest<String>(
      document: document,
      variables: {'id': conversationId},
    );

    final response = await Amplify.API.query(request: request).response;
    if (response.errors.isNotEmpty) {
      throw Exception(
        'GraphQL errors: ${response.errors.map((e) => e.message).join(', ')}',
      );
    }

    final data = response.data != null
        ? jsonDecode(response.data!) as Map<String, dynamic>
        : <String, dynamic>{};
    final fieldName = _documents.getConversationFieldName;
    return Conversation.fromJson(
      data['data']?[fieldName] as Map<String, dynamic>? ??
          data[fieldName] as Map<String, dynamic>? ??
          {},
    );
  }

  /// Deletes a conversation.
  Future<void> delete(String conversationId) async {
    final document = _documents.deleteConversation();
    final request = GraphQLRequest<String>(
      document: document,
      variables: {
        'input': {'id': conversationId},
      },
    );

    final response = await Amplify.API.mutate(request: request).response;
    if (response.errors.isNotEmpty) {
      throw Exception(
        'GraphQL errors: ${response.errors.map((e) => e.message).join(', ')}',
      );
    }
  }

  /// Lists messages in a conversation.
  Future<List<ConversationMessage>> listMessages(String conversationId) async {
    final document = _documents.listMessages();
    final request = GraphQLRequest<String>(
      document: document,
      variables: {
        'filter': {
          'conversationId': {'eq': conversationId},
        },
      },
    );

    final response = await Amplify.API.query(request: request).response;
    if (response.errors.isNotEmpty) {
      throw Exception(
        'GraphQL errors: ${response.errors.map((e) => e.message).join(', ')}',
      );
    }

    final data = response.data != null
        ? jsonDecode(response.data!) as Map<String, dynamic>
        : <String, dynamic>{};
    final fieldName = _documents.listMessagesFieldName;
    final items =
        (data['data']?[fieldName]?['items'] ?? data[fieldName]?['items'] ?? [])
            as List;
    final messages = items
        .map(
          (item) => ConversationMessage.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    // Sort messages by createdAt in chronological order
    messages.sort((a, b) {
      final aTime = a.createdAt ?? DateTime(0);
      final bTime = b.createdAt ?? DateTime(0);
      return aTime.compareTo(bTime);
    });
    return messages;
  }

  /// Sends a message and returns a stream of response events.
  ///
  /// The [toolConfiguration] parameter allows passing tool configuration
  /// with the message. If not provided, uses the route-level toolConfiguration.
  /// The [aiContext] parameter allows passing additional AI context as JSON.
  /// The [toolHandler] parameter allows passing a per-call tool handler that
  /// overrides the route-level handler for this message's tool-use cycle.
  Stream<ConversationStreamEvent> sendMessage({
    required String conversationId,
    required List<ContentBlock> content,
    ToolConfiguration? toolConfiguration,
    Map<String, dynamic>? aiContext,
    ToolUseHandler? toolHandler,
  }) {
    final controller = StreamController<ConversationStreamEvent>();
    final effectiveToolHandler = toolHandler ?? this.toolHandler;

    _sendAndStream(
      conversationId: conversationId,
      content: content,
      toolConfiguration: toolConfiguration ?? this.toolConfiguration,
      aiContext: aiContext,
      controller: controller,
      toolHandler: effectiveToolHandler,
    );

    return controller.stream;
  }

  Future<void> _sendAndStream({
    required String conversationId,
    required List<ContentBlock> content,
    ToolConfiguration? toolConfiguration,
    Map<String, dynamic>? aiContext,
    required StreamController<ConversationStreamEvent> controller,
    ToolUseHandler? toolHandler,
  }) async {
    try {
      await _doSendAndStream(
        conversationId: conversationId,
        content: content,
        toolConfiguration: toolConfiguration,
        aiContext: aiContext,
        controller: controller,
        toolHandler: toolHandler,
      );
    } catch (e) {
      controller.addError(e);
      await controller.close();
    }
  }

  Future<void> _doSendAndStream({
    required String conversationId,
    required List<ContentBlock> content,
    ToolConfiguration? toolConfiguration,
    Map<String, dynamic>? aiContext,
    required StreamController<ConversationStreamEvent> controller,
    ToolUseHandler? toolHandler,
  }) async {
    // Subscribe first
    final subscriptionDoc = _documents.onStreamEvent();
    final subscriptionRequest = GraphQLRequest<String>(
      document: subscriptionDoc,
      variables: {'conversationId': conversationId},
    );

    final subscription = Amplify.API.subscribe(
      subscriptionRequest,
      onEstablished: () {
        safePrint('AI subscription established for $routeName');
      },
    );

    // Send the message - variables are passed directly (not wrapped in "input")
    final mutationDoc = _documents.sendMessage();
    final mutationRequest = GraphQLRequest<String>(
      document: mutationDoc,
      variables: {
        'conversationId': conversationId,
        'content': content.map((c) => c.toJson()).toList(),
        if (aiContext != null) 'aiContext': jsonEncode(aiContext),
        if (toolConfiguration != null)
          'toolConfiguration': toolConfiguration.toJson(),
      },
    );

    await Amplify.API.mutate(request: mutationRequest).response;

    // Collect tool use events for the tool cycle
    final pendingToolUses = <ToolUseContentBlock>[];

    // Listen to subscription events
    await for (final event in subscription) {
      if (event.data == null) continue;
      final data = jsonDecode(event.data!) as Map<String, dynamic>;
      final fieldName = _documents.onAssistantResponseFieldName;
      final eventData = data['data']?[fieldName] ?? data[fieldName] ?? data;
      final streamEvent = ConversationStreamEvent.fromJson(
        eventData as Map<String, dynamic>,
      );
      controller.add(streamEvent);

      // Collect tool use events
      if (streamEvent is ConversationStreamToolUseEvent) {
        pendingToolUses.add(streamEvent.toolUse);
      }

      // Handle turn done
      if (streamEvent is ConversationStreamTurnDoneEvent) {
        // If stopReason is 'tool_use' and we have a handler, execute tools
        // and send results back to continue the conversation
        if (streamEvent.stopReason == 'tool_use' &&
            toolHandler != null &&
            pendingToolUses.isNotEmpty) {
          final toolResults = <ContentBlock>[];
          for (final toolUse in pendingToolUses) {
            final result = await toolHandler.handleToolUse(toolUse);
            toolResults.add(result);
          }
          pendingToolUses.clear();

          // Send tool results back and continue streaming
          await _doSendAndStream(
            conversationId: conversationId,
            content: toolResults,
            toolConfiguration: toolConfiguration,
            aiContext: aiContext,
            controller: controller,
            toolHandler: toolHandler,
          );
        } else {
          await controller.close();
        }
        break;
      }
    }
  }
}
