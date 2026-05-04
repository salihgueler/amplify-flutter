// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:amplify_ai/amplify_ai.dart';

/// Builds content blocks from a list of stream events.
///
/// This function reassembles streaming chunks into complete content
/// blocks, handling text deltas, tool use blocks, and content block
/// ordering by index.
///
/// The logic mirrors the JS `contentFromEvents` implementation:
/// - Text blocks are concatenated from all delta events for a given
///   [contentBlockIndex], ordered by [contentBlockDeltaIndex].
/// - Tool use blocks are taken as-is (they're never chunked).
/// - Events are grouped by [contentBlockIndex] to produce the final
///   list of content blocks.
///
/// ```dart
/// final events = <ConversationStreamEvent>[...];
/// final contentBlocks = buildContentFromEvents(events);
/// ```
List<ContentBlock> buildContentFromEvents(
  List<ConversationStreamEvent> events,
) {
  final reassembler = StreamReassembler();
  for (final event in events) {
    reassembler.addEvent(event);
  }
  return reassembler.getContentBlocks();
}

/// Incrementally updates content blocks as new events arrive.
///
/// This is useful for real-time UI updates where you want to show
/// partially accumulated text as it streams in.
///
/// Returns a map of blockIndex → accumulated text so far.
Map<int, String> getPartialTextFromEvents(
  List<ConversationStreamEvent> events,
) {
  final textBlocks = <int, Map<int, String>>{};

  for (final event in events) {
    if (event.isTextDelta && event.contentBlockIndex != null) {
      final blockIndex = event.contentBlockIndex!;
      final deltaIndex = event.contentBlockDeltaIndex ?? 0;
      textBlocks.putIfAbsent(blockIndex, () => {});
      textBlocks[blockIndex]![deltaIndex] = event.contentBlockText!;
    }
  }

  final result = <int, String>{};
  for (final entry in textBlocks.entries) {
    final deltas = entry.value;
    if (deltas.isEmpty) continue;
    final maxDelta = deltas.keys.reduce((a, b) => a > b ? a : b);
    final buffer = StringBuffer();
    for (var i = 0; i <= maxDelta; i++) {
      if (deltas.containsKey(i)) {
        buffer.write(deltas[i]);
      }
    }
    result[entry.key] = buffer.toString();
  }

  return result;
}
