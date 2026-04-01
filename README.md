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

<img width="1206" height="2622" alt="onboarding2" src="https://github.com/user-attachments/assets/45f08624-6854-48ee-93bf-29311f3f81c9" />
<img width="1206" height="2622" alt="onboarding3" src="https://github.com/user-attachments/assets/acf23249-f161-481d-a910-4a8cbb45a490" />
<img width="1206" height="2622" alt="composer" src="https://github.com/user-attachments/assets/ee0e2ebf-9e28-463a-bb63-245db6fa318f" />
<img width="1080" height="2400" alt="importFromResume" src="https://github.com/user-attachments/assets/8beaf2a5-468b-484b-8b7c-3e7579e94e28" />
<img width="1080" height="2400" alt="options" src="https://github.com/user-attachments/assets/073e45b4-9067-46aa-a955-060c5f3ae8b8" />
<img width="1080" height="2400" alt="history" src="https://github.com/user-attachments/assets/d325b666-fe70-44e5-af51-4a4d1d7a2307" />


---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.7+ / Dart 3.7+ |
| AI | Google Gemini 2.5 Flash (`google_generative_ai`) |
| State management | Riverpod 2.x |
| Secure storage | `flutter_secure_storage` (Android Keystore / iOS Keychain) |
| Local persistence | `shared_preferences` |
| PDF processing | Syncfusion Flutter PDF |
| File & image picking | `image_picker`, `file_picker` |
| Sharing | `share_plus` |
| Typography | Google Fonts (Inter, JetBrains Mono) |

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

### 3. Run the app

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
    └── app_router.dart              # Custom navigation transitions
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
            Gemini 2.5 Flash
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
