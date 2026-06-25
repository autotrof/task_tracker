# Repository Guidelines

## Project Structure & Module Organization
This repo is a Flutter app for the Task Tracker recruitment test. Keep UI, state, and data access separated so the app stays easy to explain and extend. Use `Riverpod` for presentation state, `Dio` for API access, and `SharedPreferences` only for lightweight local persistence or cache. The brief expects at least `presentation`, `domain/service`, and `data/repository` layers. Use `lib/` for the app code, with task list, detail, and add-task flows split into focused files rather than one large screen. The backend contract is documented in [`API_REFERENCE.md`](./API_REFERENCE.md); the test brief is in [`Technical Test - Fullstack Developer (Flutter focus).md`](./Technical%20Test%20-%20Fullstack%20Developer%20%28Flutter%20focus%29.md).

## Build, Test, and Development Commands
Use the standard Flutter toolchain:

- `flutter pub get` to fetch dependencies
- `flutter run` to launch the app locally
- `flutter analyze` to run the analyzer
- `flutter test` to run the full test suite
- `flutter test test/widget_test.dart` to run a single test file
- `flutter build apk` to produce an Android build

## Coding Style & Naming Conventions
The project uses `flutter_lints` via [`analysis_options.yaml`](./analysis_options.yaml), so keep code analyzer-clean and prefer the recommended Flutter/Dart conventions. Follow Dart naming norms: `PascalCase` for types, `camelCase` for members, and `snake_case` for files. Keep widgets small and reusable, expose async task state through Riverpod providers, and name repository/service classes after the feature they support, such as task repositories or task services.

## Testing Guidelines
There is a starter widget test in [`test/widget_test.dart`](./test/widget_test.dart). Replace the template counter test with coverage for task list rendering, form validation, loading states, empty states, and API error handling. Keep API parsing and repository logic testable by isolating them from widgets; no mock-heavy setup is required for this submission.

## Commit & Pull Request Guidelines
This checkout has no Git history yet, so there is no established commit convention to mirror. Use short, imperative commit messages and make each change easy to review. For the recruitment submission, include a README update that explains setup, architecture, state management choice, and any tradeoffs, plus screenshots or a short recording if available.

## API Integration Notes
The backend exposes `/tasks` endpoints for list, detail, create, and status updates, with task statuses limited to `pending` and `done`. Handle loading, empty, validation, and server-error states explicitly. Use the provided backend endpoint from the task instructions when wiring the app, and keep response parsing inside the data layer.
