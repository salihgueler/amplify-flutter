// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../state/ai_client_state.dart';
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
class AIConversationProvider extends ChangeNotifier {
  /// Creates an [AIConversationProvider].
  AIConversationProvider({
    this.conversationId,
    this.onMessage,
    this.onError,
    this.toolHandlers = const {},
  });

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

    // Simulated streaming — in real usage this connects to ConversationRoute
    // The actual implementation would call:
    // conversationRoute.sendMessage(text) and subscribe to the stream
    try {
      await _processStream(text);
    } catch (e) {
      _error = e;
      _isLoading = false;
      _isStreaming = false;
      onError?.call(e);
      notifyListeners();
    }
  }

  /// Processes a stream of events from the backend.
  Future<void> _processStream(String userText) async {
    _isStreaming = true;
    notifyListeners();

    // This is the integration point where the actual streaming
    // subscription would be connected. The pattern mirrors the JS:
    //
    // subscription = conversationRoute.onStreamEvent((event) {
    //   if (event.contentBlockDelta) handleDelta(event);
    //   if (event.toolUse) handleToolUse(event);
    //   if (event.stop) handleStop(event);
    // });
    //
    // For now we finalize as a placeholder.
    _finalizeAssistantMessage();
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
        // In full impl, send tool result back to continue the conversation
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
    notifyListeners();
  }

  @override
  void dispose() {
    _messages.clear();
    super.dispose();
  }
}
