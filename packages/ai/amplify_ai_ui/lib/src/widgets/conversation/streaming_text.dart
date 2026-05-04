// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// A widget that displays text as it streams in character-by-character.
///
/// Used to show the AI assistant's response as it's being generated,
/// with an optional blinking cursor at the end.
///
/// ```dart
/// StreamingText(
///   text: controller.streamingText,
///   showCursor: true,
/// )
/// ```
class StreamingText extends StatefulWidget {
  /// The current accumulated text to display.
  final String text;

  /// Whether to show a blinking cursor at the end.
  final bool showCursor;

  /// Optional text style override.
  final TextStyle? style;

  /// The cursor character to display.
  final String cursorCharacter;

  const StreamingText({
    super.key,
    required this.text,
    this.showCursor = true,
    this.style,
    this.cursorCharacter = '▊',
  });

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _cursorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cursorController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);
    final textStyle = widget.style ?? theme.messageTextStyle;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: theme.assistantBubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(4),
          topRight: theme.bubbleBorderRadius.topRight,
          bottomLeft: theme.bubbleBorderRadius.bottomLeft,
          bottomRight: theme.bubbleBorderRadius.bottomRight,
        ),
      ),
      padding: theme.bubblePadding,
      child: AnimatedBuilder(
        animation: _cursorAnimation,
        builder: (context, child) {
          final cursorOpacity = widget.showCursor
              ? _cursorAnimation.value
              : 0.0;
          return RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.text,
                  style: textStyle.copyWith(color: theme.assistantTextColor),
                ),
                if (widget.showCursor)
                  TextSpan(
                    text: widget.cursorCharacter,
                    style: textStyle.copyWith(
                      color: theme.assistantTextColor.withValues(
                        alpha: cursorOpacity,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
