// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Content block types for AI conversation messages.
///
/// A message can contain multiple content blocks of different types:
/// text, image, toolUse, and toolResult.

import 'dart:convert';

import 'package:meta/meta.dart';

/// A single content block within a conversation message.
@immutable
class ContentBlock {
  /// Text content.
  final String? text;

  /// Image content.
  final ImageBlock? image;

  /// Document content.
  final DocumentBlock? document;

  /// Tool use request from the AI model.
  final ToolUseBlock? toolUse;

  /// Tool result sent back to the AI model.
  final ToolResultBlock? toolResult;

  const ContentBlock({
    this.text,
    this.image,
    this.document,
    this.toolUse,
    this.toolResult,
  });

  /// Creates a text content block.
  const ContentBlock.text(String value)
      : text = value,
        image = null,
        document = null,
        toolUse = null,
        toolResult = null;

  /// Creates an image content block.
  const ContentBlock.image(ImageBlock value)
      : text = null,
        image = value,
        document = null,
        toolUse = null,
        toolResult = null;

  /// Creates a document content block.
  const ContentBlock.document(DocumentBlock value)
      : text = null,
        image = null,
        document = value,
        toolUse = null,
        toolResult = null;

  /// Creates a tool use content block.
  const ContentBlock.toolUse(ToolUseBlock value)
      : text = null,
        image = null,
        document = null,
        toolUse = value,
        toolResult = null;

  /// Creates a tool result content block.
  const ContentBlock.toolResult(ToolResultBlock value)
      : text = null,
        image = null,
        document = null,
        toolUse = null,
        toolResult = value;

