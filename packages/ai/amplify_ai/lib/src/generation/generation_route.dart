import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';

import '../graphql/ai_graphql_documents.dart';

/// Response from a generation route.
class GenerationResponse {
  const GenerationResponse({required this.content});
  final String content;

  factory GenerationResponse.fromJson(Map<String, dynamic> json) {
    return GenerationResponse(content: json['content'] as String? ?? '');
  }
}

/// A route for AI generation (non-conversational, single prompt/response).
/// Uses Amplify.API directly — no manual wiring needed.
///
/// Usage:
/// ```dart
/// final summarizer = GenerationRoute(routeName: 'summarize');
/// final response = await summarizer.generate(prompt: 'Summarize this...');
/// ```
class GenerationRoute {
  /// Creates a generation route that uses Amplify.API directly.
  GenerationRoute({required this.routeName})
      : _documents = AIGraphQLDocuments(routeName: routeName);

  /// The name of this generation route from the AI config.
  final String routeName;

  final AIGraphQLDocuments _documents;

  /// Generates content from a prompt.
  Future<GenerationResponse> generate({
    required String prompt,
    Map<String, dynamic>? additionalContext,
  }) async {
    final document = _documents.generate();
    final request = GraphQLRequest<String>(
      document: document,
      variables: {
        'input': {
          'prompt': prompt,
          if (additionalContext != null) ...additionalContext,
        },
      },
    );

    final response = await Amplify.API.query(request: request).response;
    if (response.errors.isNotEmpty) {
      throw Exception(
        'GraphQL errors: ${response.errors.map((e) => e.message).join(', ')}',
      );
    }

    final data = response.data != null
        ? jsonDecode(response.data!) as Map<String, dynamic>
        : <String, dynamic>{};
    final fieldName = _documents.generateFieldName;
    final resultData = data['data']?[fieldName] ?? data[fieldName] ?? data;
    return GenerationResponse.fromJson(resultData as Map<String, dynamic>);
  }
}
