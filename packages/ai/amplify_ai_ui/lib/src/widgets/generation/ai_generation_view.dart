// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// A view for single-turn AI generation (non-conversational).
///
/// Displays a prompt input, generates a response, and shows the result.
/// Useful for summarization, translation, code generation, etc.
///
/// ```dart
/// AIGenerationView(
///   onGenerate: (prompt) async {
///     final result = await generationClient.generate(prompt);
///     return result.data?.text ?? '';
///   },
///   title: 'AI Summary',
///   hintText: 'Enter text to summarize...',
/// )
/// ```
class AIGenerationView extends StatefulWidget {
  /// Callback that performs the generation and returns the result text.
  final Future<String> Function(String prompt) onGenerate;

  /// Optional title displayed above the input.
  final String? title;

  /// Hint text for the input field.
  final String hintText;

  /// Label for the generate button.
  final String generateButtonLabel;

  /// Optional widget to display above the input.
  final Widget? headerWidget;

  /// Optional builder for customizing the result display.
  final Widget Function(BuildContext context, String result)? resultBuilder;

  /// Maximum lines for the input field.
  final int inputMaxLines;

  /// Whether to show a clear button after generation.
  final bool showClearButton;

  const AIGenerationView({
    super.key,
    required this.onGenerate,
    this.title,
    this.hintText = 'Enter your prompt...',
    this.generateButtonLabel = 'Generate',
    this.headerWidget,
    this.resultBuilder,
    this.inputMaxLines = 8,
    this.showClearButton = true,
  });

  @override
  State<AIGenerationView> createState() => _AIGenerationViewState();
}

class _AIGenerationViewState extends State<AIGenerationView> {
  final TextEditingController _inputController = TextEditingController();
  String? _result;
  bool _isGenerating = false;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    final prompt = _inputController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _error = null;
      _result = null;
    });

    try {
      final result = await widget.onGenerate(prompt);
      if (mounted) {
        setState(() {
          _result = result;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isGenerating = false;
        });
      }
    }
  }

  void _handleClear() {
    setState(() {
      _result = null;
      _error = null;
      _inputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.headerWidget != null) widget.headerWidget!,
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: theme.messageTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildInputArea(theme),
          const SizedBox(height: 12),
          _buildActionRow(theme),
          if (_isGenerating) ...[
            const SizedBox(height: 16),
            _buildLoadingState(theme),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            _buildErrorState(theme),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            _buildResultArea(context, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(AIThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.inputBackgroundColor,
        borderRadius: theme.cardBorderRadius,
        border: Border.all(
          color: theme.assistantTextColor.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _inputController,
        maxLines: widget.inputMaxLines,
        minLines: 3,
        enabled: !_isGenerating,
        style: theme.messageTextStyle,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.messageTextStyle.copyWith(
            color: theme.assistantTextColor.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildActionRow(AIThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.showClearButton && (_result != null || _error != null)) ...[
          TextButton(
            onPressed: _isGenerating ? null : _handleClear,
            child: Text(
              'Clear',
              style: TextStyle(color: theme.assistantTextColor),
            ),
          ),
          const SizedBox(width: 8),
        ],
        ElevatedButton.icon(
          onPressed: _isGenerating ? null : _handleGenerate,
          icon: _isGenerating
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.userTextColor,
                    ),
                  ),
                )
              : const Icon(Icons.auto_awesome, size: 18),
          label: Text(widget.generateButtonLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.userTextColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(AIThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.assistantBubbleColor,
        borderRadius: theme.cardBorderRadius,
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
          const SizedBox(height: 12),
          Text('Generating...', style: theme.captionTextStyle),
        ],
      ),
    );
  }

  Widget _buildErrorState(AIThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.errorColor.withValues(alpha: 0.1),
        borderRadius: theme.cardBorderRadius,
        border: Border.all(color: theme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.errorColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: theme.messageTextStyle.copyWith(color: theme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultArea(BuildContext context, AIThemeData theme) {
    if (widget.resultBuilder != null) {
      return widget.resultBuilder!(context, _result!);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.assistantBubbleColor,
        borderRadius: theme.cardBorderRadius,
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: theme.primaryColor),
              const SizedBox(width: 6),
              Text(
                'Result',
                style: theme.captionTextStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            _result!,
            style: theme.messageTextStyle.copyWith(
              color: theme.assistantTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
