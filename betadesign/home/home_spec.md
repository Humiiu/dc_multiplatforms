# Spec Halaman Home (dari home.png)

- Frame desain: **440 dp** lebar (PNG 1760 px konten, diekspor 4x, dpi 288), tinggi total ±1258 dp.
- Margin halaman: **20 dp**.
- Font: **Playfair Display** (judul/angka), **Plus Jakarta Sans** (UI/isi).
- Kolom "Sumber": `T` = terukur dari pixel, `P` = perkiraan (cek di emulator).

## Warna

| Token | Hex | Dipakai di | Sumber |
|---|---|---|---|
| surface | #FFF8F3 | background halaman, header, nav | T |
| card | #FFFFFF | kartu debt, kartu menu, tombol Atur Preferensi | T |
| secondaryContainer | #FFF2E0 | kartu "Punya request khusus?" | T |
| tertiaryContainer | #FFDEA5 | area gambar menu, tile bintang | T |
| blob | #F5DAD2 | dekorasi sudut kartu request | T |
| pillBg | #FFEADF | pill di kartu debt | T |
| chipBg | putih 90% | chip hari | T |
| primary | #9E003A | tombol Pay Now, Start Buying! | T |
| primaryDark | #740028 | See All, chip teks, ikon receipt, nav aktif | T |
| tertiary | #735C00 | ikon bintang | T |
| error | #BA1A1A | titik merah di pill | T |
| ink | #261900 | judul, nama menu | T |
| inkVariant | #594043 | teks sekunder, nav tidak aktif | T |
| avatarIcon | #B9B5B2 | ikon profil header | T |

## Layout per komponen (dp)

| Komponen | Posisi / ukuran | Radius | Shadow | Sumber |
|---|---|---|---|---|
| Header | tinggi ±77 (termasuk status bar), avatar 32 dp di kanan (margin kanan 28) | - | tipis 0 2 8 | T / P |
| WELCOME | x 20, cap-top y 93, 14 dp w500, letterSpacing 0.5 | - | - | T |
| Greeting | x 20, 28 dp Playfair w700 | - | - | T |
| Kartu debt | x 20-420, y 174-374 (tinggi 200), padding 24 | 32 | 0 4 16 #594043 6% | T / P |
| Pill debt | 32 x 20, titik 8 x 8 | 10 | - | T |
| Jumlah | "Rp" 13 dp + 8 gap + "60.000" 46 dp Playfair w700 | - | - | T |
| Pay Now | x 44-396 (352 lebar), tinggi 52 | 8 | 0 4 12 primary 25% | T / P |
| Glow kartu debt | kanan atas (kuning #FFDEA5 ~28%), kiri bawah (primary ~8%) | - | - | P |
| Weekly Menu | cap-top y 410, 24 dp Playfair w700; See All 14 dp + chevron 16 | - | - | T |
| Kartu menu | lebar 238, tinggi 216, gap 16, mulai y 459; kartu 2 terpotong di kanan | 16 | 0 4 16 #594043 6% | T / P |
| Gambar menu | tinggi 130; solid sampai 67%, lalu fade ke putih | - | - | T |
| Chip hari | offset 12/12, padding 12 x 8, teks 12 dp w500 | pill | - | T |
| Teks menu | padding 16; judul 15 dp w600, sub 13 dp | - | - | T |
| Kartu request | x 20-420, y 744-1055 (tinggi ±311), padding 32 | 32 | - | T |
| Blob kanan atas | 80 x 80, radius kiri-bawah penuh | - | - | T |
| Blob kiri bawah | 64 x 64, radius kanan-atas penuh | - | - | T |
| Tile bintang | 64 x 64, miring ±-6 derajat, ikon 30 dp | 16 | 0 4 12 tertiary 14% | T / P |
| Judul request | 24 dp Playfair w700, tengah | - | - | T |
| Isi request | 14 dp w400, lineHeight 1.5, lebar maks ±220 (3 baris) | - | - | T |
| Atur Preferensi | tinggi 42, padding horizontal 24, border primary 12% | 12 | - | T / P |
| Start Buying! | x 28-412 (384 lebar), y 1096-1148 (tinggi 52) | 12 | 0 8 16 primary 30% | T / P |
| Bottom nav | x 24-416, y 1173-1237 (tinggi 64), ikon 22, label 12 dp | 20 | tipis 0 2 8 | T / P |

## Catatan keyakinan

- Jarak vertikal antar blok bisa meleset ±3 dp (diukur dari ujung glyph, bukan dari box teks).
- Weight font (w400/w500/w600/w700) adalah tebakan dari tampilan.
- Ukuran font dicocokkan ke lebar teks asli, toleransi ±3%.
- Shadow, glow, border tombol, dan radius nav adalah perkiraan dari gradasi pixel.
- Kemiringan tile bintang (-6 derajat) adalah perkiraan; set `_M.tileTiltDeg = 0` kalau di Figma lurus.
- Posisi "Start Buying!" di dalam scroll (bukan sticky) adalah asumsi dari tangkapan satu halaman penuh.