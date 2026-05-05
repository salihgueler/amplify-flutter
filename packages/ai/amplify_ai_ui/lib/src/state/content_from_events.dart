// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Utilities for converting streaming AI events into renderable content blocks.
///
/// Mirrors the contentFromEvents logic in @aws-amplify/ui-react-ai that
/// accumulates streamed text deltas, tool-use blocks, and images into
/// a list of typed content blocks suitable for rendering.
library;

import 'package:flutter/foundation.dart';

/// The type of a content block.
enum ContentBlockType {
  /// Plain or streamed text content.
  text,

  /// An image content block.
  image,

  /// A tool-use request block.
  toolUse,

  /// A tool result block.
  toolResult,
}

/// A single content block produced from streaming events.
@immutable
class ContentBlock {
  /// Creates a text content block.
  const ContentBlock.text(this.text)
      : type = ContentBlockType.text,
        image = null,
        toolUse = null,
        toolResult = null;

  /// Creates an image content block.
  const ContentBlock.image(this.image)
      : type = ContentBlockType.image,
        text = null,
        toolUse = null,
        toolResult = null;

  /// Creates a tool-use content block.
  const ContentBlock.toolUse(this.toolUse)
      : type = ContentBlockType.toolUse,
        text = null,
        image = null,
        toolResult = null;

  /// Creates a tool-result content block.
  const ContentBlock.toolResult(this.toolResult)
      : type = ContentBlockType.toolResult,
        text = null,
        image = null,
        toolUse = null;

  /// The type of content.
  final ContentBlockType type;

  /// Text content, if this is a text block.
  final String? text;

  /// Image data, if this is an image block.
  final ImageContent? image;

  /// Tool use info, if this is a tool-use block.
  final ToolUseContent? toolUse;

  /// Tool result info, if this is a tool-result block.
  final ToolResultContent? toolResult;
}

/// Image content data.
@immutable
class ImageContent {
  /// Creates an [ImageContent].
  const ImageContent({required this.source, this.format});

  /// The image source (URL or base64).
  final String source;

  /// The image format (e.g., 'png', 'jpeg').
  final String? format;
}

/// Tool use content data.
@immutable
class ToolUseContent {
  /// Creates a [ToolUseContent].
  const ToolUseContent({
    required this.toolUseId,
    required this.name,
    required this.input,
  });

  /// Unique ID for this tool-use request.
  final String toolUseId;

  /// Name of the tool being used.
  final String name;

  /// Input passed to the tool as JSON.
  final Map<String, dynamic> input;
}

/// Tool result content data.
@immutable
class ToolResultContent {
  /// Creates a [ToolResultContent].
  const ToolResultContent({
    required this.toolUseId,
    required this.status,
    this.content,
  });

  /// The tool-use ID this result responds to.
  final String toolUseId;

  /// The status of the tool execution.
  final ToolResultStatus status;

  /// The result content (text/JSON).
  final dynamic content;
}

/// Status of a tool result.
enum ToolResultStatus {
  /// Tool executed successfully.
  success,

  /// Tool execution failed.
  error,
}

/// Accumulates streaming events into content blocks.
///
/// This mirrors the JS `getContentFromEvents` helper that builds up
/// a list of [ContentBlock] objects from incremental stream events.
class ContentBlockAccumulator {
  /// Current accumulated content blocks.
  final List<ContentBlock> blocks = [];

  /// Accumulated text buffer for the current text block.
  final StringBuffer _textBuffer = StringBuffer();

  /// Appends a text delta to the current text block.
  void addTextDelta(String delta) {
    _textBuffer.write(delta);
  }

  /// Finalizes the current text block and adds it to [blocks].
  void finalizeTextBlock() {
    if (_textBuffer.isNotEmpty) {
      blocks.add(ContentBlock.text(_textBuffer.toString()));
      _textBuffer.clear();
    }
  }

  /// Adds a tool-use block.
  void addToolUseBlock(ToolUseContent toolUse) {
    finalizeTextBlock();
    blocks.add(ContentBlock.toolUse(toolUse));
  }

  /// Adds a tool-result block.
  void addToolResultBlock(ToolResultContent toolResult) {
    finalizeTextBlock();
    blocks.add(ContentBlock.toolResult(toolResult));
  }

  /// Adds an image block.
  void addImageBlock(ImageContent image) {
    finalizeTextBlock();
    blocks.add(ContentBlock.image(image));
  }

  /// Returns the current text being accumulated (for streaming display).
  String get currentText => _textBuffer.toString();

  /// Resets the accumulator.
  void reset() {
    blocks.clear();
    _textBuffer.clear();
  }
}
