// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../providers/ai_conversation_provider.dart';
import 'ai_conversation.dart';
import 'ai_conversation_controller.dart';

/// A higher-level convenience widget that wraps [AIConversation] with a
/// provider, mirroring the AmplifyAIConversation connected component pattern.
///
/// This automatically creates a controller from the given provider and
/// disposes it when the widget is removed.
///
/// Usage:
/// ```dart
/// AmplifyAIConversation(
///   provider: myProvider,
///   welcomeMessage: 'Hello! Ask me anything.',
/// )
/// ```
class AmplifyAIConversation extends StatefulWidget {
  /// Creates an [AmplifyAIConversation].
  const AmplifyAIConversation({
    super.key,
    required this.provider,
    this.welcomeMessage,
    this.avatarBuilder,
    this.messageBuilder,
    this.inputBuilder,
    this.showTypingIndicator = true,
    this.allowAttachments = false,
  });

  /// The AI conversation provider to connect to.
  final AIConversationProvider provider;

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
    _controller = AIConversationController(provider: widget.provider);
  }

  @override
  void didUpdateWidget(AmplifyAIConversation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      _controller.dispose();
      _controller = AIConversationController(provider: widget.provider);
    }
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
