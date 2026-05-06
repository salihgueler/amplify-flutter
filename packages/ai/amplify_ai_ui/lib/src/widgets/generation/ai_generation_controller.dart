// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/foundation.dart';

import '../../providers/ai_generation_provider.dart';
import '../../state/ai_client_state.dart';

/// Controller for AI generation — mirrors useAIGeneration hook.
///
/// Wraps [AIGenerationProvider] with a convenient controller interface
/// for use with [AIGenerationView] or custom widgets.
///
/// Usage (route-name based):
/// ```dart
/// final controller = AIGenerationController(routeName: 'summarize');
/// await controller.generate(() => generationRoute.generate(args));
/// ```
class AIGenerationController<T> extends ChangeNotifier {
  /// Creates an [AIGenerationController].
  ///
  /// Provide either [routeName] (preferred, mirrors JS pattern) or [provider].
  factory AIGenerationController({
    String? routeName,
    AIGenerationProvider<T>? provider,
  }) {
    assert(
      routeName != null || provider != null,
      'Either routeName or provider must be provided.',
    );
    final effectiveProvider = provider ?? AIGenerationProvider<T>();
    return AIGenerationController._(provider: effectiveProvider);
  }

  AIGenerationController._({
    required AIGenerationProvider<T> provider,
  }) : _provider = provider {
    _provider.addListener(_onProviderChanged);
  }

  final AIGenerationProvider<T> _provider;

  /// The underlying provider (for advanced usage).
  AIGenerationProvider<T> get provider => _provider;

  /// The current state.
  AIClientState<T> get state => _provider.state;

  /// Whether generation is in progress.
  bool get isLoading => _provider.isLoading;

  /// Whether an error occurred.
  bool get hasError => _provider.hasError;

  /// The result, if available.
  T? get result => _provider.result;

  /// The error, if any.
  Object? get error => _provider.error;

  /// Executes a generation request.
  Future<void> generate(Future<T> Function() generator) async {
    await _provider.generate(generator);
  }

  /// Resets the state.
  void reset() {
    _provider.reset();
  }

  void _onProviderChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    super.dispose();
  }
}
