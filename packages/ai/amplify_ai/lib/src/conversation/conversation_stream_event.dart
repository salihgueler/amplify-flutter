import 'package:meta/meta.dart';

import '../content/content_block.dart';

/// Represents a streaming event from an AI conversation.
/// Mirrors the JS AI Kit ConversationStreamEvent with exact field parity.
@immutable
sealed class ConversationStreamEvent {
  const ConversationStreamEvent({
    required this.id,
    required this.conversationId,
    required this.associatedUserMessageId,
    this.contentBlockIndex,
    this.contentBlockDeltaIndex,
  });

  /// The unique event ID.
  final String id;

  /// The conversation this event belongs to.
  final String conversationId;

  /// The user message ID that triggered this response.
  final String associatedUserMessageId;

  /// The index of the content block being streamed.
  final int? contentBlockIndex;

  /// The delta index within the content block.
  final int? contentBlockDeltaIndex;

  /// Deserializes a stream event from JSON.
  static ConversationStreamEvent fromJson(Map<String, dynamic> json) {
    final stopReason = json['stopReason'] as String?;
    final contentBlockText = json['contentBlockText'] as String?;
    final contentBlockToolUse =
        json['contentBlockToolUse'] as Map<String, dynamic>?;
    final contentBlockDoneAtIndex = json['contentBlockDoneAtIndex'] as int?;

    final id = json['id'] as String? ?? '';
    final conversationId = json['conversationId'] as String? ?? '';
    final associatedUserMessageId =
        json['associatedUserMessageId'] as String? ?? '';
    final contentBlockIndex = json['contentBlockIndex'] as int?;
    final contentBlockDeltaIndex = json['contentBlockDeltaIndex'] as int?;

    if (stopReason != null) {
      return ConversationStreamTurnDoneEvent(
        id: id,
        conversationId: conversationId,
        associatedUserMessageId: associatedUserMessageId,
        contentBlockIndex: contentBlockIndex,
        contentBlockDeltaIndex: contentBlockDeltaIndex,
        stopReason: stopReason,
        message: json['message'] as Map<String, dynamic>?,
      );
    }

    if (contentBlockDoneAtIndex != null) {
      return ConversationStreamBlockDoneEvent(
        id: id,
        conversationId: conversationId,
        associatedUserMessageId: associatedUserMessageId,
        contentBlockIndex: contentBlockDoneAtIndex,
        contentBlockDeltaIndex: contentBlockDeltaIndex,
      );
    }

    if (contentBlockToolUse != null) {
      return ConversationStreamToolUseEvent(
        id: id,
        conversationId: conversationId,
        associatedUserMessageId: associatedUserMessageId,
        contentBlockIndex: contentBlockIndex,
        contentBlockDeltaIndex: contentBlockDeltaIndex,
        toolUse: ToolUseContentBlock(
          toolUseId: contentBlockToolUse['toolUseId'] as String? ?? '',
          name: contentBlockToolUse['name'] as String? ?? '',
          input: contentBlockToolUse['input'] as Map<String, dynamic>? ?? {},
        ),
      );
    }

    if (contentBlockText != null) {
      return ConversationStreamTextEvent(
        id: id,
        conversationId: conversationId,
        associatedUserMessageId: associatedUserMessageId,
        contentBlockIndex: contentBlockIndex,
        contentBlockDeltaIndex: contentBlockDeltaIndex,
        text: contentBlockText,
      );
    }

    return ConversationStreamTextEvent(
      id: id,
      conversationId: conversationId,
      associatedUserMessageId: associatedUserMessageId,
      contentBlockIndex: contentBlockIndex,
      contentBlockDeltaIndex: contentBlockDeltaIndex,
      text: '',
    );
  }
}

/// A text delta event in a conversation stream.
@immutable
class ConversationStreamTextEvent extends ConversationStreamEvent {
  const ConversationStreamTextEvent({
    required super.id,
    required super.conversationId,
    required super.associatedUserMessageId,
    super.contentBlockIndex,
    super.contentBlockDeltaIndex,
    required this.text,
  });

  /// The text delta.
  final String text;

  @override
  String toString() =>
      'ConversationStreamTextEvent(text: "${text.length > 50 ? '${text.substring(0, 50)}...' : text}")';
}

/// A tool use event in a conversation stream.
@immutable
class ConversationStreamToolUseEvent extends ConversationStreamEvent {
  const ConversationStreamToolUseEvent({
    required super.id,
    required super.conversationId,
    required super.associatedUserMessageId,
    super.contentBlockIndex,
    super.contentBlockDeltaIndex,
    required this.toolUse,
  });

  /// The tool use content block.
  final ToolUseContentBlock toolUse;

  @override
  String toString() => 'ConversationStreamToolUseEvent(tool: ${toolUse.name})';
}

/// Event indicating a content block is complete.
@immutable
class ConversationStreamBlockDoneEvent extends ConversationStreamEvent {
  const ConversationStreamBlockDoneEvent({
    required super.id,
    required super.conversationId,
    required super.associatedUserMessageId,
    super.contentBlockIndex,
    super.contentBlockDeltaIndex,
  });

  @override
  String toString() =>
      'ConversationStreamBlockDoneEvent(index: $contentBlockIndex)';
}

/// Event indicating the turn is complete.
@immutable
class ConversationStreamTurnDoneEvent extends ConversationStreamEvent {
  const ConversationStreamTurnDoneEvent({
    required super.id,
    required super.conversationId,
    required super.associatedUserMessageId,
    super.contentBlockIndex,
    super.contentBlockDeltaIndex,
    required this.stopReason,
    this.message,
  });

  /// The reason the model stopped generating.
  final String stopReason;

  /// The complete message, if available.
  final Map<String, dynamic>? message;

  @override
  String toString() =>
      'ConversationStreamTurnDoneEvent(stopReason: $stopReason)';
}
