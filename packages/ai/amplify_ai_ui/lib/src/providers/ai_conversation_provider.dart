// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:amplify_ai/amplify_ai.dart' as ai;
import 'package:flutter/foundation.dart';

import '../state/content_from_events.dart';

/// Callback for handling tool use requests from the AI.
typedef ToolHandler = Future<ToolResultContent> Function(ToolUseContent toolUse);

/// A message in a conversation.
@immutable
class ConversationMessage {
  /// Creates a [ConversationMessage].
  const ConversationMessage({
    required this.id,
    required this.role,
    required this.content,
    this.createdAt,
    this.isStreaming = false,
  });

  /// Unique message ID.
  final String id;

  /// The role: 'user' or 'assistant'.
  final String role;

  /// The content blocks of the message.
  final List<ContentBlock> content;

  /// When the message was created.
  final DateTime? createdAt;

  /// Whether this message is currently being streamed.
  final bool isStreaming;

  /// Creates a copy with modified fields.
  ConversationMessage copyWith({
    String? id,
    String? role,
    List<ContentBlock>? content,
    DateTime? createdAt,
    bool? isStreaming,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}

/// Provider that manages an AI conversation — mirrors useAIConversation hook.
///
/// Handles sending messages, receiving streaming responses, and
/// coordinating tool-use cycles.
///
/// When a [conversationRoute] is provided (resolved from [AmplifyAI.instance]),
/// messages are sent via the real GraphQL backend. Otherwise operates in
/// local-only mode for testing.
class AIConversationProvider extends ChangeNotifier {
  /// Creates an [AIConversationProvider].
  AIConversationProvider({
    this.conversationRoute,
    this.conversationId,
    this.onMessage,
    this.onError,
    this.toolHandlers = const {},
  });

  /// The conversation route (resolved from AmplifyAI.instance).
  final ai.ConversationRoute? conversationRoute;

  /// The conversation ID (if resuming an existing conversation).
  final String? conversationId;

  /// Callback when a complete message is received.
  final ValueChanged<ConversationMessage>? onMessage;

  /// Callback when an error occurs.
  final ValueChanged<Object>? onError;

  /// Map of tool name to handler function.
  final Map<String, ToolHandler> toolHandlers;

  /// The list of messages in this conversation.
  List<ConversationMessage> get messages => List.unmodifiable(_messages);
  final List<ConversationMessage> _messages = [];

  /// Current streaming text (partial response).
  String get streamingText => _streamingText;
  String _streamingText = '';

  /// Whether the assistant is currently responding.
  bool get isLoading => _isLoading;
  bool _isLoading = false;

  /// Whether the assistant is currently streaming a response.
  bool get isStreaming => _isStreaming;
  bool _isStreaming = false;

  /// The current error, if any.
  Object? get error => _error;
  Object? _error;

  /// The active conversation ID (created or resumed).
  String? _activeConversationId;

  /// Content block accumulator for building streamed responses.
  final ContentBlockAccumulator _accumulator = ContentBlockAccumulator();

  /// Sends a user message and begins receiving a streamed response.
  ///
  /// Mirrors the sendMessage action from useAIConversation.
  Future<void> sendMessage(String text, {List<ContentBlock>? attachments}) async {
    _error = null;

    // Add user message
    final userMessage = ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: [
        ContentBlock.text(text),
        if (attachments != null) ...attachments,
      ],
      createdAt: DateTime.now(),
    );
    _messages.add(userMessage);
    _isLoading = true;
    _isStreaming = false;
    _streamingText = '';
    _accumulator.reset();
    notifyListeners();

    try {
      if (conversationRoute != null) {
        await _processWithRoute(text);
      } else {
        // No route configured — finalize with empty response
        _finalizeAssistantMessage();
      }
    } catch (e) {
      _error = e;
      _isLoading = false;
      _isStreaming = false;
      onError?.call(e);
      notifyListeners();
    }
  }

  /// Processes a message using the actual ConversationRoute from AmplifyAI.
  Future<void> _processWithRoute(String userText) async {
    _isStreaming = true;
    notifyListeners();

    final route = conversationRoute!;

    // Create conversation if needed
    _activeConversationId ??= conversationId;
    if (_activeConversationId == null) {
      final conversation = await route.create();
      _activeConversationId = conversation.id;
    }

    // Stream the message using the amplify_ai ContentBlock type
    final stream = route.streamMessage(
      conversationId: _activeConversationId!,
      content: [ai.ContentBlock.text(userText)],
    );

    await for (final event in stream) {
      if (event is ai.ConversationStreamTextEvent) {
        handleTextDelta(event.text);
      } else if (event is ai.ConversationStreamToolUseEvent) {
        final toolUse = ToolUseContent(
          toolUseId: event.toolUse.toolUseId,
          name: event.toolUse.name,
          input: event.toolUse.input,
        );
        await handleToolUse(toolUse);
      } else if (event is ai.ConversationStreamTurnDoneEvent) {
        _finalizeAssistantMessage();
        break;
      }
    }
  }

  /// Handles a text delta event from streaming.
  void handleTextDelta(String delta) {
    _accumulator.addTextDelta(delta);
    _streamingText = _accumulator.currentText;
    notifyListeners();
  }

  /// Handles a tool-use request from the assistant.
  Future<void> handleToolUse(ToolUseContent toolUse) async {
    _accumulator.addToolUseBlock(toolUse);
    notifyListeners();

    final handler = toolHandlers[toolUse.name];
    if (handler != null) {
      try {
        final result = await handler(toolUse);
        _accumulator.addToolResultBlock(result);
        notifyListeners();
      } catch (e) {
        final errorResult = ToolResultContent(
          toolUseId: toolUse.toolUseId,
          status: ToolResultStatus.error,
          content: e.toString(),
        );
        _accumulator.addToolResultBlock(errorResult);
        notifyListeners();
      }
    }
  }

  /// Finalizes the current assistant message after streaming completes.
  void _finalizeAssistantMessage() {
    _accumulator.finalizeTextBlock();

    if (_accumulator.blocks.isNotEmpty) {
      final assistantMessage = ConversationMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: List.from(_accumulator.blocks),
        createdAt: DateTime.now(),
      );
      _messages.add(assistantMessage);
      onMessage?.call(assistantMessage);
    }

    _isLoading = false;
    _isStreaming = false;
    _streamingText = '';
    _accumulator.reset();
    notifyListeners();
  }

  /// Clears the conversation history.
  void clearMessages() {
    _messages.clear();
    _streamingText = '';
    _error = null;
    _activeConversationId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messages.clear();
    super.dispose();
  }
}
