# OpenAI Integration for MineChat

This document explains how the OpenAI integration works in the MineChat Flutter application.

## Overview

The application now uses real OpenAI API responses instead of the previous rule-based system. Users can configure their AI assistant with custom settings and get intelligent responses from GPT-3.5-turbo.

## Features

### 1. AI Assistant Configuration
- **Name**: Custom name for the AI assistant
- **Intro Message**: Initial greeting message
- **Short Description**: Brief description of the assistant's role
- **AI Guidelines**: Instructions for how the AI should behave
- **Response Length**: Short, Normal, or Long responses

### 2. Real-time AI Chat
- Direct integration with OpenAI GPT-3.5-turbo
- Loading indicators during response generation
- Error handling for API issues
- Disabled send button during processing

### 3. Configuration Management
- Centralized configuration in `lib/core/config/app_config.dart`
- Secure API key management
- Environment-specific settings

## Setup Instructions

### 1. API Key Configuration
The OpenAI API key is configured in `lib/core/config/app_config.dart`:

```dart
static const String openaiApiKey = 'your-api-key-here';
```

### 2. Dependencies
The integration requires the `http` package, which is already added to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.0
```

### 3. Usage Flow

1. **Setup AI Assistant**:
   - Navigate to Setup → AI Assistant
   - Fill in the assistant details
   - Save the configuration

2. **Test AI**:
   - Click "Test AI" button or navigate to AI Testing screen
   - Send messages to test the AI responses
   - Use the refresh button to quickly test the connection

3. **Business Information**:
   - Navigate to AI Business Information screen
   - Chat with the configured AI assistant

## Technical Implementation

### Files Modified/Created

1. **`lib/core/services/openai_service.dart`**
   - Handles OpenAI API calls
   - Manages system prompts
   - Error handling and response processing

2. **`lib/core/config/app_config.dart`**
   - Centralized configuration management
   - API keys and environment variables

3. **`lib/controller/ai_assistant_controller/ai_assistant_controller.dart`**
   - Updated `sendMessage` method to use OpenAI API
   - Added loading states and error handling

4. **`lib/view/screens/setup/ai_testing_screen.dart`**
   - Added loading indicators
   - Disabled send button during processing
   - Added test connection button

5. **`lib/view/screens/setup/ai_business_information.dart`**
   - Same improvements as testing screen

### API Integration Details

The OpenAI service uses the following configuration:

- **Model**: GPT-3.5-turbo
- **Temperature**: 0.7 (balanced creativity)
- **Max Tokens**: Variable based on response length setting
- **System Prompt**: Dynamically built from assistant configuration

### Error Handling

The integration handles various error scenarios:

- **401**: Authentication error (invalid API key)
- **429**: Rate limit exceeded
- **Network errors**: Connection issues
- **Empty responses**: API returns no content

## Testing

### Quick Test
1. Open the AI Testing screen
2. Click the refresh button in the app bar
3. The AI should respond with an introduction

### Manual Test
1. Configure an AI assistant in the setup
2. Navigate to AI Testing
3. Send various messages to test responses
4. Verify loading states and error handling

## Security Considerations

- API keys are stored in the configuration file
- For production, consider using environment variables
- API calls are made over HTTPS
- Error messages don't expose sensitive information

## Troubleshooting

### Common Issues

1. **"Authentication error"**
   - Check if the API key is correct
   - Verify the key has proper permissions

2. **"Rate limit exceeded"**
   - Wait a few minutes before trying again
   - Check your OpenAI account usage

3. **"Network error"**
   - Check internet connection
   - Verify firewall settings

4. **No response generated**
   - Check if the assistant is properly configured
   - Verify all required fields are filled

### Debug Information

Enable debug logging by checking the console output for:
- API request/response details
- Error messages
- Loading state changes

## Future Enhancements

Potential improvements for the OpenAI integration:

1. **Conversation History**: Maintain context across messages
2. **Multiple Models**: Support for different GPT models
3. **Custom Prompts**: Allow users to create custom system prompts
4. **Response Streaming**: Real-time response generation
5. **Usage Analytics**: Track API usage and costs
6. **Fallback Responses**: Local responses when API is unavailable
