# Tech Context

## 1. Technologies Used

*   **Programming Language:** Dart (SDK version ^3.7.0)
*   **Framework:** Flutter (Version >=3.27.0)
*   **State Management:** `provider` (^6.1.1)
*   **Local Storage:** `shared_preferences` (^2.2.2)
*   **HTTP Client:** `http` (^1.1.0)
*   **Environment Variables:** `flutter_dotenv` (^5.1.0)
*   **AI Service:** Google Gemini API (direct fetch call from worker)
*   **AI Model:** `gemini-pro`
*   **Backend Proxy:** Cloudflare Worker (JavaScript)
*   **Unique IDs:** `uuid` (^4.0.0) used in Flutter.
*   **Linting:** `flutter_lints` (^5.0.0)

## 2. Development Setup

*   Requires Flutter SDK installed.
*   Requires Dart SDK installed.
*   Requires a Cloudflare account with Wrangler CLI (or dashboard access) for deploying the worker.
*   Requires a Google Gemini API key configured as `GEMINI_API_KEY` secret in the Cloudflare worker environment.
*   An `.env` file is needed in the Flutter project root, containing `CLOUDFLARE_API_ENDPOINT` (URL of the deployed worker). A fallback URL is provided in `main.dart`.
*   Standard Flutter commands (`flutter pub get`, `flutter run`) are used for the app.
*   Cloudflare deployment commands (e.g., `wrangler deploy`) for the worker.

## 3. Technical Constraints

*   **Storage:** Relies solely on local device storage (`shared_preferences`); no cloud sync or backup implemented.
*   **Interpretation Quality:** Depends on the Gemini API and the effectiveness of the Lynchian prompt in `cloudflare_worker.js`.
*   **Network:** Connectivity is required for dream interpretation.
*   **Cloudflare Limits:** Worker execution limits (CPU time, memory etc.) apply.
*   **API Keys:** Gemini API key must be kept secure in the Cloudflare worker environment variables/secrets.

## 4. Dependencies

*   **Flutter:** See `pubspec.yaml` and `pubspec.lock`.
*   **Cloudflare Worker:** Uses standard Fetch API and expects `GEMINI_API_KEY` binding in the environment (`env`). (KV binding no longer needed).

## 5. Tool Usage Patterns

*   `flutter pub get`: To install Flutter dependencies.
*   `flutter run`: To run the application.
*   `wrangler deploy` (or similar): To deploy the Cloudflare Worker script.
*   Code Editor (e.g., VS Code, Android Studio) with Flutter/Dart extensions. 