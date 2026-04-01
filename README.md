<p align="center"> <img width="300" height="715" alt="sql_mate_logo" src="https://github.com/user-attachments/assets/b86f7f19-72ef-41bf-afb8-6402930f21d8" /> </p>

#SQL Mate

> Your mate who never drops the table.

A Flutter app for practising SQL queries with **offline, result-based validation** and an **AI-powered SQL assistant**. Built with MVVM + Riverpod.

<p align="center">
<img width="250" height="1920" alt="img_1774704999" src="https://github.com/user-attachments/assets/2941e6c4-b9d7-43cd-9fdb-f54040eaba7b" />
<img width="250" height="1920" alt="img_1774704978" src="https://github.com/user-attachments/assets/a5568e03-dabd-4ae9-93a0-1c5a3400bb8f" />
<img width="250" height="1920" alt="img_1774704831" src="https://github.com/user-attachments/assets/21049fd9-1816-494a-852a-7de67d104ba6" />
<img width="250" height="1920" alt="img_1774704821" src="https://github.com/user-attachments/assets/81facec3-adef-44fb-949d-53e6168a56d3" />
<img width="250" height="1920" alt="img_1774704817" src="https://github.com/user-attachments/assets/30ef2ca2-c354-414f-980e-3d0261138db3" />
<img width="250" height="1920" alt="img_1774704776" src="https://github.com/user-attachments/assets/d5518b5a-b6cb-4f75-a883-d0cc2efee4c3" />
<img width="250" height="1920" alt="img_1774704748" src="https://github.com/user-attachments/assets/760acb0f-20a5-409f-95d9-5750fc38299b" />
<img width="250" height="1920" alt="img_1774704613" src="https://github.com/user-attachments/assets/2c85a153-7fa8-4bae-a937-7874db32a7f1" />
<img width="250" height="1920" alt="img_1774704604" src="https://github.com/user-attachments/assets/40abe54a-42c7-494e-b0af-c190bf75b86e" /> </p>

---

## Features

| | |
|---|---|
| ⚡ | Offline SQL execution via in-memory SQLite |
| ✅ | Output-based validation — any query that produces the correct result passes |
| 🤖 | Built-in AI chat assistant (GPT-4o mini) for learning and discussion |
| 📊 | Attempt counter + correct submission counter per question |
| 🔥 | Daily streak tracking |
| 🗂️ | Category and difficulty filters |
| 🧩 | Collapsible schema viewer with column types |
| 💡 | Progressive hint system |
| 🔍 | Side-by-side output comparison on wrong answers |
| 📖 | Explanation shown after solving |
| 💾 | Progress persisted across app restarts |

---

## How validation works

Each question bundles a schema, seed data, and a reference query. When a user submits:

1. A fresh **in-memory SQLite database** is created via `sqflite`
2. The **reference query** runs → expected output
3. The **user's query** runs → actual output
4. Result sets are compared **row-by-row and column-by-column**

Because it compares outputs — not query text — any valid SQL that produces the correct result is accepted.

---

## AI Assistant

Tap the **SQL Assistant** FAB on the home screen to open a chat powered by GPT-4o mini. The assistant is tuned as an SQL tutor — it explains concepts, provides examples, and answers questions about your queries.

The FAB collapses to a compact icon while scrolling and expands again when you stop.

**Setup:** Replace `YOUR_OPENAI_API_KEY` in `lib/repositories/chat_bot/chat_repository.dart` with your key. For production, move it to secure storage or a `.env` file — never ship keys in source.

---

## Project structure

