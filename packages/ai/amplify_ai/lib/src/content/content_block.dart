import 'dart:convert';

import 'package:meta/meta.dart';

/// Sealed class representing content blocks in AI messages.
/// Matches the AmplifyAIContentBlockInput type from the schema:
/// - text: String
/// - document: AmplifyAIDocumentBlockInput
/// - image: AmplifyAIImageBlockInput
/// - toolResult: AmplifyAIToolResultBlockInput
/// - toolUse: AmplifyAIToolUseBlockInput
@immutable
sealed class ContentBlock {
  const ContentBlock();

  /// Creates a text content block.
  factory ContentBlock.text(String text) = TextContentBlock;

  /// Creates an image content block.
  factory ContentBlock.image({required String format, required String source}) =
      ImageContentBlock;

  /// Creates a document content block.
  factory ContentBlock.document({
    required String format,
    required String name,
    required String source,
  }) = DocumentContentBlock;

  /// Creates a tool use content block.
  factory ContentBlock.toolUse({
    required String toolUseId,
    required String name,
    required Map<String, dynamic> input,
  }) = ToolUseContentBlock;

  /// Creates a tool result content block.
  factory ContentBlock.toolResult({
    required String toolUseId,
    required List<ToolResultContent> content,
    String? status,
  }) = ToolResultContentBlock;

  /// Serializes this content block to a JSON map.
  Map<String, dynamic> toJson();

  /// Deserializes a content block from a JSON map.
  static ContentBlock fromJson(Map<String, dynamic> json) {
    if (json.containsKey('text')) {
      return TextContentBlock(json['text'] as String);
    } else if (json.containsKey('image')) {
      final image = json['image'] as Map<String, dynamic>;
      final source = image['source'] as Map<String, dynamic>;
      return ImageContentBlock(
        format: image['format'] as String,
        source: source['bytes'] as String,
      );
    } else if (json.containsKey('document')) {
      final document = json['document'] as Map<String, dynamic>;
      final source = document['source'] as Map<String, dynamic>;
      return DocumentContentBlock(
        format: document['format'] as String,
        name: document['name'] as String,
        source: source['bytes'] as String,
      );
    } else if (json.containsKey('toolUse')) {
      final toolUse = json['toolUse'] as Map<String, dynamic>;
      final rawInput = toolUse['input'];
      final Map<String, dynamic> parsedInput;
      if (rawInput is Map<String, dynamic>) {
        parsedInput = rawInput;
      } else if (rawInput is String) {
        parsedInput = jsonDecode(rawInput) as Map<String, dynamic>;
      } else {
        parsedInput = {};
      }
      return ToolUseContentBlock(
        toolUseId: toolUse['toolUseId'] as String,
        name: toolUse['name'] as String,
        input: parsedInput,
      );
    } else if (json.containsKey('toolResult')) {
      final toolResult = json['toolResult'] as Map<String, dynamic>;
      final contentList = toolResult['content'] as List<dynamic>? ?? [];
      return ToolResultContentBlock(
        toolUseId: toolResult['toolUseId'] as String,
        content: contentList
            .map((c) => ToolResultContent.fromJson(c as Map<String, dynamic>))
            .toList(),
        status: toolResult['status'] as String?,
      );
    }
    throw ArgumentError('Unknown content block type: $json');
  }
}

/// A text content block.
@immutable
class TextContentBlock extends ContentBlock {
  /// Creates a text content block.
  const TextContentBlock(this.text);

  /// The text content.
  final String text;

  @override
  Map<String, dynamic> toJson() => {'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextContentBlock &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'TextContentBlock(text: $text)';
}

/// An image content block matching AmplifyAIImageBlockInput.
/// Schema: { format: String, source: { bytes: String } }
@immutable
class ImageContentBlock extends ContentBlock {
  /// Creates an image content block.
  const ImageContentBlock({required this.format, required this.source});

  /// The image format (e.g., 'png', 'jpeg', 'gif', 'webp').
  final String format;

  /// The base64-encoded image data.
  final String source;

  @override
  Map<String, dynamic> toJson() => {
    'image': {
      'format': format,
      'source': {'bytes': source},
    },
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageContentBlock &&
          runtimeType == other.runtimeType &&
          format == other.format &&
          source == other.source;

  @override
  int get hashCode => Object.hash(format, source);

  @override
  String toString() => 'ImageContentBlock(format: $format)';
}

/// A document content block matching AmplifyAIDocumentBlockInput.
/// Schema: { format: String, name: String, source: { bytes: String } }
@immutable
class DocumentContentBlock extends ContentBlock {
  /// Creates a document content block.
  const DocumentContentBlock({
    required this.format,
    required this.name,
    required this.source,
  });

