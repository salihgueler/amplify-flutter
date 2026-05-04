// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// A circular send button with animated state transitions.
///
/// Changes appearance based on enabled/disabled state and can
/// optionally show a loading indicator while sending.
class SendButton extends StatelessWidget {
  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is enabled.
  final bool enabled;

  /// Whether to show a loading indicator.
  final bool isLoading;

  /// Button size.
  final double size;

  /// Icon to display.
  final IconData icon;

  const SendButton({
    super.key,
    this.onPressed,
    this.enabled = true,
    this.isLoading = false,
    this.size = 40,
    this.icon = Icons.arrow_upward_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: enabled ? theme.sendButtonColor : theme.sendButtonDisabledColor,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(size / 2),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: size * 0.5,
                    height: size * 0.5,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(icon, size: size * 0.5, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
