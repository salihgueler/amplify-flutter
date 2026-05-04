import '../content/content_block.dart';
import 'conversation_message.dart';

/// Serializer for ConversationMessage to/from GraphQL JSON format.
/// Handles the transformation between the wire format and domain objects.
class ConversationMessageSerializer {
  const ConversationMessageSerializer._();

  /// Serializes a ConversationMessage to GraphQL input format.
  static Map<String, dynamic> toGraphQLInput(ConversationMessage message) {
    return {
      'conversationId': message.conversationId,
      'role': message.role.name,
      'content': message.content.map(_serializeContentBlock).toList(),
      if (message.aiContext != null) 'aiContext': message.aiContext,
    };
  }

  /// Deserializes a ConversationMessage from GraphQL response format.
  static ConversationMessage fromGraphQLResponse(Map<String, dynamic> json) {
    final contentJson = json['content'];
    List<ContentBlock> content;

    if (contentJson is List) {
      content = contentJson
          .map((c) => _deserializeContentBlock(c as Map<String, dynamic>))
          .toList();
    } else if (contentJson is String) {
      // Handle case where content comes as a JSON string
      content = [TextContentBlock(contentJson)];
    } else {
      content = [];
    }

    return ConversationMessage(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      role: _parseRole(json['role'] as String?),
      content: content,
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

  /// Serializes a list of messages to GraphQL input format.
  static List<Map<String, dynamic>> toGraphQLInputList(
    List<ConversationMessage> messages,
  ) {
    return messages.map(toGraphQLInput).toList();
  }

  /// Deserializes a list of messages from GraphQL response format.
  static List<ConversationMessage> fromGraphQLResponseList(
    List<dynamic> jsonList,
  ) {
    return jsonList
        .map((json) => fromGraphQLResponse(json as Map<String, dynamic>))
        .toList();
  }

  static Map<String, dynamic> _serializeContentBlock(ContentBlock block) {
    return block.toJson();
  }

  static ContentBlock _deserializeContentBlock(Map<String, dynamic> json) {
    return ContentBlock.fromJson(json);
  }

  static ConversationMessageRole _parseRole(String? role) {
    if (role == null) return ConversationMessageRole.user;
    switch (role.toLowerCase()) {
      case 'assistant':
        return ConversationMessageRole.assistant;
      case 'user':
      default:
        return ConversationMessageRole.user;
    }
  }
}
