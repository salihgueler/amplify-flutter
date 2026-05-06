import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';

import '../graphql/ai_graphql_documents.dart';

/// Response from a generation route.
/// Holds the parsed response data as a map of field name → value.
class GenerationResponse {
  const GenerationResponse({required this.data});

  /// The raw response data map (e.g., {'summary': '...', 'keyPoints': '...'}).
  final Map<String, dynamic> data;

  /// Gets a field value by name.
  String? operator [](String key) => data[key]?.toString();

  /// Gets the first string value from the response (convenience for simple responses).
  String get content {
    if (data.isEmpty) return '';
    final firstValue = data.values.first;
    if (firstValue is String) return firstValue;
    return jsonEncode(firstValue);
  }

  factory GenerationResponse.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return GenerationResponse(data: json);
    } else if (json is String) {
      return GenerationResponse(data: {'content': json});
    }
    return const GenerationResponse(data: {});
  }
}

/// A route for AI generation (non-conversational).
/// Uses Amplify.API directly — no manual wiring needed.
///
/// Each generation route has its own typed arguments and return type.
/// For example:
/// - "summarize" takes {text: String!, maxLength: Int} and returns {summary, keyPoints}
/// - "generateCode" takes {description: String!, language: String!} and returns {code, explanation}
/// - "describeImage" takes {imageUrl: String!} and returns {description, tags}
///
/// Usage:
/// ```dart
/// final summarizer = GenerationRoute(
///   routeName: 'summarize',
///   variables: r'$text: String!, $maxLength: Int',
///   args: r'text: $text, maxLength: $maxLength',
///   selectionSet: 'summary keyPoints',
/// );
/// final response = await summarizer.generate(
///   arguments: {'text': 'Long article...', 'maxLength': 200},
/// );
/// print(response['summary']);
/// ```
class GenerationRoute {
  /// Creates a generation route that uses Amplify.API directly.
  ///
  /// [routeName] - The name of the route (e.g., 'summarize', 'generateCode').
  /// [variables] - GraphQL variable declarations (e.g., r'$text: String!, $maxLength: Int').
  /// [args] - GraphQL field arguments (e.g., r'text: $text, maxLength: $maxLength').
  /// [selectionSet] - Fields to return (e.g., 'summary keyPoints').
  GenerationRoute({
    required this.routeName,
    required this.variables,
    required this.args,
    required this.selectionSet,
  }) : _documents = AIGraphQLDocuments(routeName: routeName);

  /// The name of this generation route from the AI config.
  final String routeName;

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

  /// Generates content from typed arguments.
  ///
  /// [arguments] is a map of argument name to value, matching the route's schema.
  /// For example, for "summarize": {'text': 'article text...', 'maxLength': 200}
  Future<GenerationResponse> generate({
    required Map<String, dynamic> arguments,
  }) async {
    final document = _documents.generate(
      variables: variables,
      args: args,
      selectionSet: selectionSet,
    );
    final request = GraphQLRequest<String>(
      document: document,
      variables: arguments,
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
    return GenerationResponse.fromJson(resultData);
  }
}
