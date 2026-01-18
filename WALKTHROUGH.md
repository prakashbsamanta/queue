# FlowState App Walkthrough

## Overview
**FlowState** is a premium, offline-first course tracking application built with Flutter. It allows you to import YouTube playlists and videos, track your progress meticulously, and visualize your learning habits.

## Features
*   **Offline First**: All data is saved locally using Hive.
*   **YouTube Integration**: Extracts metadata without API keys using `youtube_explode_dart`.
*   **Deep Work Player**: Custom video player with position syncing every 5 seconds.
*   **Analytics**: Weekly charts and heatmaps to track consistency.
*   **OLED Minimalist Design**: A sleek, battery-saving dark interface.

## Getting Started

### Prerequisites
*   Flutter SDK (Latest Stable)
*   Android/iOS Simulator or Physical Device

### Installation
1.  **Dependencies**:
    ```bash
    flutter pub get
    ```
2.  **Code Generation**:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
3.  **Run**:
    ```bash
    flutter run
    ```

## User Guide

### 1. Dashboard
The home screen shows your "Current Focus" (last played course) and a grid of all your courses.
*   **Hero Card**: Tap "Resume Learning" to jump back into your last video.
*   **Course Grid**: Shows progress bars for each course.

### 2. Adding a Course
1.  Tap the **+** (Plus) button on the Dashboard.
2.  Paste a **YouTube Playlist Link** or **Video Link**.
3.  Click "Extract & Add".
4.  The app will fetch titles, thumbnails, and durations automatically.

### 3. Watching & Tracking
*   Tap on a course to view the **Detail Screen**.
*   Select a video to launch the **Deep Work Player**.
    *   *Note: Video playback is currently optimized for Android & iOS. Desktop users will see a placeholder message.*
*   The player tracks your watch time in real-time.
*   If you leave and come back, the video resumes EXACTLY where you left off.
*   Videos are marked "Completed" (green check) when 90% watched.

### 4. Analytics
*   Tap the **Chart Icon** on the Dashboard (bottom right).
*   View your **Weekly Watch Time** and **Consistency Heatmap**.

## Architecture & Code
*   **State Management**: Riverpod (Providers found in `lib/logic`).
*   **Database**: Hive (Models in `lib/data/models`, Repositories in `lib/data/repositories`).
*   **UI**: Modular widgets in `lib/ui`, employing `flutter_animate` for smooth transitions.

## troubleshooting
*   **Video Fails to Load**: Ensure you have an active internet connection for the *first* load.
*   **Extraction Error**: Ensure the YouTube link is public/unlisted (not private).

Built with ❤️ by FlowState Team.
