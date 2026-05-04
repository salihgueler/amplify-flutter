// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Client-side tool handling framework for AI conversations.
///
/// When the AI model requests a client-side tool invocation,
/// the client receives a [ToolUseBlock] via streaming. This framework
/// helps manage tool handlers and send results back.

import 'dart:async';

import '../types/content_block.dart';

/// A function that handles a tool invocation and returns a result.
///
/// Receives the tool name and input, and should return a [ToolResultContent]
/// list with the result.
typedef ToolHandler = FutureOr<List<ToolResultContent>> Function(
  String toolName,
  Map<String, dynamic> input,
);

/// Manages client-side tool handlers for a conversation.
///
/// Register tool handlers with [registerHandler], then use [handleToolUse]
/// to process tool use requests from the AI model.
///
/// Example:
/// ```dart
/// final toolHandler = ClientToolHandler();
/// toolHandler.registerHandler('getWeather', (name, input) async {
///   final city = input['city'] as String;
///   final weather = await fetchWeather(city);
///   return [ToolResultContent.text(weather)];
/// });
///
/// // When a tool use event is received from the stream:
/// final result = await toolHandler.handleToolUse(toolUseBlock);
/// // Send the result back via conversation.sendMessage(...)
/// ```
class ClientToolHandler {
  final Map<String, ToolHandler> _handlers = {};

  /// Registers a handler for the given tool name.
  void registerHandler(String toolName, ToolHandler handler) {
    _handlers[toolName] = handler;
  }

  /// Removes a handler for the given tool name.
  void removeHandler(String toolName) {
    _handlers.remove(toolName);
  }

  /// Whether a handler is registered for the given tool name.
  bool hasHandler(String toolName) => _handlers.containsKey(toolName);

  /// Returns the list of registered tool names.
  List<String> get registeredTools => _handlers.keys.toList();

  /// Handles a tool use request from the AI model.
  ///
  /// Returns a [ToolResultBlock] that can be sent back to the conversation
  /// as part of a message's content.
  ///
  /// Throws [ToolNotFoundError] if no handler is registered for the tool.
  Future<ToolResultBlock> handleToolUse(ToolUseBlock toolUse) async {
    final handler = _handlers[toolUse.name];
    if (handler == null) {
      throw ToolNotFoundError(toolUse.name);
    }

    try {
      final resultContent = await handler(toolUse.name, toolUse.input);
      return ToolResultBlock(
        toolUseId: toolUse.toolUseId,
        content: resultContent,
        status: 'success',
      );
    } catch (e) {
      return ToolResultBlock(
        toolUseId: toolUse.toolUseId,
        content: [ToolResultContent.text('Error: $e')],
        status: 'error',
      );
    }
  }

  /// Processes all tool use blocks from a list of content blocks.
  ///
  /// Returns a list of [ContentBlock.toolResult] blocks that can be
  /// sent back in a follow-up message.
  Future<List<ContentBlock>> handleAllToolUses(
      List<ContentBlock> contentBlocks) async {
    final results = <ContentBlock>[];
    for (final block in contentBlocks) {
      if (block.toolUse != null) {
        final result = await handleToolUse(block.toolUse!);
        results.add(ContentBlock.toolResult(result));
      }
    }
    return results;
  }
}

/// Error thrown when a tool use request is received but no handler
/// is registered for that tool name.
class ToolNotFoundError implements Exception {
  /// The tool name that was not found.
  final String toolName;

  const ToolNotFoundError(this.toolName);

  @override
  String toString() =>
      'ToolNotFoundError: No handler registered for tool "$toolName"';
}