  /// The document format (e.g., 'pdf', 'txt', 'md').
  final String format;

  /// The document name.
  final String name;

  /// The base64-encoded document data.
  final String source;

  @override
  Map<String, dynamic> toJson() => {
    'document': {
      'format': format,
      'name': name,
      'source': {'bytes': source},
    },
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentContentBlock &&
          runtimeType == other.runtimeType &&
          format == other.format &&
          name == other.name &&
          source == other.source;

  @override
  int get hashCode => Object.hash(format, name, source);

  @override
  String toString() => 'DocumentContentBlock(name: $name, format: $format)';
}

/// A tool use content block — the model is requesting tool execution.
/// Matches AmplifyAIToolUseBlockInput: { toolUseId: String, name: String, input: AWSJSON }
@immutable
class ToolUseContentBlock extends ContentBlock {
  /// Creates a tool use content block.
  const ToolUseContentBlock({
    required this.toolUseId,
    required this.name,
    required this.input,
  });

  /// The unique ID for this tool use invocation.
  final String toolUseId;

  /// The name of the tool to invoke.
  final String name;

  /// The input parameters for the tool (parsed from AWSJSON).
  final Map<String, dynamic> input;

  @override
  Map<String, dynamic> toJson() => {
    'toolUse': {
      'toolUseId': toolUseId,
      'name': name,
      // input is AWSJSON type — must be stringified on the wire
      'input': jsonEncode(input),
    },
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolUseContentBlock &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId &&
          name == other.name;

  @override
  int get hashCode => Object.hash(toolUseId, name);

  @override
  String toString() => 'ToolUseContentBlock(name: $name, id: $toolUseId)';
}

/// A tool result content block — the result of a tool execution.
/// Matches AmplifyAIToolResultBlockInput:
/// { toolUseId: String, status: String, content: [AmplifyAIToolResultContentBlockInput] }
///
/// Each content item in the array can have: text, json, image, document.
@immutable
class ToolResultContentBlock extends ContentBlock {
  /// Creates a tool result content block.
  const ToolResultContentBlock({
    required this.toolUseId,
    required this.content,
    this.status,
  });

  /// The tool use ID this result corresponds to.
  final String toolUseId;

  /// The content/result from executing the tool.
  /// Each item can contain text, json, image, or document.
  final List<ToolResultContent> content;

  /// The status of the tool execution (e.g., 'success', 'error').
  final String? status;

  @override
  Map<String, dynamic> toJson() => {
    'toolResult': {
      'toolUseId': toolUseId,
      'content': content.map((c) => c.toJson()).toList(),
      if (status != null) 'status': status,
    },
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolResultContentBlock &&
          runtimeType == other.runtimeType &&
          toolUseId == other.toolUseId;

  @override
  int get hashCode => toolUseId.hashCode;

  @override
  String toString() =>
      'ToolResultContentBlock(toolUseId: $toolUseId, status: $status)';
}

/// Content within a tool result, matching AmplifyAIToolResultContentBlockInput.
/// Can contain: text, json, image, document.
@immutable
class ToolResultContent {
  const ToolResultContent({this.text, this.json, this.image, this.document});

  /// Text content in the tool result.
  final String? text;

  /// JSON content in the tool result (AWSJSON — already a stringified JSON string).
  final String? json;

  /// Image content in the tool result.
  final Map<String, dynamic>? image;

  /// Document content in the tool result.
  final Map<String, dynamic>? document;

  Map<String, dynamic> toJson() => {
    if (text != null) 'text': text,
    if (json != null) 'json': json,
    if (image != null) 'image': image,
    if (document != null) 'document': document,
  };

  factory ToolResultContent.fromJson(Map<String, dynamic> jsonMap) {
    // Handle json field: it may come as a String (correct) or as a raw object
    final rawJson = jsonMap['json'];
    final String? jsonValue;
    if (rawJson is String) {
      jsonValue = rawJson;
    } else if (rawJson != null) {
      jsonValue = jsonEncode(rawJson);
    } else {
      jsonValue = null;
    }
    return ToolResultContent(
      text: jsonMap['text'] as String?,
      json: jsonValue,
      image: jsonMap['image'] as Map<String, dynamic>?,
      document: jsonMap['document'] as Map<String, dynamic>?,
    );
  }

  /// Convenience constructor for text-only tool result content.
  factory ToolResultContent.text(String text) => ToolResultContent(text: text);

  /// Convenience constructor for JSON tool result content.
  factory ToolResultContent.jsonContent(String jsonStr) =>
      ToolResultContent(json: jsonStr);
}
