/// GraphQL document templates for AI operations.
/// Generates the correct GraphQL queries, mutations, and subscriptions
/// based on the conversation route name, matching Amplify AI Kit conventions.
///
/// For a route named "chat", the generated operations are:
/// - createConversationChat (mutation)
/// - getConversationChat (query)
/// - listConversationChats (query)
/// - deleteConversationChat (mutation)
/// - chat (mutation - send message / conversation handler)
/// - listConversationMessageChats (query)
/// - onCreateAssistantResponseChat (subscription)
/// - generateChat (query - for generation routes)
class AIGraphQLDocuments {
  /// Creates GraphQL documents for the given route.
  const AIGraphQLDocuments({required this.routeName});

  /// The route name used to generate operation-specific GraphQL documents.
  final String routeName;

  String get _capitalizedRouteName =>
      routeName[0].toUpperCase() + routeName.substring(1);

  // --- Operation name getters (useful for response parsing) ---

  /// The GraphQL field name for creating a conversation.
  String get createConversationFieldName =>
      'createConversation$_capitalizedRouteName';

  /// The GraphQL field name for getting a conversation.
  String get getConversationFieldName =>
      'getConversation$_capitalizedRouteName';

  /// The GraphQL field name for listing conversations.
  String get listConversationsFieldName =>
      'listConversation${_capitalizedRouteName}s';

  /// The GraphQL field name for deleting a conversation.
  String get deleteConversationFieldName =>
      'deleteConversation$_capitalizedRouteName';

  /// The GraphQL field name for sending a message (conversation handler).
  String get sendMessageFieldName => routeName;

  /// The GraphQL field name for listing messages.
  String get listMessagesFieldName =>
      'listConversationMessage${_capitalizedRouteName}s';

  /// The GraphQL field name for the assistant response subscription.
  String get onAssistantResponseFieldName =>
      'onCreateAssistantResponse$_capitalizedRouteName';

  /// The GraphQL field name for generation.
  String get generateFieldName => 'generate$_capitalizedRouteName';

  // --- GraphQL document builders ---

  /// Creates a GraphQL mutation to create a new conversation.
  String createConversation() {
    return '''
      mutation CreateConversation$_capitalizedRouteName(\$input: CreateConversation${_capitalizedRouteName}Input!) {
        createConversation$_capitalizedRouteName(input: \$input) {
          id
          name
          metadata
          owner
          createdAt
          updatedAt
        }
      }
    ''';
  }

  /// Creates a GraphQL query to get a conversation by ID.
  String getConversation() {
    return '''
      query GetConversation$_capitalizedRouteName(\$id: ID!) {
        getConversation$_capitalizedRouteName(id: \$id) {
          id
          name
          metadata
          owner
          createdAt
          updatedAt
        }
      }
    ''';
  }

  /// Creates a GraphQL query to list conversations.
  String listConversations() {
    return '''
      query ListConversation${_capitalizedRouteName}s(\$filter: ModelConversation${_capitalizedRouteName}FilterInput, \$limit: Int, \$nextToken: String) {
        listConversation${_capitalizedRouteName}s(filter: \$filter, limit: \$limit, nextToken: \$nextToken) {
          items {
            id
            name
            metadata
            owner
            createdAt
            updatedAt
          }
          nextToken
        }
      }
    ''';
  }

  /// Creates a GraphQL mutation to delete a conversation.
  String deleteConversation() {
    return '''
      mutation DeleteConversation$_capitalizedRouteName(\$input: DeleteConversation${_capitalizedRouteName}Input!) {
        deleteConversation$_capitalizedRouteName(input: \$input) {
          id
        }
      }
    ''';
  }

  /// Creates a GraphQL mutation to send a message (conversation handler).
  /// This is the primary mutation that triggers the AI model.
  /// The mutation field name is the route name itself (e.g., "chat", "pirateChat").
  String sendMessage() {
    return '''
      mutation $_capitalizedRouteName(\$aiContext: AWSJSON, \$content: [AmplifyAIContentBlockInput], \$conversationId: ID!, \$toolConfiguration: AmplifyAIToolConfigurationInput) {
        $routeName(aiContext: \$aiContext, content: \$content, conversationId: \$conversationId, toolConfiguration: \$toolConfiguration) {
          aiContext
          associatedUserMessageId
          content {
            text
            toolResult {
              status
              content {
                document {
                  format
                  name
                  source {
                    bytes
                  }
                }
                image {
                  format
                  source {
                    bytes
                  }
                }
                json
                text
              }
              toolUseId
            }
            toolUse {
              input
              name
              toolUseId
            }
            image {
              format
              source {
                bytes
              }
            }
            document {
              format
              name
              source {
                bytes
              }
            }
          }
          conversationId
          createdAt
          id
          owner
          role
          toolConfiguration {
            tools {
              toolSpec {
                description
                inputSchema {
                  json
                }
                name
              }
            }
          }
          updatedAt
        }
      }
    ''';
  }

  /// Creates a GraphQL subscription for assistant response streaming.
  /// Subscribes to `onCreateAssistantResponse{RouteName}`.
  String onStreamEvent() {
    return '''
      subscription OnCreateAssistantResponse$_capitalizedRouteName(\$conversationId: ID) {
        onCreateAssistantResponse$_capitalizedRouteName(conversationId: \$conversationId) {
          id
          conversationId
          associatedUserMessageId
          contentBlockIndex
          contentBlockDeltaIndex
          contentBlockText
          contentBlockToolUse {
            input
            name
            toolUseId
          }
          contentBlockDoneAtIndex
          stopReason
          errors {
            errorType
            message
          }
          owner
        }
      }
    ''';
  }

  /// Creates a GraphQL query to list messages for a conversation.
  String listMessages() {
    return '''
      query ListConversationMessage${_capitalizedRouteName}s(\$filter: ModelConversationMessage${_capitalizedRouteName}FilterInput, \$limit: Int, \$nextToken: String) {
        listConversationMessage${_capitalizedRouteName}s(filter: \$filter, limit: \$limit, nextToken: \$nextToken) {
          items {
            id
            conversationId
            role
            content {
              text
              toolResult {
                status
                content {
                  document {
                    format
                    name
                    source {
                      bytes
                    }
                  }
                  image {
                    format
                    source {
                      bytes
                    }
                  }
                  json
                  text
                }
                toolUseId
              }
              toolUse {
                input
                name
                toolUseId
              }
              image {
                format
                source {
                  bytes
                }
              }
              document {
                format
                name
                source {
                  bytes
                }
              }
            }
            associatedUserMessageId
            owner
            createdAt
            updatedAt
          }
          nextToken
        }
      }
    ''';
  }

  /// Creates a GraphQL query for generation routes.
  /// The field name is `generate{RouteName}` (e.g., `generateSummarize`).
  String generate() {
    return '''
      query Generate$_capitalizedRouteName(\$input: String) {
        generate$_capitalizedRouteName(input: \$input)
      }
    ''';
  }
}
