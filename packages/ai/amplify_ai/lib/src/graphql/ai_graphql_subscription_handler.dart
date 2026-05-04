import 'dart:async';

/// Handler for GraphQL subscriptions used in AI streaming.
/// Provides an abstraction over the underlying subscription mechanism.
class AIGraphQLSubscriptionHandler {
  /// Creates a subscription handler.
  AIGraphQLSubscriptionHandler({
    required this.subscribeFn,
  });

  /// Function to create GraphQL subscriptions.
  final Stream<Map<String, dynamic>> Function({
    required String document,
    required Map<String, dynamic> variables,
  }) subscribeFn;

  /// Subscribes to a GraphQL subscription.
  Stream<Map<String, dynamic>> subscribe({
    required String document,
    required Map<String, dynamic> variables,
  }) {
    return subscribeFn(document: document, variables: variables);
  }

  /// Creates a subscription handler from Amplify's GraphQL API plugin.
  factory AIGraphQLSubscriptionHandler.fromAmplifyAPI({
    required Stream<Map<String, dynamic>> Function(
      String document,
      Map<String, dynamic> variables,
    ) subscribe,
  }) {
    return AIGraphQLSubscriptionHandler(
      subscribeFn: ({required document, required variables}) =>
          subscribe(document, variables),
    );
  }
}
