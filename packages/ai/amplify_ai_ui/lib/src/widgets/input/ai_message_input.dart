// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../../theme/ai_theme.dart';
import 'attachment_button.dart';
import 'send_button.dart';

/// Message input field for the AI conversation.
///
/// Provides a text field with send button and optional attachment support.
/// Mirrors the message input in the JS AIConversation component.
class AIMessageInput extends StatefulWidget {
  /// Creates an [AIMessageInput].
  const AIMessageInput({
    super.key,
    required this.onSend,
    this.enabled = true,
    this.allowAttachments = false,
    this.placeholder = 'Type a message...',
    this.onAttachmentPressed,
  });

  /// Callback when a message is sent.
  final void Function(String text) onSend;

  /// Whether the input is enabled.
  final bool enabled;

  /// Whether to show the attachment button.
  final bool allowAttachments;

  /// Placeholder text for the input field.
  final String placeholder;

  /// Callback when attachment button is pressed.
  final VoidCallback? onAttachmentPressed;

  @override
  State<AIMessageInput> createState() => _AIMessageInputState();
}

class _AIMessageInputState extends State<AIMessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool get _hasText => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (!_hasText || !widget.enabled) return;
    widget.onSend(_controller.text.trim());
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AITheme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.inputBackgroundColor,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.allowAttachments) ...[
              AttachmentButton(
                onPressed: widget.onAttachmentPressed,
                enabled: widget.enabled,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => _handleSend(),
                decoration: InputDecoration(
                  hintText: widget.placeholder,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: theme.inputFieldColor ?? colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SendButton(
              onPressed: _handleSend,
              enabled: widget.enabled && _hasText,
            ),
          ],
        ),
      ),
    );
  }
}
