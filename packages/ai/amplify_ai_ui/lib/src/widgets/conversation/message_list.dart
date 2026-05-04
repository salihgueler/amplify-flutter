// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:amplify_ai/amplify_ai.dart';
import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';
import 'amplify_ai_conversation.dart';
import 'message_bubble.dart';

/// A scrollable list of conversation messages.
///
/// Displays messages in chronological order with support for auto-scrolling
/// to the newest message and custom message bubble builders.
class MessageList extends StatefulWidget {
  /// The list of messages to display.
  final List<ConversationMessage> messages;

  /// Whether to auto-scroll to the bottom on new messages.
  final bool autoScrollToBottom;

  /// Padding around the list.
  final EdgeInsets padding;

  /// Optional custom message bubble builder.
  final Widget Function(BuildContext context, ConversationDisplayMessage message)?
      messageBubbleBuilder;

  const MessageList({
    super.key,
    required this.messages,
    this.autoScrollToBottom = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.messageBubbleBuilder,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoScrollToBottom &&
        widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        final isUser = message.role == ConversationParticipantRole.user;

        if (widget.messageBubbleBuilder != null) {
          final displayMessage = ConversationDisplayMessage(
            message: message,
            isUser: isUser,
            text: _extractText(message),
          );
          return widget.messageBubbleBuilder!(context, displayMessage);
        }

        return MessageBubble(
          message: message,
          showTimestamp: _shouldShowTimestamp(index),
        );
      },
    );
  }

  bool _shouldShowTimestamp(int index) {
    if (index == 0) return true;
    // Show timestamp if more than 5 minutes between messages
    try {
      final current = DateTime.parse(widget.messages[index].createdAt);
      final previous = DateTime.parse(widget.messages[index - 1].createdAt);
      return current.difference(previous).inMinutes > 5;
    } catch (_) {
      return false;
    }
  }

  String _extractText(ConversationMessage message) {
    return message.content
        .where((block) => block.text != null)
        .map((block) => block.text!)
        .join('\n');
  }
}
