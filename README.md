# Frontend (Flutter Web)

This folder is fully independent and can be installed/run without root scripts.

## Prerequisites

- Node.js 18+ (for `npm` scripts in this folder)
- Flutter 3.24+ with web enabled

## Configure API URL

1. Copy env file:

   ```powershell
   copy .env.example .env
   ```

2. Set backend URL in `.env`:

   ```env
   API_BASE_URL=http://localhost:5000
   ```

The npm starter script maps `API_BASE_URL` to Flutter's compile-time define:
`--dart-define=API_BASE=<value>`.

## Install and Run

```powershell
npm install
npm start
```

Equivalent direct Flutter command:

```powershell
flutter run -d chrome --dart-define=API_BASE=http://localhost:5000
```
