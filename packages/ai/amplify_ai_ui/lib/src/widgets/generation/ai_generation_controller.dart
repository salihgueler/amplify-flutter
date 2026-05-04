// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:amplify_ai/amplify_ai.dart';
import 'package:flutter/foundation.dart';

/// Controller for managing AI generation state.
///
/// This is a [ChangeNotifier] that holds the current generation state,
/// input, result, and error information for single-turn AI generation.
///
/// ```dart
/// final controller = AIGenerationController(
///   onGenerate: (input) async {
///     final result = await generationClient.generate(arguments: input);
///     return result.data;
///   },
/// );
///
/// await controller.generate({'description': 'A pasta recipe'});
/// print(controller.result);
/// ```
class AIGenerationController extends ChangeNotifier {
  /// Callback that performs the generation.
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic> input)
  onGenerate;

  /// The current state of generation.
  AIGenerationState get state => _state;
  AIGenerationState _state = AIGenerationState.idle;

  /// The generation result, if available.
  Map<String, dynamic>? get result => _result;
  Map<String, dynamic>? _result;

  /// The last error message.
  String? get errorMessage => _errorMessage;
  String? _errorMessage;

  /// Whether a generation is currently in progress.
  bool get isGenerating => _state == AIGenerationState.loading;

  /// Whether there is a result available.
  bool get hasResult => _result != null;

  /// Whether there is an error.
  bool get hasError => _state == AIGenerationState.error;

  /// Creates a generation controller with the given callback.
  AIGenerationController({required this.onGenerate});

  /// Performs a generation with the given input arguments.
  Future<void> generate(Map<String, dynamic> input) async {
    _state = AIGenerationState.loading;
    _errorMessage = null;
    _result = null;
    notifyListeners();

    try {
      final result = await onGenerate(input);
      _result = result;
      _state = AIGenerationState.success;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AIGenerationState.error;
    }

    notifyListeners();
  }

  /// Resets the controller to its initial state.
  void reset() {
    _state = AIGenerationState.idle;
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }
}

/// The state of an AI generation operation.
enum AIGenerationState {
  /// No generation in progress.
  idle,

  /// Generation is loading.
  loading,

  /// Generation completed successfully.
  success,

  /// Generation failed with an error.
  error,
}
