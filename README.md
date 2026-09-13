# TriplePick

Riguarda la scelta, non il catalogo.

TriplePick risolve il paradosso della scelta nello streaming. Inserisci una richiesta in linguaggio naturale e ricevi rigorosamente **SOLO 3 consigli mirati** con link diretti alle piattaforme.

## Caratteristiche

- **Richiesta in linguaggio naturale**: descrivi cosa vuoi guardare
- **3 consigli precisi**: niente piu scelte infinite
- **Link diretti**: clicca e si apre Netflix, Prime Video, Disney+
- **AI-powered**: modelli gratuiti via OpenRouter
- **Catalogo aggiornato**: dati in tempo reale da TMDB

## Requisiti

- Flutter SDK >=3.1.0
- Account TMDB (https://www.themoviedb.org/settings/api)
- Account OpenRouter (https://openrouter.ai)

## Setup

### 1. Clone il progetto

```bash
git clone https://github.com/fiore1088/triple-pick.git
cd triple-pick
```

### 2. Configura le variabili d'ambiente

Crea il file `.env` nella root del progetto:

```
TMDB_API_KEY=la_tua_chiave_tmdb
TMDB_USERNAME=il_tuo_username_tmdb
OPENROUTER_API_KEY=la_tua_chiave_openrouter
```

### 3. Installa le dipendenze

```bash
flutter pub get
```

### 4. Genera il progetto

```bash
flutter create .
```

### 5. Avvia l'app

```bash
flutter run
```

## Struttura del Progetto

```
triple-pick/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── app.dart                  # Configurazione app
│   ├── core/
│   │   ├── constants/            # Costanti API e app
│   │   ├── theme/                # Tema cinematografico scuro
│   │   ├── utils/                # Utility (deep linking)
│   │   └── env/                  # Variabili d'ambiente
│   ├── data/
│   │   ├── models/               # Modelli dati
│   │   ├── services/             # Servizi API (TMDB, AI, Storage)
│   │   └── repositories/         # Repository layer
│   └── presentation/
│       ├── screens/              # Schermate
│       ├── widgets/              # Widget riutilizzabili
│       └── providers/            # State management (Riverpod)
├── .env                          # Variabili d'ambiente (non committare!)
└── pubspec.yaml                  # Dipendenze
```

## Architettura

- **Clean Architecture**: separazione tra data, domain e presentation
- **Riverpod**: state management moderno e testabile
- **TMDB API**: catalogo + disponibilita Italia + link diretti
- **OpenRouter**: accesso a modelli AI gratuiti (Llama, Gemma, Mistral, Qwen)

## Piattaforme Supportate

- Netflix, Prime Video, Disney+, Apple TV+, .now, Infinity

## Licenza

Proprietario - Tutti i diritti riservati