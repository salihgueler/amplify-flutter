import 'package:meta/meta.dart';

/// Sealed class representing content blocks in AI messages.
/// Mirrors the JS AI Kit ContentBlock type exactly.
@immutable
sealed class ContentBlock {
  const ContentBlock();

  /// Creates a text content block.
  factory ContentBlock.text(String text) = TextContentBlock;

  /// Creates an image content block.
  factory ContentBlock.image({
    required String format,
    required String source,
  }) = ImageContentBlock;

  /// Creates a tool use content block.
  factory ContentBlock.toolUse({
    required String toolUseId,
    required String name,
    required Map<String, dynamic> input,
  }) = ToolUseContentBlock;

  /// Creates a tool result content block.
  factory ContentBlock.toolResult({
    required String toolUseId,
    required Map<String, dynamic> content,
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
    } else if (json.containsKey('toolUse')) {
      final toolUse = json['toolUse'] as Map<String, dynamic>;
      return ToolUseContentBlock(
        toolUseId: toolUse['toolUseId'] as String,
        name: toolUse['name'] as String,
        input: toolUse['input'] as Map<String, dynamic>,
      );
    } else if (json.containsKey('toolResult')) {
      final toolResult = json['toolResult'] as Map<String, dynamic>;
      return ToolResultContentBlock(
        toolUseId: toolResult['toolUseId'] as String,
        content: toolResult['content'] as Map<String, dynamic>,
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

/// An image content block.
@immutable
class ImageContentBlock extends ContentBlock {
  /// Creates an image content block.
  const ImageContentBlock({
    required this.format,
    required this.source,
  });

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

/// A tool use content block — the model is requesting tool execution.
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

  /// The input parameters for the tool.
  final Map<String, dynamic> input;

  @override
  Map<String, dynamic> toJson() => {
        'toolUse': {
          'toolUseId': toolUseId,
          'name': name,
          'input': input,
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
  final Map<String, dynamic> content;

  /// The status of the tool execution (e.g., 'success', 'error').
  final String? status;

  @override
  Map<String, dynamic> toJson() => {
        'toolResult': {
          'toolUseId': toolUseId,
          'content': content,
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
