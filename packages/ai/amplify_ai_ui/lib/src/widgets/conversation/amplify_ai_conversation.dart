// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../providers/ai_conversation_provider.dart';
import '../../theme/ai_theme.dart';
import 'ai_conversation_controller.dart';
import 'message_list.dart';
import 'streaming_text.dart';
import 'typing_indicator.dart';
import '../input/ai_message_input.dart';

/// A drop-in AI conversation widget.
///
/// Provides a complete chat UI with message list, streaming responses,
/// typing indicators, and message input. Fully customizable via
/// [AITheme] and builder callbacks.
///
/// ```dart
/// AmplifyAIConversation(
///   controller: AIConversationController(
///     conversationClient: aiPlugin.getConversationClient('myRoute'),
///   ),
/// )
/// ```
class AmplifyAIConversation extends StatefulWidget {
  /// The controller managing conversation state.
  final AIConversationController controller;

  /// Optional custom message bubble builder.
  final Widget Function(BuildContext context, ConversationDisplayMessage message)?
      messageBubbleBuilder;

  /// Optional custom input widget builder.
  final Widget Function(BuildContext context, AIConversationController controller)?
      inputBuilder;

  /// Optional widget displayed when the message list is empty.
  final Widget? emptyStateWidget;

  /// Optional header widget displayed above the message list.
  final Widget? headerWidget;

  /// Whether to show the typing indicator while streaming.
  final bool showTypingIndicator;

  /// Whether to auto-scroll to the bottom on new messages.
  final bool autoScrollToBottom;

  /// Padding around the message list.
  final EdgeInsets? listPadding;

  const AmplifyAIConversation({
    super.key,
    required this.controller,
    this.messageBubbleBuilder,
    this.inputBuilder,
    this.emptyStateWidget,
    this.headerWidget,
    this.showTypingIndicator = true,
    this.autoScrollToBottom = true,
    this.listPadding,
  });

  @override
  State<AmplifyAIConversation> createState() => _AmplifyAIConversationState();
}

class _AmplifyAIConversationState extends State<AmplifyAIConversation> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(AmplifyAIConversation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return AIConversationProvider(
      controller: widget.controller,
      child: Container(
        color: theme.surfaceColor,
        child: Column(
          children: [
            if (widget.headerWidget != null) widget.headerWidget!,
            Expanded(
              child: _buildMessageArea(context, theme),
            ),
            _buildStreamingArea(context, theme),
            _buildInputArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageArea(BuildContext context, AIThemeData theme) {
    final messages = widget.controller.messages;

    if (messages.isEmpty && widget.controller.state == ConversationState.idle) {
      return widget.emptyStateWidget ??
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: theme.assistantTextColor.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start a conversation',
                    style: theme.messageTextStyle.copyWith(
                      color: theme.assistantTextColor.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    return MessageList(
      messages: messages,
      autoScrollToBottom: widget.autoScrollToBottom,
      padding: widget.listPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      messageBubbleBuilder: widget.messageBubbleBuilder,
    );
  }

  Widget _buildStreamingArea(BuildContext context, AIThemeData theme) {
    if (!widget.controller.isStreaming) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.controller.streamingText.isNotEmpty)
            StreamingText(
              text: widget.controller.streamingText,
            ),
          if (widget.showTypingIndicator &&
              widget.controller.streamingText.isEmpty)
            const TypingIndicator(),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    if (widget.inputBuilder != null) {
      return widget.inputBuilder!(context, widget.controller);
    }
    return AIMessageInput(
      onSend: (text) => widget.controller.sendMessage(text),
      enabled: !widget.controller.isSending && !widget.controller.isStreaming,
    );
  }
}

/// A display-friendly representation of a conversation message for builders.
class ConversationDisplayMessage {
  /// The underlying message data.
  final dynamic message;

  /// Whether this is a user message.
  final bool isUser;

  /// The display text (concatenated text content blocks).
  final String text;

  const ConversationDisplayMessage({
    required this.message,
    required this.isUser,
    required this.text,
  });
}
