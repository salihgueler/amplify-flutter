// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// An animated typing indicator showing bouncing dots.
///
/// Displayed while waiting for the AI assistant to begin responding.
class TypingIndicator extends StatefulWidget {
  /// The size of each dot.
  final double dotSize;

  /// Spacing between dots.
  final double spacing;

  /// Number of dots.
  final int dotCount;

  const TypingIndicator({
    super.key,
    this.dotSize = 8.0,
    this.spacing = 4.0,
    this.dotCount = 3,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.dotCount,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: -8.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Stagger the animations
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.assistantBubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(4),
          topRight: theme.bubbleBorderRadius.topRight,
          bottomLeft: theme.bubbleBorderRadius.bottomLeft,
          bottomRight: theme.bubbleBorderRadius.bottomRight,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.dotCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.only(
                  right: index < widget.dotCount - 1 ? widget.spacing : 0,
                ),
                child: Transform.translate(
                  offset: Offset(0, _animations[index].value),
                  child: Container(
                    width: widget.dotSize,
                    height: widget.dotSize,
                    decoration: BoxDecoration(
                      color: theme.assistantTextColor.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
