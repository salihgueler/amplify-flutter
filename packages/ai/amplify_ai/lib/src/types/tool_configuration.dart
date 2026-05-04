// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Tool configuration types for AI conversations.

import 'dart:convert';

import 'package:meta/meta.dart';

/// Configuration for tools available to the AI model.
@immutable
class ToolConfiguration {
  /// The list of tools available.
  final List<Tool> tools;

  const ToolConfiguration({required this.tools});

  Map<String, dynamic> toJson() => {
        'tools': tools.map((t) => t.toJson()).toList(),
      };

  factory ToolConfiguration.fromJson(Map<String, dynamic> json) {
    return ToolConfiguration(
      tools: (json['tools'] as List<dynamic>)
          .map((e) => Tool.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A single tool definition.
@immutable
class Tool {
  /// The tool specification.
  final ToolSpecification toolSpec;

  const Tool({required this.toolSpec});

  Map<String, dynamic> toJson() => {
        'toolSpec': toolSpec.toJson(),
      };

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      toolSpec:
          ToolSpecification.fromJson(json['toolSpec'] as Map<String, dynamic>),
    );
  }
}

/// Specification for a tool including its name, description, and input schema.
@immutable
class ToolSpecification {
  /// The name of the tool (1-64 chars, alphanumeric + underscore).
  final String name;

  /// A description of what the tool does.
  final String? description;

  /// The JSON schema defining the tool's input parameters.
  final ToolInputSchema inputSchema;

  const ToolSpecification({
    required this.name,
    this.description,
    required this.inputSchema,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        'inputSchema': inputSchema.toJson(),
      };

  factory ToolSpecification.fromJson(Map<String, dynamic> json) {
    return ToolSpecification(
      name: json['name'] as String,
      description: json['description'] as String?,
      inputSchema:
          ToolInputSchema.fromJson(json['inputSchema'] as Map<String, dynamic>),
    );
  }
}

/// The input schema for a tool, specified as a JSON schema.
@immutable
class ToolInputSchema {
  /// The JSON schema object defining the input parameters.
  final Map<String, dynamic> json;

  const ToolInputSchema({required this.json});

  Map<String, dynamic> toJson() {
    final encoded = jsonEncode(json);
    return {'json': encoded};
  }

  factory ToolInputSchema.fromJson(Map<String, dynamic> jsonMap) {
    final rawJson = jsonMap['json'];
    Map<String, dynamic> parsedJson;
    if (rawJson is String) {
      parsedJson = jsonDecode(rawJson) as Map<String, dynamic>;
    } else if (rawJson is Map<String, dynamic>) {
      parsedJson = rawJson;
    } else {
      parsedJson = <String, dynamic>{};
    }
    return ToolInputSchema(json: parsedJson);
  }
}
