# ☸️ Nyingma Calendar

**Ancient Wisdom, Modern Life** — A comprehensive Tibetan Buddhist calendar application
for the Nyingma tradition, featuring dual calendar display, astrological charts, practice
tracking, and events across all 8 major Nyingma lineages.

![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue)
![Backend](https://img.shields.io/badge/Backend-FastAPI%20+%20SQLite-green)
![Frontend](https://img.shields.io/badge/Frontend-Flutter%203.24-blue)

---

## ✨ Key Features

- 📅 **Dual Calendar** — Tibetan lunar & Western solar dates side by side
- 🌕 **6 Auspicious Days** — Medicine Buddha, Guru Rinpoche, Full Moon/Amitabha, Dakini, Protector, New Moon
- ☸️ **8 Nyingma Lineages** — Dudjom · Mindrolling · Dorje Drak · Kathok · Palyul · Shechen · Dzogchen
- 🙏 **40+ Sacred Events** — Parinirvana dates, birthdays, 4 great duchen, ceremonies
- 🔮 **15 Astrology Charts** — Naga days, hair cutting, prayer flags, parkha, life force & more
- 📊 **Practice Tracker** — Daily checklist with streaks and monthly goals
- 🏔️ **Bilingual** — English + Tibetan (བོད་ཡིག) language toggle
- 🌓 **Dark Mode** — Beautiful dark theme with traditional Nyingma colors

## 🚀 Quick Start

```bash
# 1. Backend (FastAPI + SQLite — zero config)
cd backend
pip install -r requirements.txt
copy .env.example .env
python -m uvicorn app.main:app --reload --port 8000

# 2. Frontend (Flutter)
cd frontend
flutter pub get
flutter run -d chrome
```

> 📖 See [SETUP.md](SETUP.md) for detailed setup instructions, PostgreSQL config, and production builds.

## 🏗️ Tech Stack

| Layer     | Technology                              |
|-----------|-----------------------------------------|
| Backend   | Python 3.10+, FastAPI, SQLAlchemy, SQLite |
| Frontend  | Flutter 3.24, Dart, Provider             |
| Database  | SQLite (default) / PostgreSQL (optional) |
| API Docs  | Swagger UI at `/docs`                    |

## 📱 Screenshots

The app features 5 main screens accessible via bottom navigation:

1. **Calendar** — Hero date card, monthly grid, Tibetan astrology section
2. **Auspicious** — Next milestone countdown, significant dates list
3. **Events** — Filterable by 8 lineages, event cards with images
4. **Practice** — Daily tracker, streak counter, personal events
5. **Settings** — Profile, appearance, notifications, community links

---

*May all beings benefit from the Dharma!* 🙏
