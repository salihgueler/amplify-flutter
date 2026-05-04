// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ai_theme.dart';

/// A styled code block view with syntax highlighting label and copy button.
///
/// Displays code in a dark container with a language label header
/// and a button to copy the code to the clipboard.
///
/// ```dart
/// CodeBlockView(
///   code: 'print("Hello, world!");',
///   language: 'dart',
/// )
/// ```
class CodeBlockView extends StatelessWidget {
  /// The source code to display.
  final String code;

  /// The programming language (for display and future syntax highlighting).
  final String language;

  /// Whether to show the copy button.
  final bool showCopyButton;

  /// Whether to show line numbers.
  final bool showLineNumbers;

  /// Maximum height before the view becomes scrollable.
  final double? maxHeight;

  const CodeBlockView({
    super.key,
    required this.code,
    this.language = '',
    this.showCopyButton = true,
    this.showLineNumbers = false,
    this.maxHeight = 400,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
      decoration: BoxDecoration(
        color: theme.codeBlockColor,
        borderRadius: theme.cardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, theme),
          Flexible(child: _buildCodeArea(theme)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AIThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.only(
          topLeft: theme.cardBorderRadius.topLeft,
          topRight: theme.cardBorderRadius.topRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            language.isNotEmpty ? language : 'code',
            style: theme.captionTextStyle.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          if (showCopyButton) _CopyButton(code: code, theme: theme),
        ],
      ),
    );
  }

  Widget _buildCodeArea(AIThemeData theme) {
    final lines = code.split('\n');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: showLineNumbers
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line numbers
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(lines.length, (i) {
                        return Text(
                          '${i + 1}',
                          style: theme.codeTextStyle.copyWith(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    // Code
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: lines.map((line) {
                        return Text(line, style: theme.codeTextStyle);
                      }).toList(),
                    ),
                  ],
                )
              : Text(code, style: theme.codeTextStyle),
        ),
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  final String code;
  final AIThemeData theme;

  const _CopyButton({required this.code, required this.theme});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (mounted) {
      setState(() => _copied = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _copied = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleCopy,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _copied ? Icons.check : Icons.copy,
            size: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 4),
          Text(
            _copied ? 'Copied!' : 'Copy',
            style: widget.theme.captionTextStyle.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
