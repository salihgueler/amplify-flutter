// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Conversation type representing a conversation session.

import 'package:meta/meta.dart';

/// Represents a conversation session with an AI model.
@immutable
class ConversationSummary {
  /// Unique identifier for this conversation.
  final String id;

  /// When this conversation was created (ISO 8601).
  final String createdAt;

  /// When this conversation was last updated (ISO 8601).
  final String updatedAt;

  /// Optional metadata associated with the conversation.
  final Map<String, dynamic>? metadata;

  /// Optional name for the conversation.
  final String? name;

  const ConversationSummary({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
    this.name,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      id: json['id'] as String,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        if (metadata != null) 'metadata': metadata,
        if (name != null) 'name': name,
      };

  @override
  String toString() => 'ConversationSummary(id: $id, name: $name)';
}

/// A paginated list result.
@immutable
class PaginatedResult<T> {
  /// The items in this page.
  final List<T> items;

  /// Token for fetching the next page, or null if no more pages.
  final String? nextToken;

  const PaginatedResult({
    required this.items,
    this.nextToken,
  });
}

/// Result of a single operation (create, get, update, delete).
@immutable
class SingleResult<T> {
  /// The data returned.
  final T? data;

  /// Errors from the operation.
  final List<GraphQLResponseError>? errors;

  const SingleResult({this.data, this.errors});

  /// Whether the operation was successful.
  bool get hasData => data != null;

  /// Whether errors occurred.
  bool get hasErrors => errors != null && errors!.isNotEmpty;
}

/// A GraphQL response error.
@immutable
class GraphQLResponseError {
  /// The error message.
  final String message;

  const GraphQLResponseError({required this.message});

  factory GraphQLResponseError.fromJson(Map<String, dynamic> json) {
    return GraphQLResponseError(
      message: json['message'] as String? ?? 'Unknown error',
    );
  }

  @override
  String toString() => 'GraphQLResponseError($message)';
}
