# TitipO Backend Service — Divisi TitipO (Community Commerce)

> **STATUS: stub — facade ke Lumbung.** Template awal Opsi A, belum logika produksi.
> TownHall: [TitipO-TownHall](https://github.com/Coding-Skuy/TitipO-TownHall).
> Auth ikut pola Lumbung — detail: `docs/auth.md`, TownHall Lumbung: [Lumbung-TownHall](https://github.com/Coding-Skuy/Lumbung-TownHall).

## Teknologi (pin standar Rust)

- axum `0.8`
- tokio (full) `1`
- sqlx (postgres, rustls) `0.8`
- jsonwebtoken `9`
- serde / serde_json `1`

Lihat `Cargo.toml`.

## Endpoint stub

| Metode | Rute | Fungsi |
|--------|------|--------|
| GET | `/healthz` | liveness, selalu `{"status":"ok","service":"titipo-backend-service"}` |
| GET | `/v1/contoh` | contoh GET jujur berlabel stub |

## DB terpisah

Database `titipo` terpisah dari `lumbung`. Migrasi awal: `migrations/0001_init.sql` (tabel `pesanan`, `langganan` minimal).

```bash
export DATABASE_URL=postgres://titipo:titipo@localhost:5432/titipo
sqlx migrate run
cargo run
```

## Auth

- JWT pengguna: `aud=titipo`, diverifikasi via JWKS Lumbung.
- Service key `titipo→lumbung`: header `X-Titipo-Service-Key` untuk panggilan server-ke-server.

Detail: `docs/auth.md`.

## Tautan

- TownHall TitipO: https://github.com/Coding-Skuy/TitipO-TownHall
- Kontrak Lumbung: https://github.com/Coding-Skuy/Lumbung-TownHall
- App: https://github.com/Coding-Skuy/titipo-app-kmp
- Web: https://github.com/Coding-Skuy/titipo-web
