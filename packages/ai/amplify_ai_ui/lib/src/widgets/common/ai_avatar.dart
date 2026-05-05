// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// Avatar widget for user and assistant messages.
///
/// Shows different icons/styles based on role.
class AIAvatar extends StatelessWidget {
  /// Creates an [AIAvatar].
  const AIAvatar({
    super.key,
    required this.role,
    this.size = 32,
  });

  /// The role ('user' or 'assistant').
  final String role;

  /// The avatar size.
  final double size;

  bool get _isUser => role == 'user';

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _isUser
            ? theme.userAvatarColor ?? colorScheme.primary
            : theme.assistantAvatarColor ?? colorScheme.tertiary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _isUser ? Icons.person_rounded : Icons.auto_awesome_rounded,
        size: size * 0.55,
        color: _isUser
            ? colorScheme.onPrimary
            : colorScheme.onTertiary,
      ),
    );
  }
}
