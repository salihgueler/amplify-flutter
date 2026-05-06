import 'dart:async';
import 'dart:convert';

import 'package:amplify_core/amplify_core.dart';

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

  /// Optional tool configuration for this route.
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
        'input': {
          if (name != null) 'name': name,
        },
      },
    );

    final response = await Amplify.API.mutate(request: request).response;
    if (response.errors.isNotEmpty) {
      throw Exception('GraphQL errors: ${response.errors.map((e) => e.message).join(', ')}');
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
      throw Exception('GraphQL errors: ${response.errors.map((e) => e.message).join(', ')}');
    }

    final data = response.data != null
        ? jsonDecode(response.data!) as Map<String, dynamic>
        : <String, dynamic>{};
    final fieldName = _documents.listConversationsFieldName;
    final items = (data['data']?[fieldName]?['items'] ??
        data[fieldName]?['items'] ??
        []) as List;
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
      throw Exception('GraphQL errors: ${response.errors.map((e) => e.message).join(', ')}');
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
      variables: {'input': {'id': conversationId}},
    );

    final response = await Amplify.API.mutate(request: request).response;
    if (response.errors.isNotEmpty) {
      throw Exception('GraphQL errors: ${response.errors.map((e) => e.message).join(', ')}');
    }
  }

  /// Lists messages in a conversation.
  Future<List<ConversationMessage>> listMessages(String conversationId) async {
    final document = _documents.listMessages();
    final request = GraphQLRequest<String>(
      document: document,
      variables: {
        'filter': {'conversationId': {'eq': conversationId}},
      },
    );

    final response = await Amplify.API.query(request: request).response;
    if (response.errors.isNotEmpty) {
      throw Exception('GraphQL errors: ${response.errors.map((e) => e.message).join(', ')}');
    }

    final data = response.data != null
        ? jsonDecode(response.data!) as Map<String, dynamic>
        : <String, dynamic>{};
    final fieldName = _documents.listMessagesFieldName;
    final items = (data['data']?[fieldName]?['items'] ??
        data[fieldName]?['items'] ??
        []) as List;
    return items
        .map((item) => ConversationMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Sends a message and returns a stream of response events.
  Stream<ConversationStreamEvent> sendMessage({
    required String conversationId,
    required List<ContentBlock> content,
    List<ContentBlock>? toolResult,
  }) {
    final controller = StreamController<ConversationStreamEvent>();

    _sendAndStream(
      conversationId: conversationId,
      content: content,
      toolResult: toolResult,
      controller: controller,
    );

    return controller.stream;
  }

  Future<void> _sendAndStream({
    required String conversationId,
    required List<ContentBlock> content,
    List<ContentBlock>? toolResult,
    required StreamController<ConversationStreamEvent> controller,
  }) async {
    try {
      // Subscribe first
      final subscriptionDoc = _documents.onCreateAssistantResponse();
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

      // Send the message
      final mutationDoc = _documents.createMessage();
      final mutationRequest = GraphQLRequest<String>(
        document: mutationDoc,
        variables: {
          'input': {
            'conversationId': conversationId,
            'content': content.map((c) => c.toJson()).toList(),
            if (toolResult != null)
              'toolResult': toolResult.map((c) => c.toJson()).toList(),
          },
        },
      );

      await Amplify.API.mutate(request: mutationRequest).response;

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

        // Close when done
        if (streamEvent.stopReason != null) {
          await controller.close();
          break;
        }
      }
    } catch (e) {
      controller.addError(e);
      await controller.close();
    }
  }
}
