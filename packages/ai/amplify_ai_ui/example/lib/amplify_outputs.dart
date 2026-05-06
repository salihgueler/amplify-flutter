// This file is auto-generated from the Amplify backend configuration.
// Do not edit manually.

const amplifyOutputs = '''{
  "version": "1.4",
  "ai": {
    "conversation": {
      "chat": {
        "modelId": "anthropic.claude-3-haiku-20240307-v1:0",
        "systemPrompt": "You are a helpful assistant.",
        "inferenceConfiguration": {
          "maxTokens": 2048,
          "temperature": 0.7,
          "topP": 0.9
        }
      }
    },
    "generation": {
      "summarize": {
        "modelId": "anthropic.claude-3-haiku-20240307-v1:0",
        "systemPrompt": "You are a summarization assistant.",
        "inferenceConfiguration": {
          "maxTokens": 1024
        }
      },
      "generateCode": {
        "modelId": "anthropic.claude-3-haiku-20240307-v1:0",
        "systemPrompt": "You are a code generation assistant.",
        "inferenceConfiguration": {
          "maxTokens": 2048
        }
      },
      "describeImage": {
        "modelId": "anthropic.claude-3-haiku-20240307-v1:0",
        "systemPrompt": "You are an image description assistant.",
        "inferenceConfiguration": {
          "maxTokens": 1024
        }
      }
    }
  }
}''';
