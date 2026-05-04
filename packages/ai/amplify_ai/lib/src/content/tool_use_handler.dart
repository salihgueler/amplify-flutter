import 'dart:async';

import 'content_block.dart';

/// A handler function that processes a tool use request and returns the result.
/// Mirrors the JS AI Kit tool handler pattern for bidirectional tool use.
typedef ToolHandler = FutureOr<ToolResultContentBlock> Function(
  ToolUseContentBlock toolUse,
);

/// Registry for tool use handlers in AI conversations.
/// Supports bidirectional tool use between the client and the model.
class ToolUseHandler {
  /// Creates a tool use handler with the given handler map.
  ToolUseHandler({
    Map<String, ToolHandler>? handlers,
  }) : _handlers = handlers ?? {};

  final Map<String, ToolHandler> _handlers;

  /// Registers a handler for a specific tool name.
  void registerHandler(String toolName, ToolHandler handler) {
    _handlers[toolName] = handler;
  }

  /// Unregisters a handler for a specific tool name.
  void unregisterHandler(String toolName) {
    _handlers.remove(toolName);
  }

  /// Returns whether a handler is registered for the given tool name.
  bool hasHandler(String toolName) => _handlers.containsKey(toolName);

  /// Returns the list of registered tool names.
  List<String> get registeredTools => _handlers.keys.toList();

  /// Processes a tool use content block by dispatching to the registered handler.
  /// Returns the tool result content block.
  /// Throws [StateError] if no handler is registered for the tool.
  Future<ToolResultContentBlock> handleToolUse(
    ToolUseContentBlock toolUse,
  ) async {
    final handler = _handlers[toolUse.name];
    if (handler == null) {
      throw StateError(
        'No handler registered for tool: ${toolUse.name}. '
        'Registered tools: ${_handlers.keys.join(', ')}',
      );
    }
    return handler(toolUse);
  }

  /// Processes all tool use blocks in a list of content blocks.
  /// Returns a list of tool result content blocks for each tool use found.
  Future<List<ToolResultContentBlock>> handleToolUses(
    List<ContentBlock> contentBlocks,
  ) async {
    final toolUses = contentBlocks.whereType<ToolUseContentBlock>().toList();
    final results = <ToolResultContentBlock>[];
    for (final toolUse in toolUses) {
      results.add(await handleToolUse(toolUse));
    }
    return results;
  }
}
