-- 0001_init.sql — DB titipo TERPISAH dari lumbung.
-- Database: titipo. Tabel minimal pesanan + langganan.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS pesanan (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_rumah_tangga TEXT NOT NULL,
    id_vendor TEXT NOT NULL,
    daftar_item JSONB NOT NULL DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'dibuat' CHECK (status IN ('dibuat','diterima','diantar','selesai','batal')),
    jadwal_titip DATE NOT NULL,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS langganan (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_rumah_tangga TEXT NOT NULL,
    id_vendor TEXT NOT NULL,
    pola TEXT NOT NULL DEFAULT 'harian' CHECK (pola IN ('harian','mingguan','bulanan')),
    aktif BOOLEAN NOT NULL DEFAULT true,
    dibuat_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
    diubah_pada TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (id_rumah_tangga, id_vendor, pola)
);

CREATE INDEX IF NOT EXISTS idx_pesanan_jadwal ON pesanan (jadwal_titip);
CREATE INDEX IF NOT EXISTS idx_pesanan_vendor ON pesanan (id_vendor);
CREATE INDEX IF NOT EXISTS idx_langganan_rumah_tangga ON langganan (id_rumah_tangga);
