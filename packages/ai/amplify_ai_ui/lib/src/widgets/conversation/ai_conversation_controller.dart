// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:amplify_ai/amplify_ai.dart';
import 'package:flutter/foundation.dart';

/// The current state of the conversation UI.
enum ConversationState {
  /// Idle — no active operations.
  idle,

  /// Currently sending a message.
  sending,

  /// Receiving streaming response from the assistant.
  streaming,

  /// An error occurred.
  error,

  /// Loading message history.
  loading,
}

/// Controller for managing AI conversation state.
///
/// This is a [ChangeNotifier] that holds the current messages, streaming
/// state, and provides methods for sending messages and managing the
/// conversation lifecycle.
///
/// ```dart
/// final controller = AIConversationController(
///   conversationClient: aiPlugin.getConversationClient('myRoute'),
/// );
///
/// // Load or create a conversation
/// await controller.loadConversation(conversationId: 'abc123');
///
/// // Send a message
/// await controller.sendMessage('Hello!');
///
/// // Listen for state changes
/// controller.addListener(() {
///   print('State: ${controller.state}');
/// });
/// ```
class AIConversationController extends ChangeNotifier {
  /// The underlying conversation client.
  final ConversationClient conversationClient;

  /// The current list of messages (newest last).
  List<ConversationMessage> get messages => List.unmodifiable(_messages);
  final List<ConversationMessage> _messages = [];

  /// The currently streaming text (accumulated from stream events).
  String get streamingText => _streamingText;
  String _streamingText = '';

  /// Current state of the conversation.
  ConversationState get state => _state;
  ConversationState _state = ConversationState.idle;

  /// The active conversation, if any.
  Conversation? get conversation => _conversation;
  Conversation? _conversation;

  /// The last error message, if state is [ConversationState.error].
  String? get errorMessage => _errorMessage;
  String? _errorMessage;

  /// Whether the controller is currently streaming a response.
  bool get isStreaming => _state == ConversationState.streaming;

  /// Whether the controller is sending a message.
  bool get isSending => _state == ConversationState.sending;

  /// Whether the controller is loading.
  bool get isLoading => _state == ConversationState.loading;

  StreamSubscription<ConversationStreamEvent>? _streamSubscription;

  /// Creates a controller with the given conversation client.
  AIConversationController({required this.conversationClient});

  /// Loads an existing conversation by ID, or creates a new one.
  ///
  /// If [conversationId] is provided, fetches that conversation and its
  /// message history. Otherwise, creates a new conversation.
  Future<void> loadConversation({String? conversationId, String? name}) async {
    _setState(ConversationState.loading);
    _errorMessage = null;

    try {
      if (conversationId != null) {
        final result = await conversationClient.get(id: conversationId);
        if (result.hasErrors) {
          _setError(result.errors!.first.message);
          return;
        }
        _conversation = result.data;
      } else {
        final result = await conversationClient.create(name: name);
        if (result.hasErrors) {
          _setError(result.errors!.first.message);
          return;
        }
        _conversation = result.data;
      }

      if (_conversation != null) {
        await _loadMessages();
        _subscribeToStream();
      }

      _setState(ConversationState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Sends a text message in the current conversation.
  ///
  /// Automatically creates a conversation if one doesn't exist.
  Future<void> sendMessage(String text) async {
    await sendMessageInput(SendMessageInput.text(text));
  }

  /// Sends a [SendMessageInput] in the current conversation.
  ///
  /// This allows sending messages with images, tool configs, etc.
  Future<void> sendMessageInput(SendMessageInput input) async {
    if (_conversation == null) {
      await loadConversation();
      if (_conversation == null) return;
    }

    _setState(ConversationState.sending);
    _errorMessage = null;
    _streamingText = '';

    // Add an optimistic user message to the UI
    final userMessage = ConversationMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: _conversation!.id,
      content: input.content,
      role: ConversationParticipantRole.user,
      createdAt: DateTime.now().toIso8601String(),
    );
    _messages.add(userMessage);
    notifyListeners();

    try {
      final result = await _conversation!.sendMessage(input);
      if (result.hasErrors) {
        _setError(result.errors!.first.message);
        return;
      }

      // Replace optimistic message with actual message from server
      if (result.data != null) {
        _messages.removeLast();
        _messages.add(result.data!);
      }

      _setState(ConversationState.streaming);
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Clears the current conversation and resets state.
  void reset() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _conversation = null;
    _messages.clear();
    _streamingText = '';
    _errorMessage = null;
    _setState(ConversationState.idle);
  }

  /// Stops the current streaming response.
  void stopStreaming() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    if (_streamingText.isNotEmpty) {
      _finalizeStreamingMessage();
    }
    _setState(ConversationState.idle);
  }

  Future<void> _loadMessages() async {
    if (_conversation == null) return;

    final allMessages = await _conversation!.listAllMessages();
    _messages.clear();
    _messages.addAll(allMessages);
    notifyListeners();
  }

  void _subscribeToStream() {
    if (_conversation == null) return;

    _streamSubscription?.cancel();
    _streamSubscription = _conversation!.onStreamEvent().listen(
      _handleStreamEvent,
      onError: (Object error) {
        _setError(error.toString());
      },
    );
  }

  void _handleStreamEvent(ConversationStreamEvent event) {
    if (event.hasError) {
      _setError(event.errors!.first.message);
      return;
    }

    if (event.isTextDelta) {
      _streamingText += event.contentBlockText!;
      if (_state != ConversationState.streaming) {
        _setState(ConversationState.streaming);
      }
      notifyListeners();
    }

    if (event.isTurnComplete) {
      _finalizeStreamingMessage();
      _setState(ConversationState.idle);
    }
  }

  void _finalizeStreamingMessage() {
    if (_streamingText.isNotEmpty) {
      final assistantMessage = ConversationMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: _conversation!.id,
        content: [ContentBlock.text(_streamingText)],
        role: ConversationParticipantRole.assistant,
        createdAt: DateTime.now().toIso8601String(),
      );
      _messages.add(assistantMessage);
      _streamingText = '';
    }
    notifyListeners();
  }

  void _setState(ConversationState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(ConversationState.error);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
