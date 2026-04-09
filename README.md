# OPLNova API

The OPLNova API is a lightweight service written in the V programming language, designed to provide metadata and artwork support for the **OPLNova** PS2 game manager.

## Features

- **Game Metadata Lookup:** Search for game titles by normalized game IDs.
- **Artwork Serving:** Provides access to game-specific artwork stored in the server's database.

## Prerequisites

- The API requires a `db/` directory containing game data. This can be initialized automatically using the provided setup script.

## Getting Started

### Database Setup
To download and prepare the required game data and artwork, run:
```bash
bash setup_db.sh
```

### Installation

You can either compile the project yourself or use a pre-built binary.

1. **Download:** Get the latest binary from [https://code.weexnes.dev/oplnova_vapi/~builds](https://code.weexnes.dev/oplnova_vapi/~builds).
2. **Compile:** Ensure you have the [V language](https://vlang.io/) installed.
   ```bash
   v run api.v
   ```

### Usage

The API runs on port `3000` by default.

#### Endpoints

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/` | Serves the main landing page (`index.html`). |
| `GET` | `/contact` | Serves the contact page (`contact.html`). |
| `GET` | `/search/:id` | Returns JSON metadata for a given game ID (e.g., `/search/SCES12345`). |
| `GET` | `/art/:file` | Serves artwork files from `db/PS2/` (e.g., `/art/cover.png`). |

## License

This project is part of the [OPLNova](https://code.weexnes.dev/OPLNova) ecosystem.
