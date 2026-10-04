# 40-TECHSTACK — titipo-backend-service

STATUS: defined pending (target dikunci, implementasi menunggu).

Mengacu: TitipO-TownHall v1.0.0

## 1. Target stack

| Lapisan | Teknologi + versi | Keterangan |
|---|---|---|
| Bahasa | Rust stabil | Layanan facade ke Lumbung |
| HTTP | axum 0.8.4 | Router dan middleware |
| DB | sqlx 0.8 + PostgreSQL 16 | Akses DB titipo |
| ID | uuid v7 | ID pesanan dan idempoten |
| Waktu | chrono | timestamptz UTC |
| Auth | jsonwebtoken 9 RS256 | Verifikasi JWT beraudien titipo via JWKS Lumbung |
| Menara | tower + tower-http cors trace | Batas dan observabilitas |
| Log | tracing + tracing-subscriber | Log tanpa secret |

Aturan bisnis yang dijaga backend: pesan maksimal 20.00, serah 06.00–08.00, fee 12 persen, repeat minimal 40 persen, tolak audien selain titipo, simpan service key titipo ke lumbung hanya di server.

## 2. Konfigurasi kunci

- Env wajib: LUMBUNG_JWKS_URL, LUMBUNG_ISSUER, TITIPO_JWT_AUD=titipo, TITIPO_SERVICE_KEY, DATABASE_URL postgres titipo.
- Rute awal: GET healthz bebas, contoh berauth; rute pesanan dan langganan mengikuti matriks peran household vendor admin.
- Migrasi 0001_init dan seterusnya; uang rupiah integer; berat gram integer; idempoten via kunci ULID klien.
- Rotasi service key 90 hari dengan 2 kunci aktif 7 hari saat rotasi.

## Batasan

- Hanya facade TitipO; bukan pemilik katalog Lumbung dan bukan penghitung harga pokok.
- Dilarang menyimpan secret di repo dan dilarang mengirim service key ke browser atau biner mobile.
- Dilarang menaikkan atau menurunkan pin axum 0.8.4, sqlx, uuid v7 tanpa PR.
