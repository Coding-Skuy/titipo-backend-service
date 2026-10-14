# ADR-0001 — Fondasi teknis titipo-backend-service

Status: Diterima | Tanggal: 2026-10-14

## Konteks

titipo-backend-service adalah bagian divisi TitipO (Epic E2 #3, milestone v1.0.0). Spesifikasi v1.0.0 beku sejak 2026-10-07 di [TitipO-TownHall](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/platform/versions/v1.0.0/FSD/30-kontrak.md). Repo ini memerlukan fondasi teknis yang tetap agar pengembangan oleh AI dan manusia konsisten.

## Keputusan

Keputusan kunci CEO yang berlaku untuk repo ini:

1. **Stack backend terkunci.** Rust + Axum 0.8, Tokio, SQLx Postgres, uuid v7, tower-http, tracing, validator, jsonwebtoken + argon2.
2. **DB per service.** Database logis `titipo` terpisah dari `lumbung`; tidak ada akses langsung ke DB divisi lain. Titeny hanya membaca lewat event.
3. **JWT audiens titipo.** Token beraudien `titipo` dari Lumbung (JWKS, cache 10 menit, skew 60 detik); audiens lain ditolak 403. Peran: vendor, household, admin.
4. **Service key titipo-lumbung.** Header `X-Titipo-Service-Key`, rotasi 90 hari dengan 2 kunci aktif 7 hari; hanya di server.
5. **Idempotensi.** Semua POST membawa kunci ULID klien; pengiriman ulang mengembalikan 200 tanpa rekaman ganda.
6. **Sinyal pedaree.stok.v1 anjuran saja.** Penerima mengabaikan duplikat `item_id + tanggal` dengan `200 duplikat_diabaikan` dan tidak pernah membuat pesanan otomatis.

Keputusan lintas repo: satu DB logis per service, JWT beraudien divisi, kunci idempoten ULID klien pada semua POST, uang integer rupiah, waktu timestamptz UTC.

## Konsekuensi

Perubahan kontrak API/event wajib bump versi + ADR baru + pembaruan `docs/api/openapi.yaml`. Rilis diblokir bila QA gate gagal.
ADR ini immutable; perubahan keputusan ditulis sebagai ADR baru yang menggantikan.
