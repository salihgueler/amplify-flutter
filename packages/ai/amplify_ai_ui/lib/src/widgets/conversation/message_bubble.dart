// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../providers/ai_conversation_provider.dart';
import '../../state/content_from_events.dart';
import '../../theme/ai_theme.dart';
import '../common/ai_avatar.dart';
import '../common/content_block_renderer.dart';

/// A single message bubble in the conversation.
///
/// Displays user and assistant messages with appropriate styling,
/// avatars, and content rendering.
class MessageBubble extends StatelessWidget {
  /// Creates a [MessageBubble].
  const MessageBubble({
    super.key,
    required this.message,
    this.displayText,
    this.streamingTextWidget,
    this.avatarBuilder,
  });

  /// The message to display.
  final ConversationMessage message;

  /// Override text to display instead of message content.
  final String? displayText;

  /// Widget for streaming text display.
  final Widget? streamingTextWidget;

  /// Custom avatar builder.
  final Widget Function(String role)? avatarBuilder;

  bool get _isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final bubbleColor = _isUser
        ? theme.userBubbleColor ?? colorScheme.primaryContainer
        : theme.assistantBubbleColor ?? colorScheme.surfaceContainerHighest;

    final textColor = _isUser
        ? theme.userTextColor ?? colorScheme.onPrimaryContainer
        : theme.assistantTextColor ?? colorScheme.onSurface;

    final avatar = avatarBuilder?.call(message.role) ??
        AIAvatar(role: message.role);

    return Row(
      mainAxisAlignment: _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isUser) ...[
          avatar,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: _isUser ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight: _isUser ? const Radius.circular(4) : const Radius.circular(16),
              ),
            ),
            child: _buildContent(textColor),
          ),
        ),
        if (_isUser) ...[
          const SizedBox(width: 8),
          avatar,
        ],
      ],
    );
  }

  Widget _buildContent(Color textColor) {
    // Streaming text widget takes priority
    if (streamingTextWidget != null) {
      return streamingTextWidget!;
    }

    // Override display text
    if (displayText != null) {
      return Text(
        displayText!,
        style: TextStyle(color: textColor),
      );
    }

    // Render content blocks
    if (message.content.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: message.content.map((block) {
        return ContentBlockRenderer(block: block, textColor: textColor);
      }).toList(),
    );
  }
}
