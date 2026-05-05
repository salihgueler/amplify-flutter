// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

/// Animated streaming text that reveals characters progressively.
///
/// Mirrors the streaming text behavior in the JS AIConversation component,
/// showing text as it arrives with a blinking cursor at the end.
class StreamingText extends StatefulWidget {
  /// Creates a [StreamingText] widget.
  const StreamingText({
    super.key,
    required this.text,
    this.style,
    this.cursorColor,
    this.showCursor = true,
    this.animationDuration = const Duration(milliseconds: 30),
  });

  /// The text to display (grows as streaming progresses).
  final String text;

  /// Text style override.
  final TextStyle? style;

  /// Color of the blinking cursor.
  final Color? cursorColor;

  /// Whether to show the blinking cursor.
  final bool showCursor;

  /// Duration between character reveals.
  final Duration animationDuration;

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = widget.style ?? TextStyle(color: theme.colorScheme.onSurface);
    final cursorColor = widget.cursorColor ?? theme.colorScheme.primary;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: widget.text,
            style: style,
          ),
          if (widget.showCursor)
            WidgetSpan(
              child: FadeTransition(
                opacity: _cursorController,
                child: Container(
                  width: 2,
                  height: style.fontSize ?? 16,
                  margin: const EdgeInsets.only(left: 1),
                  color: cursorColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
