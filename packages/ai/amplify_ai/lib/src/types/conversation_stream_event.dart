// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Stream event types received via GraphQL subscriptions during AI conversations.

import 'package:meta/meta.dart';

import 'content_block.dart';

/// A stream event received from the AI model via AppSync subscription.
///
/// Stream events deliver incremental content as the AI generates its response.
/// Events are identified by [contentBlockIndex] (which content block) and
/// [contentBlockDeltaIndex] (ordering within that block).
@immutable
class ConversationStreamEvent {
  /// Unique event ID.
  final String id;

  /// The conversation this event belongs to.
  final String conversationId;

  /// The user message ID that triggered this assistant response.
  final String associatedUserMessageId;

  /// Which content block this event belongs to.
  final int? contentBlockIndex;

  /// A text delta for the content block.
  final String? contentBlockText;

  /// The ordering index of this delta within the content block.
  final int? contentBlockDeltaIndex;

  /// A tool use block (delivered as complete block, not chunked).
  final ToolUseBlock? contentBlockToolUse;

  /// Signals that a content block is complete at this index.
  final int? contentBlockDoneAtIndex;

  /// Signals the turn is complete (e.g., "end_turn", "tool_use").
  final String? stopReason;

  /// Errors that occurred during the conversation turn.
  final List<ConversationTurnError>? errors;

  /// Padding string (from Bedrock).
  final String? p;

  const ConversationStreamEvent({
    required this.id,
    required this.conversationId,
    required this.associatedUserMessageId,
    this.contentBlockIndex,
    this.contentBlockText,
    this.contentBlockDeltaIndex,
    this.contentBlockToolUse,
    this.contentBlockDoneAtIndex,
    this.stopReason,
    this.errors,
    this.p,
  });

  /// Whether this event signals the end of the conversation turn.
  bool get isTurnComplete => stopReason != null;

  /// Whether this event contains an error.
  bool get hasError => errors != null && errors!.isNotEmpty;

  /// Whether this event is a text delta.
  bool get isTextDelta => contentBlockText != null;

  /// Whether this event is a tool use block.
  bool get isToolUse => contentBlockToolUse != null;

  /// Whether this event signals a content block is done.
  bool get isBlockDone => contentBlockDoneAtIndex != null;

  factory ConversationStreamEvent.fromJson(Map<String, dynamic> json) {
    return ConversationStreamEvent(
      id: json['id'] as String? ?? '',
      conversationId: json['conversationId'] as String? ?? '',
      associatedUserMessageId: json['associatedUserMessageId'] as String? ?? '',
      contentBlockIndex: json['contentBlockIndex'] as int?,
      contentBlockText: json['contentBlockText'] as String?,
      contentBlockDeltaIndex: json['contentBlockDeltaIndex'] as int?,
      contentBlockToolUse: json['contentBlockToolUse'] != null
          ? ToolUseBlock.fromJson(
              json['contentBlockToolUse'] as Map<String, dynamic>)
          : null,
      contentBlockDoneAtIndex: json['contentBlockDoneAtIndex'] as int?,
      stopReason: json['stopReason'] as String?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map(
              (e) => ConversationTurnError.fromJson(e as Map<String, dynamic>))
          .toList(),
      p: json['p'] as String?,
    );
  }

  @override
  String toString() {
    if (isTextDelta) {
      return 'StreamEvent.text(block: $contentBlockIndex, '
          'delta: $contentBlockDeltaIndex)';
    }
    if (isToolUse) {
      return 'StreamEvent.toolUse(block: $contentBlockIndex, '
          'tool: ${contentBlockToolUse!.name})';
    }
    if (isBlockDone) {
      return 'StreamEvent.blockDone(index: $contentBlockDoneAtIndex)';
    }
    if (isTurnComplete) {
      return 'StreamEvent.turnComplete(reason: $stopReason)';
    }
    if (hasError) return 'StreamEvent.error(${errors!.first.message})';
    return 'StreamEvent(id: $id)';
  }
}

/// An error that occurred during a conversation turn.
@immutable
class ConversationTurnError {
  /// The error message.
  final String message;

  /// The type/category of error.
  final String errorType;

  const ConversationTurnError({
    required this.message,
    required this.errorType,
  });

  factory ConversationTurnError.fromJson(Map<String, dynamic> json) {
    return ConversationTurnError(
      message: json['message'] as String? ?? '',
      errorType: json['errorType'] as String? ?? 'UnknownError',
    );
  }

  @override
  String toString() => 'ConversationTurnError($errorType: $message)';
}
