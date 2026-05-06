// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../providers/ai_conversation_provider.dart';
import 'ai_conversation.dart';
import 'ai_conversation_controller.dart';

/// A higher-level convenience widget that wraps [AIConversation] with a
/// provider, mirroring the AmplifyAIConversation connected component pattern.
///
/// This automatically creates a controller and disposes it when the widget
/// is removed.
///
/// Usage (route-name based, like JS):
/// ```dart
/// AmplifyAIConversation(
///   routeName: 'chat',
///   welcomeMessage: 'Hello! Ask me anything.',
/// )
/// ```
///
/// Or with an explicit provider:
/// ```dart
/// AmplifyAIConversation(
///   provider: myProvider,
///   welcomeMessage: 'Hello! Ask me anything.',
/// )
/// ```
class AmplifyAIConversation extends StatefulWidget {
  /// Creates an [AmplifyAIConversation] from a route name.
  ///
  /// Mirrors the JS pattern: `<AIConversation routeName="chat" />`
  const AmplifyAIConversation({
    super.key,
    this.routeName,
    this.provider,
    this.toolHandlers,
    this.welcomeMessage,
    this.avatarBuilder,
    this.messageBuilder,
    this.inputBuilder,
    this.showTypingIndicator = true,
    this.allowAttachments = false,
  }) : assert(
          routeName != null || provider != null,
          'Either routeName or provider must be provided.',
        );

  /// The route name for the conversation (e.g., 'chat').
  /// Mirrors the JS pattern: `useAIConversation('chat')`.
  final String? routeName;

  /// The AI conversation provider to connect to (alternative to routeName).
  final AIConversationProvider? provider;

  /// Tool handlers for client-side tool use.
  final Map<String, ToolHandler>? toolHandlers;

  /// Optional welcome message.
  final String? welcomeMessage;

  /// Custom avatar builder.
  final Widget Function(String role)? avatarBuilder;

  /// Custom message builder.
  final Widget Function(ConversationMessage message)? messageBuilder;

  /// Custom input builder.
  final Widget Function(void Function(String) onSend)? inputBuilder;

  /// Whether to show typing indicator.
  final bool showTypingIndicator;

  /// Whether to allow attachments.
  final bool allowAttachments;

  @override
  State<AmplifyAIConversation> createState() => _AmplifyAIConversationState();
}

class _AmplifyAIConversationState extends State<AmplifyAIConversation> {
  late AIConversationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController();
  }

  @override
  void didUpdateWidget(AmplifyAIConversation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routeName != widget.routeName ||
        oldWidget.provider != widget.provider) {
      _controller.dispose();
      _controller = _createController();
    }
  }

  AIConversationController _createController() {
    return AIConversationController(
      routeName: widget.routeName,
      provider: widget.provider,
      toolHandlers: widget.toolHandlers,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AIConversation(
      controller: _controller,
      welcomeMessage: widget.welcomeMessage,
      avatarBuilder: widget.avatarBuilder,
      messageBuilder: widget.messageBuilder,
      inputBuilder: widget.inputBuilder,
      showTypingIndicator: widget.showTypingIndicator,
      allowAttachments: widget.allowAttachments,
    );
  }
}
