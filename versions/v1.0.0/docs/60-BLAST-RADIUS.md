# 60-BLAST-RADIUS — titipo-backend-service

> Versi: v1.0.0 | Status: disetujui | Menggantikan: -
> Acuan: [TitipO-TownHall platform/versions/v1.0.0](https://github.com/Coding-Skuy/TitipO-TownHall/tree/main/platform/versions/v1.0.0) (BRD/PRD/FRD/FSD/SRS beku 2026-10-07).

## Konsumen

- Konsumen langsung: `titipo-app-kmp` (pesanan dan langganan), `titipo-web` (admin dan job), `titipo-data-pipeline` (event pesanan).
- Hulu: JWKS Lumbung (verifikasi JWT), DB titipo (sumber kebenaran), secret manager (service key titipo ke lumbung).
- Hilir: Titeny via event pipeline; tidak ada tulis langsung ke DB Lumbung.

## Failure

- JWKS Lumbung tidak terjangkau: login dan verifikasi baru gagal tertutup dengan cache 10 menit terakhir; sesi berjalan tetap valid sampai kedaluwarsa.
- DB titipo down: semua tulis 500; baca cache web menampilkan data terakhir; antre mobile menahan 50 aksi per 24 jam.
- Service key salah atau kedaluwarsa: panggilan ke Lumbung 401 atau 403; cek stok ditolak; pesanan baru ditahan dengan pesan jelas.
- Clock-skew di atas 60 detik: token valid ditolak; perbaiki NTP sebelum rotasi kunci.

## Rollback

- Rollback berarti deploy biner sebelumnya; migrasi DB tidak otomatis mundur.
- Bila migrasi sudah jalan, biner lama wajib tetap baca skema baru; bila tidak kompatibel, majukan perbaikan kecil ke depan, bukan downgrade skema.
- Kunci idempoten uuid v7 tidak dipakai ulang; replay aman tanpa rekaman ganda.

## Batasan

- Dampak maksimal API dan job TitipO; tidak menyentuh biner mobile, token visual, model AI, atau runner CI.
- Insiden JWKS dan katalog Lumbung dieskalasi ke pemilik Lumbung via TownHall, bukan bypass auth lokal.

## Boleh disentuh

API pesanan/vendor/fee, mesin status pesanan, ledger fee, DB `titipo`, verifikasi JWT via JWKS Lumbung, panggilan server-ke-server ke Lumbung dengan service key.

## Dilarang

Tulis ke DB Lumbung atau divisi lain, menyimpan secret di repo, mengirim service key ke klien, membuat pesanan otomatis dari `pedaree.stok.v1`, mengubah harga pokok Lumbung.

## Kontrak yang dikonsumsi

Lumbung (katalog + JWKS, service key `X-Titipo-Service-Key`); sinyal bilateral `pedaree.stok.v1` dari Pedaree (3 jenis: `stok.menipis`, `stok.habis`, `kedaluwarsa.dekat`; idempoten `item_id + tanggal`; duplikat `200 duplikat_diabaikan`; anjuran saja).

## Kontrak yang diproduksi

API v1 (13 endpoint + healthz), 7 event pesanan (`pesanan.dibuat`, `pesanan.dibayar`, `pesanan.dikonfirmasi`, `pesanan.diserahkan`, `pesanan.dialihkan`, `fee.dicairkan`, `konflik.dicatat`) ke outbox untuk pipeline.

Sumber batas: [townhall-roadmap.md §2](https://github.com/Coding-Skuy/ChefGenie-TownHall/blob/main/townhall-roadmap.md) baris TitipO (pesan <=20.00, serah 06.00-08.00; sinyal `pedaree.stok.v1` anjuran saja; fee vendor 12%) dan [KONTEKS-LINTAS-DIVISI.md](https://github.com/Coding-Skuy/ChefGenie-TownHall/blob/main/KONTEKS-LINTAS-DIVISI.md) §3, §8, §9.
