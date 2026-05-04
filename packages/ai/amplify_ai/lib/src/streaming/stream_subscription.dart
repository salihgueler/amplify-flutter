// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// AppSync subscription handler for AI conversation streaming.
///
/// Manages the lifecycle of a GraphQL subscription that delivers
/// streaming response chunks from the AI model.

import 'dart:async';

import '../graphql/documents.dart' as docs;
import '../types/conversation_stream_event.dart';
import '../clients/graphql_api_provider.dart';
import 'stream_reassembler.dart';

/// Manages a subscription to AI conversation stream events.
///
/// Handles connection lifecycle, event deserialization, and automatic
/// reassembly of streaming chunks into content blocks.
///
/// ```dart
/// final subscription = StreamSubscription(
///   api: apiProvider,
///   conversationId: 'conv-123',
///   subscribeFieldName: 'onCreateAssistantResponsePirateChat',
/// );
///
/// await for (final event in subscription.events) {
///   print(event);
/// }
/// ```
class StreamSubscription {
  final GraphQLAPIProvider _api;
  final String _conversationId;
  final String _subscribeFieldName;

  StreamController<ConversationStreamEvent>? _controller;
  bool _isCancelled = false;

  /// The reassembler accumulating events for this subscription.
  final StreamReassembler reassembler = StreamReassembler();

  /// Creates a stream subscription for the given conversation.
  StreamSubscription({
    required GraphQLAPIProvider api,
    required String conversationId,
    required String subscribeFieldName,
  })  : _api = api,
        _conversationId = conversationId,
        _subscribeFieldName = subscribeFieldName;

  /// The conversation ID this subscription is for.
  String get conversationId => _conversationId;

  /// Whether this subscription has been cancelled.
  bool get isCancelled => _isCancelled;

  /// Whether the current turn is complete.
  bool get isComplete => reassembler.isComplete;

  /// A broadcast stream of conversation stream events.
  ///
  /// Events are emitted as they arrive from the AppSync subscription.
  /// Use [reassembler] to accumulate them into content blocks.
  Stream<ConversationStreamEvent> get events {
    _controller ??= _createController();
    return _controller!.stream;
  }

  StreamController<ConversationStreamEvent> _createController() {
    final controller = StreamController<ConversationStreamEvent>.broadcast(
      onListen: _startListening,
      onCancel: _handleCancel,
    );
    return controller;
  }

  void _startListening() {
    if (_isCancelled) return;

    final responseStream = _api.subscribe(
      document: docs.onStreamEventDocument(_subscribeFieldName),
      variables: {'conversationId': _conversationId},
    );

    final mapped = responseStream.where((r) => r.data != null).map((response) {
      final eventData =
          response.data![_subscribeFieldName] as Map<String, dynamic>;
      return ConversationStreamEvent.fromJson(eventData);
    });

    mapped.listen(
      (event) {
        if (_isCancelled) return;
        reassembler.addEvent(event);
        _controller?.add(event);
      },
      onError: (Object error) {
        if (_isCancelled) return;
        _controller?.addError(error);
      },
      onDone: () {
        if (_isCancelled) return;
        _controller?.close();
      },
    );
  }

  void _handleCancel() {
    // No-op for broadcast controller; cleanup via cancel().
  }

  /// Cancels the subscription and releases resources.
  void cancel() {
    _isCancelled = true;
    _controller?.close();
    _controller = null;
  }

  /// Resets the reassembler for a new turn within the same conversation.
  void resetForNewTurn() {
    reassembler.reset();
  }
}
