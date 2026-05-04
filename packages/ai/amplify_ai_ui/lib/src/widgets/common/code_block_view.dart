// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ai_theme.dart';

/// A widget that displays a code block with syntax highlighting appearance
/// and a copy-to-clipboard button.
///
/// ```dart
/// CodeBlockView(
///   code: 'print("Hello, World!");',
///   language: 'dart',
/// )
/// ```
class CodeBlockView extends StatelessWidget {
  /// The source code to display.
  final String code;

  /// The programming language (used for display label).
  final String language;

  /// Whether to show the copy button.
  final bool showCopyButton;

  /// Whether to show the language label.
  final bool showLanguageLabel;

  const CodeBlockView({
    super.key,
    required this.code,
    this.language = '',
    this.showCopyButton = true,
    this.showLanguageLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.codeBlockColor,
        borderRadius: theme.cardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLanguageLabel || showCopyButton) _buildHeader(context, theme),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SelectableText(code, style: theme.codeTextStyle),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AIThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.only(
          topLeft: theme.cardBorderRadius.topLeft,
          topRight: theme.cardBorderRadius.topRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showLanguageLabel && language.isNotEmpty)
            Text(
              language,
              style: theme.captionTextStyle.copyWith(
                color: theme.codeTextStyle.color?.withValues(alpha: 0.7),
              ),
            )
          else
            const SizedBox.shrink(),
          if (showCopyButton) _CopyButton(code: code, theme: theme),
        ],
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
    return InkWell(
      onTap: _handleCopy,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _copied ? Icons.check : Icons.copy,
              size: 14,
              color: widget.theme.codeTextStyle.color?.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              _copied ? 'Copied!' : 'Copy',
              style: widget.theme.captionTextStyle.copyWith(
                color: widget.theme.codeTextStyle.color?.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
