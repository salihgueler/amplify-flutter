// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// Avatar widget for user or assistant messages.
///
/// Displays a circular avatar with an icon or initials to identify
/// the message sender.
///
/// ```dart
/// AIAvatar.user()
/// AIAvatar.assistant()
/// AIAvatar(icon: Icons.person, label: 'U')
/// ```
class AIAvatar extends StatelessWidget {
  /// The icon to display in the avatar.
  final IconData? icon;

  /// A text label (e.g., initials) displayed if no icon.
  final String? label;

  /// Background color override.
  final Color? backgroundColor;

  /// Icon/text color override.
  final Color? foregroundColor;

  /// Size of the avatar.
  final double size;

  const AIAvatar({
    super.key,
    this.icon,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 32,
  });

  /// Creates a user avatar with a person icon.
  const AIAvatar.user({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 32,
  }) : icon = Icons.person,
       label = null;

  /// Creates an assistant avatar with a smart toy icon.
  const AIAvatar.assistant({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 32,
  }) : icon = Icons.auto_awesome,
       label = null;

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);
    final bg = backgroundColor ?? theme.primaryColor;
    final fg = foregroundColor ?? theme.userTextColor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: icon != null
            ? Icon(icon, size: size * 0.55, color: fg)
            : Text(
                label ?? '',
                style: TextStyle(
                  color: fg,
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