```
lib/
├── main.dart
├── models/
│   ├── question.dart              # SqlQuestion, TableSchema, ColumnDef, Difficulty
│   ├── user_progress.dart         # QuestionProgress, SubmissionResult
│   ├── chat_message.dart          # ChatMessage, MessageRole
│   └── chat_state.dart            # ChatState
├── repositories/
│   ├── question_repository.dart   # Loads questions from JSON assets
│   ├── progress_repository.dart   # Persists progress to SharedPreferences
│   └── chat_bot/
│       └── chat_repository.dart   # OpenAI API integration
├── core/
│   ├── providers.dart
│   ├── sql_executor.dart          # In-memory SQLite evaluation engine
│   └── theme/
│       └── app_theme.dart
├── viewmodels/
│   ├── question_list_viewmodel.dart
│   ├── practice_viewmodel.dart
│   └── chat_viewmodel.dart        # Chat state + OpenAI calls
└── views/
    ├── screens/
    │   ├── splash_screen.dart     # Animated launch screen
    │   ├── home_screen.dart
    │   ├── practice_screen.dart
    │   └── chat_bot/
    │       └── chat_screen.dart   # AI assistant screen
    └── widgets/
        ├── chat_bubble.dart       # Markdown-aware message renderer
        ├── sql_editor.dart
        ├── result_table.dart
        ├── submission_banner.dart
        ├── schema_panel.dart
        ├── hint_panel.dart
        ├── question_card.dart
        ├── difficulty_badge.dart
        ├── filter_chips.dart
        └── stat_chip.dart

assets/
└── questions/
    ├── manifest.json
    ├── q001_select_all.json
    └── ...
```

---

## Setup

```bash
flutter pub get
flutter run
```

Make sure your `pubspec.yaml` includes:

```yaml
dependencies:
  flutter_riverpod: ^2.x.x
  sqflite: ^2.x.x
  shared_preferences: ^2.x.x
  google_fonts: ^6.x.x
  gap: ^3.x.x
  http: ^1.x.x
  uuid: ^4.x.x
```

---

## Adding questions

1. Create a JSON file in `assets/questions/`, e.g. `q009_my_question.json`
2. Add the filename to `assets/questions/manifest.json`
3. Follow this structure:

```json
{
  "id": "q009",
  "title": "My Question Title",
  "description": "What the user needs to write a query for.",
  "category": "JOIN",
  "difficulty": "medium",
  "schema": [
    {
      "table_name": "my_table",
      "columns": [
        { "name": "id",    "type": "INTEGER", "primary": true },
        { "name": "name",  "type": "TEXT",    "not_null": true },
        { "name": "value", "type": "REAL" }
      ]
    }
  ],
  "seed_data": [
    {
      "table": "my_table",
      "rows": [
        { "id": 1, "name": "Row A", "value": 10.5 },
        { "id": 2, "name": "Row B", "value": 20.0 }
      ]
    }
  ],
  "reference_query": "SELECT name, value FROM my_table WHERE value > 10",
  "hints": [
    "First hint shown on demand.",
    "Second hint shown on demand."
  ],
  "explanation": "Optional explanation shown after solving."
}
```

### Field reference

| Field | Required | Notes |
|---|---|---|
| `id` | ✅ | Unique string, used for progress tracking |
| `title` | ✅ | Short display name |
| `description` | ✅ | Full problem statement shown to user |
| `category` | ✅ | Used for filtering — e.g. `SELECT`, `JOIN`, `Aggregates`, `Subquery` |
| `difficulty` | ✅ | `"easy"`, `"medium"`, or `"hard"` |
| `schema` | ✅ | Array of table definitions |
| `seed_data` | ✅ | Array of `{ "table": "name", "rows": [...] }` |
| `reference_query` | ✅ | Correct SQL — used to generate expected output |
| `hints` | ✅ | Array of hint strings (can be `[]`) |
| `explanation` | ❌ | Shown after a correct answer |

**Supported SQLite column types:** `INTEGER`, `TEXT`, `REAL`, `BLOB`, `NUMERIC`

---

## Result comparison rules

- Row **count** must match exactly
- Row **order** must match — add `ORDER BY` to your reference query if order matters
- Column **names** are compared case-insensitively
- String values are trimmed and lowercased before comparison
- `NULL` values are handled correctly

---

## Architecture

The app follows **MVVM** with **Riverpod** for state management.

```
Model  →  Repository  →  ViewModel  →  UI
```

- **Models** — plain Dart classes, no framework dependencies
- **Repositories** — data access only (SQLite, SharedPreferences, HTTP)
- **ViewModels** — `StateNotifier` subclasses, hold all business logic
- **Views** — `ConsumerWidget` / `ConsumerStatefulWidget`, read providers and react to state

The chat feature uses `autoDispose` so conversation state is cleared when the screen is closed.
