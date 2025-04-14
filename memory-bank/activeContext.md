# Active Context

## 1. Current Focus

Resolving architectural inconsistencies and minor UI issues based on initial analysis.

## 2. Recent Changes

*   Analyzed all `.dart`, `.yaml`, `.md`, and `.js` files in the project.
*   Identified core functionality: Local dream recording (`shared_preferences`), AI interpretation via Cloudflare Worker (using Gemini API with Lynchian prompt).
*   Discovered a storage mismatch and a non-functional delete button.
*   Corrected the approach to create Memory Bank files using standard tools.
*   Created/Updated all core Memory Bank files.
*   **Fixed Deletion Bug:** Moved deletion functionality from entry screen to details screen and implemented the call to the service.
*   **Resolved Storage Mismatch:** Removed unused Cloudflare KV code from the worker script (`cloudflare_worker.js`), confirming `shared_preferences` as the sole storage mechanism.

## 3. Next Steps

*   Correct the "Data" label in `TelaEntradaSonho`.
*   Consider further UI refinements or feature additions (e.g., testing, font changes).
*   Await further user instructions.

## 4. Active Decisions & Considerations

*   Deletion functionality is located in the Dream Details screen.
*   `shared_preferences` is the sole storage mechanism.
*   Cloudflare worker acts only as an interpretation proxy.
*   The Lynchian aesthetic is central to the app's identity.

## 5. Important Patterns & Preferences

*   Provider is used for state management/dependency injection.
*   Models include `fromJson`/`toJson` for serialization.
*   Asynchronous operations are handled using `FutureBuilder` and `async/await`.
*   Custom themed widgets (`BotaoLynchiano`, `CampoTextoLynchiano`) are used.

## 6. Learnings & Insights

*   The project successfully integrates local storage (`shared_preferences`) with external API calls (Cloudflare Worker -> Gemini).
*   Clear separation between UI, services, and models.
*   Cloudflare worker implements specific prompt engineering.
*   Importance of aligning implementation across different parts of the system (Flutter app vs. Worker). 