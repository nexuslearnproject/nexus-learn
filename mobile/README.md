# Nexus Learn Mobile

Flutter mobile application for Nexus Learn, connecting to the Django REST API backend.

## Prerequisites

- Flutter SDK installed (version 3.4.3 or higher)
- Android Studio / Xcode (for iOS development)
- Backend API running (Django backend on port 8000)

## Setup

1. **Install dependencies**:
   ```bash
   cd mobile
   flutter pub get
   ```

2. **Configure API URL**:
   
   The API URL is configured in `lib/services/api_service.dart`. Choose the appropriate URL based on your setup:
   
   - **Android Emulator**: `http://10.0.2.2:8000` (default)
   - **iOS Simulator**: `http://localhost:8000`
   - **Physical Device**: `http://YOUR_COMPUTER_IP:8000`
   
   Update the `baseUrl` constant in `lib/services/api_service.dart` accordingly.

3. **Start the backend**:
   ```bash
   # From project root
   docker-compose up
   ```

## Running the App

### Android
```bash
flutter run
```

### iOS
```bash
flutter run
```

### Specific Device
```bash
flutter devices  # List available devices
flutter run -d <device-id>
```

## Project Structure

```
mobile/
├── lib/
│   ├── main.dart              # App entry point
│   ├── models/
│   │   └── item.dart          # Item data model
│   ├── services/
│   │   └── api_service.dart   # API communication service
│   ├── providers/
│   │   └── item_provider.dart # State management
│   ├── screens/
│   │   └── home_screen.dart   # Main screen
│   └── widgets/
│       ├── item_card.dart     # Item display widget
│       └── add_item_dialog.dart # Add item dialog
├── android/                   # Android-specific files
├── ios/                       # iOS-specific files
└── pubspec.yaml              # Dependencies
```

## Features

- ✅ View list of items from the API
- ✅ Add new items
- ✅ Delete items
- ✅ Backend health status indicator
- ✅ Pull-to-refresh
- ✅ Error handling and loading states

## API Configuration

The app connects to the Django REST API at the following endpoints:

- `GET /api/health/` - Health check
- `GET /api/items/` - List all items
- `POST /api/items/` - Create a new item
- `DELETE /api/items/{id}/` - Delete an item

## Troubleshooting

### Cannot connect to backend

1. **Android Emulator**: Make sure you're using `10.0.2.2:8000` instead of `localhost:8000`
2. **Physical Device**: 
   - Find your computer's IP address: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
   - Update `baseUrl` in `api_service.dart` to use your IP
   - Ensure your phone and computer are on the same network
   - Make sure the backend is accessible from your network

### Build Errors

- Run `flutter clean` and then `flutter pub get`
- Ensure Flutter SDK is up to date: `flutter upgrade`
- Check that all dependencies are compatible

## Development

The app uses:
- **Provider** for state management
- **HTTP** package for API calls
- **Material Design 3** for UI

Hot reload is supported during development. Press `r` in the terminal or use your IDE's hot reload button.
