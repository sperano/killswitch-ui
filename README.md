# LED NHL Killswitch

An iOS app to communicate with this [killswitch](https://github.com/sperano/killswitch/) process running on a server.

The original goal for both projects is simply to have an easy way to start / stop the [NHL LED Scoreboard](https://github.com/falkyre/nhl-led-scoreboard) project from an iPhone.

## Features

- **Remote Process Control**: Start and stop the NHL LED Scoreboard process with a simple toggle switch
- **Real-time Status Monitoring**: Automatically polls server status every second
- **Secure Authentication**: Uses Bearer token authentication for all REST API requests

## Setup

### First Launch

When you first launch the app, you'll be prompted to enter:

1. **Server URL**: The base URL of your LED NHL server (e.g., `http://192.168.1.100:9966`)
2. **Password**: The Bearer token/password used for authentication

These settings are saved locally and persist across app restarts.

### Changing Settings

Tap the gear icon in the top-right corner to modify the server URL or password at any time.

## Usage

### Main Screen

The main screen displays:

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

See [killswitch](https://github.com/sperano/killswitch).

## Technical Details

- **Platform**: iOS
- **Framework**: SwiftUI
- **Storage**: AppStorage for persistent configuration
- **Networking**: URLSession for HTTP requests
- **Polling Interval**: 1 second

## Development

Built with:
- Xcode
- SwiftUI
- iOS SDK

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
