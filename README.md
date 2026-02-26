3. App Workflow
The workflow follows a linear path from raw data to a published post:

Step 1: Input & Analysis
User enters "F1 Companion" details.

User uploads a screenshot of the "Compliance Tracker."

System Action: Flutter app packages the text and image into a single Multimodal prompt.

Step 2: AI Contextualization
The prompt is sent to Gemini with a "Persona" wrapper.

System Prompt: "You are a top-tier Tech Influencer. Write a Peerlist post for this project. The image shows a sleek Android UI; mention the design polish."

Step 3: Refinement
User receives the draft.

User clicks "Make it more witty."

System Action: A follow-up prompt is sent to the AI to adjust the tone while keeping the technical facts (Tech Stack) intact.

Step 4: Distribution
User selects "Copy" or "Share."

User is directed to the Peerlist/LinkedIn app with the text already in the clipboard.

4. Implementation Next Steps
To make this a reality, you should start with the Gemini Integration in Flutter.

Would you like me to generate the System Prompt library for this app? (This would be the collection of "instructions" for each platform—Peerlist, LinkedIn, etc.—that ensures the AI output is actually good).