# 💰 Expense Tracker — Multi-Currency Budget App

A **multi-currency expense and income tracker** built with Flutter and FastAPI.
Offline-first, simple, and focused on personal finance management — track spending, view totals in a base currency.

---

## 🚀 Features

- **Authentication** — user registration and login (JWT-based, FastAPI backend)
- **Profile settings** — choose your default currency
- **Transactions** — add, edit, delete, and view detailed info
  - Each transaction supports **income/expense types**
  - Real-time **conversion to default currency**
  - Displayed as clean, minimal **cards**
- **Offline-first architecture** — local caching and synchronization on reconnect
- **Categories** — choose from existing or add your own
- **Multi-currency support** — automatic conversion using live exchange rates
- **Modern, adaptive UI** — built with Flutter and Material 3
- **Data persistence** — Hive for local storage
- **Repository pattern** — clear separation between data, logic, and UI

---

## 🧠 Tech Stack

### 🖥️ Frontend (Flutter)

- Flutter + Dart
- State management: BLoC
- Dependency injection: Provider
- Local database: Hive
- Networking: Dio (REST API)
- Charts & analytics: fl_chart
- Adaptive layout: LayoutBuilder + MediaQuery
- Testing: unit & widget tests
- Offline-first sync logic

### ⚙️ Backend (FastAPI)

- FastAPI (async-ready)
- PostgreSQL for persistent data
- JWT authorization
- Redis for caching / background tasks
- pgAdmin for DB management
- Dockerized environment for easy local setup
- CRUD endpoints:
  - `/auth/login`
  - `/auth/register`
  - `/transactions`
  - `/rates`
- Migrations: Alembic
- Testing: unit & integration tests

---

## 🧩 CI/CD & Git Workflow

- **Git Flow**: `main`, `develop`, `feature/*`, `hotfix/*`

- **GitHub Actions** for:
  - **Backend testing** — unit and integration tests for FastAPI using PostgreSQL via pytest
  - **Database migrations** — run Alembic migrations before tests
  - **Dependency checks** — verify Python dependencies installation
  - **Branch-based triggers** — CI runs on pushes and PRs to `develop` and `feature/tests`
  - **Future steps (planned)**:
    - Linting (flake8 / black / pylint)
    - Flutter unit & widget tests
    - Build checks for Flutter app
    - Automatic release builds (APK / iOS)

---

## 🗺️ Roadmap

- [ ] Filters & advanced search for transactions
- [ ] Analytics dashboard (charts, insights, daily/weekly reports)
- [ ] Visual & UX polish (consistent theme, icons, transitions)
- [ ] Error handling & empty state improvements
- [ ] Complete CI/CD pipeline for backend + mobile
- [ ] Comprehensive test coverage

---

## ✨ Highlights

- Offline-first design ensures app usability without Internet
- Clear separation of UI, business logic, and data layers
- Scalable and ready for future modules (e.g., budgeting goals, reports)
- Clean and minimal UI design

---

## 📌 Status

Currently in development.
The current version includes authentication, categories, currencies, and full transaction management with offline sync, and a backend (FastAPI + PostgreSQL + Redis) ready for local Docker setup.
