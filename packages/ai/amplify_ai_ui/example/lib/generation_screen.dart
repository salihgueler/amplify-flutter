// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Example generation screen demonstrating typed arguments for each route.
///
/// Each generation route has its own typed arguments and return type:
/// - "summarize": {text: String!, maxLength: Int} → {summary, keyPoints}
/// - "generateCode": {description: String!, language: String!} → {code, explanation}
/// - "describeImage": {imageUrl: String!} → {description, tags}
library;

import 'package:flutter/material.dart';
import 'package:amplify_ai/amplify_ai.dart';

/// Screen demonstrating the generation routes with typed arguments.
class GenerationScreen extends StatefulWidget {
  const GenerationScreen({super.key});

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  final _textController = TextEditingController();
  String _result = '';
  bool _isLoading = false;
  String _selectedRoute = 'summarize';

  // Generation routes with typed arguments matching the actual schema
  late final _summarizeRoute = GenerationRoute(
    routeName: 'summarize',
    variables: r'$text: String!, $maxLength: Int',
    args: r'text: $text, maxLength: $maxLength',
    selectionSet: 'summary keyPoints',
  );

  late final _generateCodeRoute = GenerationRoute(
    routeName: 'generateCode',
    variables: r'$description: String!, $language: String!',
    args: r'description: $description, language: $language',
    selectionSet: 'code explanation',
  );

  late final _describeImageRoute = GenerationRoute(
    routeName: 'describeImage',
    variables: r'$imageUrl: String!',
    args: r'imageUrl: $imageUrl',
    selectionSet: 'description tags',
  );

  Future<void> _generate() async {
    final inputText = _textController.text.trim();
    if (inputText.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      GenerationResponse response;

      switch (_selectedRoute) {
        case 'summarize':
          response = await _summarizeRoute.generate(
            arguments: {'text': inputText, 'maxLength': 200},
          );
          _result =
              'Summary: ${response['summary']}\n\nKey Points: ${response['keyPoints']}';
          break;
        case 'generateCode':
          response = await _generateCodeRoute.generate(
            arguments: {'description': inputText, 'language': 'dart'},
          );
          _result =
              'Code:\n${response['code']}\n\nExplanation: ${response['explanation']}';
          break;
        case 'describeImage':
          response = await _describeImageRoute.generate(
            arguments: {'imageUrl': inputText},
          );
          _result =
              'Description: ${response['description']}\n\nTags: ${response['tags']}';
          break;
      }
    } catch (e) {
      _result = 'Error: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Generation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'summarize', label: Text('Summarize')),
                ButtonSegment(
                  value: 'generateCode',
                  label: Text('Generate Code'),
                ),
                ButtonSegment(
                  value: 'describeImage',
                  label: Text('Describe Image'),
                ),
              ],
              selected: {_selectedRoute},
              onSelectionChanged: (value) {
                setState(() {
                  _selectedRoute = value.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: _getHintText(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _generate,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generate'),
            ),
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: Text(_result))),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    switch (_selectedRoute) {
      case 'summarize':
        return 'Enter text to summarize...';
      case 'generateCode':
        return 'Describe what code to generate...';
      case 'describeImage':
        return 'Enter image URL...';
      default:
        return 'Enter input...';
    }
  }
}
