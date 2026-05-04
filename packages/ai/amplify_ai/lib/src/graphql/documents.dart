// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// GraphQL document templates for AI Kit operations.

/// Fragment for content block fields used across queries and mutations.
const String contentBlockFields = '''
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
''';

/// Fragment for conversation message fields.
const String messageFields = '''
  id
  conversationId
  role
  content {
    $contentBlockFields
  }
  associatedUserMessageId
  createdAt
  updatedAt
''';

/// Fragment for conversation summary fields.
const String conversationFields = '''
  id
  createdAt
  updatedAt
  metadata
  name
''';

/// Fragment for stream event fields (subscription).
const String streamEventFields = '''
  id
  conversationId
  associatedUserMessageId
  contentBlockIndex
  contentBlockText
  contentBlockDeltaIndex
  contentBlockToolUse {
    toolUseId
    name
    input
  }
  contentBlockDoneAtIndex
  stopReason
  errors {
    message
    errorType
  }
  p
''';

/// Generates a create conversation mutation document.
String createConversationDocument(String fieldName) => '''
  mutation CreateConversation(\$input: Create${_capitalize(fieldName)}Input!) {
    $fieldName(input: \$input) {
      $conversationFields
    }
  }
''';

/// Generates a get conversation query document.
String getConversationDocument(String fieldName) => '''
  query GetConversation(\$id: ID!) {
    $fieldName(id: \$id) {
      $conversationFields
    }
  }
''';

/// Generates a list conversations query document.
String listConversationsDocument(String fieldName) => '''
  query ListConversations(\$limit: Int, \$nextToken: String) {
    $fieldName(limit: \$limit, nextToken: \$nextToken) {
      items {
        $conversationFields
      }
      nextToken
    }
  }
''';

/// Generates a delete conversation mutation document.
String deleteConversationDocument(String fieldName) => '''
  mutation DeleteConversation(\$input: Delete${_capitalize(fieldName)}Input!) {
    $fieldName(input: \$input) {
      $conversationFields
    }
  }
''';

/// Generates an update conversation mutation document.
String updateConversationDocument(String fieldName) => '''
  mutation UpdateConversation(\$input: Update${_capitalize(fieldName)}Input!) {
    $fieldName(input: \$input) {
      $conversationFields
    }
  }
''';

/// Generates a send message mutation document.
String sendMessageDocument(String fieldName) => '''
  mutation SendMessage(
    \$conversationId: ID!
    \$content: [AmplifyAIContentBlockInput]
    \$aiContext: AWSJSON
    \$toolConfiguration: AmplifyAIToolConfigurationInput
  ) {
    $fieldName(
      conversationId: \$conversationId
      content: \$content
      aiContext: \$aiContext
      toolConfiguration: \$toolConfiguration
    ) {
      $messageFields
    }
  }
''';

/// Generates a list messages query document.
String listMessagesDocument(String fieldName) => '''
  query ListMessages(
    \$conversationId: ID!
    \$limit: Int
    \$nextToken: String
  ) {
    $fieldName(
      filter: { conversationId: { eq: \$conversationId } }
      limit: \$limit
      nextToken: \$nextToken
    ) {
      items {
        $messageFields
      }
      nextToken
    }
  }
''';

/// Generates a subscription document for stream events.
String onStreamEventDocument(String fieldName) => '''
  subscription OnStreamEvent(\$conversationId: ID!) {
    $fieldName(conversationId: \$conversationId) {
      $streamEventFields
    }
  }
''';

/// Generates a generation query document.
String generationQueryDocument(
  String fieldName,
  List<String> argumentNames,
  List<String> returnFields,
) {
  final args = argumentNames.map((name) => '\$$name: String').join(', ');
  final params = argumentNames.map((name) => '$name: \$$name').join(', ');
  final returns = returnFields.join('\n    ');

  return '''
  query Generation($args) {
    $fieldName($params) {
      $returns
    }
  }
''';
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
