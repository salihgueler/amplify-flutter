import 'ai_route_config.dart';

/// Parser for AI configuration from amplify_outputs.json.
/// Extracts AI route configurations from the Amplify outputs config.
class AIConfigParser {
  const AIConfigParser._();

  /// Parses AI configuration from the full amplify_outputs.json map.
  /// Returns a map of route name to route configuration.
  static Map<String, AIRouteConfig> parse(Map<String, dynamic> config) {
    final aiConfig = config['ai'] as Map<String, dynamic>?;
    if (aiConfig == null) return {};

    return parseAIConfig(aiConfig);
  }

  /// Parses the AI section of the config directly.
  static Map<String, AIRouteConfig> parseAIConfig(
    Map<String, dynamic> aiConfig,
  ) {
    final routes = <String, AIRouteConfig>{};

    // Parse conversation routes
    final conversationRoutes =
        aiConfig['conversation'] as Map<String, dynamic>?;
    if (conversationRoutes != null) {
      for (final entry in conversationRoutes.entries) {
        final routeConfig = entry.value as Map<String, dynamic>;
        routes[entry.key] = AIRouteConfig(
          routeName: entry.key,
          routeType: AIRouteType.conversation,
          modelId: routeConfig['modelId'] as String?,
          systemPrompt: routeConfig['systemPrompt'] as String?,
          inferenceConfiguration: routeConfig['inferenceConfiguration'] != null
              ? InferenceConfiguration.fromJson(
                  routeConfig['inferenceConfiguration'] as Map<String, dynamic>,
                )
              : null,
        );
      }
    }

    // Parse generation routes
    final generationRoutes = aiConfig['generation'] as Map<String, dynamic>?;
    if (generationRoutes != null) {
      for (final entry in generationRoutes.entries) {
        final routeConfig = entry.value as Map<String, dynamic>;
        routes[entry.key] = AIRouteConfig(
          routeName: entry.key,
          routeType: AIRouteType.generation,
          modelId: routeConfig['modelId'] as String?,
          systemPrompt: routeConfig['systemPrompt'] as String?,
          inferenceConfiguration: routeConfig['inferenceConfiguration'] != null
              ? InferenceConfiguration.fromJson(
                  routeConfig['inferenceConfiguration'] as Map<String, dynamic>,
                )
              : null,
        );
      }
    }

    return routes;
  }

  /// Gets conversation route configs only.
  static Map<String, AIRouteConfig> getConversationRoutes(
    Map<String, dynamic> config,
  ) {
    final routes = parse(config);
    return Map.fromEntries(
      routes.entries
          .where((e) => e.value.routeType == AIRouteType.conversation),
    );
  }

  /// Gets generation route configs only.
  static Map<String, AIRouteConfig> getGenerationRoutes(
    Map<String, dynamic> config,
  ) {
    final routes = parse(config);
    return Map.fromEntries(
      routes.entries.where((e) => e.value.routeType == AIRouteType.generation),
    );
  }
}
