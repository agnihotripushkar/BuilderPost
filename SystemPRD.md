1. System PRD (Product Requirements Document)
Product Name: BuilderPost AI

Objective: A mobile tool for developers to transform technical project descriptions into high-engagement social media posts (Peerlist, LinkedIn, X) using Multimodal AI.

Core Functional Requirements
Project Input: Users can manually enter text, paste a GitHub README URL, or upload a JSON/Markdown project file, or a PDF resume / LinkedIn profile.

Multimodal Processing: Ability to upload 1-3 screenshots of the project. The AI should analyze the UI (e.g., "clean dark mode," "data-heavy dashboard") to include in the copy.

Platform-Specific Templates:

Peerlist: Focused on "Proof of Work," Tech Stack, and Challenges.

LinkedIn: Focused on "Career Growth," Impact, and Professional Achievement.

X (Twitter): Focused on punchy threads and "Build in Public" hooks.

AI Customization: Toggle switches for "Tone" (Witty, Professional, Academic, or Casual).

Export/Sync: One-tap "Copy to Clipboard" or "Share" via system intent.

Technical Stack (Proposed)
Frontend: Flutter (for cross-platform iOS/Android reach).

AI Engine: Google Gemini 1.5 Flash (for speed and multimodal image support).

Backend (Optional): Firebase for anonymous auth and saving "Drafts."

State Management: Riverpod or Provider (standard for Flutter scaling).