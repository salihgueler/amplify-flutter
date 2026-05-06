import 'package:meta/meta.dart';

import '../content/content_block.dart';

/// Represents a streaming event from an AI conversation.
/// Mirrors the AmplifyAIConversationMessageStreamPart type from the schema.
///
/// Fields from the schema:
/// - id, owner, conversationId, associatedUserMessageId
/// - contentBlockIndex (Int), contentBlockText (String)
/// - contentBlockDeltaIndex (Int)
/// - contentBlockToolUse (AmplifyAIToolUseBlock with toolUseId, name, input, type)
/// - contentBlockDoneAtIndex (Int), stopReason (String)
/// - errors [{errorType, message}]
/// - p (String) - partial/progress indicator
@immutable
sealed class ConversationStreamEvent {
  const ConversationStreamEvent({
    required this.id,
    required this.conversationId,
    required this.associatedUserMessageId,
    this.owner,
    this.contentBlockIndex,
    this.contentBlockDeltaIndex,
    this.p,
  });

  /// The unique event ID.
  final String id;

  /// The conversation this event belongs to.
  final String conversationId;

  /// The user message ID that triggered this response.
  final String associatedUserMessageId;

  /// The owner of this message stream part.
  final String? owner;

  /// The index of the content block being streamed.
  final int? contentBlockIndex;

  /// The delta index within the content block.
  final int? contentBlockDeltaIndex;

  /// Partial/progress indicator field.
  final String? p;

  /// Deserializes a stream event from JSON matching
  /// AmplifyAIConversationMessageStreamPart.
  static ConversationStreamEvent fromJson(Map<String, dynamic> json) {
    final stopReason = json['stopReason'] as String?;
    final contentBlockText = json['contentBlockText'] as String?;
    final contentBlockToolUse =
        json['contentBlockToolUse'] as Map<String, dynamic>?;
    final contentBlockDoneAtIndex = json['contentBlockDoneAtIndex'] as int?;
    final errors = json['errors'] as List<dynamic>?;

    final id = json['id'] as String? ?? '';
    final conversationId = json['conversationId'] as String? ?? '';
    final associatedUserMessageId =
        json['associatedUserMessageId'] as String? ?? '';
    final owner = json['owner'] as String?;
    final contentBlockIndex = json['contentBlockIndex'] as int?;
    final contentBlockDeltaIndex = json['contentBlockDeltaIndex'] as int?;
    final p = json['p'] as String?;

    // Check for errors
    if (errors != null && errors.isNotEmpty) {
      return ConversationStreamErrorEvent(
        id: id,
        conversationId: conversationId,
        associatedUserMessageId: associatedUserMessageId,
        owner: owner,
        contentBlockIndex: contentBlockIndex,
        contentBlockDeltaIndex: contentBlockDeltaIndex,
        p: p,
        errors: errors
            .map((e) => StreamError.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }

    if (stopReason != null) {
      return ConversationStreamTurnDoneEvent(
        id: id,
        conversationId: conversationId,
        associatedUserMessageId: associatedUserMessageId,
        owner: owner,
        contentBlockIndex: contentBlockIndex,
        contentBlockDeltaIndex: contentBlockDeltaIndex,
        p: p,
        stopReason: stopReason,
      );
    }

    if (contentBlockDoneAtIndex != null) {
      return ConversationStreamBlockDoneEvent(
        id: id,
        conversationId: conversationId,
        associatedUserMessageId: associatedUserMessageId,
        owner: owner,
        contentBlockIndex: contentBlockDoneAtIndex,
        contentBlockDeltaIndex: contentBlockDeltaIndex,
        p: p,
      );
    }

    if (contentBlockToolUse != null) {
      return ConversationStreamToolUseEvent(
        id: id,
        conversationId: conversationId,
        associatedUserMessageId: associatedUserMessageId,
        owner: owner,
        contentBlockIndex: contentBlockIndex,
        contentBlockDeltaIndex: contentBlockDeltaIndex,
        p: p,
        toolUse: ToolUseContentBlock(
          toolUseId: contentBlockToolUse['toolUseId'] as String? ?? '',
          name: contentBlockToolUse['name'] as String? ?? '',
          input: contentBlockToolUse['input'] is Map<String, dynamic>
              ? contentBlockToolUse['input'] as Map<String, dynamic>
              : {},
        ),
        toolUseType: contentBlockToolUse['type'] as String?,
      );
    }

    if (contentBlockText != null) {
      return ConversationStreamTextEvent(
        id: id,
        conversationId: conversationId,
        associatedUserMessageId: associatedUserMessageId,
        owner: owner,
        contentBlockIndex: contentBlockIndex,
        contentBlockDeltaIndex: contentBlockDeltaIndex,
        p: p,
        text: contentBlockText,
      );
    }

    return ConversationStreamTextEvent(
      id: id,
      conversationId: conversationId,
      associatedUserMessageId: associatedUserMessageId,
      owner: owner,
      contentBlockIndex: contentBlockIndex,
      contentBlockDeltaIndex: contentBlockDeltaIndex,
      p: p,
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
    super.owner,
    super.contentBlockIndex,
    super.contentBlockDeltaIndex,
    super.p,
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
    super.owner,
    super.contentBlockIndex,
    super.contentBlockDeltaIndex,
    super.p,
    required this.toolUse,
    this.toolUseType,
  });

  /// The tool use content block.
  final ToolUseContentBlock toolUse;

  /// The type field from AmplifyAIToolUseBlock.
  final String? toolUseType;

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
    super.owner,
    super.contentBlockIndex,
    super.contentBlockDeltaIndex,
    super.p,
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
    super.owner,
    super.contentBlockIndex,
    super.contentBlockDeltaIndex,
    super.p,
    required this.stopReason,
  });

  /// The reason the model stopped generating.
  final String stopReason;

  @override
  String toString() =>
      'ConversationStreamTurnDoneEvent(stopReason: $stopReason)';
}

/// Event indicating errors in the stream.
@immutable
class ConversationStreamErrorEvent extends ConversationStreamEvent {
  const ConversationStreamErrorEvent({
    required super.id,
    required super.conversationId,
    required super.associatedUserMessageId,
    super.owner,
    super.contentBlockIndex,
    super.contentBlockDeltaIndex,
    super.p,
    required this.errors,
  });

  /// The errors from the stream.
  final List<StreamError> errors;

  @override
  String toString() =>
      'ConversationStreamErrorEvent(errors: ${errors.map((e) => e.message).join(', ')})';
}

/// An error in the conversation stream.
@immutable
class StreamError {
  const StreamError({this.errorType, this.message});

  /// The type of error.
  final String? errorType;

  /// The error message.
  final String? message;

  factory StreamError.fromJson(Map<String, dynamic> json) {
    return StreamError(
      errorType: json['errorType'] as String?,
      message: json['message'] as String?,
    );
  }

  @override
  String toString() => 'StreamError(type: $errorType, message: $message)';
}
