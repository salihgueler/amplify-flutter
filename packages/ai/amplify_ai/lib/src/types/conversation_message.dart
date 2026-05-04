// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Conversation message types for AI Kit.

import 'package:meta/meta.dart';

import 'content_block.dart';

/// Role of a participant in a conversation.
enum ConversationParticipantRole {
  /// Message from the user.
  user,

  /// Message from the AI assistant.
  assistant,
}

/// A message in a conversation.
@immutable
class ConversationMessage {
  /// Unique identifier for this message.
  final String id;

  /// The conversation this message belongs to.
  final String conversationId;

  /// The content blocks of this message.
  final List<ContentBlock> content;

  /// The role of the sender (user or assistant).
  final ConversationParticipantRole role;

  /// When this message was created (ISO 8601).
  final String createdAt;

  /// When this message was last updated (ISO 8601).
  final String? updatedAt;

  /// For assistant messages, the ID of the user message that triggered it.
  final String? associatedUserMessageId;

  const ConversationMessage({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.role,
    required this.createdAt,
    this.updatedAt,
    this.associatedUserMessageId,
  });

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      content: (json['content'] as List<dynamic>?)
              ?.map((e) => ContentBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      role: _parseRole(json['role'] as String?),
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
      associatedUserMessageId: json['associatedUserMessageId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'content': content.map((c) => c.toJson()).toList(),
        'role': role.name,
        'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
        if (associatedUserMessageId != null)
          'associatedUserMessageId': associatedUserMessageId,
      };

  static ConversationParticipantRole _parseRole(String? role) {
    switch (role) {
      case 'assistant':
        return ConversationParticipantRole.assistant;
      case 'user':
      default:
        return ConversationParticipantRole.user;
    }
  }

  @override
  String toString() => 'ConversationMessage(id: $id, role: ${role.name}, '
      'contentBlocks: ${content.length})';
}

/// Input for sending a message in a conversation.
@immutable
class SendMessageInput {
  /// The content blocks to send.
  final List<ContentBlock> content;

  /// Optional AI context to include (will be JSON stringified).
  final Map<String, dynamic>? aiContext;

  /// Optional tool configuration for client-side tools.
  final Map<String, dynamic>? toolConfiguration;

  const SendMessageInput({
    required this.content,
    this.aiContext,
    this.toolConfiguration,
  });

  /// Creates a simple text message input.
  factory SendMessageInput.text(String text) {
    return SendMessageInput(
      content: [ContentBlock.text(text)],
    );
  }
}
