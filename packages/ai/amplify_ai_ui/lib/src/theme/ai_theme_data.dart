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

  /// Overall background color for the conversation container.
  final Color? backgroundColor;

  /// User message bubble color.
  final Color userBubbleColor;

  /// Assistant message bubble color.
  final Color assistantBubbleColor;

  /// User message text color.
  final Color userTextColor;

  /// Assistant message text color.
  final Color assistantTextColor;

  /// Input area background color.
  final Color inputBackgroundColor;

  /// Input field fill color.
  final Color? inputFieldColor;

  /// Send button color when active.
  final Color sendButtonColor;

  /// Send button color when disabled.
  final Color sendButtonDisabledColor;

  /// Error color.
  final Color errorColor;

  /// Tool card background color.
  final Color? toolCardColor;

  /// Tool result card background color.
  final Color? toolResultCardColor;

  /// Typing indicator dot color.
  final Color? typingIndicatorColor;

  /// User avatar background color.
  final Color? userAvatarColor;

  /// Assistant avatar background color.
  final Color? assistantAvatarColor;

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
    this.backgroundColor,
    required this.userBubbleColor,
    required this.assistantBubbleColor,
    required this.userTextColor,
    required this.assistantTextColor,
    required this.inputBackgroundColor,
    this.inputFieldColor,
    required this.sendButtonColor,
    required this.sendButtonDisabledColor,
    required this.errorColor,
    this.toolCardColor,
    this.toolResultCardColor,
    this.typingIndicatorColor,
    this.userAvatarColor,
    this.assistantAvatarColor,
    required this.messageTextStyle,
    required this.captionTextStyle,
    required this.bubbleBorderRadius,
    required this.bubblePadding,
    required this.messageSpacing,
    required this.avatarSize,
  });

  /// Creates a copy of this theme with the given fields replaced.
  AIThemeData copyWith({
    Color? primaryColor,
    Color? surfaceColor,
    Color? backgroundColor,
    Color? userBubbleColor,
    Color? assistantBubbleColor,
    Color? userTextColor,
    Color? assistantTextColor,
    Color? inputBackgroundColor,
    Color? inputFieldColor,
    Color? sendButtonColor,
    Color? sendButtonDisabledColor,
    Color? errorColor,
    Color? toolCardColor,
    Color? toolResultCardColor,
    Color? typingIndicatorColor,
    Color? userAvatarColor,
    Color? assistantAvatarColor,
    TextStyle? messageTextStyle,
    TextStyle? captionTextStyle,
    BorderRadius? bubbleBorderRadius,
    EdgeInsets? bubblePadding,
    double? messageSpacing,
    double? avatarSize,
  }) {
    return AIThemeData(
      primaryColor: primaryColor ?? this.primaryColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      assistantBubbleColor: assistantBubbleColor ?? this.assistantBubbleColor,
      userTextColor: userTextColor ?? this.userTextColor,
      assistantTextColor: assistantTextColor ?? this.assistantTextColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputFieldColor: inputFieldColor ?? this.inputFieldColor,
      sendButtonColor: sendButtonColor ?? this.sendButtonColor,
      sendButtonDisabledColor: sendButtonDisabledColor ?? this.sendButtonDisabledColor,
      errorColor: errorColor ?? this.errorColor,
      toolCardColor: toolCardColor ?? this.toolCardColor,
      toolResultCardColor: toolResultCardColor ?? this.toolResultCardColor,
      typingIndicatorColor: typingIndicatorColor ?? this.typingIndicatorColor,
      userAvatarColor: userAvatarColor ?? this.userAvatarColor,
      assistantAvatarColor: assistantAvatarColor ?? this.assistantAvatarColor,
      messageTextStyle: messageTextStyle ?? this.messageTextStyle,
      captionTextStyle: captionTextStyle ?? this.captionTextStyle,
      bubbleBorderRadius: bubbleBorderRadius ?? this.bubbleBorderRadius,
      bubblePadding: bubblePadding ?? this.bubblePadding,
      messageSpacing: messageSpacing ?? this.messageSpacing,
      avatarSize: avatarSize ?? this.avatarSize,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIThemeData &&
          runtimeType == other.runtimeType &&
          primaryColor == other.primaryColor &&
          surfaceColor == other.surfaceColor &&
          backgroundColor == other.backgroundColor &&
          userBubbleColor == other.userBubbleColor &&
          assistantBubbleColor == other.assistantBubbleColor &&
          userTextColor == other.userTextColor &&
          assistantTextColor == other.assistantTextColor &&
          inputBackgroundColor == other.inputBackgroundColor &&
          inputFieldColor == other.inputFieldColor &&
          sendButtonColor == other.sendButtonColor &&
          errorColor == other.errorColor &&
          toolCardColor == other.toolCardColor &&
          toolResultCardColor == other.toolResultCardColor &&
          typingIndicatorColor == other.typingIndicatorColor &&
          userAvatarColor == other.userAvatarColor &&
          assistantAvatarColor == other.assistantAvatarColor;

  @override
  int get hashCode => Object.hash(
        primaryColor,
        surfaceColor,
        backgroundColor,
        userBubbleColor,
        assistantBubbleColor,
        userTextColor,
        assistantTextColor,
        inputBackgroundColor,
        sendButtonColor,
        errorColor,
        toolCardColor,
      );
}
