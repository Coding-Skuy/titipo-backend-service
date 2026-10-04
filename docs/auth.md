# Kontrak Auth TitipO — mengikuti pola Lumbung

Sumber pola: [Lumbung-TownHall](https://github.com/Coding-Skuy/Lumbung-TownHall).
TownHall TitipO: [TitipO-TownHall](https://github.com/Coding-Skuy/TitipO-TownHall).

## 1. JWT pengguna (`aud=titipo`)

- Penerbit: layanan auth Lumbung (issuer `https://auth.lumbung.skuy`).
- Klaim wajib:
  - `aud = "titipo"` — tolak token dengan audien lain (`403`).
  - `sub` — id pengguna Lumbung.
  - `role` — salah satu `vendor`, `household`, `admin`.
  - `exp`, `iat` standar.
- Verifikasi: JWKS Lumbung, cache 10 menit, toleransi clock-skew 60 detik.
- Klien (`titipo-app-kmp`, `titipo-web`) mengirim `Authorization: Bearer <token>` ke setiap request.

Contoh verifikasi (jsonwebtoken 9, RS256):

```rust
// Kunci JWKS diambil dari https://auth.lumbung.skuy/.well-known/jwks.json
// Validasi: aud == ["titipo"], iss == "https://auth.lumbung.skuy"
```

## 2. Service key `titipo → lumbung`

Untuk panggilan server-ke-server (mis. cek saldo penitip, validasi vendor):

- Header: `X-Titipo-Service-Key: <nilai dari TITIPO_SERVICE_KEY>`
- Simpan di env backend TitipO (`TITIPO_SERVICE_KEY`) dan di secret manager Lumbung (`LUMBUNG_TITIPO_KEYS`).
- Rotasi tiap 90 hari. Saat rotasi, dukung 2 kunci aktif selama 7 hari.
- Tolak tanpa kunci (`401`) atau kunci salah (`403`).

## 3. Variabel lingkungan

```bash
LUMBUNG_JWKS_URL=https://auth.lumbung.skuy/.well-known/jwks.json
LUMBUNG_ISSUER=https://auth.lumbung.skuy
TITIPO_JWT_AUD=titipo
TITIPO_SERVICE_KEY=isi-di-secret-manager
DATABASE_URL=postgres://titipo:titipo@localhost:5432/titipo
```

## 4. Matriks akses awal

| Rute | household | vendor | admin |
|------|-----------|--------|-------|
| `GET /healthz` | bebas | bebas | bebas |
| `GET /v1/contoh` | token | token | token |
| `pesanan/*` (nanti) | buat/baca miliknya | baca/terima lapaknya | semua |
| `langganan/*` (nanti) | kelola miliknya | baca pelanggannya | semua |
