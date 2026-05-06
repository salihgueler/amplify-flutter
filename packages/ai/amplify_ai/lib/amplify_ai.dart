/// Amplify AI Kit — zero-boilerplate AI integration for Flutter.
///
/// ## Quick Start:
/// ```dart
/// // In main.dart — configure once:
/// await Amplify.addPlugins([AmplifyAPI()]);
/// await Amplify.configure(amplifyConfig);
/// AmplifyAI.instance.configure(
///   outputsConfig: amplifyConfig,
///   api: Amplify.API,
/// );
///
/// // In any widget — just works:
/// AmplifyAIConversation(routeName: 'chat')
/// ```
library amplify_ai;

// Plugin (the main entry point for developers)
export 'src/plugin/amplify_ai_plugin.dart';

// Content types
export 'src/content/content_block.dart';
export 'src/content/tool_configuration.dart';
export 'src/content/tool_use_handler.dart';

// Conversation types
export 'src/conversation/conversation.dart';
export 'src/conversation/conversation_message.dart';
export 'src/conversation/conversation_route.dart';
export 'src/conversation/conversation_stream_event.dart';

// Generation types
export 'src/generation/generation_client.dart';
export 'src/generation/generation_route.dart';

// Config types (read-only, for introspection)
export 'src/config/ai_route_config.dart';

// Client options
export 'src/client/ai_client_options.dart';
