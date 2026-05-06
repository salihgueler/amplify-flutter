// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../providers/ai_conversation_provider.dart';
import 'message_bubble.dart';
import 'streaming_text.dart';

/// Displays a scrollable list of conversation messages.
///
/// Handles empty state with welcome message, streaming text display,
/// and proper scroll behavior.
class MessageList extends StatelessWidget {
  /// Creates a [MessageList].
  const MessageList({
    super.key,
    required this.messages,
    this.scrollController,
    this.welcomeMessage,
    this.streamingText,
    this.messageBuilder,
    this.avatarBuilder,
  });

  /// The messages to display.
  final List<ConversationMessage> messages;

  /// Scroll controller for the list.
  final ScrollController? scrollController;

  /// Welcome message shown when no messages exist.
  final String? welcomeMessage;

  /// Currently streaming text from assistant.
  final String? streamingText;

  /// Custom message widget builder.
  final Widget Function(ConversationMessage message)? messageBuilder;

  /// Custom avatar builder.
  final Widget Function(String role)? avatarBuilder;

  @override
  Widget build(BuildContext context) {

    if (messages.isEmpty && welcomeMessage == null) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length + (streamingText != null ? 1 : 0) + (messages.isEmpty && welcomeMessage != null ? 1 : 0),
      itemBuilder: (context, index) {
        // Welcome message
        if (messages.isEmpty && welcomeMessage != null && index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: MessageBubble(
              message: ConversationMessage(
                id: 'welcome',
                role: 'assistant',
                content: [],
                createdAt: DateTime.now(),
              ),
              displayText: welcomeMessage,
              avatarBuilder: avatarBuilder,
            ),
          );
        }

        // Streaming text at the end
        final messageIndex = messages.isEmpty && welcomeMessage != null ? index - 1 : index;

        if (messageIndex >= messages.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: MessageBubble(
              message: ConversationMessage(
                id: 'streaming',
                role: 'assistant',
                content: [],
                isStreaming: true,
              ),
              streamingTextWidget: StreamingText(text: streamingText ?? ''),
              avatarBuilder: avatarBuilder,
            ),
          );
        }

        final message = messages[messageIndex];
        if (messageBuilder != null) {
          return messageBuilder!(message);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: MessageBubble(
            message: message,
            avatarBuilder: avatarBuilder,
          ),
        );
      },
    );
  }
}
