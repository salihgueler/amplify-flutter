// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: Apache-2.0

/// Flutter UI components for Amplify AI Kit.
///
/// Provides ready-to-use widgets for AI conversations, streaming text,
/// tool use visualization, content rendering, and single-turn generation.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:amplify_ai_ui/amplify_ai_ui.dart';
///
/// // Drop-in chat widget
/// AIConversation(
///   controller: AIConversationController(conversationClient: client),
/// )
/// ```
library amplify_ai_ui;

// Theme
export 'src/theme/ai_theme.dart';
export 'src/theme/ai_theme_data.dart';
export 'src/theme/default_theme.dart';

// State
export 'src/state/ai_client_state.dart';
export 'src/state/content_from_events.dart';

// Providers
export 'src/providers/ai_conversation_provider.dart';
export 'src/providers/ai_generation_provider.dart';
export 'src/providers/ai_providers.dart';

// Controller
export 'src/widgets/conversation/ai_conversation_controller.dart';

// Conversation widgets
export 'src/widgets/conversation/ai_conversation.dart';
export 'src/widgets/conversation/amplify_ai_conversation.dart';
export 'src/widgets/conversation/message_bubble.dart';
export 'src/widgets/conversation/message_list.dart';
export 'src/widgets/conversation/streaming_text.dart';
export 'src/widgets/conversation/typing_indicator.dart';

// Input widgets
export 'src/widgets/input/ai_message_input.dart';
export 'src/widgets/input/attachment_button.dart';
export 'src/widgets/input/send_button.dart';

// Tool widgets
export 'src/widgets/tools/tool_use_card.dart';
export 'src/widgets/tools/tool_result_card.dart';
export 'src/widgets/tools/tool_progress_indicator.dart';

// Generation widgets
export 'src/widgets/generation/ai_generation_view.dart';
export 'src/widgets/generation/ai_generation_controller.dart';

// Common widgets
export 'src/widgets/common/ai_avatar.dart';
export 'src/widgets/common/ai_loading_indicator.dart';
export 'src/widgets/common/ai_error_view.dart';

// Content widgets
export 'src/widgets/content/content_block_renderer.dart';
export 'src/widgets/content/code_block_view.dart';
