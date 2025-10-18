# LED NHL Killswitch

An iOS app to remotely control and monitor an NHL LED display process via HTTP API.

## Features

- **Remote Process Control**: Start and stop the LED display process with a simple toggle switch
- **Real-time Status Monitoring**: Automatically polls server status every second
- **Secure Authentication**: Uses Bearer token authentication for all API requests
- **Easy Configuration**: Simple setup screen for server URL and password
- **Settings Management**: Edit server configuration anytime via the gear icon

## Setup

### First Launch

When you first launch the app, you'll be prompted to enter:

1. **Server URL**: The base URL of your LED NHL server (e.g., `http://192.168.1.100:8080`)
2. **Password**: The Bearer token used for authentication

These settings are saved locally and persist across app restarts.

### Changing Settings

Tap the gear icon in the top-right corner to modify the server URL or password at any time.

## Usage

### Main Screen

The main screen displays:

- **App Icon**: Your LED NHL Killswitch logo
- **Status Text**: Real-time status message from the server
- **Process Toggle**: Switch to start/stop the LED display process
  - ON: Process is running
  - OFF: Process is stopped

### API Integration

The app communicates with your server using these endpoints:

#### GET /status
- Called every second to check process status
- Returns text indicating current state
- Process is considered running if response starts with "Process is running with PID"

#### POST /start
- Called when toggle is switched ON
- Starts the LED display process

#### POST /stop
- Called when toggle is switched OFF
- Stops the LED display process

All requests include the `Authorization: Bearer <password>` header.

## Server Requirements

Your LED NHL server must implement the following HTTP endpoints:

### GET /status
Returns the current process status as plain text.

**Example responses:**
```
Process is running with PID 1234
```
```
Process is not running
```

### POST /start
Starts the LED display process.

**Authentication**: Requires `Authorization: Bearer <token>` header

### POST /stop
Stops the LED display process.

**Authentication**: Requires `Authorization: Bearer <token>` header

## Technical Details

- **Platform**: iOS
- **Framework**: SwiftUI
- **Storage**: AppStorage for persistent configuration
- **Networking**: URLSession for HTTP requests
- **Polling Interval**: 1 second

## Logging

The app logs all HTTP requests and responses to stdout for debugging:

- 🌐 HTTP GET/POST requests with full URLs
- 🔑 Authorization headers (for debugging)
- ✅ Successful responses
- ❌ Error messages

View logs in Xcode's console when running the app.

## Error Handling

The app gracefully handles:

- Invalid server URLs
- Network connectivity issues
- Server errors
- Missing or invalid responses

All errors are displayed in the status text for user feedback.

## Development

Built with:
- Xcode
- SwiftUI
- iOS SDK

## License

Created by Éric Spérano on 10/17/25.
