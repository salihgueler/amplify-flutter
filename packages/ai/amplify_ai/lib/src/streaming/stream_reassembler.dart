// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Stream reassembler that accumulates stream events into content blocks.
///
/// The AI model sends text in chunks via AppSync subscriptions. Each chunk
/// has a [contentBlockIndex] (which content block it belongs to) and a
/// [contentBlockDeltaIndex] (ordering within that block). Tool use blocks
/// are delivered as complete blocks (not chunked).

import '../types/content_block.dart';
import '../types/conversation_stream_event.dart';

/// Reassembles streaming events into complete content blocks.
///
/// Usage:
/// ```dart
/// final reassembler = StreamReassembler();
/// for (final event in events) {
///   reassembler.addEvent(event);
/// }
/// final contentBlocks = reassembler.getContentBlocks();
/// ```
class StreamReassembler {
  /// Text chunks indexed by [contentBlockIndex][contentBlockDeltaIndex].
  final Map<int, Map<int, String>> _textBlocks = {};

  /// Tool use blocks indexed by [contentBlockIndex].
  final Map<int, ToolUseBlock> _toolUseBlocks = {};

  /// Set of content block indices that have been marked as done.
  final Set<int> _doneBlocks = {};

  /// The stop reason when the turn completes.
  String? _stopReason;

  /// Errors accumulated during the stream.
  final List<ConversationTurnError> _errors = [];

  /// The associated user message ID from the stream.
  String? _associatedUserMessageId;

  /// The conversation ID from the stream.
  String? _conversationId;

  /// Whether the turn has completed.
  bool get isComplete => _stopReason != null;

  /// The stop reason for the turn.
  String? get stopReason => _stopReason;

  /// Whether errors occurred.
  bool get hasErrors => _errors.isNotEmpty;

  /// The errors that occurred.
  List<ConversationTurnError> get errors => List.unmodifiable(_errors);

  /// The associated user message ID.
  String? get associatedUserMessageId => _associatedUserMessageId;

  /// The conversation ID.
  String? get conversationId => _conversationId;

  /// Adds a stream event to the reassembler.
  void addEvent(ConversationStreamEvent event) {
    _conversationId ??= event.conversationId;
    _associatedUserMessageId ??= event.associatedUserMessageId;

    if (event.hasError) {
      _errors.addAll(event.errors!);
      return;
    }

    if (event.isTurnComplete) {
      _stopReason = event.stopReason;
      return;
    }

    if (event.isBlockDone) {
      _doneBlocks.add(event.contentBlockDoneAtIndex!);
      return;
    }

    final blockIndex = event.contentBlockIndex;
    if (blockIndex == null) return;

    if (event.isTextDelta) {
      final deltaIndex = event.contentBlockDeltaIndex ?? 0;
      _textBlocks.putIfAbsent(blockIndex, () => {});
      // Direct index assignment - idempotent, handles out-of-order
      _textBlocks[blockIndex]![deltaIndex] = event.contentBlockText!;
    } else if (event.isToolUse) {
      _toolUseBlocks[blockIndex] = event.contentBlockToolUse!;
    }
  }

  /// Gets the reassembled content blocks in order.
  ///
  /// Text blocks are assembled by concatenating all delta chunks in order.
  /// Tool use blocks are returned as-is (they're never chunked).
  List<ContentBlock> getContentBlocks() {
    final maxIndex = _getMaxBlockIndex();
    if (maxIndex < 0) return [];

    final blocks = <ContentBlock>[];
    for (var i = 0; i <= maxIndex; i++) {
      if (_toolUseBlocks.containsKey(i)) {
        blocks.add(ContentBlock.toolUse(_toolUseBlocks[i]!));
      } else if (_textBlocks.containsKey(i)) {
        final text = _assembleTextBlock(i);
        blocks.add(ContentBlock.text(text));
      }
    }
    return blocks;
  }

  /// Gets the current accumulated text for a specific block index.
  String getTextForBlock(int blockIndex) {
    if (!_textBlocks.containsKey(blockIndex)) return '';
    return _assembleTextBlock(blockIndex);
  }

  /// Resets the reassembler for reuse.
  void reset() {
    _textBlocks.clear();
    _toolUseBlocks.clear();
    _doneBlocks.clear();
    _stopReason = null;
    _errors.clear();
    _associatedUserMessageId = null;
    _conversationId = null;
  }

  String _assembleTextBlock(int blockIndex) {
    final deltas = _textBlocks[blockIndex]!;
    if (deltas.isEmpty) return '';

    final maxDelta = deltas.keys.reduce((a, b) => a > b ? a : b);
    final buffer = StringBuffer();
    for (var i = 0; i <= maxDelta; i++) {
      if (deltas.containsKey(i)) {
        buffer.write(deltas[i]);
      }
    }
    return buffer.toString();
  }

  int _getMaxBlockIndex() {
    var max = -1;
    for (final key in _textBlocks.keys) {
      if (key > max) max = key;
    }
    for (final key in _toolUseBlocks.keys) {
      if (key > max) max = key;
    }
    return max;
  }
}
