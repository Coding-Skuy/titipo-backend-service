# AGENTS.md — titipo-backend-service

Backend Rust TitipO: API pesanan, vendor, fee, dan penerima sinyal `pedaree.stok.v1`; facade ke Lumbung.

Divisi TitipO (Epic E2 [#3](https://github.com/Coding-Skuy/ChefGenie-TownHall/issues/3), milestone v1.0.0). Bahasa semua artefak: Indonesia.

## Sumber kebenaran

Dokumen beku v1.0.0 ada di repo [TitipO-TownHall](https://github.com/Coding-Skuy/TitipO-TownHall). Repo ini hanya menjalankan, bukan mendefinisikan, requirement.

| Dokumen | Isi | Link |
|---|---|---|
| `platform/versions/v1.0.0/BRD/20-titip-harian.md` | Alur titip harian | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/platform/versions/v1.0.0/BRD/20-titip-harian.md) |
| `platform/versions/v1.0.0/BRD/30-keuangan-fee.md` | Fee 12%, bonus Prioritas, denda, cair H+1 | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/platform/versions/v1.0.0/BRD/30-keuangan-fee.md) |
| `platform/versions/v1.0.0/FRD/10-fungsional.md` | Kebutuhan fungsional FR-001..FR-304 | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/platform/versions/v1.0.0/FRD/10-fungsional.md) |
| `platform/versions/v1.0.0/FSD/10-alur.md` | Alur sistem, tulis lokal dahulu, sinkron | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/platform/versions/v1.0.0/FSD/10-alur.md) |
| `platform/versions/v1.0.0/FSD/20-model-data.md` | Model data, aturan angka | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/platform/versions/v1.0.0/FSD/20-model-data.md) |
| `platform/versions/v1.0.0/FSD/30-kontrak.md` | Kontrak API, event, galat | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/platform/versions/v1.0.0/FSD/30-kontrak.md) |
| `platform/versions/v1.0.0/SRS/30-non-functional.md` | Non-fungsional (kinerja, keamanan, rollback) | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/platform/versions/v1.0.0/SRS/30-non-functional.md) |
| `platform/versions/v1.0.0/SRS/40-acceptance-criteria.md` | Kriteria penerimaan QA gate | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/platform/versions/v1.0.0/SRS/40-acceptance-criteria.md) |
| `produk/20-kontrak-api-KMP-mobile.md` | Kontrak API mobile 7 endpoint (living) | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/produk/20-kontrak-api-KMP-mobile.md) |
| `produk/21-kontrak-api-web-bun.md` | Kontrak API admin 6 endpoint (living) | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/produk/21-kontrak-api-web-bun.md) |
| `pesanan/10-alur-titip-harian.md` | Alur 8 langkah + sinyal pedaree.stok.v1 sisi konsumen (§6) (living) | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/pesanan/10-alur-titip-harian.md) |
| `pesanan/20-model-data.md` | Model data pesanan (living) | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/pesanan/20-model-data.md) |
| `keuangan/10-bagi-fee.md` | Bagi fee, 3 kasus hitungan (living) | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/keuangan/10-bagi-fee.md) |
| `vendor/10-sla-vendor.md` | SLA vendor (living) | [buka](https://github.com/Coding-Skuy/TitipO-TownHall/blob/main/vendor/10-sla-vendor.md) |
| `KONTEKS-LINTAS-DIVISI.md` | Konteks lintas-divisi (event registry, ID, satuan, metrik) | [buka](https://github.com/Coding-Skuy/ChefGenie-TownHall/blob/main/KONTEKS-LINTAS-DIVISI.md) |
| `townhall-roadmap.md` | Epic E2 #3, milestone v1.0.0, Definisi Selesai §6 | [buka](https://github.com/Coding-Skuy/ChefGenie-TownHall/blob/main/townhall-roadmap.md) |

Aturan:
- Dilarang menduplikasi requirement di repo kode; cukup tautkan ke versi di atas.
- Requirement berubah = PR di TitipO-TownHall dahulu (versi baru), baru kode mengikuti.
- Bila dokumen divisi bertentangan dengan KONTEKS-LINTAS-DIVISI.md, laporkan; jangan memperbaiki diam-diam.

## Tech stack terkunci

- Rust + Axum 0.8 (path parameter `{id}`), Tokio, SQLx Postgres + `migrate!`, tower-http (Trace + Timeout), tracing, uuid v7, validator, jsonwebtoken + argon2.
- `AppState { db: PgPool }`; satu `AppError: IntoResponse`; test DB dengan `#[sqlx::test]`.
- DB logis `titipo`. JWT beraudien `titipo` diverifikasi via JWKS Lumbung (cache 10 menit, toleransi 60 detik); service key `X-Titipo-Service-Key` untuk server-ke-server (rotasi 90 hari, 2 kunci aktif 7 hari). Acuan: `docs/auth.md` di repo ini dan di lumbung-backend-service.
- Dokumentasi API: `docs/api/openapi.yaml` (OpenAPI 3.1) + Scalar.
- Dilarang: akses DB Lumbung/divisi lain, service key ke klien, pesanan otomatis dari sinyal `pedaree.stok.v1`.

Angka bisnis TitipO yang berlaku di seluruh repo: fee vendor 12% (+0,5% Prioritas), ongkir flat Rp5.000 (Rp4.000 vendor + Rp1.000 kas), pesan maksimal 20.00, serah 06.00-08.00, pokok ke Lumbung tiap Senin, denda batal sepihak Rp15.000, maksimal 50 kg per transaksi (di atasnya ditandai grosir), ID pesanan `T-2026-NNNNNN`.

## Aturan kerja AI

a. Baca AGENTS.md ini dan seluruh ADR di `docs/decisions/` sebelum menulis kode.
b. TDD merah-hijau: tulis test yang gagal dahulu. Rilis diblokir bila QA gate (SRS/40-acceptance-criteria.md) gagal.
c. Kontrak API/event hanya diubah lewat bump versi + catatan di ADR baru.
d. Pesan commit berawalan `docs:`, `feat:`, atau `fix:`; wajib memperbarui `CHANGELOG.md` repo ini.
e. Keputusan arsitektur baru = tambah ADR bernomor di `docs/decisions/`; jangan mengedit ADR lama (immutable, sama seperti aturan versi TownHall).
f. Dilarang menyentuh DB divisi lain (DB per service; Titeny read-only).
g. Khusus repo ini:
- Kontrak OpenAPI (`docs/api/openapi.yaml`) adalah turunan FSD/30-kontrak.md; ubah hanya bersama bump versi dan ADR baru.
- Aturan bisnis yang ditegakkan server: pesan maksimal 20.00, serah 06.00-08.00, fee vendor 12% (+0,5% Prioritas), ongkir flat Rp5.000 (Rp4.000 vendor + Rp1.000 kas), denda batal sepihak Rp15.000, ID `T-YYYY-NNNNNN`, pokok ke Lumbung tiap Senin.

## Definisi selesai

- Dokumen versi lengkap (BRD/PRD/FRD/FSD/SRS) + `SNAPSHOT-ROADMAP.md`.
- QA gate berbasis SRS lulus (TDD merah-hijau).
- Kontrak API terbit; audit keamanan bersih (JWT audiens + DB per service).
- Bukti metrik lintas-divisi (KONTEKS §7) tercatat.
- CHANGELOG versi diperbarui; dokumen beku tidak diedit.
Sumber: [townhall-roadmap.md §6](https://github.com/Coding-Skuy/ChefGenie-TownHall/blob/main/townhall-roadmap.md)
