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
| **Testing** | 🧪 Unit & Widget | >85% Coverage across UI, Logic, and Data layers. |
| **CI/CD** | 🤖 GitHub Actions | Automated quality gates (PRs) and deployments (Main). |

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

We maintain a strict quality standard of **>85% Test Coverage**.

### 🛑 Local Pre-Commit Hooks
We use `husky` to ensure quality before you commit. The hook runs:
1.  `flutter analyze` (Strict linting)
2.  `flutter test` (Unit/Widget checks)
3.  **Strict Linting**: No unused imports or variables allowed.

If these fail, **you cannot commit**.

### 🤖 GitHub Actions Pipeline
1.  **Flutter CI** (On Pull Request):
    - Runs `flutter analyze`.
    - Runs `flutter test --coverage` (Must exceed 85%).
2.  **App Beta Release** (On Push to `main`):
    - Builds signed Android App Bundle & APKs.
    - Builds Web version.
    - Creates a GitHub Release.

> **Note for Contributors**: You need to set `GOOGLE_SERVICES_JSON_BASE64` in GitHub Secrets for Android builds to succeed.

---

## 🧪 Running Tests

### Run All Tests
```bash
flutter test
```

### Check Coverage
```bash
./scripts/check_coverage.sh
```
This generates a detailed `coverage/lcov_filtered.info` report, excluding generated files to give you the real coverage metric.

---

## 🤝 Contributing

1.  Fork it!
2.  Create your feature branch: `git checkout -b my-new-feature`
3.  Commit your changes: `git commit -m 'Add some feature'`
4.  Push to the branch: `git push origin my-new-feature`
5.  Submit a pull request.

---

**Crafted with 💙 and ☕ by the Queue Engineering Team.**
