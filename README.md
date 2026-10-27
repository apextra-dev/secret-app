# Real-Time Messaging App (MVP)

A lightweight, high-performance cross-platform instant messaging application built with Flutter and powered by Firebase. This project serves as a production-ready Minimum Viable Product (MVP), demonstrating efficient reactive state management, real-time data streaming, and serverless NoSQL database architecture.

## 🚀 Key Features

- **Real-Time Communication:** Instant message delivery and receipt status tracking using custom double-check indicators.
- **Live User Presence & Statuses:** Dynamic, reactive UI indicators for user activity (`online`, `typing...`, `last seen recently`).
- **Global User Search:** Instant contact discovery via unique `@username` queries with live Firebase database validation.
- **Smart UI Placeholders:** Performance-optimized dynamic letter-avatar generation for a lightweight client-side footprint.
- **Modern UX:** Sleek, fully responsive Dark Mode interface with custom chat wallpapers.

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **Backend / BaaS:** Firebase (Realtime Database, Authentication)
- **Real-Time Layer:** Firebase WebSockets (Live Data Synchronization via Streams)
- **Architecture Patterns:** Reactive UI, Stream-based State Management

## 📱 Architecture & Highlights

- **Reactive Stream Architecture:** Fully utilized Dart Streams and Firebase Realtime Database listeners to establish a persistent bi-directional connection. This ensures sub-second latency for message delivery and instantaneous UI updates.
- **Efficient Presence System:** Implemented a lightweight user presence tracking system that updates user statuses (`online`/`typing`) globally without triggering unnecessary widget rebuilds or high CPU overhead.
- **Optimized Performance:** Utilized dynamic Flutter-native CustomPaint/Container shapes for initials-based avatars instead of heavy network image assets, drastically reducing network payloads and ensuring 60 FPS scrolling.

## 🔧 Installation & Setup

Ensure you have the Flutter SDK installed and a Firebase project configured.

```bash
# Clone the repository
git clone https://github.com/apextra-dev/secret-app/

# Navigate to the project directory
cd secret-app

# Get Flutter packages
flutter pub get

# Run the app on your connected device/emulator
flutter run

# You can build apk file for real Android Phone
flutter build apk --release

```

---