  /// Converts this content block to a JSON-compatible map for GraphQL input.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (text != null) map['text'] = text;
    if (image != null) map['image'] = image!.toJson();
    if (document != null) map['document'] = document!.toJson();
    if (toolUse != null) map['toolUse'] = toolUse!.toJson();
    if (toolResult != null) map['toolResult'] = toolResult!.toJson();
    return map;
  }

  /// Creates a content block from a JSON map (GraphQL response).
  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      text: json['text'] as String?,
      image: json['image'] != null
          ? ImageBlock.fromJson(json['image'] as Map<String, dynamic>)
          : null,
      document: json['document'] != null
          ? DocumentBlock.fromJson(json['document'] as Map<String, dynamic>)
          : null,
      toolUse: json['toolUse'] != null
          ? ToolUseBlock.fromJson(json['toolUse'] as Map<String, dynamic>)
          : null,
      toolResult: json['toolResult'] != null
          ? ToolResultBlock.fromJson(json['toolResult'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() {
    if (text != null) return 'ContentBlock.text($text)';
    if (image != null) return 'ContentBlock.image($image)';
    if (document != null) return 'ContentBlock.document($document)';
    if (toolUse != null) return 'ContentBlock.toolUse($toolUse)';
    if (toolResult != null) return 'ContentBlock.toolResult($toolResult)';
    return 'ContentBlock.empty()';
  }
}

/// An image block containing format and source data.
@immutable
class ImageBlock {
  /// The image format (e.g., "png", "jpeg", "gif", "webp").
  final String format;

  /// The image source containing base64-encoded bytes.
  final ImageSource source;

  const ImageBlock({
    required this.format,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'format': format,
        'source': source.toJson(),
      };

  factory ImageBlock.fromJson(Map<String, dynamic> json) {
    return ImageBlock(
      format: json['format'] as String,
      source: ImageSource.fromJson(json['source'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() => 'ImageBlock(format: $format)';
}

/// Source data for an image block.
@immutable
class ImageSource {
  /// Base64-encoded image bytes.
  final String? bytes;

  const ImageSource({this.bytes});

  Map<String, dynamic> toJson() => {'bytes': bytes};

  factory ImageSource.fromJson(Map<String, dynamic> json) {
    return ImageSource(bytes: json['bytes'] as String?);
  }
}

/// A document block containing format, name, and source data.
@immutable
class DocumentBlock {
  /// The document format (e.g., "pdf", "txt", "md").
  final String format;

  /// The document name.
  final String name;

  /// The document source containing base64-encoded bytes.
  final DocumentSource source;

  const DocumentBlock({
    required this.format,
    required this.name,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'format': format,
        'name': name,
        'source': source.toJson(),
      };

  factory DocumentBlock.fromJson(Map<String, dynamic> json) {
    return DocumentBlock(
      format: json['format'] as String,
      name: json['name'] as String,
      source: DocumentSource.fromJson(json['source'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() => 'DocumentBlock(format: $format, name: $name)';
}

/// Source data for a document block.
@immutable
class DocumentSource {
  /// Base64-encoded document bytes.
  final String? bytes;

  const DocumentSource({this.bytes});

  Map<String, dynamic> toJson() => {'bytes': bytes};

  factory DocumentSource.fromJson(Map<String, dynamic> json) {
    return DocumentSource(bytes: json['bytes'] as String?);
  }
}

/// A tool use block representing a request from the AI model to invoke a tool.
@immutable
class ToolUseBlock {
  /// Unique identifier for this tool use request.
  final String toolUseId;

  /// Name of the tool to invoke.
  final String name;

  /// Input parameters for the tool as a JSON object.
  final Map<String, dynamic> input;

  const ToolUseBlock({
    required this.toolUseId,
    required this.name,
    required this.input,
  });

  Map<String, dynamic> toJson() => {
        'toolUseId': toolUseId,
        'name': name,
        'input': json.encode(input),
      };

  factory ToolUseBlock.fromJson(Map<String, dynamic> jsonMap) {
    final rawInput = jsonMap['input'];
    Map<String, dynamic> parsedInput;
    if (rawInput is String) {
      parsedInput = json.decode(rawInput) as Map<String, dynamic>;
    } else if (rawInput is Map<String, dynamic>) {
      parsedInput = rawInput;
    } else {
      parsedInput = <String, dynamic>{};
    }
    return ToolUseBlock(
      toolUseId: jsonMap['toolUseId'] as String,
      name: jsonMap['name'] as String,
      input: parsedInput,
    );
  }

  @override
  String toString() => 'ToolUseBlock(toolUseId: $toolUseId, name: $name)';
}

/// A tool result block sent back to the AI model after tool execution.
@immutable
class ToolResultBlock {
  /// The ID matching the original tool use request.
  final String toolUseId;

  /// The content of the tool result.
  final List<ToolResultContent> content;

  /// Optional status of the tool execution.
  final String? status;

  const ToolResultBlock({
    required this.toolUseId,
    required this.content,
    this.status,
  });

  Map<String, dynamic> toJson() => {
        'toolUseId': toolUseId,
        'content': content.map((c) => c.toJson()).toList(),
        if (status != null) 'status': status,
      };

  factory ToolResultBlock.fromJson(Map<String, dynamic> jsonMap) {
    return ToolResultBlock(
      toolUseId: jsonMap['toolUseId'] as String,
      content: (jsonMap['content'] as List<dynamic>)
          .map((e) => ToolResultContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: jsonMap['status'] as String?,
    );
  }

  @override
  String toString() =>
      'ToolResultBlock(toolUseId: $toolUseId, status: $status)';
}

/// Content within a tool result.
@immutable
class ToolResultContent {
  /// Text content in the tool result.
  final String? text;

  /// JSON content in the tool result.
  final Map<String, dynamic>? jsonValue;

  /// Image content in the tool result.
  final ImageBlock? image;

  /// Document content in the tool result.
  final DocumentBlock? document;

  const ToolResultContent({
    this.text,
    this.jsonValue,
    this.image,
    this.document,
  });

  /// Creates a text tool result content.
  const ToolResultContent.text(String value)
      : text = value,
        jsonValue = null,
        image = null,
        document = null;

  /// Creates a JSON tool result content.
  const ToolResultContent.json(Map<String, dynamic> value)
      : text = null,
        jsonValue = value,
        image = null,
        document = null;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (text != null) map['text'] = text;
    if (jsonValue != null) map['json'] = json.encode(jsonValue);
    if (image != null) map['image'] = image!.toJson();
    if (document != null) map['document'] = document!.toJson();
    return map;
  }

  factory ToolResultContent.fromJson(Map<String, dynamic> jsonMap) {
    final rawJson = jsonMap['json'];
    Map<String, dynamic>? parsedJson;
    if (rawJson is String) {
      parsedJson = json.decode(rawJson) as Map<String, dynamic>;
    } else if (rawJson is Map<String, dynamic>) {
      parsedJson = rawJson;
    }

    return ToolResultContent(
      text: jsonMap['text'] as String?,
      jsonValue: parsedJson,
      image: jsonMap['image'] != null
          ? ImageBlock.fromJson(jsonMap['image'] as Map<String, dynamic>)
          : null,
      document: jsonMap['document'] != null
          ? DocumentBlock.fromJson(jsonMap['document'] as Map<String, dynamic>)
          : null,
    );
  }
}
