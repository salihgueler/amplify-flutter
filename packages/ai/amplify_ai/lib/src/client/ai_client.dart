import '../config/ai_config_parser.dart';
import '../config/ai_route_config.dart';
import '../content/tool_configuration.dart';
import '../content/tool_use_handler.dart';
import '../conversation/conversation_route.dart';
import '../generation/generation_route.dart';
import '../graphql/ai_graphql_request_factory.dart';
import '../graphql/ai_graphql_subscription_handler.dart';
import 'ai_client_options.dart';

/// The main AI client that provides access to conversation and generation routes.
/// Mirrors the JS AI Kit client created via `client.ai`.
class AIClient {
  /// Creates an AI client from configuration and GraphQL factories.
  AIClient({
    required this.config,
    required this.graphqlRequestFactory,
    required this.subscriptionHandler,
    this.options = const AIClientOptions(),
  }) : _routes = AIConfigParser.parseAIConfig(config);

  /// The AI configuration map.
  final Map<String, dynamic> config;

  /// The GraphQL request factory.
  final AIGraphQLRequestFactory graphqlRequestFactory;

  /// The subscription handler.
  final AIGraphQLSubscriptionHandler subscriptionHandler;

  /// Client options.
  final AIClientOptions options;

  /// Parsed route configurations.
  final Map<String, AIRouteConfig> _routes;

  /// Cache of conversation route instances.
  final Map<String, ConversationRoute> _conversationRoutes = {};

  /// Cache of generation route instances.
  final Map<String, GenerationRoute> _generationRoutes = {};

  /// Gets a conversation route by name.
  /// Throws [ArgumentError] if the route is not found or is not a conversation route.
  ConversationRoute conversation(
    String routeName, {
    ToolConfiguration? toolConfiguration,
    ToolUseHandler? toolHandler,
  }) {
    final cacheKey =
        '$routeName:${toolConfiguration.hashCode}:${toolHandler.hashCode}';

    return _conversationRoutes.putIfAbsent(cacheKey, () {
      final routeConfig = _routes[routeName];
      if (routeConfig == null) {
        throw ArgumentError(
          'Conversation route "$routeName" not found in AI config. '
          'Available routes: ${_routes.keys.join(', ')}',
        );
      }
      if (routeConfig.routeType != AIRouteType.conversation) {
        throw ArgumentError(
          'Route "$routeName" is a ${routeConfig.routeType.value} route, '
          'not a conversation route.',
        );
      }

      return ConversationRoute(
        routeName: routeName,
        graphqlRequestFactory: graphqlRequestFactory,
        subscriptionHandler: subscriptionHandler,
        toolConfiguration: toolConfiguration ?? options.toolConfiguration,
        toolHandler: toolHandler ?? options.toolHandler,
      );
    });
  }

  /// Gets a generation route by name.
  /// Throws [ArgumentError] if the route is not found or is not a generation route.
  GenerationRoute generation(String routeName) {
    return _generationRoutes.putIfAbsent(routeName, () {
      final routeConfig = _routes[routeName];
      if (routeConfig == null) {
        throw ArgumentError(
          'Generation route "$routeName" not found in AI config. '
          'Available routes: ${_routes.keys.join(', ')}',
        );
      }
      if (routeConfig.routeType != AIRouteType.generation) {
        throw ArgumentError(
          'Route "$routeName" is a ${routeConfig.routeType.value} route, '
          'not a generation route.',
        );
      }

      return GenerationRoute(
        routeName: routeName,
        graphqlRequestFactory: graphqlRequestFactory,
      );
    });
  }

  /// Returns all available route configurations.
  Map<String, AIRouteConfig> get routes => Map.unmodifiable(_routes);

  /// Returns the names of all conversation routes.
  List<String> get conversationRouteNames => _routes.entries
      .where((e) => e.value.routeType == AIRouteType.conversation)
      .map((e) => e.key)
      .toList();

  /// Returns the names of all generation routes.
  List<String> get generationRouteNames => _routes.entries
      .where((e) => e.value.routeType == AIRouteType.generation)
      .map((e) => e.key)
      .toList();

  /// Creates an AI client from a full amplify_outputs.json config map.
  factory AIClient.fromOutputsConfig({
    required Map<String, dynamic> outputsConfig,
    required AIGraphQLRequestFactory graphqlRequestFactory,
    required AIGraphQLSubscriptionHandler subscriptionHandler,
    AIClientOptions options = const AIClientOptions(),
  }) {
    final aiConfig = outputsConfig['ai'] as Map<String, dynamic>? ?? {};
    return AIClient(
      config: aiConfig,
      graphqlRequestFactory: graphqlRequestFactory,
      subscriptionHandler: subscriptionHandler,
      options: options,
    );
  }
}
