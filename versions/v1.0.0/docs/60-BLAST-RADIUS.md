# 60-BLAST-RADIUS — titipo-backend-service

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
