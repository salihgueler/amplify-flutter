// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

/// Attachment button for the message input.
///
/// Allows users to attach files/images to messages.
class AttachmentButton extends StatelessWidget {
  /// Creates an [AttachmentButton].
  const AttachmentButton({
    super.key,
    this.onPressed,
    this.enabled = true,
  });

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Whether the button is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: Icon(
        Icons.attach_file_rounded,
        color: enabled
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurfaceVariant.withOpacity(0.4),
      ),
      tooltip: 'Attach file',
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
      ),
    );
  }
}
