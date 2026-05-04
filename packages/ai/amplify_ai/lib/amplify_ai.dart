/// Amplify AI Kit — 1-1 mirror of JS @aws-amplify/data-schema AI runtime.
library amplify_ai;

// Content
export 'src/content/content_block.dart';
export 'src/content/tool_configuration.dart';
export 'src/content/tool_use_handler.dart';

// Conversation
export 'src/conversation/conversation.dart';
export 'src/conversation/conversation_message.dart';
export 'src/conversation/conversation_message_serializer.dart';
export 'src/conversation/conversation_route.dart';
export 'src/conversation/conversation_stream_event.dart';

// Generation
export 'src/generation/generation_client.dart';
export 'src/generation/generation_route.dart';

// GraphQL
export 'src/graphql/ai_graphql_documents.dart';
export 'src/graphql/ai_graphql_request_factory.dart';
export 'src/graphql/ai_graphql_subscription_handler.dart';

// Config
export 'src/config/ai_config_parser.dart';
export 'src/config/ai_route_config.dart';

// Client
export 'src/client/ai_client.dart';
export 'src/client/ai_client_options.dart';

// Plugin
export 'src/plugin/amplify_ai_category.dart';
