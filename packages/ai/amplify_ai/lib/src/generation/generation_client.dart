import 'dart:async';

import '../graphql/ai_graphql_documents.dart';
import '../graphql/ai_graphql_request_factory.dart';

/// Client for AI generation routes (non-conversational).
/// Mirrors the JS AI Kit generation client pattern.
///
/// Generation uses a GraphQL query where the field name IS the route name
/// (e.g., `summarize`, `generateCode`, `describeImage`).
class GenerationClient {
  /// Creates a generation client.
  GenerationClient({
    required this.routeName,
    required this.graphqlRequestFactory,
    required this.variables,
    required this.args,
    required this.selectionSet,
  }) : _documents = AIGraphQLDocuments(routeName: routeName);

  /// The name of this generation route.
  final String routeName;

  /// The GraphQL request factory for making API calls.
  final AIGraphQLRequestFactory graphqlRequestFactory;

  /// GraphQL variable declarations for this route.
  /// Example: r'$text: String!, $maxLength: Int'
  final String variables;

  /// GraphQL field arguments for this route.
  /// Example: r'text: $text, maxLength: $maxLength'
  final String args;

  /// GraphQL selection set (return fields) for this route.
  /// Example: 'summary keyPoints'
  final String selectionSet;

  final AIGraphQLDocuments _documents;

  /// Generates content based on the provided arguments.
  /// Returns the response data as a map.
  ///
  /// The [arguments] map should contain the typed input arguments as defined
  /// in the schema (e.g., `{'text': 'some text', 'maxLength': 200}`).
  Future<Map<String, dynamic>> generate(Map<String, dynamic> arguments) async {
    final document = _documents.generate(
      variables: variables,
      args: args,
      selectionSet: selectionSet,
    );

    final response = await graphqlRequestFactory.query(
      document: document,
      variables: arguments,
    );

    final fieldName = _documents.generateFieldName;
    final data = response['data']?[fieldName];
    if (data is String) {
      return {'content': data};
    } else if (data is Map<String, dynamic>) {
      return data;
    }
    return {};
  }

  /// Generates content and returns a stream of results.
  Stream<Map<String, dynamic>> generateStream(Map<String, dynamic> arguments) {
    final controller = StreamController<Map<String, dynamic>>();

    _handleGeneration(controller: controller, arguments: arguments);

    return controller.stream;
  }

  Future<void> _handleGeneration({
    required StreamController<Map<String, dynamic>> controller,
    required Map<String, dynamic> arguments,
  }) async {
    try {
      final result = await generate(arguments);
      controller.add(result);
    } catch (e) {
      controller.addError(e);
    } finally {
      await controller.close();
    }
  }
}
