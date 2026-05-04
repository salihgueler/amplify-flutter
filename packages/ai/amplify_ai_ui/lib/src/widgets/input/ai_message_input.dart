// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';

/// A message input widget with text field, send button, and attachment support.
///
/// Provides a Material 3 styled input area for composing messages
/// in an AI conversation.
///
/// ```dart
/// AIMessageInput(
///   onSend: (text) => controller.sendMessage(text),
///   hintText: 'Ask a question...',
/// )
/// ```
class AIMessageInput extends StatefulWidget {
  /// Callback when the user sends a message.
  final ValueChanged<String> onSend;

  /// Whether the input is enabled.
  final bool enabled;

  /// Placeholder text.
  final String hintText;

  /// Optional callback when the attachment button is pressed.
  final VoidCallback? onAttachmentPressed;

  /// Whether to show the attachment button.
  final bool showAttachmentButton;

  /// Maximum number of lines before scrolling.
  final int maxLines;

  /// Optional focus node.
  final FocusNode? focusNode;

  const AIMessageInput({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.hintText = 'Type a message...',
    this.onAttachmentPressed,
    this.showAttachmentButton = true,
    this.maxLines = 5,
    this.focusNode,
  });

  @override
  State<AIMessageInput> createState() => _AIMessageInputState();
}

class _AIMessageInputState extends State<AIMessageInput> {
  late TextEditingController _textController;
  late FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.inputBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.assistantTextColor.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (widget.showAttachmentButton)
                _AttachmentButton(
                  onPressed: widget.onAttachmentPressed,
                  enabled: widget.enabled,
                  theme: theme,
                ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _focusNode.hasFocus
                          ? theme.primaryColor
                          : theme.assistantTextColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    maxLines: widget.maxLines,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (_) => _handleSend(),
                    style: theme.messageTextStyle,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: theme.messageTextStyle.copyWith(
                        color: theme.assistantTextColor.withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SendButton(
                onPressed: _handleSend,
                enabled: widget.enabled && _hasText,
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool enabled;
  final dynamic theme;

  const _AttachmentButton({
    this.onPressed,
    required this.enabled,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onPressed : null,
      icon: Icon(
        Icons.attach_file_rounded,
        color: enabled
            ? theme.assistantTextColor.withValues(alpha: 0.6)
            : theme.sendButtonDisabledColor,
      ),
      splashRadius: 20,
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;
  final dynamic theme;

  const _SendButton({
    required this.onPressed,
    required this.enabled,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: enabled ? theme.sendButtonColor : theme.sendButtonDisabledColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.arrow_upward_rounded, size: 20),
        color: Colors.white,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
