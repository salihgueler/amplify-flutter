/// GraphQL document templates for AI operations.
/// Generates the correct GraphQL queries, mutations, and subscriptions
/// based on the conversation route name.
class AIGraphQLDocuments {
  /// Creates GraphQL documents for the given route.
  const AIGraphQLDocuments({required this.routeName});

  /// The route name used to generate operation-specific GraphQL documents.
  final String routeName;

  String get _capitalizedRouteName =>
      routeName[0].toUpperCase() + routeName.substring(1);

  /// Creates a GraphQL mutation to create a new conversation.
  String createConversation() {
    return '''
      mutation Create$_capitalizedRouteName(\$input: Create${_capitalizedRouteName}Input!) {
        create$_capitalizedRouteName(input: \$input) {
          id
          name
          metadata
          createdAt
          updatedAt
        }
      }
    ''';
  }

  /// Creates a GraphQL query to get a conversation by ID.
  String getConversation() {
    return '''
      query Get$_capitalizedRouteName(\$id: ID!) {
        get$_capitalizedRouteName(id: \$id) {
          id
          name
          metadata
          messages {
            items {
              id
              conversationId
              role
              content
              associatedUserMessageId
              aiContext
              createdAt
              updatedAt
            }
          }
          createdAt
          updatedAt
        }
      }
    ''';
  }

  /// Creates a GraphQL query to list conversations.
  String listConversations() {
    return '''
      query List${_capitalizedRouteName}s(\$limit: Int, \$nextToken: String) {
        list${_capitalizedRouteName}s(limit: \$limit, nextToken: \$nextToken) {
          items {
            id
            name
            metadata
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
      mutation Delete$_capitalizedRouteName(\$input: Delete${_capitalizedRouteName}Input!) {
        delete$_capitalizedRouteName(input: \$input) {
          id
        }
      }
    ''';
  }

  /// Creates a GraphQL mutation to send a message.
  String sendMessage() {
    final messageModelName = '${_capitalizedRouteName}Message';
    return '''
      mutation Send$messageModelName(\$input: Create${messageModelName}Input!) {
        create$messageModelName(input: \$input) {
          id
          conversationId
          role
          content
          associatedUserMessageId
          aiContext
          createdAt
          updatedAt
        }
      }
    ''';
  }

  /// Creates a GraphQL subscription for stream events.
  String onStreamEvent() {
    final messageModelName = '${_capitalizedRouteName}Message';
    return '''
      subscription OnCreate${messageModelName}Stream(\$conversationId: ID!) {
        onCreate${messageModelName}Stream(conversationId: \$conversationId) {
          id
          conversationId
          associatedUserMessageId
          contentBlockIndex
          contentBlockDeltaIndex
          contentBlockText
          contentBlockToolUse
          contentBlockDoneAtIndex
          stopReason
          message
        }
      }
    ''';
  }

  /// Creates a GraphQL query to list messages for a conversation.
  String listMessages() {
    final messageModelName = '${_capitalizedRouteName}Message';
    return '''
      query List${messageModelName}s(\$conversationId: ID!, \$limit: Int, \$nextToken: String) {
        list${messageModelName}s(
          filter: { conversationId: { eq: \$conversationId } }
          limit: \$limit
          nextToken: \$nextToken
        ) {
          items {
            id
            conversationId
            role
            content
            associatedUserMessageId
            aiContext
            createdAt
            updatedAt
          }
          nextToken
        }
      }
    ''';
  }

  /// Creates a GraphQL mutation for generation.
  String generate() {
    return '''
      mutation Generate$_capitalizedRouteName(\$input: Generate${_capitalizedRouteName}Input!) {
        generate$_capitalizedRouteName(input: \$input) {
          content
          stopReason
          usage {
            inputTokens
            outputTokens
            totalTokens
          }
        }
      }
    ''';
  }
}
