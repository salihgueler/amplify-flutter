// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Example app demonstrating Amplify AI UI components.
///
/// This example shows how to:
/// 1. Set up an AIConversationController
/// 2. Use the AmplifyAIConversation drop-in widget
/// 3. Customize the theme
/// 4. Use the AIGenerationView for single-turn generation
library;

import 'package:flutter/material.dart';
import 'package:amplify_ai_ui/amplify_ai_ui.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amplify AI UI Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Amplify AI UI Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DemoCard(
            title: 'AI Conversation',
            subtitle: 'Full chat experience with streaming',
            icon: Icons.chat_bubble_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConversationDemoPage()),
            ),
          ),
          const SizedBox(height: 12),
          _DemoCard(
            title: 'AI Generation',
            subtitle: 'Single-turn text generation',
            icon: Icons.auto_awesome,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GenerationDemoPage()),
            ),
          ),
          const SizedBox(height: 12),
          _DemoCard(
            title: 'Components Gallery',
            subtitle: 'Individual widget showcase',
            icon: Icons.widgets_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ComponentsGalleryPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _DemoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Demo page showing a full AI conversation.
///
/// In a real app, you would pass a real ConversationClient:
/// ```dart
/// final controller = AIConversationController(
///   conversationClient: aiPlugin.getConversationClient('myRoute'),
/// );
/// ```
class ConversationDemoPage extends StatelessWidget {
  const ConversationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTE: In a real app, initialize with an actual ConversationClient.
    // This demo just shows the UI layout.
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // controller.reset();
            },
          ),
        ],
      ),
      body: AITheme(
        themeData: createDefaultAITheme(context),
        child: const Center(
          child: Text(
            'Connect a ConversationClient to use\n'
            'AmplifyAIConversation widget here.\n\n'
            'See README for setup instructions.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Demo page for single-turn AI generation.
class GenerationDemoPage extends StatelessWidget {
  const GenerationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Generation')),
      body: AITheme(
        themeData: createDefaultAITheme(context),
        child: const Center(
          child: Text(
            'Connect an AIGenerationProvider to use\n'
            'AIGenerationView widget here.\n\n'
            'See README for setup instructions.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Showcase of individual components.
class ComponentsGalleryPage extends StatelessWidget {
  const ComponentsGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Components Gallery')),
      body: AITheme(
        themeData: createDefaultAITheme(context),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Typing Indicator',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const TypingIndicator(),
            const SizedBox(height: 24),
            Text(
              'Tool Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const ToolProgressIndicator(
              toolName: 'searchDatabase',
            ),
            const SizedBox(height: 16),
            const ToolProgressIndicator(
              toolName: 'fetchWeather',
            ),
            const SizedBox(height: 24),
            Text('Code Block', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const CodeBlockContentView(
              language: 'dart',
              code:
                  'void main() {\n'
                  '  print("Hello, Amplify AI!");\n'
                  '}',
            ),
            const SizedBox(height: 24),
            Text(
              'Send Button States',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SendButton(onPressed: () {}, enabled: true),
                const SizedBox(width: 16),
                SendButton(onPressed: () {}, enabled: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
