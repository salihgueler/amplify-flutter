import 'dart:convert';

import 'package:amplify_core/amplify_core.dart';

import '../client/ai_client.dart';
import '../client/ai_client_options.dart';
import '../config/ai_config_parser.dart';
import '../config/ai_route_config.dart';
import '../content/tool_configuration.dart';
import '../content/tool_use_handler.dart';
import '../conversation/conversation_route.dart';
import '../generation/generation_route.dart';
import '../graphql/ai_graphql_request_factory.dart';
import '../graphql/ai_graphql_subscription_handler.dart';

/// The Amplify AI plugin — zero-boilerplate AI integration.
///
/// Internally uses Amplify.API for all GraphQL operations. Users never
/// need to create GraphQL factories or subscription handlers manually.
///
/// ## Setup (in main.dart):
/// ```dart
/// await Amplify.addPlugins([...]);
/// await Amplify.configure(amplifyConfig);
/// AmplifyAI.instance.configure(
///   outputsConfig: amplifyConfig,
///   api: Amplify.API,
/// );
/// ```
///
/// ## Usage (zero config):
/// ```dart
/// final chat = AmplifyAI.instance.conversation('chat');
/// // or just use the widget:
/// AmplifyAIConversation(routeName: 'chat')
/// ```
class AmplifyAI {
  AmplifyAI._();

  /// The global singleton instance.
  static final AmplifyAI instance = AmplifyAI._();

  AIClient? _client;
  Map<String, AIRouteConfig> _routeConfigs = {};
  bool _isConfigured = false;

  /// Whether this plugin has been configured.
  bool get isConfigured => _isConfigured;

  /// The underlying AI client.
  AIClient get client {
    _ensureConfigured();
    return _client!;
  }

  /// Configures the AI plugin from amplify_outputs config.
  ///
  /// This is the ONLY setup needed. Internally creates all GraphQL
  /// request factories and subscription handlers from [api].
  ///
  /// ```dart
  /// AmplifyAI.instance.configure(
  ///   outputsConfig: amplifyConfig,
  ///   api: Amplify.API,
  /// );
  /// ```
  void configure({
    required Map<String, dynamic> outputsConfig,
    required APICategory api,
    AIClientOptions options = const AIClientOptions(),
  }) {
    // Internally create the request factory from Amplify.API
    final graphqlRequestFactory = AIGraphQLRequestFactory(
      queryFn: ({required document, required variables}) async {
        final request = GraphQLRequest<String>(
          document: document,
          variables: variables,
        );
        final operation = api.query(request: request);
        final response = await operation.response;
        if (response.errors.isNotEmpty) {
          throw Exception(
            'GraphQL query errors: ${response.errors.map((e) => e.message).join(', ')}',
          );
        }
        return _parseResponse(response.data);
      },
      mutateFn: ({required document, required variables}) async {
        final request = GraphQLRequest<String>(
          document: document,
          variables: variables,
        );
        final operation = api.mutate(request: request);
        final response = await operation.response;
        if (response.errors.isNotEmpty) {
          throw Exception(
            'GraphQL mutation errors: ${response.errors.map((e) => e.message).join(', ')}',
          );
        }
        return _parseResponse(response.data);
      },
    );

    // Internally create the subscription handler from Amplify.API
    final subscriptionHandler = AIGraphQLSubscriptionHandler(
      subscribeFn: ({required document, required variables}) {
        final request = GraphQLRequest<String>(
          document: document,
          variables: variables,
        );
        return api.subscribe(request).map((response) {
          if (response.errors.isNotEmpty) {
            throw Exception(
              'GraphQL subscription errors: '
              '${response.errors.map((e) => e.message).join(', ')}',
            );
          }
          return _parseResponse(response.data);
        });
      },
    );

    _routeConfigs = AIConfigParser.parse(outputsConfig);
    _client = AIClient.fromOutputsConfig(
      outputsConfig: outputsConfig,
      graphqlRequestFactory: graphqlRequestFactory,
      subscriptionHandler: subscriptionHandler,
      options: options,
    );
    _isConfigured = true;
  }

  /// Gets a conversation route by name.
  ///
  /// ```dart
  /// final chat = AmplifyAI.instance.conversation('chat');
  /// ```
  ConversationRoute conversation(
    String routeName, {
    ToolConfiguration? toolConfiguration,
    ToolUseHandler? toolHandler,
  }) {
    _ensureConfigured();
    return _client!.conversation(
      routeName,
      toolConfiguration: toolConfiguration,
      toolHandler: toolHandler,
    );
  }

  /// Gets a generation route by name.
  ///
  /// ```dart
  /// final recipe = AmplifyAI.instance.generation('recipe');
  /// ```
  GenerationRoute generation(String routeName) {
    _ensureConfigured();
    return _client!.generation(routeName);
  }

  /// Returns all available route configurations.
  Map<String, AIRouteConfig> get routes {
    _ensureConfigured();
    return Map.unmodifiable(_routeConfigs);
  }

  /// Returns the names of all conversation routes.
  List<String> get conversationRouteNames {
    _ensureConfigured();
    return _client!.conversationRouteNames;
  }

  /// Returns the names of all generation routes.
  List<String> get generationRouteNames {
    _ensureConfigured();
    return _client!.generationRouteNames;
  }

  /// Resets the plugin configuration (for testing).
  void reset() {
    _client = null;
    _routeConfigs = {};
    _isConfigured = false;
  }

  void _ensureConfigured() {
    if (!_isConfigured || _client == null) {
      throw StateError(
        'AmplifyAI has not been configured. '
        'Call AmplifyAI.instance.configure() before using AI features.\n\n'
        'Example:\n'
        '  AmplifyAI.instance.configure(\n'
        '    outputsConfig: amplifyConfig,\n'
        '    api: Amplify.API,\n'
        '  );',
      );
    }
  }

  /// Parses a GraphQL response data string into a Map.
  static Map<String, dynamic> _parseResponse(String? data) {
    if (data == null || data.isEmpty) {
      return <String, dynamic>{};
    }
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{'data': decoded};
    } catch (_) {
      return <String, dynamic>{'data': data};
    }
  }
}
