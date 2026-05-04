import '../client/ai_client.dart';
import '../client/ai_client_options.dart';
import '../config/ai_config_parser.dart';
import '../config/ai_route_config.dart';
import '../conversation/conversation_route.dart';
import '../generation/generation_route.dart';
import '../graphql/ai_graphql_request_factory.dart';
import '../graphql/ai_graphql_subscription_handler.dart';

/// The Amplify AI category plugin.
/// Provides access to AI conversation and generation routes
/// through the Amplify plugin system.
class AmplifyAICategory {
  /// Creates the AI category.
  AmplifyAICategory();

  AIClient? _client;
  Map<String, AIRouteConfig> _routeConfigs = {};
  bool _isConfigured = false;

  /// Whether this category has been configured.
  bool get isConfigured => _isConfigured;

  /// The underlying AI client.
  AIClient get client {
    _ensureConfigured();
    return _client!;
  }

  /// Configures the AI category with the given outputs config and dependencies.
  void configure({
    required Map<String, dynamic> outputsConfig,
    required AIGraphQLRequestFactory graphqlRequestFactory,
    required AIGraphQLSubscriptionHandler subscriptionHandler,
    AIClientOptions options = const AIClientOptions(),
  }) {
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
  ConversationRoute conversation(String routeName) {
    _ensureConfigured();
    return _client!.conversation(routeName);
  }

  /// Gets a generation route by name.
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

  /// Resets the category configuration.
  void reset() {
    _client = null;
    _routeConfigs = {};
    _isConfigured = false;
  }

  void _ensureConfigured() {
    if (!_isConfigured || _client == null) {
      throw StateError(
        'AmplifyAICategory has not been configured. '
        'Call configure() before using AI features.',
      );
    }
  }
}
