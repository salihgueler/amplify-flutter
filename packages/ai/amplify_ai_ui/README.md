# amplify_ai_ui

Flutter UI components for Amplify AI Kit.

## Features

- **AmplifyAIConversation** — Drop-in chat widget with message list, streaming text, and input
- **AIConversationController** — State management for conversations (ChangeNotifier)
- **MessageBubble** — Adaptive message bubbles (user/assistant) with content rendering
- **StreamingText** — Animated text display with blinking cursor for streaming responses
- **TypingIndicator** — Bouncing dots animation while waiting for AI response
- **AIMessageInput** — Text input with attachment support and send button
- **ToolUseCard** — Displays tool invocation requests with status indicators
- **ToolResultCard** — Shows tool execution results (text, JSON)
- **ToolProgressIndicator** — Linear progress for long-running tool operations
- **AIGenerationView** — Single-turn generation UI (prompt → result)
- **ContentBlockRenderer** — Renders text, images, code blocks, and tool blocks
- **CodeBlockView** — Syntax-highlighted code with copy button and line numbers
- **AITheme / AIThemeData** — Full theming (Material 3, dark mode support)
- **AIConversationProvider** — InheritedWidget for dependency injection

## Getting Started

```dart
import 'package:amplify_ai_ui/amplify_ai_ui.dart';

// 1. Create a controller
final controller = AIConversationController(
  conversationClient: aiPlugin.getConversationClient('myRoute'),
);

// 2. Load or create a conversation
await controller.loadConversation();

// 3. Use the drop-in widget
AITheme(
  data: AIThemeData.fromMaterialTheme(Theme.of(context)),
  child: AmplifyAIConversation(
    controller: controller,
  ),
)
```

## Theming

```dart
// Use built-in themes
AITheme(data: AIThemeData.light(), child: ...)
AITheme(data: AIThemeData.dark(), child: ...)

// Derive from Material theme
AITheme(data: AIThemeData.fromMaterialTheme(Theme.of(context)), child: ...)

// Customize specific values
AITheme(
  data: AIThemeData.light().copyWith(
    userBubbleColor: Colors.indigo,
    bubbleBorderRadius: BorderRadius.circular(12),
  ),
  child: ...,
)
```

## Custom Message Bubbles

```dart
AmplifyAIConversation(
  controller: controller,
  messageBubbleBuilder: (context, message) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(message.text),
    );
  },
)
```

## Single-Turn Generation

```dart
AIGenerationView(
  title: 'Summarize',
  hintText: 'Paste text to summarize...',
  onGenerate: (prompt) async {
    final result = await generationClient.generate(
      GenerationInput(prompt: prompt),
    );
    return result.data ?? '';
  },
)
```
