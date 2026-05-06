import 'dart:async';

/// Factory for creating and executing GraphQL requests.
/// Provides an abstraction over the underlying GraphQL client.
class AIGraphQLRequestFactory {
  /// Creates a GraphQL request factory.
  AIGraphQLRequestFactory({required this.queryFn, required this.mutateFn});

  /// Function to execute GraphQL queries.
  final Future<Map<String, dynamic>> Function({
    required String document,
    required Map<String, dynamic> variables,
  })
  queryFn;

  /// Function to execute GraphQL mutations.
  final Future<Map<String, dynamic>> Function({
    required String document,
    required Map<String, dynamic> variables,
  })
  mutateFn;

  /// Executes a GraphQL query.
  Future<Map<String, dynamic>> query({
    required String document,
    required Map<String, dynamic> variables,
  }) async {
    return queryFn(document: document, variables: variables);
  }

  /// Executes a GraphQL mutation.
  Future<Map<String, dynamic>> mutate({
    required String document,
    required Map<String, dynamic> variables,
  }) async {
    return mutateFn(document: document, variables: variables);
  }

  /// Creates a request factory from Amplify's GraphQL API plugin.
  factory AIGraphQLRequestFactory.fromAmplifyAPI({
    required Future<Map<String, dynamic>> Function(
      String document,
      Map<String, dynamic> variables,
    )
    query,
    required Future<Map<String, dynamic>> Function(
      String document,
      Map<String, dynamic> variables,
    )
    mutate,
  }) {
    return AIGraphQLRequestFactory(
      queryFn: ({required document, required variables}) =>
          query(document, variables),
      mutateFn: ({required document, required variables}) =>
          mutate(document, variables),
    );
  }
}
