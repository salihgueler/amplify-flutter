// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

/// Send button for the message input.
class SendButton extends StatelessWidget {
  /// Creates a [SendButton].
  const SendButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
  });

  /// Callback when pressed.
  final VoidCallback onPressed;

  /// Whether the button is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: Icon(
        Icons.send_rounded,
        color: enabled
            ? colorScheme.onPrimary
            : colorScheme.onSurfaceVariant.withOpacity(0.4),
      ),
      tooltip: 'Send message',
      style: IconButton.styleFrom(
        backgroundColor: enabled
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
      ),
    );
  }
}
