import 'dart:async';

import '../graphql/ai_graphql_documents.dart';
import '../graphql/ai_graphql_request_factory.dart';

/// A route for AI generation (non-conversational, single prompt/response).
/// Mirrors the JS AI Kit generation route pattern.
class GenerationRoute {
  /// Creates a generation route.
  GenerationRoute({
    required this.routeName,
    required this.graphqlRequestFactory,
  }) : _documents = AIGraphQLDocuments(routeName: routeName);

  /// The name of this generation route from the AI config.
  final String routeName;

  /// The GraphQL request factory for making API calls.
  final AIGraphQLRequestFactory graphqlRequestFactory;

  final AIGraphQLDocuments _documents;

  /// Generates content based on a prompt.
  /// Returns the generated content as a structured response.
  Future<GenerationResponse> generate({
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

    final data = response['data']?['generate'] as Map<String, dynamic>? ?? {};
    return GenerationResponse.fromJson(data);
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
      if (result.content != null) {
        controller.add(result.content!);
      }
    } catch (e) {
      controller.addError(e);
    } finally {
      await controller.close();
    }
  }
}

/// Response from a generation request.
class GenerationResponse {
  /// Creates a generation response.
  const GenerationResponse({
    this.content,
    this.stopReason,
    this.usage,
  });

  /// The generated content.
  final String? content;

  /// The reason the model stopped generating.
  final String? stopReason;

  /// Token usage information.
  final GenerationUsage? usage;

  /// Deserializes from JSON.
  factory GenerationResponse.fromJson(Map<String, dynamic> json) {
    return GenerationResponse(
      content: json['content'] as String?,
      stopReason: json['stopReason'] as String?,
      usage: json['usage'] != null
          ? GenerationUsage.fromJson(json['usage'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
        if (content != null) 'content': content,
        if (stopReason != null) 'stopReason': stopReason,
        if (usage != null) 'usage': usage!.toJson(),
      };
}

/// Token usage information for a generation.
class GenerationUsage {
  /// Creates a generation usage.
  const GenerationUsage({
    this.inputTokens,
    this.outputTokens,
    this.totalTokens,
  });

  /// The number of input tokens consumed.
  final int? inputTokens;

  /// The number of output tokens generated.
  final int? outputTokens;

  /// The total number of tokens used.
  final int? totalTokens;

  /// Deserializes from JSON.
  factory GenerationUsage.fromJson(Map<String, dynamic> json) {
    return GenerationUsage(
      inputTokens: json['inputTokens'] as int?,
      outputTokens: json['outputTokens'] as int?,
      totalTokens: json['totalTokens'] as int?,
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
        if (inputTokens != null) 'inputTokens': inputTokens,
        if (outputTokens != null) 'outputTokens': outputTokens,
        if (totalTokens != null) 'totalTokens': totalTokens,
      };
}
