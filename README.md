# Landmark-Based Navigation App

> A navigation system based on visual landmarks and hybrid text-to-speech guidance.

---

## Project Overview

Traditional navigation systems (such as Google Maps) rely almost exclusively on metric instructions (*"In 200 meters, turn left"*). In complex urban and rural environments, this can increase cognitive load and driver uncertainty.

This project implements a **landmark-based hybrid navigation system** that identifies prominent environmental landmarks (churches, monuments, public transit stops, supermarkets, roundabouts) and incorporates them into clear, natural language navigation instructions (*"In 200 m turn left at 'St. Martin Church'"*).

### Key Features
* **3 Guidance Modes:**
  * **Hybrid:** Combines metric distance with a visual landmark (*recommended mode*).
  * **Landmark:** Relies solely on environmental landmarks without mentioning metric distances.
  * **Classic:** Traditional metric-only turn-by-turn instructions.
* **Intelligent Landmark Scoring Algorithm:**
  * Category weighting (Monuments / Cultural / Religious > Transit Stations > Shops & Commercial > Generic Buildings).
  * Spatial distance decay penalty ($Score = Weight - 0.05 \times distance$).
* **Spatial PostgreSQL Caching:**
  * Cached landmarks are stored in PostgreSQL with geospatial indexing, yielding up to **9.7x lower latency** compared to external Google Places API calls.
* **Step Consolidation:**
  * Merges straight continuous segments and micro-maneuvers to prevent cognitive overload from redundant instructions.
* **Text-to-Speech (TTS) Voice Guidance:**
  * Milestone-based audio prompts (1 km, 500 m, 200 m, 50 m for driving; 300 m, 100 m, 25 m for walking).
  * Context-aware roundabout/rotary phrasing and departure compass orientation.
* **Simulated Navigation & Automatic Rerouting:**
  * Built-in route simulator with interpolated GPS coordinates and customizable vehicle speeds.
  * Automatic rerouting upon detecting 3 consecutive off-route position updates.
* **Telemetry & Empirical Evaluation:**
  * Asynchronous event logging pipeline (`EventLogger`) with retry mechanisms for measuring reaction times and user behavior.
  * Automated evaluation script with 10 diverse benchmark routes (`evaluate.ts`).

---

## System Architecture

* **Mobile Application (`/mobile`):**
  * Framework: Flutter / Dart
  * State Management: `flutter_riverpod`
  * Maps & Geolocation: `google_maps_flutter`, `geolocator`, `flutter_google_places_sdk`
  * Voice Synthesis: `flutter_tts`
* **Backend Server (`/backend`):**
  * Runtime & Language: Node.js, TypeScript, Express.js
  * Database & ORM: PostgreSQL, Prisma ORM
  * Validation: Zod
  * Documentation: OpenAPI 3.0 / Swagger UI

---

## Repository Structure

```
landmark_navigation_app/
├── backend/
│   ├── clients/           # Google Routes & Google Places API clients
│   ├── config/            # Database, environment, and Swagger configurations
│   ├── controllers/       # HTTP controllers (routes, users, landmarks, sessions, events)
│   ├── docs/              # OpenAPI / Swagger YAML specifications
│   ├── prisma/            # Prisma schema and database migrations
│   ├── routes/            # Express route definitions
│   ├── scripts/           # Evaluation and benchmark script (evaluate.ts)
│   ├── services/          # Business logic (route generation, landmark matching, instruction generation)
│   ├── tests/             # Automated backend unit tests
│   └── validators/        # Zod request validation schemas
├── mobile/
│   ├── lib/
│   │   ├── models/        # Dart data models
│   │   ├── providers/     # Riverpod notifiers (navigation, active_navigation, settings)
│   │   ├── screens/       # Main views (HomeScreen, NavigationScreen, SettingsScreen)
│   │   ├── services/      # Client services (API, Location, TTS, Event Logger)
│   │   ├── utils/         # Helper utilities (maneuver, navigation math, polyline)
│   │   └── widgets/       # Modular UI components (SearchBox, DestinationPanel, InstructionBanner, NextStep)
│   └── test/              # Flutter unit tests
└── README.md
```

---

## Getting Started

### Prerequisites
* [Node.js](https://nodejs.org/) (v20+)
* [Flutter SDK](https://flutter.dev/) (v3.7+)
* [PostgreSQL](https://www.postgresql.org/) database instance
* Google Cloud API Key with the following enabled: *Routes API*, *Places API (New)*, and *Maps SDK for Android/iOS*.

---

### 1. Backend Setup

1. Navigate to the `backend` directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure environment variables:
   * Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   * Populate `DATABASE_URL` and `GOOGLE_MAPS_API_KEY` in `.env`.
4. Run Prisma database migrations:
   ```bash
   npx prisma migrate dev
   ```
5. Start the development server:
   ```bash
   npm run dev
   ```
   * API Server: `http://localhost:3000`
   * Swagger Documentation: `http://localhost:3000/api-docs`

---

### 2. Mobile App Setup

1. Navigate to the `mobile` directory:
   ```bash
   cd mobile
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure environment variables:
   * Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   * Set `GOOGLE_MAPS_API_KEY` and `API_BASE_URL` (use `http://10.0.2.2:3000/api` for Android emulator).
4. Add your Google Maps API key to `mobile/android/local.properties`:
   ```properties
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key_here
   ```
5. Launch the application:
   ```bash
   flutter run
   ```

---

## Testing & Evaluation

### Backend Unit Tests
```bash
cd backend
npm test
```
*Executes 18 automated unit tests covering instruction generation, landmark scoring, and edge cases.*

### Flutter Unit Tests
```bash
cd mobile
flutter test
```
*Executes 22 automated unit tests verifying geometry calculations, threshold detection, off-route tracking, and audio prompt formatting.*

### Evaluation & Benchmark Suite
```bash
cd backend
npm run evaluate
```
*Executes the benchmark over 10 test routes across all modes, measuring landmark coverage, instruction word count, and cache latency speedup, outputting the results into `backend/evaluation_tables.md`.*
