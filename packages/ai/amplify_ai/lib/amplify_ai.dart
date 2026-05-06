/// Amplify AI Kit for Flutter.
///
/// Just works with standard Amplify setup — no extra plugin or configuration.
///
/// ```dart
/// // Standard Amplify setup (main.dart)
/// await Amplify.addPlugins([AmplifyAuthCognito(), AmplifyAPI()]);
/// await Amplify.configure(amplifyConfig);
///
/// // Use AI anywhere — it uses Amplify.API internally
/// final chat = ConversationRoute(routeName: 'chat');
/// final conversation = await chat.create();
///
/// // Or use the widget (from amplify_ai_ui)
/// AmplifyAIConversation(routeName: 'chat')
/// ```
library amplify_ai;

// Conversation
export 'src/conversation/conversation.dart';
export 'src/conversation/conversation_message.dart';
export 'src/conversation/conversation_message_serializer.dart';
export 'src/conversation/conversation_route.dart';
export 'src/conversation/conversation_stream_event.dart';

// Generation
export 'src/generation/generation_client.dart';
export 'src/generation/generation_route.dart';

// Content types
export 'src/content/content_block.dart';
export 'src/content/tool_configuration.dart';
export 'src/content/tool_use_handler.dart';

// GraphQL documents (for advanced usage / custom queries)
export 'src/graphql/ai_graphql_documents.dart';
export 'src/graphql/ai_graphql_request_factory.dart';

// Config types (read-only, for introspection)
export 'src/config/ai_config_parser.dart';
export 'src/config/ai_route_config.dart';
