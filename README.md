# 🌊 Queue: Flow Into Knowledge

**Your offline-first, distraction-free sanctuary for YouTube learning.**

Queue (formerly FlowState) is a beautifully designed Flutter app that transforms chaotic YouTube playlists and videos into structured, trackable courses. It’s built for learners who want to own their focus.

![Banner](https://via.placeholder.com/1200x400?text=Queue:+Focus+Over+Noise)

---

## 🚀 Why Queue?

Most learning apps are boring lists. Queue is **alive**.
We use a **Neo-Brutalism** design language mixed with fluid animations to make adding and tracking courses feel premium and satisfying.

### ✨ Key Features
- **🔍 Smart Extraction**: Paste *any* YouTube URL (Video or Playlist), and we extract the metadata instantly.
- **⚡ Super Fast**: Built with `Hive` for blistering fast offline local storage.
- **🎨 Dynamic UI**: Glassmorphism cards, smooth animations, and a UI that pops.
- **🛠️ Universal Input**: One modal to rule them all—create new courses or add resources (Links/Text) to existing ones seamlessly.
- **📈 Progress Tracking**: Visual progress bars and session tracking to keep you motivated.
- **🤖 AI Ready**: Built-in configuration to bring your own API keys (OpenAI/Gemini) for future smart features.

---

## 🛠️ The Tech Stack

We use the best of modern Flutter development:

| Component | Tech | Why? |
| :--- | :--- | :--- |
| **Framework** | 💙 Flutter | Cross-platform power. |
| **State** | 🌊 Riverpod | Reactive, safe, and testable state management. |
| **Database** | 🐝 Hive | NoSQL, lightweight, and incredibly fast. |
| **Network** | 🧨 YoutubeExplode | Extracts video data without an API key! |
| **Testing** | 🧪 Integration Test | Full E2E verification on real devices. |
| **CI/CD** | 🤖 GitHub Actions | Automated quality gates and beta releases. |

---

## 🏁 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Android Studio / VS Code
- Git

### Installation

1.  **Clone the Repo**
    ```bash
    git clone https://github.com/prakashbsamanta/queue.git
    cd queue
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run It!** 🏃‍♂️
    ```bash
    flutter run
    ```

---

## 🛡️ Quality Gates & CI/CD

We take code quality seriously. 

### 🛑 Pre-Push Hooks
Before you can push code, our local hook (`scripts/pre_push.sh`) runs:
1.  `flutter analyze` (Strict linting)
2.  `flutter test` (Unit checks)

If these fail, **you cannot push**. This keeps our `main` branch pristine.

### 🤖 GitHub Actions Pipeline
Every merge to `main` triggers our automated pipeline:
1.  **Quality Check**: Runs Analysis, Unit Tests, and **E2E Integration Tests**.
2.  **Build**: Compiles a signed `release` APK for Android.
3.  **Release**: Automatically creates a **Beta Release** on GitHub with the installable APK.

👉 **[Download Latest Beta](https://github.com/prakashbsamanta/queue/releases)**

---

## 🧪 Running Tests

### Unit Tests
```bash
flutter test
```

### E2E / Integration Tests
To verify the app on a real device/emulator:
```bash
flutter test integration_test/app_test.dart
```

---

## 🤝 Contributing

1.  Fork it!
2.  Create your feature branch: `git checkout -b my-new-feature`
3.  Commit your changes: `git commit -m 'Add some feature'`
4.  Push to the branch: `git push origin my-new-feature`
5.  Submit a pull request.

---

**Crafted with 💙 and ☕ by the Queue Engineering Team.**
