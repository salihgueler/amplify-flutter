import 'dart:convert';

import 'package:meta/meta.dart';

/// Tool configuration for AI conversations.
/// Mirrors the JS AI Kit ToolConfiguration type.
@immutable
class ToolConfiguration {
  /// Creates a tool configuration.
  const ToolConfiguration({required this.tools, this.toolChoice});

  /// The list of tools available for the model to use.
  final List<ToolSpec> tools;

  /// Controls how the model selects tools.
  /// Can be 'auto', 'any', or a specific tool name.
  final ToolChoice? toolChoice;

  /// Serializes this configuration to JSON.
  Map<String, dynamic> toJson() => {
    'tools': tools.map((t) => t.toJson()).toList(),
    if (toolChoice != null) 'toolChoice': toolChoice!.toJson(),
  };

  /// Deserializes a tool configuration from JSON.
  factory ToolConfiguration.fromJson(Map<String, dynamic> json) {
    final toolsList = (json['tools'] as List<dynamic>)
        .map((t) => ToolSpec.fromJson(t as Map<String, dynamic>))
        .toList();
    final toolChoiceJson = json['toolChoice'] as Map<String, dynamic>?;
    return ToolConfiguration(
      tools: toolsList,
      toolChoice: toolChoiceJson != null
          ? ToolChoice.fromJson(toolChoiceJson)
          : null,
    );
  }
}

/// Specification for a single tool available to the model.
@immutable
class ToolSpec {
  /// Creates a tool specification.
  const ToolSpec({
    required this.name,
    required this.description,
    required this.inputSchema,
  });

  /// The name of the tool.
  final String name;

  /// A description of what the tool does.
  final String description;

  /// The JSON schema for the tool's input parameters.
  final Map<String, dynamic> inputSchema;

  /// Serializes this tool spec to JSON.
  /// Note: inputSchema.json is AWSJSON type — it must be a JSON-encoded string,
  /// not a raw Map. This matches the JS behavior: JSON.stringify(tool.inputSchema.json)
  Map<String, dynamic> toJson() => {
    'toolSpec': {
      'name': name,
      'description': description,
      'inputSchema': {'json': jsonEncode(inputSchema)},
    },
  };

  /// Deserializes a tool spec from JSON.
  factory ToolSpec.fromJson(Map<String, dynamic> json) {
    final spec = json['toolSpec'] as Map<String, dynamic>? ?? json;
    final inputSchemaWrapper =
        spec['inputSchema'] as Map<String, dynamic>? ?? {};
    final jsonField = inputSchemaWrapper['json'];
    // Handle both string (AWSJSON) and raw Map formats
    final Map<String, dynamic> parsedSchema;
    if (jsonField is String) {
      parsedSchema = jsonDecode(jsonField) as Map<String, dynamic>;
    } else if (jsonField is Map<String, dynamic>) {
      parsedSchema = jsonField;
    } else {
      parsedSchema = inputSchemaWrapper;
    }
    return ToolSpec(
      name: spec['name'] as String,
      description: spec['description'] as String,
      inputSchema: parsedSchema,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolSpec &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// Controls how the model selects tools.
@immutable
class ToolChoice {
  const ToolChoice._({this.auto, this.any, this.tool});

  /// Let the model decide whether to use a tool.
  const ToolChoice.auto() : this._(auto: const {});

  /// Force the model to use any tool.
  const ToolChoice.any() : this._(any: const {});

  /// Force the model to use a specific tool.
  ToolChoice.specific(String toolName) : this._(tool: {'name': toolName});

  /// Auto tool choice indicator.
  final Map<String, dynamic>? auto;

  /// Any tool choice indicator.
  final Map<String, dynamic>? any;

  /// Specific tool choice indicator.
  final Map<String, dynamic>? tool;

  /// Serializes this tool choice to JSON.
  Map<String, dynamic> toJson() {
    if (auto != null) return {'auto': auto};
    if (any != null) return {'any': any};
    if (tool != null) return {'tool': tool};
    return {};
  }

  /// Deserializes a tool choice from JSON.
  factory ToolChoice.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('auto')) return const ToolChoice.auto();
    if (json.containsKey('any')) return const ToolChoice.any();
    if (json.containsKey('tool')) {
      final tool = json['tool'] as Map<String, dynamic>;
      return ToolChoice.specific(tool['name'] as String);
    }
    return const ToolChoice.auto();
  }
}
