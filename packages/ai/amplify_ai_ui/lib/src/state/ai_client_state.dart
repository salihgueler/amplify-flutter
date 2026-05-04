// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/foundation.dart';

/// Represents the current state of an AI client operation.
///
/// Used by both conversation and generation views to track
/// loading, streaming, error, and idle states.
@immutable
class AIClientState<T> {
  /// The data returned from the operation.
  final T? data;

  /// Whether the operation is currently loading.
  final bool isLoading;

  /// Whether the operation is streaming (conversation only).
  final bool isStreaming;

  /// Whether an error has occurred.
  final bool hasError;

  /// Error messages from the operation.
  final List<String>? errors;

  const AIClientState({
    this.data,
    this.isLoading = false,
    this.isStreaming = false,
    this.hasError = false,
    this.errors,
  });

  /// Creates an idle state with no data.
  const AIClientState.idle()
    : data = null,
      isLoading = false,
      isStreaming = false,
      hasError = false,
      errors = null;

  /// Creates a loading state.
  const AIClientState.loading()
    : data = null,
      isLoading = true,
      isStreaming = false,
      hasError = false,
      errors = null;

  /// Creates a streaming state with data.
  const AIClientState.streaming(this.data)
    : isLoading = false,
      isStreaming = true,
      hasError = false,
      errors = null;

  /// Creates a success state with data.
  const AIClientState.success(this.data)
    : isLoading = false,
      isStreaming = false,
      hasError = false,
      errors = null;

  /// Creates an error state.
  const AIClientState.error(List<String> errorMessages)
    : data = null,
      isLoading = false,
      isStreaming = false,
      hasError = true,
      errors = errorMessages;

  /// Creates a copy with the specified overrides.
  AIClientState<T> copyWith({
    T? data,
    bool? isLoading,
    bool? isStreaming,
    bool? hasError,
    List<String>? errors,
  }) {
    return AIClientState<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      hasError: hasError ?? this.hasError,
      errors: errors ?? this.errors,
    );
  }

  @override
  String toString() {
    if (isLoading) return 'AIClientState.loading';
    if (isStreaming) return 'AIClientState.streaming($data)';
    if (hasError) return 'AIClientState.error($errors)';
    if (data != null) return 'AIClientState.success($data)';
    return 'AIClientState.idle';
  }
}
