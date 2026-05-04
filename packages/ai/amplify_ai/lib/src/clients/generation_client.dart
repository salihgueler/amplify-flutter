// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Generation client for single request-response AI operations.

import '../config/ai_config.dart';
import '../types/conversation.dart';
import 'graphql_api_provider.dart';

/// Client for invoking AI generation routes.
///
/// Generation routes are single request-response operations (not streaming).
/// They take typed arguments and return typed results via GraphQL queries.
class GenerationClient {
  final GenerationRouteConfig _config;
  final GraphQLAPIProvider _api;

  /// Creates a generation client for the given route configuration.
  GenerationClient({
    required GenerationRouteConfig config,
    required GraphQLAPIProvider api,
  })  : _config = config,
        _api = api;

  /// The route name for this generation client.
  String get routeName => _config.name;

  /// Invokes the generation with the given arguments.
  ///
  /// The [arguments] map is passed as GraphQL variables.
  /// The response is returned as a raw map that can be decoded
  /// to your expected return type.
  ///
  /// Example:
  /// ```dart
  /// final result = await generationClient.generate(
  ///   arguments: {'description': 'A spicy pasta dish'},
  /// );
  /// if (result.hasData) {
  ///   print(result.data); // { 'name': '...', 'ingredients': [...] }
  /// }
  /// ```
  Future<SingleResult<Map<String, dynamic>>> generate({
    required Map<String, dynamic> arguments,
  }) async {
    // Build a simple query document for the generation
    final argEntries = arguments.entries.toList();
    final argDefs = argEntries.map((e) => '\$${e.key}: String').join(', ');
    final argParams = argEntries.map((e) => '${e.key}: \$${e.key}').join(', ');

    final document = '''
      query Generation($argDefs) {
        ${_config.queryFieldName}($argParams)
      }
    ''';

    final response = await _api.query(
      document: document,
      variables: arguments,
    );

    if (response.hasErrors) {
      return SingleResult(
        errors: response.errors!
            .map((e) => GraphQLResponseError.fromJson(e))
            .toList(),
      );
    }

    final data =
        response.data?[_config.queryFieldName] as Map<String, dynamic>?;
    return SingleResult(data: data);
  }
}
