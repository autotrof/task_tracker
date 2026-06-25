# Task Tracker App

Flutter implementation for the Task Tracker recruitment test. The app can list tasks, search by title, sort the list, switch between `pending` and `done` tabs, add a new task, view task detail, and toggle task status.

## Tech Stack

- Flutter 3.44 / Dart 3.12
- Riverpod for presentation state
- Dio for HTTP API access
- SharedPreferences for lightweight task-list cache

## Running Locally

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

By default the app loads the development environment from:

```text
.env.development
```

The default development backend endpoint is:

```bash
http://localhost:8080/api
```

To switch the development endpoint, edit `.env.development`.

For Android emulator against a host-machine backend, use:

```text
API_BASE_URL=http://10.0.2.2:8080/api
```

To run with the production environment file instead, use:

```bash
flutter run --dart-define=APP_ENV=production
```

The app chooses its env file like this:

- `development` -> `.env.development`
- `production` -> `.env.production`

Update `.env.production` with the real production API base URL before release.

## Verification

```bash
flutter analyze
flutter test
flutter build apk
```

## Architecture

The app is split into focused layers:

- `lib/data`: API model, API exception mapping, repository contract, and Dio repository implementation.
- `lib/domain/service`: use-case oriented task service. It trims and validates input before repository calls.
- `lib/presentation/providers`: Riverpod providers and async task-list notifier.
- `lib/presentation/screens`: task list, add task, and detail flows.
- `lib/presentation/widgets`: reusable task card, status chip, empty state, and error state widgets.

This is intentionally not a full textbook clean architecture setup. The goal is a small structure that is easy to explain, test, and extend.

## State Management Choice

Riverpod is used because it keeps async API state explicit, lets widgets stay small, and makes dependency overrides straightforward in tests. `AsyncNotifier` powers the task list so loading, data, and error states are represented consistently. Repository providers can be replaced with fakes in widget tests without hitting the backend.

## API Integration

The Dio repository follows the contract in `API_REFERENCE.md`:

- `GET /tasks?per_page=20`
- `GET /tasks/{id}`
- `POST /tasks`
- `PATCH /tasks/{id}`

API errors are normalized into `ApiException`, including validation field errors when the backend returns them. The latest successful task list is cached in `SharedPreferences`; if list/detail fetching fails and cached data exists, the app can still render cached tasks.

## UI and Error Handling

The app includes:

- server-backed search by task title
- server-backed sorting by `created_at` and `title`
- status tabs for `pending` and `done`
- loading indicators for list/detail/submission
- empty task state
- retryable API error state
- form validation for required title and description
- status chips and one-tap status toggle
- pull-to-refresh on the task list
- a more editorial visual style with a hero header, richer task cards, and clearer hierarchy

## Tests

The starter counter test has been replaced with widget coverage for:

- task list rendering
- loading state
- empty state
- API error state
- add-task form validation

Tests use a fake repository through Riverpod provider overrides, so they are deterministic and do not require a running backend.

## Tradeoffs

Pagination metadata is parsed by the backend contract but not surfaced yet because the core brief only requires task listing. The code is shaped so pagination can be added later inside the repository and task-list notifier without rewriting screens.
