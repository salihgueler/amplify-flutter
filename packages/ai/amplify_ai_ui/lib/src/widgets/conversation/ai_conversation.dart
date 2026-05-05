// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../providers/ai_conversation_provider.dart';
import '../../theme/ai_theme.dart';
import '../common/content_block_renderer.dart';
import '../input/ai_message_input.dart';
import 'ai_conversation_controller.dart';
import 'message_list.dart';
import 'typing_indicator.dart';

/// A drop-in AI conversation widget — mirrors the AIConversation component.
///
/// Renders a full chat interface with message list, typing indicator,
/// input field, and auto-scroll behavior.
///
/// Usage:
/// ```dart
/// AIConversation(
///   controller: myController,
///   welcomeMessage: 'How can I help you today?',
/// )
/// ```
class AIConversation extends StatefulWidget {
  /// Creates an [AIConversation] widget.
  const AIConversation({
    super.key,
    required this.controller,
    this.welcomeMessage,
    this.avatarBuilder,
    this.messageBuilder,
    this.inputBuilder,
    this.showTypingIndicator = true,
    this.allowAttachments = false,
  });

  /// The conversation controller.
  final AIConversationController controller;

  /// Optional welcome message shown when conversation is empty.
  final String? welcomeMessage;

  /// Custom avatar builder for messages.
  final Widget Function(String role)? avatarBuilder;

  /// Custom message builder.
  final Widget Function(ConversationMessage message)? messageBuilder;

  /// Custom input builder.
  final Widget Function(void Function(String) onSend)? inputBuilder;

  /// Whether to show the typing indicator when assistant is responding.
  final bool showTypingIndicator;

  /// Whether to allow file attachments.
  final bool allowAttachments;

  @override
  State<AIConversation> createState() => _AIConversationState();
}

class _AIConversationState extends State<AIConversation> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(AIConversation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
      if (_autoScroll) {
        _scrollToBottom();
      }
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      _autoScroll = (maxScroll - currentScroll) < 50;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    widget.controller.sendMessage(text);
    _autoScroll = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Message list
          Expanded(
            child: MessageList(
              messages: widget.controller.messages,
              scrollController: _scrollController,
              welcomeMessage: widget.welcomeMessage,
              streamingText: widget.controller.isStreaming
                  ? widget.controller.streamingText
                  : null,
              messageBuilder: widget.messageBuilder,
              avatarBuilder: widget.avatarBuilder,
            ),
          ),

          // Typing indicator
          if (widget.showTypingIndicator && widget.controller.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TypingIndicator(),
              ),
            ),

          // Input
          widget.inputBuilder?.call(_handleSend) ??
              AIMessageInput(
                onSend: _handleSend,
                enabled: !widget.controller.isLoading,
                allowAttachments: widget.allowAttachments,
              ),
        ],
      ),
    );
  }
}
