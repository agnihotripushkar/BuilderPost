# BuilderPost AI

A Flutter mobile app that transforms your technical project descriptions into engaging, platform-specific social media posts using Google Gemini AI.

Built for developers who want to share their work on Peerlist, LinkedIn, and X (Twitter) — without spending time writing posts.

---

## Features

- **AI-powered post generation** — Describe your project, upload screenshots, and get 3 ready-to-publish post variations
- **Platform-specific tone** — Tailored output for Peerlist (proof of work), LinkedIn (career impact), and X (build-in-public threads)
- **Tone control** — Choose Witty, Professional, Academic, or Casual
- **Resume / PDF parser** — Upload your resume and the AI extracts your projects to pre-fill the composer
- **GitHub README import** — Paste a GitHub URL and the app fetches your README as context
- **Multimodal input** — Attach up to 3 screenshots for richer, UI-aware post copy
- **Draft management** — Save, edit, and revisit project drafts locally
- **Generation history** — Browse and re-share past generations
- **Privacy-first** — No backend, no data collection; your API key is stored encrypted on-device only

---

## Screenshots

> Add screenshots here after first run (`assets/screenshots/`)

---

## Tech Stack

| Layer | Technology | Description / Usage |
|---|---|---|
| **Framework** | Flutter 3.7+ / Dart 3.7+ | High-performance cross-platform application structure |
| **AI Engine** | Google Gemini 3.5 Flash (`google_generative_ai`) | Generative AI integration using token-by-token streaming |
| **State Management** | Riverpod 2.x | Robust state and dependency management (`flutter_riverpod`) |
| **Navigation** | GoRouter (`go_router`) | Declarative navigation routing with custom page transitions |
| **Models / Codegen** | `freezed` + `json_serializable` | Auto-generated immutable data models and JSON serialization |
| **Networking** | `dio` | HTTP client with custom timeouts and error handling |
| **Secure Storage** | `flutter_secure_storage` | Encrypted storage for API keys (Android Keystore / iOS Keychain) |
| **Local Persistence** | `shared_preferences` | Local key-value storage for project drafts and history entries |
| **PDF Processing** | Syncfusion Flutter PDF | Text extraction from uploaded PDF resumes and LinkedIn profiles |
| **UI Components** | `flutter_markdown` + `shimmer` | Rich Markdown post rendering and smooth skeleton loading animation |
| **File & Image Picking** | `image_picker`, `file_picker` | Picking project screenshots and PDF files from local device storage |
| **Sharing & URLs** | `share_plus` + `url_launcher` | Platform-native share sheets and launching external links |
| **Typography** | Google Fonts | Custom modern typography utilizing Inter and JetBrains Mono fonts |
| **Utilities** | `uuid` | Generating cryptographically secure unique identifiers |
| **Android Build Stack** | Kotlin `2.1.20` / AGP `8.7.0` / NDK `27.0.x` | Modernized native build configurations for compatibility and performance |
| **Testing** | `flutter_test` | Comprehensive test suite covering models, providers, services, and widgets |

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.7.0 or later
- Android SDK (for Android) or Xcode 14+ (for iOS)
- A **Google Gemini API key** — get one free at [aistudio.google.com](https://aistudio.google.com)

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/BuilderPost.git
cd BuilderPost
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Generate code (freezed / json_serializable)

Generated `*.freezed.dart` / `*.g.dart` files are not committed — build them once after cloning (and after editing any model):

```bash
dart run build_runner build
```

### 4. Run the app

```bash
# Android
flutter run

# iOS
flutter run -d ios
```

> No `.env` file or build-time secrets needed. The app prompts you for your Gemini API key on first launch and stores it securely on your device.

---

## API Key Setup

1. Go to [https://aistudio.google.com](https://aistudio.google.com) and create a free API key
2. Launch the app — the onboarding screen will prompt you to enter it
3. The key is stored using `flutter_secure_storage` (encrypted via Android Keystore / iOS Keychain)
4. You can update or clear the key anytime from the in-app Settings screen

**The API key is never hardcoded, never logged, and never leaves your device.**

---

## Project Structure

```
lib/
├── main.dart                        # App entry point
├── models/
│   ├── project_draft.dart           # Draft data model
│   ├── generated_post.dart          # AI output model
│   ├── extracted_project.dart       # Resume parser output
│   └── history_entry.dart           # Generation history entry
├── services/
│   ├── gemini_service.dart          # Gemini API integration
│   ├── github_service.dart          # GitHub README fetcher
│   └── key_storage_service.dart     # Secure API key storage
├── providers/
│   ├── composer_provider.dart       # Post generation state
│   ├── drafts_provider.dart         # Draft persistence
│   └── history_provider.dart        # History persistence
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── api_key_screen.dart
│   ├── composer_screen.dart         # Main composer UI
│   ├── preview_screen.dart          # Generated posts display
│   ├── project_hub_screen.dart      # Draft list / home
│   ├── history_screen.dart
│   └── resume_projects_screen.dart  # PDF resume parser UI
├── widgets/
│   ├── platform_chips.dart          # Peerlist / LinkedIn / X selector
│   ├── tone_toggles.dart
│   ├── image_upload_strip.dart
│   ├── post_preview_card.dart
│   └── shimmer_loader.dart
├── theme/
│   ├── app_theme.dart
│   └── app_colors.dart
└── utils/
    └── app_router.dart              # GoRouter config + custom page transitions
```

---

## How It Works

```
Splash → Onboarding → API Key Setup (first time only)
            ↓
       Project Hub  ←──────────────────────┐
       ├─ New Project → Composer           │
       ├─ Resume Upload → PDF Parser → Composer
       ├─ History                          │
       └─ Settings (API key management)   │
                  ↓                        │
            Composer Screen                │
            (title, description, GitHub URL, images, platform, tone)
                  ↓
            Gemini 3.5 Flash
                  ↓
            Preview Screen (3 variations)
            (copy · share · regenerate · save draft) ──┘
```

---

## Security

- No API keys in source code or config files
- `lib/env/env.dart` is listed in `.gitignore` (reserved for future build-time config)
- API keys stored exclusively in encrypted on-device storage
- No remote backend — all data stays on your device
- Input validation: only keys starting with `AIza` are accepted

---

## Contributing

Pull requests are welcome. For major changes, open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create your feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'Add my feature'`
4. Push to the branch: `git push origin feature/my-feature`
5. Open a pull request

---

## License

MIT
