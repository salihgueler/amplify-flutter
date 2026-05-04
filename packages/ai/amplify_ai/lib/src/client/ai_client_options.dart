import 'package:meta/meta.dart';

import '../content/tool_configuration.dart';
import '../content/tool_use_handler.dart';

/// Options for configuring the AI client.
@immutable
class AIClientOptions {
  /// Creates AI client options.
  const AIClientOptions({
    this.toolConfiguration,
    this.toolHandler,
    this.apiEndpoint,
    this.authMode,
  });

  /// Default tool configuration applied to all routes.
  final ToolConfiguration? toolConfiguration;

  /// Default tool handler for processing tool use requests.
  final ToolUseHandler? toolHandler;

  /// Optional custom API endpoint override.
  final String? apiEndpoint;

  /// The authentication mode to use for requests.
  final AIAuthMode? authMode;

  /// Creates a copy with optional overrides.
  AIClientOptions copyWith({
    ToolConfiguration? toolConfiguration,
    ToolUseHandler? toolHandler,
    String? apiEndpoint,
    AIAuthMode? authMode,
  }) {
    return AIClientOptions(
      toolConfiguration: toolConfiguration ?? this.toolConfiguration,
      toolHandler: toolHandler ?? this.toolHandler,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      authMode: authMode ?? this.authMode,
    );
  }
}

/// Authentication mode for AI API requests.
enum AIAuthMode {
  /// Amazon Cognito User Pools authentication.
  userPool,

  /// IAM authentication.
  iam,

  /// API Key authentication.
  apiKey,

  /// OpenID Connect authentication.
  oidc,

  /// Lambda authorizer authentication.
  lambda,
}
