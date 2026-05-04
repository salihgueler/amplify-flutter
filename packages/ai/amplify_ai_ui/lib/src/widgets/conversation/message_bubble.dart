// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:amplify_ai/amplify_ai.dart';
import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';
import '../../theme/ai_theme_data.dart';
import '../content/content_block_renderer.dart';
import 'amplify_ai_conversation.dart';

/// A message bubble widget for displaying a single conversation message.
///
/// Adapts its appearance based on the message role (user vs assistant)
/// and the current [AITheme].
class MessageBubble extends StatelessWidget {
  /// The conversation message to display.
  final ConversationMessage message;

  /// Optional custom builder for message content.
  final Widget Function(BuildContext context, ConversationMessage message)?
      contentBuilder;

  /// Whether to show the message timestamp.
  final bool showTimestamp;

  /// Optional avatar widget for the message sender.
  final Widget? avatar;

  const MessageBubble({
    super.key,
    required this.message,
    this.contentBuilder,
    this.showTimestamp = false,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);
    final isUser = message.role == ConversationParticipantRole.user;

    return Padding(
      padding: EdgeInsets.only(bottom: theme.messageSpacing),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && avatar != null) ...[
            avatar!,
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? theme.userBubbleColor
                        : theme.assistantBubbleColor,
                    borderRadius: _getBorderRadius(isUser, theme),
                  ),
                  padding: theme.bubblePadding,
                  child: contentBuilder != null
                      ? contentBuilder!(context, message)
                      : _buildDefaultContent(context, theme, isUser),
                ),
                if (showTimestamp) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.createdAt),
                    style: theme.captionTextStyle,
                  ),
                ],
              ],
            ),
          ),
          if (isUser && avatar != null) ...[
            const SizedBox(width: 8),
            avatar!,
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultContent(
      BuildContext context, AIThemeData theme, bool isUser) {
    final contentBlocks = message.content;
    if (contentBlocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentBlocks.map((block) {
        return ContentBlockRenderer(
          block: block,
          textColor: isUser ? theme.userTextColor : theme.assistantTextColor,
          textStyle: theme.messageTextStyle,
        );
      }).toList(),
    );
  }

  BorderRadius _getBorderRadius(bool isUser, AIThemeData theme) {
    final radius = theme.bubbleBorderRadius.topLeft;
    if (isUser) {
      return BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: const Radius.circular(4),
      );
    }
    return BorderRadius.only(
      topLeft: const Radius.circular(4),
      topRight: radius,
      bottomLeft: radius,
      bottomRight: radius,
    );
  }

  String _formatTimestamp(String isoTimestamp) {
    try {
      final dateTime = DateTime.parse(isoTimestamp);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }
}
