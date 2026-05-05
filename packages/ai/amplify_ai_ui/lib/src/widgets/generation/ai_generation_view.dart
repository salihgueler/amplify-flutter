// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../providers/ai_generation_provider.dart';
import '../../theme/ai_theme.dart';
import '../common/ai_error_view.dart';
import '../common/ai_loading_indicator.dart';

/// A view widget for AI generation results.
///
/// Displays loading, error, and result states for single-turn AI generation.
/// Mirrors the generation view pattern in @aws-amplify/ui-react-ai.
class AIGenerationView<T> extends StatelessWidget {
  /// Creates an [AIGenerationView].
  const AIGenerationView({
    super.key,
    required this.provider,
    required this.resultBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  });

  /// The generation provider to observe.
  final AIGenerationProvider<T> provider;

  /// Builder for displaying the result.
  final Widget Function(BuildContext context, T result) resultBuilder;

  /// Optional custom loading widget builder.
  final WidgetBuilder? loadingBuilder;

  /// Optional custom error widget builder.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Optional widget shown in idle state.
  final WidgetBuilder? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        if (provider.isLoading) {
          return loadingBuilder?.call(context) ??
              const Center(child: AILoadingIndicator());
        }

        if (provider.hasError) {
          return errorBuilder?.call(context, provider.error!) ??
              AIErrorView(error: provider.error!);
        }

        final result = provider.result;
        if (result != null) {
          return resultBuilder(context, result);
        }

        return emptyBuilder?.call(context) ?? const SizedBox.shrink();
      },
    );
  }
}
