/// GraphQL document templates for AI operations.
/// Generates the correct GraphQL queries, mutations, and subscriptions
/// based on the conversation route name, matching Amplify AI Kit conventions.
///
/// For a conversation route named "chat", the generated operations are:
/// - createConversationChat (mutation)
/// - getConversationChat (query)
/// - listConversationChats (query)
/// - deleteConversationChat (mutation)
/// - chat (mutation - send message / conversation handler)
/// - listConversationMessageChats (query)
/// - onCreateAssistantResponseChat (subscription)
///
/// For a generation route named "summarize", the generated operation is:
/// - summarize (query - with typed arguments specific to each route)
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
  /// For generation routes, the field name IS the route name itself
  /// (e.g., "summarize", "generateCode", "describeImage").
  String get generateFieldName => routeName;

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
  /// Arguments are passed directly (not wrapped in an "input" object):
  /// - conversationId: ID! (required)
  /// - content: [AmplifyAIContentBlockInput] (nullable array)
  /// - aiContext: AWSJSON
  /// - toolConfiguration: AmplifyAIToolConfigurationInput
  String sendMessage() {
    return '''
      mutation $_capitalizedRouteName(\$conversationId: ID!, \$content: [AmplifyAIContentBlockInput], \$aiContext: AWSJSON, \$toolConfiguration: AmplifyAIToolConfigurationInput) {
        $routeName(conversationId: \$conversationId, content: \$content, aiContext: \$aiContext, toolConfiguration: \$toolConfiguration) {
          id
          conversationId
          role
          content {
            text
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
            toolUse {
              toolUseId
              name
              input
            }
            toolResult {
              toolUseId
              status
              content {
                text
                json
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
            }
          }
          createdAt
          updatedAt
        }
      }
    ''';
  }

  /// Creates a GraphQL subscription for assistant response streaming.
  /// Subscribes to `onCreateAssistantResponse{RouteName}`.
  /// The conversationId argument is required (ID!).
  /// Returns AmplifyAIConversationMessageStreamPart fields.
  String onStreamEvent() {
    return '''
      subscription OnCreateAssistantResponse$_capitalizedRouteName(\$conversationId: ID!) {
        onCreateAssistantResponse$_capitalizedRouteName(conversationId: \$conversationId) {
          id
          owner
          conversationId
          associatedUserMessageId
          contentBlockIndex
          contentBlockText
          contentBlockDeltaIndex
          contentBlockToolUse {
            toolUseId
            name
            input
            type
          }
          contentBlockDoneAtIndex
          stopReason
          errors {
            errorType
            message
          }
          p
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
              toolUse {
                toolUseId
                name
                input
              }
              toolResult {
                toolUseId
                status
                content {
                  text
                  json
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
  /// The field name is the route name itself (e.g., "summarize", "generateCode").
  /// Each route has its own typed arguments and return type.
  ///
  /// [variables] defines the GraphQL variable declarations (e.g., '\$text: String!, \$maxLength: Int').
  /// [args] defines the field arguments (e.g., 'text: \$text, maxLength: \$maxLength').
  /// [selectionSet] defines the return fields (e.g., 'summary keyPoints').
  String generate({
    required String variables,
    required String args,
    required String selectionSet,
  }) {
    return '''
      query $_capitalizedRouteName($variables) {
        $routeName($args) {
          $selectionSet
        }
      }
    ''';
  }

  /// Creates a simple generation query with a single string input.
  /// Use [generate] for typed arguments.
  String generateSimple() {
    return '''
      query $_capitalizedRouteName(\$input: String) {
        $routeName(input: \$input)
      }
    ''';
  }
}
