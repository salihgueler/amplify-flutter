import 'dart:async';

import '../graphql/ai_graphql_documents.dart';
import '../graphql/ai_graphql_request_factory.dart';

/// Client for AI generation routes (non-conversational).
/// Mirrors the JS AI Kit generation client pattern.
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

  /// Generates content based on the provided prompt.
  /// Returns the generated content as a string.
  Future<String> generate({
    required String prompt,
    Map<String, dynamic>? inferenceConfiguration,
  }) async {
    final document = _documents.generate();
    final variables = <String, dynamic>{
      'input': {
        'prompt': prompt,
        if (inferenceConfiguration != null)
          'inferenceConfiguration': inferenceConfiguration,
      },
    };

    final response = await graphqlRequestFactory.mutate(
      document: document,
      variables: variables,
    );

    return response['data']?['generate'] as String? ?? '';
  }

  /// Generates content and returns a stream of text chunks.
  Stream<String> generateStream({
    required String prompt,
    Map<String, dynamic>? inferenceConfiguration,
  }) {
    final controller = StreamController<String>();

    _handleGeneration(
      controller: controller,
      prompt: prompt,
      inferenceConfiguration: inferenceConfiguration,
    );

    return controller.stream;
  }

  Future<void> _handleGeneration({
    required StreamController<String> controller,
    required String prompt,
    Map<String, dynamic>? inferenceConfiguration,
  }) async {
    try {
      final result = await generate(
        prompt: prompt,
        inferenceConfiguration: inferenceConfiguration,
      );
      controller.add(result);
    } catch (e) {
      controller.addError(e);
    } finally {
      await controller.close();
    }
  }
}
