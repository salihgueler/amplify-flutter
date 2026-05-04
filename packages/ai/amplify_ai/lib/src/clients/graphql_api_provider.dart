// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Abstract interface for GraphQL operations.
///
/// This allows the AI Kit to be decoupled from the specific GraphQL
/// implementation (e.g., amplify_api). Users provide an implementation
/// that wraps their existing Amplify API plugin.

/// A GraphQL response containing data and optional errors.
class GraphQLResponse<T> {
  /// The decoded data from the response.
  final T? data;

  /// Errors returned by the GraphQL API.
  final List<Map<String, dynamic>>? errors;

  const GraphQLResponse({this.data, this.errors});

  /// Whether the response has errors.
  bool get hasErrors => errors != null && errors!.isNotEmpty;
}

/// Abstract interface for executing GraphQL operations.
///
/// Implement this interface to connect the AI Kit to your GraphQL API
/// provider (e.g., Amplify API plugin).
abstract class GraphQLAPIProvider {
  /// Executes a GraphQL query and returns the decoded response.
  Future<GraphQLResponse<Map<String, dynamic>>> query({
    required String document,
    required Map<String, dynamic> variables,
    String? apiName,
  });

  /// Executes a GraphQL mutation and returns the decoded response.
  Future<GraphQLResponse<Map<String, dynamic>>> mutate({
    required String document,
    required Map<String, dynamic> variables,
    String? apiName,
  });

  /// Subscribes to a GraphQL subscription and returns a stream of events.
  Stream<GraphQLResponse<Map<String, dynamic>>> subscribe({
    required String document,
    required Map<String, dynamic> variables,
    String? apiName,
  });
}
