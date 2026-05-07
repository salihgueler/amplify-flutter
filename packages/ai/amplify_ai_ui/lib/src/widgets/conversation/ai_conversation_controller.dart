// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:amplify_ai/amplify_ai.dart' as ai;
import 'package:flutter/foundation.dart';

import '../../providers/ai_conversation_provider.dart';
import '../../state/content_from_events.dart';

/// Controller for an AI conversation — mirrors useAIConversation hook.
///
/// Manages the conversation lifecycle including sending messages,
/// receiving streaming responses, and handling tool-use cycles.
///
/// Usage (route-name based — zero config, like JS `useAIConversation('chat')`):
/// ```dart
/// final controller = AIConversationController(routeName: 'chat');
/// ```
///
/// The controller automatically resolves the route from [AmplifyAI.instance].
/// No manual wiring needed.
class AIConversationController extends ChangeNotifier {
  /// Creates an [AIConversationController] from a route name.
  ///
  /// This mirrors the JS pattern: `useAIConversation('chat')`.
  /// Automatically resolves the [ConversationRoute] from [AmplifyAI.instance].
  ///
  /// If [conversationId] is provided, loads existing messages to resume
  /// a previous conversation.
  factory AIConversationController({
    String? routeName,
    AIConversationProvider? provider,
    Map<String, ToolHandler>? toolHandlers,
    String? conversationId,
  }) {
    assert(
      routeName != null || provider != null,
      'Either routeName or provider must be provided.',
    );

    // If routeName is given, create a ConversationRoute directly
    ai.ConversationRoute? conversationRoute;
    if (routeName != null) {
      conversationRoute = ai.ConversationRoute(routeName: routeName);
    }

    final effectiveProvider = provider ??
        AIConversationProvider(
          conversationRoute: conversationRoute,
          conversationId: conversationId,
          toolHandlers: toolHandlers ?? const {},
        );
    final controller = AIConversationController._(provider: effectiveProvider);

    // If conversationId is provided, load the existing messages
    if (conversationId != null) {
      controller._loadHistory(conversationId);
    }

    return controller;
  }

  AIConversationController._({
    required AIConversationProvider provider,
  }) : _provider = provider {
    _provider.addListener(_onProviderChanged);
  }

  final AIConversationProvider _provider;

  /// The underlying provider (for advanced usage).
  AIConversationProvider get provider => _provider;

  /// The list of messages in this conversation.
  List<ConversationMessage> get messages => _provider.messages;

  /// Whether the assistant is currently responding.
  bool get isLoading => _provider.isLoading;

  /// Whether the assistant is currently streaming a response.
  bool get isStreaming => _provider.isStreaming;

  /// The current streaming text (partial response).
  String get streamingText => _provider.streamingText;

  /// The current error, if any.
  Object? get error => _provider.error;

  /// Sends a user message.
  Future<void> sendMessage(String text, {List<ContentBlock>? attachments}) async {
    await _provider.sendMessage(text, attachments: attachments);
  }

  /// Clears all messages.
  void clearMessages() {
    _provider.clearMessages();
  }

  /// Loads history messages for the given conversation ID.
  Future<void> _loadHistory(String conversationId) async {
    await _provider.loadMessages(conversationId);
  }

  /// Loads history messages for a conversation (public API for resuming).
  Future<void> loadHistory(String conversationId) async {
    await _provider.loadMessages(conversationId);
  }

  void _onProviderChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    super.dispose();
  }
}
