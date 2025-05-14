# Instagram Clone

A Flutter application that replicates Instagram's core features using Flutter, GetX, and Firebase.

## Features

- User authentication (sign up, login, logout)
- Create and view posts
- Like and comment on posts
- User profiles
- Search for users
- Stories
- Real-time updates using Firebase

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Firebase account

### Setup

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Firebase Configuration:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android and iOS apps to your Firebase project
   - Download and replace the Firebase configuration files:
     - For Android: `google-services.json` in `android/app/`
     - For iOS: `GoogleService-Info.plist` in `ios/Runner/`
   - Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration

### Running the App

```bash
flutter run
```

## Project Structure

- `lib/controllers/`: GetX controllers for state management
- `lib/models/`: Data models
- `lib/screens/`: UI screens
- `lib/widgets/`: Reusable UI components
- `lib/routes/`: App navigation
- `lib/theme/`: App theme configuration

## Note

This project uses placeholder Firebase configuration. To make it fully functional, you need to replace it with your own Firebase project configuration.
