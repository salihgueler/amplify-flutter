// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/foundation.dart';

/// Represents the state of an AI client operation.
enum AIClientStatus {
  /// Initial idle state.
  idle,

  /// Currently loading/processing.
  loading,

  /// Successfully completed.
  success,

  /// An error occurred.
  error,
}

/// Encapsulates the state of an AI client interaction.
class AIClientState<T> {
  /// Creates an [AIClientState].
  const AIClientState({
    this.status = AIClientStatus.idle,
    this.data,
    this.error,
  });

  /// Creates an idle state.
  const AIClientState.idle() : this();

  /// Creates a loading state.
  const AIClientState.loading()
      : this(status: AIClientStatus.loading);

  /// Creates a success state with data.
  AIClientState.success(T data)
      : this(status: AIClientStatus.success, data: data);

  /// Creates an error state.
  AIClientState.error(Object error)
      : this(status: AIClientStatus.error, error: error);

  /// The current status of the operation.
  final AIClientStatus status;

  /// The result data, if available.
  final T? data;

  /// The error, if any.
  final Object? error;

  /// Whether the state is currently loading.
  bool get isLoading => status == AIClientStatus.loading;

  /// Whether the state has an error.
  bool get hasError => status == AIClientStatus.error;

  /// Whether the state has data.
  bool get hasData => data != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIClientState<T> &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          data == other.data &&
          error == other.error;

  @override
  int get hashCode => Object.hash(status, data, error);

  @override
  String toString() => 'AIClientState(status: $status, data: $data, error: $error)';
}
