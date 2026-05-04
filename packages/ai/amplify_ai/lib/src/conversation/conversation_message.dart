import 'package:meta/meta.dart';

import '../content/content_block.dart';

/// The role of the message sender.
enum ConversationMessageRole {
  /// Message from the user.
  user,

  /// Message from the AI assistant.
  assistant,
}

/// Represents a single message in a conversation.
/// Mirrors the JS AI Kit ConversationMessage type with exact field parity.
@immutable
class ConversationMessage {
  /// Creates a conversation message.
  const ConversationMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.associatedUserMessageId,
    this.aiContext,
    this.createdAt,
    this.updatedAt,
  });

  /// The unique identifier for this message.
  final String id;

  /// The conversation this message belongs to.
  final String conversationId;

  /// The role of the message sender (user or assistant).
  final ConversationMessageRole role;

  /// The content blocks that make up this message.
  final List<ContentBlock> content;

  /// The ID of the associated user message (for assistant responses).
  final String? associatedUserMessageId;

  /// Additional AI context for the message.
  final Map<String, dynamic>? aiContext;

  /// The timestamp when this message was created.
  final DateTime? createdAt;

  /// The timestamp when this message was last updated.
  final DateTime? updatedAt;

  /// Creates a copy of this message with the given fields replaced.
  ConversationMessage copyWith({
    String? id,
    String? conversationId,
    ConversationMessageRole? role,
    List<ContentBlock>? content,
    String? associatedUserMessageId,
    Map<String, dynamic>? aiContext,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      associatedUserMessageId:
          associatedUserMessageId ?? this.associatedUserMessageId,
      aiContext: aiContext ?? this.aiContext,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes this message to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'role': role.name,
        'content': content.map((c) => c.toJson()).toList(),
        if (associatedUserMessageId != null)
          'associatedUserMessageId': associatedUserMessageId,
        if (aiContext != null) 'aiContext': aiContext,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Deserializes a message from JSON.
  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: ConversationMessageRole.values.firstWhere(
        (r) => r.name == (json['role'] as String).toLowerCase(),
        orElse: () => ConversationMessageRole.user,
      ),
      content: (json['content'] as List<dynamic>)
          .map((c) => ContentBlock.fromJson(c as Map<String, dynamic>))
          .toList(),
      associatedUserMessageId: json['associatedUserMessageId'] as String?,
      aiContext: json['aiContext'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ConversationMessage(id: $id, role: ${role.name}, contentBlocks: ${content.length})';
}
