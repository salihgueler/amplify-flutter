import 'dart:async';

import '../graphql/ai_graphql_documents.dart';
import '../graphql/ai_graphql_request_factory.dart';

/// Client for AI generation routes (non-conversational).
/// Mirrors the JS AI Kit generation client pattern.
///
/// Generation uses a GraphQL query with the pattern `generate{RouteName}`.
class GenerationClient {
  /// Creates a generation client.
  GenerationClient({
    required this.routeName,
    required this.graphqlRequestFactory,
  }) : _documents = AIGraphQLDocuments(routeName: routeName);

  /// The name of this generation route.
  final String routeName;

  /// The GraphQL request factory for making API calls.
  final AIGraphQLRequestFactory graphqlRequestFactory;

  final AIGraphQLDocuments _documents;

  /// Generates content based on the provided arguments.
  /// Returns the generated content as a string.
  ///
  /// The [args] map should contain the input arguments as defined
  /// in the schema (e.g., `{'input': 'some text'}` or `{'description': '...'}`).
  Future<String> generate(Map<String, dynamic> args) async {
    final document = _documents.generate();
    final variables = <String, dynamic>{
      ...args,
    };

    final response = await graphqlRequestFactory.query(
      document: document,
      variables: variables,
    );

    final fieldName = _documents.generateFieldName;
    final data = response['data']?[fieldName];
    if (data is String) {
      return data;
    } else if (data is Map<String, dynamic>) {
      return data['content'] as String? ?? '';
    }
    return '';
  }

  /// Generates content and returns a stream of text chunks.
  Stream<String> generateStream(Map<String, dynamic> args) {
    final controller = StreamController<String>();

    _handleGeneration(
      controller: controller,
      args: args,
    );

    return controller.stream;
  }

  Future<void> _handleGeneration({
    required StreamController<String> controller,
    required Map<String, dynamic> args,
  }) async {
    try {
      final result = await generate(args);
      controller.add(result);
    } catch (e) {
      controller.addError(e);
    } finally {
      await controller.close();
    }
  }
}
