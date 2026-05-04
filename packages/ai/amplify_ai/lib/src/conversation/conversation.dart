import 'package:meta/meta.dart';

import 'conversation_message.dart';

/// Represents an AI conversation session.
/// Mirrors the JS AI Kit Conversation type.
@immutable
class Conversation {
  /// Creates a conversation instance.
  const Conversation({
    required this.id,
    required this.routeName,
    this.name,
    this.metadata,
    this.messages = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// The unique identifier for this conversation.
  final String id;

  /// The route name this conversation belongs to.
  final String routeName;

  /// Optional display name for the conversation.
  final String? name;

  /// Optional metadata associated with the conversation.
  final Map<String, dynamic>? metadata;

  /// The list of messages in this conversation.
  final List<ConversationMessage> messages;

  /// The timestamp when this conversation was created.
  final DateTime? createdAt;

  /// The timestamp when this conversation was last updated.
  final DateTime? updatedAt;

  /// Creates a copy of this conversation with the given fields replaced.
  Conversation copyWith({
    String? id,
    String? routeName,
    String? name,
    Map<String, dynamic>? metadata,
    List<ConversationMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      name: name ?? this.name,
      metadata: metadata ?? this.metadata,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes this conversation to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'routeName': routeName,
        if (name != null) 'name': name,
        if (metadata != null) 'metadata': metadata,
        'messages': messages.map((m) => m.toJson()).toList(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  /// Deserializes a conversation from JSON.
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      routeName: json['routeName'] as String? ?? '',
      name: json['name'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      messages: (json['messages'] as List<dynamic>?)
              ?.map(
                (m) => ConversationMessage.fromJson(m as Map<String, dynamic>),
              )
              .toList() ??
          const [],
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
      other is Conversation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Conversation(id: $id, name: $name)';
}
