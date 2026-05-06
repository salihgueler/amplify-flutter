// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/foundation.dart';

import '../../providers/ai_conversation_provider.dart';
import '../../state/content_from_events.dart';

/// Controller for an AI conversation — mirrors useAIConversation hook.
///
/// Manages the conversation lifecycle including sending messages,
/// receiving streaming responses, and handling tool-use cycles.
///
/// Usage (route-name based, like JS `useAIConversation('chat')`):
/// ```dart
/// final controller = AIConversationController(routeName: 'chat');
/// ```
///
/// Or with an explicit provider:
/// ```dart
/// final controller = AIConversationController(
///   provider: myConversationProvider,
/// );
/// ```
class AIConversationController extends ChangeNotifier {
  /// Creates an [AIConversationController] from a route name.
  ///
  /// This mirrors the JS pattern: `useAIConversation('chat')`.
  /// Automatically creates an [AIConversationProvider] for the route.
  factory AIConversationController({
    String? routeName,
    AIConversationProvider? provider,
    Map<String, ToolHandler>? toolHandlers,
  }) {
    assert(
      routeName != null || provider != null,
      'Either routeName or provider must be provided.',
    );
    final effectiveProvider = provider ??
        AIConversationProvider(
          toolHandlers: toolHandlers ?? const {},
        );
    return AIConversationController._(provider: effectiveProvider);
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

  void _onProviderChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    super.dispose();
  }
}
