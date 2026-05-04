// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Example demonstrating the Amplify AI Kit for Flutter/Dart.
///
/// This shows how to set up conversation and generation clients,
/// send messages, handle streaming, and use client-side tools.

// ignore_for_file: avoid_print

import 'dart:async';

import 'package:amplify_ai/amplify_ai.dart';

/// A mock GraphQL API provider for demonstration purposes.
/// In a real app, this would wrap the Amplify API plugin.
class MockGraphQLProvider implements GraphQLAPIProvider {
  @override
  Future<GraphQLResponse<Map<String, dynamic>>> query({
    required String document,
    required Map<String, dynamic> variables,
    String? apiName,
  }) async {
    // In a real app, this calls Amplify.API.query(...)
    return const GraphQLResponse(data: null);
  }

  @override
  Future<GraphQLResponse<Map<String, dynamic>>> mutate({
    required String document,
    required Map<String, dynamic> variables,
    String? apiName,
  }) async {
    // In a real app, this calls Amplify.API.mutate(...)
    return const GraphQLResponse(data: null);
  }

  @override
  Stream<GraphQLResponse<Map<String, dynamic>>> subscribe({
    required String document,
    required Map<String, dynamic> variables,
    String? apiName,
  }) {
    // In a real app, this calls Amplify.API.subscribe(...)
    return const Stream.empty();
  }
}

Future<void> main() async {
  // 1. Parse config from amplify_outputs.json
  final amplifyOutputs = <String, dynamic>{
    'data': {
      'model_introspection': {
        'conversations': {
          'pirateChat': {
            'conversation': {
              'modelName': 'PirateChatConversation',
              'get': 'getPirateChatConversation',
              'create': 'createPirateChatConversation',
              'list': 'listPirateChatConversations',
              'delete': 'deletePirateChatConversation',
              'update': 'updatePirateChatConversation',
            },
            'message': {
              'modelName': 'PirateChatMessage',
              'send': 'pirateChat',
              'subscribe': 'onCreatePirateChatAssistantResponse',
              'list': 'listPirateChatMessages',
            },
          },
        },
        'generations': {
          'generateRecipe': {
            'queryFieldName': 'generateRecipe',
          },
        },
      },
    },
  };

  final config = AmplifyAIConfig.fromOutputs(amplifyOutputs);
  final apiProvider = MockGraphQLProvider();

  // 2. Create the AI plugin
  final aiPlugin = AmplifyAIPlugin(
    config: config,
    apiProvider: apiProvider,
  );

  // 3. Use a conversation client
  final chatClient = aiPlugin.getConversationClient('pirateChat');
  print('Conversation route: ${chatClient.routeName}');

  // Create a new conversation
  final createResult = await chatClient.create(name: 'Pirate Adventure');
  if (createResult.hasData) {
    final conversation = createResult.data!;
    print('Created conversation: ${conversation.id}');

    // Send a message
    await conversation.sendMessage(
      SendMessageInput.text('Tell me a pirate story!'),
    );

    // Subscribe to streaming responses
    final reassembler = StreamReassembler();
    final subscription = conversation.onStreamEvent().listen((event) {
      reassembler.addEvent(event);

      if (event.isTextDelta) {
        // Real-time text as it comes in
        print('Chunk: ${event.contentBlockText}');
      }

      if (event.isTurnComplete) {
        // Get the full assembled response
        final blocks = reassembler.getContentBlocks();
        for (final block in blocks) {
          if (block.text != null) {
            print('Complete response: ${block.text}');
          }
        }
        reassembler.reset();
      }
    });

    // Clean up
    await subscription.cancel();
  }

  // 4. Use client-side tools
  final toolHandler = ClientToolHandler();
  toolHandler.registerHandler('getWeather', (name, input) async {
    final city = input['city'] as String?;
    return [ToolResultContent.text('Sunny and 72°F in $city')];
  });

  // When you receive a tool use from the stream:
  const mockToolUse = ToolUseBlock(
    toolUseId: 'tool-123',
    name: 'getWeather',
    input: {'city': 'Seattle'},
  );

  final toolResult = await toolHandler.handleToolUse(mockToolUse);
  print('Tool result: ${toolResult.content.first.text}');

  // 5. Use a generation client
  final genClient = aiPlugin.getGenerationClient('generateRecipe');
  print('Generation route: ${genClient.routeName}');

  final genResult = await genClient.generate(
    arguments: {'description': 'A spicy Thai curry'},
  );
  if (genResult.hasData) {
    print('Generated: ${genResult.data}');
  }
}
