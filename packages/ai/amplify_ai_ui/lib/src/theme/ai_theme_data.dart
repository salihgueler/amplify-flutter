// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

/// Theme configuration for AI conversation widgets.
///
/// Mirrors the theming approach of @aws-amplify/ui-react-ai.
class AIThemeData {
  /// Primary brand color.
  final Color primaryColor;

  /// Surface/background color.
  final Color surfaceColor;

  /// User message bubble color.
  final Color userBubbleColor;

  /// Assistant message bubble color.
  final Color assistantBubbleColor;

  /// User message text color.
  final Color userTextColor;

  /// Assistant message text color.
  final Color assistantTextColor;

  /// Input field background color.
  final Color inputBackgroundColor;

  /// Send button color when active.
  final Color sendButtonColor;

  /// Send button color when disabled.
  final Color sendButtonDisabledColor;

  /// Error color.
  final Color errorColor;

  /// Text style for messages.
  final TextStyle messageTextStyle;

  /// Text style for captions/timestamps.
  final TextStyle captionTextStyle;

  /// Border radius for message bubbles.
  final BorderRadius bubbleBorderRadius;

  /// Padding inside message bubbles.
  final EdgeInsets bubblePadding;

  /// Spacing between messages.
  final double messageSpacing;

  /// Avatar size.
  final double avatarSize;

  const AIThemeData({
    required this.primaryColor,
    required this.surfaceColor,
    required this.userBubbleColor,
    required this.assistantBubbleColor,
    required this.userTextColor,
    required this.assistantTextColor,
    required this.inputBackgroundColor,
    required this.sendButtonColor,
    required this.sendButtonDisabledColor,
    required this.errorColor,
    required this.messageTextStyle,
    required this.captionTextStyle,
    required this.bubbleBorderRadius,
    required this.bubblePadding,
    required this.messageSpacing,
    required this.avatarSize,
  });
}
