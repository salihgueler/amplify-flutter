// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Amplify AI Kit for Flutter/Dart.
///
/// Provides AI conversation and generation capabilities powered by
/// AWS AI services through AWS AppSync GraphQL.
///
/// ## Features
///
/// - **Conversations**: Multi-turn chat with AI models via streaming
/// - **Generations**: Single-turn AI inference with typed inputs/outputs
/// - **Streaming**: Real-time response streaming via AppSync subscriptions
/// - **Tools**: Client-side tool framework for AI function calling
///
/// ## Quick Start
///
/// ```dart
/// import 'package:amplify_ai/amplify_ai.dart';
///
/// // 1. Create the plugin with your config and API provider
/// final aiPlugin = AmplifyAIPlugin(
///   config: AmplifyAIConfig.fromOutputs(amplifyOutputs),
///   apiProvider: myGraphQLProvider,
/// );
///
/// // 2. Get a conversation client
/// final chatClient = aiPlugin.getConversationClient('pirateChat');
///
/// // 3. Create a conversation and send a message
/// final result = await chatClient.create(name: 'My Chat');
/// final conversation = result.data!;
/// await conversation.sendMessage(SendMessageInput.text('Hello!'));
///
/// // 4. Listen to streaming responses
/// conversation.onStreamEvent().listen((event) {
///   // Handle streaming events
/// });
/// ```
library amplify_ai;

export 'src/clients/clients.dart';
export 'src/config/config.dart';
export 'src/graphql/graphql.dart';
export 'src/plugin/plugin.dart';
export 'src/stream/stream.dart';
export 'src/types/types.dart';
