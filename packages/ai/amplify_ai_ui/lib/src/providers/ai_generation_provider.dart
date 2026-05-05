// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../state/ai_client_state.dart';

/// Provider that manages AI generation — mirrors useAIGeneration hook.
///
/// Handles single-turn generation requests (e.g., summarize, translate)
/// and manages loading/error/result state.
class AIGenerationProvider<T> extends ChangeNotifier {
  /// Creates an [AIGenerationProvider].
  AIGenerationProvider({
    this.onComplete,
    this.onError,
  });

  /// Callback when generation completes successfully.
  final ValueChanged<T>? onComplete;

  /// Callback when an error occurs.
  final ValueChanged<Object>? onError;

  /// The current state of the generation.
  AIClientState<T> get state => _state;
  AIClientState<T> _state = const AIClientState.idle();

  /// Whether a generation is in progress.
  bool get isLoading => _state.isLoading;

  /// Whether the last generation resulted in an error.
  bool get hasError => _state.hasError;

  /// The generation result, if available.
  T? get result => _state.data;

  /// The error, if any.
  Object? get error => _state.error;

  /// Executes a generation request.
  ///
  /// Mirrors the generate action from useAIGeneration.
  /// The [generator] function should call the GenerationRoute.
  Future<void> generate(Future<T> Function() generator) async {
    _state = const AIClientState.loading();
    notifyListeners();

    try {
      final result = await generator();
      _state = AIClientState.success(result);
      onComplete?.call(result);
      notifyListeners();
    } catch (e) {
      _state = AIClientState.error(e);
      onError?.call(e);
      notifyListeners();
    }
  }

  /// Resets the state to idle.
  void reset() {
    _state = const AIClientState.idle();
    notifyListeners();
  }
}
