import 'package:meta/meta.dart';

/// Configuration for an AI route (conversation or generation).
/// Mirrors the JS AI Kit route configuration from amplify_outputs.json.
@immutable
class AIRouteConfig {
  /// Creates an AI route configuration.
  const AIRouteConfig({
    required this.routeName,
    required this.routeType,
    this.modelId,
    this.systemPrompt,
    this.inferenceConfiguration,
  });

  /// The name of this route.
  final String routeName;

  /// The type of route: 'conversation' or 'generation'.
  final AIRouteType routeType;

  /// The model ID to use (e.g., 'anthropic.claude-3-sonnet').
  final String? modelId;

  /// The system prompt for this route.
  final String? systemPrompt;

  /// Default inference configuration for this route.
  final InferenceConfiguration? inferenceConfiguration;

  /// Deserializes from JSON.
  factory AIRouteConfig.fromJson(Map<String, dynamic> json) {
    return AIRouteConfig(
      routeName: json['routeName'] as String? ?? json['name'] as String? ?? '',
      routeType: AIRouteType.fromString(json['routeType'] as String? ?? ''),
      modelId: json['modelId'] as String?,
      systemPrompt: json['systemPrompt'] as String?,
      inferenceConfiguration: json['inferenceConfiguration'] != null
          ? InferenceConfiguration.fromJson(
              json['inferenceConfiguration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    'routeName': routeName,
    'routeType': routeType.value,
    if (modelId != null) 'modelId': modelId,
    if (systemPrompt != null) 'systemPrompt': systemPrompt,
    if (inferenceConfiguration != null)
      'inferenceConfiguration': inferenceConfiguration!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIRouteConfig &&
          runtimeType == other.runtimeType &&
          routeName == other.routeName;

  @override
  int get hashCode => routeName.hashCode;

  @override
  String toString() =>
      'AIRouteConfig(routeName: $routeName, routeType: ${routeType.value})';
}

/// The type of an AI route.
enum AIRouteType {
  /// A conversation route supporting multi-turn chat.
  conversation('conversation'),

  /// A generation route for single prompt/response.
  generation('generation');

  const AIRouteType(this.value);

  /// The string value of this route type.
  final String value;

  /// Parses a route type from a string.
  static AIRouteType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'conversation':
        return AIRouteType.conversation;
      case 'generation':
        return AIRouteType.generation;
      default:
        return AIRouteType.conversation;
    }
  }
}

/// Inference configuration for AI model requests.
@immutable
class InferenceConfiguration {
  /// Creates an inference configuration.
  const InferenceConfiguration({
    this.maxTokens,
    this.temperature,
    this.topP,
    this.stopSequences,
  });

  /// Maximum number of tokens to generate.
  final int? maxTokens;

  /// Temperature for randomness in generation (0.0 - 1.0).
  final double? temperature;

  /// Top-p (nucleus) sampling parameter.
  final double? topP;

  /// Sequences that will stop generation when encountered.
  final List<String>? stopSequences;

  /// Deserializes from JSON.
  factory InferenceConfiguration.fromJson(Map<String, dynamic> json) {
    return InferenceConfiguration(
      maxTokens: json['maxTokens'] as int?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['topP'] as num?)?.toDouble(),
      stopSequences: (json['stopSequences'] as List<dynamic>?)
          ?.map((s) => s as String)
          .toList(),
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
    if (maxTokens != null) 'maxTokens': maxTokens,
    if (temperature != null) 'temperature': temperature,
    if (topP != null) 'topP': topP,
    if (stopSequences != null) 'stopSequences': stopSequences,
  };
}
