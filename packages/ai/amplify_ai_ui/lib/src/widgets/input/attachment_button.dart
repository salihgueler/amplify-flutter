// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// A button for attaching files/images to a message.
///
/// Displays a popup menu with attachment options (camera, gallery, file).
class AttachmentButton extends StatelessWidget {
  /// Callback when an image from the camera is requested.
  final VoidCallback? onCameraPressed;

  /// Callback when an image from the gallery is requested.
  final VoidCallback? onGalleryPressed;

  /// Callback when a file is requested.
  final VoidCallback? onFilePressed;

  /// Whether the button is enabled.
  final bool enabled;

  /// Optional icon to use.
  final IconData icon;

  const AttachmentButton({
    super.key,
    this.onCameraPressed,
    this.onGalleryPressed,
    this.onFilePressed,
    this.enabled = true,
    this.icon = Icons.add_circle_outline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return PopupMenuButton<_AttachmentOption>(
      enabled: enabled,
      icon: Icon(
        icon,
        color: enabled ? theme.primaryColor : theme.sendButtonDisabledColor,
      ),
      onSelected: (option) {
        switch (option) {
          case _AttachmentOption.camera:
            onCameraPressed?.call();
          case _AttachmentOption.gallery:
            onGalleryPressed?.call();
          case _AttachmentOption.file:
            onFilePressed?.call();
        }
      },
      itemBuilder: (context) => [
        if (onCameraPressed != null)
          const PopupMenuItem(
            value: _AttachmentOption.camera,
            child: ListTile(
              leading: Icon(Icons.camera_alt_outlined),
              title: Text('Camera'),
              dense: true,
            ),
          ),
        if (onGalleryPressed != null)
          const PopupMenuItem(
            value: _AttachmentOption.gallery,
            child: ListTile(
              leading: Icon(Icons.photo_library_outlined),
              title: Text('Gallery'),
              dense: true,
            ),
          ),
        if (onFilePressed != null)
          const PopupMenuItem(
            value: _AttachmentOption.file,
            child: ListTile(
              leading: Icon(Icons.insert_drive_file_outlined),
              title: Text('File'),
              dense: true,
            ),
          ),
      ],
    );
  }
}

enum _AttachmentOption { camera, gallery, file }
