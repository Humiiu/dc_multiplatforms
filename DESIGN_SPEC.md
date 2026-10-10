# DESIGN_SPEC.md - Dian Catering (Customer App)

Spesifikasi tertulis dari desain Figma/PNG. Semua angka dalam dp (frame desain ±440 px lebar, 1 px = 1 dp).
Warna diambil dari sampel pixel gambar (akurat). Ukuran/jarak adalah estimasi dari gambar (toleransi ±2 dp).
Terapkan HALAMAN PER HALAMAN. Setelah tiap halaman, centang checklist-nya dan catat di `docs/FRONTEND_PROGRESS.md`.

---

## 0. DESIGN TOKEN (buat di satu file, mis. `lib/theme/app_tokens.dart`)

### Warna
| Token | Hex | Dipakai untuk |
|---|---|---|
| bg | `#FFF8F3` | background semua halaman, bottom bar |
| primary | `#9E003A` | tombol utama, badge nomor, chip aktif, tab aktif |
| primaryDark | `#7C1036` | border kartu terpilih (checkout), judul "WELCOME", nav aktif |
| peach | `#FFE3B1` | kartu isi (summary, hari belum dipilih, pembayaran, baris info history) |
| peachLight | `#FFF2E0` | kartu saldo, request card, header total checkout |
| tabBg | `#FFF0CA` | background toggle Login/Register |
| chipBg | `#FFEBCD` | chip filter history, kartu menu profile, tile ikon history |
| chipSmall | `#FFDEA5` | chip kecil "Class XII IPS 2" di profile |
| selectedPink | `#F8ECE9` | kartu TERPILIH (hari, metode bayar, QRIS) |
| selectedPinkAlt | `#FAECEA` | kartu hari terpilih |
| line | `#E1BEC1` | garis bawah input, border outline lembut |
| blobPink | `#F5DAD2` | dekorasi sudut request card |
| success | `#22C55E` | garis kiri kartu lunas, ikon centang |
| danger | `#BA1A1A` | garis kiri belum lunas, nominal belum lunas, Logout |
| textDark | `#2A1A0A` | judul serif, teks utama |
| textMuted | `#5A4A4A` | teks sekunder, label input |
| white | `#FFFFFF` | kartu menu home, kartu history |

### Font
- Judul/angka besar: **Playfair Display** (Bold/ExtraBold). Pakai `google_fonts`.
- Body/label/tombol: **Plus Jakarta Sans** (Regular 400, Medium 500, SemiBold 600, Bold 700).
- Tombol "Sign In"/"Daftar": SemiBold/Bold, letterSpacing 0.5.

### Text style (ukuran/weight)
| Nama | Font | Size | Weight | Warna |
|---|---|---|---|---|
| display | Playfair | 48-56 | 700 | textDark / primary |
| h1 | Playfair | 28 | 700 | textDark (atau primary di "Your Order") |
| h2 | Playfair | 22 | 700 | textDark |
| h3 | Playfair | 20 | 700 | textDark |
| body | Jakarta | 15 | 400 | textMuted |
| bodyBold | Jakarta | 15 | 700 | textDark |
| label | Jakarta | 13 | 500-600 | textMuted / primary |
| caption | Jakarta | 12 | 400 | textMuted |
| overline | Jakarta | 12 | 500 uppercase, letterSpacing 1-1.5 | textMuted |
| button | Jakarta | 15 | 600-700 | putih |

### Radius, spacing, shadow
- Radius: tombol 8-10, kartu isi 12-16, kartu besar (saldo/request) 24-28, chip/pill 12-14, tile ikon 10-16.
- Padding halaman horizontal: **28** (login, register, home, history, profile, checkout 20-40). Halaman Order di desain memakai margin lebih besar (±48); ikuti gambar tapi jadikan konstanta terpisah.
- Jarak antar section: 24-32. Jarak antar kartu: 12-16.
- Shadow kartu putih: `color primary @ 8%`, blur 20, offset (0, 6).
- Shadow tombol utama: `color primary @ 25%`, blur 16, offset (0, 8).

### Widget reusable yang WAJIB dibuat
`PrimaryButton`, `SectionHeader` (badge nomor + judul serif), `PeachCard`, `SelectableCard` (state selected/unselected), `AppTextField` (underline), `StatusPill`, `FilterChipPill`, `AppBottomNav`, `ProfileMenuTile`, `HistoryCard`.

---

## 1. LOGIN & REGISTER

**Struktur (atas ke bawah):**
1. Logo bulat Ø110 (background `#B03A5E`-ish merah muda tua, isi logo DC), shadow lembut bergeser ke bawah-kiri. Top ±92 dari atas.
2. "WELCOME": Playfair 28 Bold, warna primaryDark, tengah, jarak 16 di bawah logo.
3. Toggle Login/Register: tinggi 52, radius 14, bg `#FFF0CA`, margin atas 48. Pill terpilih inset 4, radius 12, bg primary, teks putih 14 SemiBold. Tak terpilih: teks textDark 14 SemiBold, tanpa bg.
4. Input: HANYA garis bawah 1 px `#E1BEC1`, tanpa kotak/border. Teks hint/label 16 textMuted. Tinggi per baris ±64. Ikon mata (show/hide) di kanan, 22, textMuted.
5. "Forgot password?" rata kanan, 12, warna primaryDark, hanya di tab Login.
6. Tombol: lebar penuh (padding 28), tinggi 52, radius 8, primary, teks putih 15 Bold letterSpacing 0.5, shadow tombol. Jarak ±32 dari link atas.
7. Bawah halaman (±40 dari dasar): tile 40x40 radius 10, bg `#FFE3B1`-ish, ikon centang-badge warna olive `#8A7420`, di tengah.

**Register (tambahan):** field Nama lengkap, Username, Kelas+Jurusan (2 kolom sejajar, dropdown gaya underline), Nomor telepon, Password. Tombol "Daftar".

**Checklist:** [ ] logo+shadow [ ] toggle persis [ ] input underline [ ] eye icon [ ] tombol+shadow [ ] tile bawah

---

## 2. HOME

1. App bar transparan: ikon profil (lingkaran outline) 28 warna abu `#9A8F8F`, kanan atas, top ±48.
2. "SELAMAT DATANG": overline 12, letterSpacing 1, textMuted. Di bawahnya "Halo, Humiiu!" Playfair 28 Bold textDark (kata "Halo" rotasi bahasa).
3. **Kartu saldo:** lebar penuh (padding 28), tinggi ±200, radius 24, bg putih dengan glow radial `#FFF2E0` → putih di pojok kanan atas, shadow lembut. Padding dalam 24.
   - Baris atas: ikon struk 18 primary + "SISA TAGIHAN" overline 12 primary. Kanan: pill 36x20, bg `#FFE0DF`, titik merah Ø8 `#D32F2F` di tengah.
   - "Rp" Jakarta 16 SemiBold textDark + "60.000" Playfair 48 Bold textDark (baseline sejajar).
   - Tombol "Bayar Sekarang →": tinggi 52, radius 8, primary, teks putih 15 SemiBold + ikon panah 18, margin atas 20.
4. Header section: "Menu Minggu Ini" Playfair 22 Bold; kanan "Lihat Semua >" 13 SemiBold primary. Margin atas 32.
5. **Kartu menu** (horizontal scroll, gap 16): lebar ±240, tinggi ±218, radius 20, bg putih, shadow lembut, clip.
   - Area atas tinggi ±128: gradient vertikal `#FFE0A8` → putih (atau gambar). Chip tanggal di kiri atas (margin 12): bg putih, radius 12, padding 12x8, teks 13 Medium textDark ("Senin, 27 Okt").
   - Bawah: judul 15 SemiBold textDark, deskripsi 14 textMuted, padding 16.
6. **Request card:** tinggi ±310, radius 28, bg `#FFF2E0`. Dekorasi: seperempat lingkaran `#F5DAD2` di pojok kanan atas (±80) dan pojok kiri bawah (±64), terpotong rapi oleh radius kartu. Isi tengah:
   - Tile ikon bintang 64x64, radius 18, bg `#FFDFA6`, sedikit miring (-8°), bintang outline warna olive `#7A5C00` 32.
   - Judul "Punya request khusus?" Playfair 22 Bold, tengah.
   - Deskripsi 14 textMuted, tengah, lineHeight 1.4, maks lebar 260.
   - Tombol "Atur Preferensi": bg putih, border 1 `#E1BEC1`, radius 14, tinggi 44, padding horizontal 24, teks 14 SemiBold primary.
7. Tombol "Pesan Ketring": lebar penuh (margin 36), tinggi 52, radius 8, primary, teks 16 SemiBold, shadow tombol, melayang di atas bottom nav (jarak 16).

**Checklist:** [ ] glow kartu saldo [ ] pill merah [ ] Rp + angka sejajar [ ] kartu menu + chip tanggal [ ] dekorasi pojok [ ] tile bintang miring [ ] tombol putih outline

---

## 3. ORDER

1. Ikon profil kanan atas (sama home).
2. "Your Order": Playfair 28 Bold, warna primary. Subtitle 14 textMuted, 2 baris.
3. **SectionHeader:** badge 32x32, radius 10, primary, angka putih 14 SemiBold + judul Playfair 22 Bold, jarak 12. Urutan tampil: ikuti posisi di layar (1 = Order Summary, 2 = Select Days, 3 = Payment Method).
4. **Order Summary card:** bg `#FFE3B1`, radius 12, padding 20, shadow tipis. Baris hari: kiri 15 textDark, kanan 15 textDark, tinggi 44, divider 1 px `#F5D9A8` (bukan baris terakhir). Total: "Total Tagihan" Playfair 22 Bold primary kiri, "Rp 40.000" Playfair 22 Bold primary kanan.
5. **Kartu hari:** radius 12, padding 16, jarak antar kartu 12.
   - Terpilih: bg `#FAECEA`, border 1 `#D9A0AD`, checkbox terisi primary dengan centang putih.
   - Belum terpilih: bg `#FFE3B1`, tanpa border, checkbox putih kosong.
   - Checkbox 20x20 radius 4. Nama hari 15 Bold; harga kanan atas 13 SemiBold primary; deskripsi 14 textMuted lineHeight 1.4, indent sejajar nama (±32 dari kiri).
6. **Kartu metode bayar:** radius 12, padding 16.
   - Terpilih: bg `#F8ECE9`, border 1 `#D9A0AD`. Tak terpilih: bg `#FFE3B1`.
   - Ikon 20 primary + judul 14 Bold; deskripsi 14 textMuted indent ±32; radio kanan 24 (**pakai warna primary, bukan biru**), tak terpilih: lingkaran putih border abu.
7. Tombol "Konfirmasi Pesanan" + ikon centang-lingkaran: tinggi 52, radius 8, primary, teks 15 SemiBold, shadow tombol, margin bawah di atas nav.

**Checklist:** [ ] badge nomor [ ] summary divider [ ] selected vs unselected [ ] checkbox [ ] radio primary [ ] tombol shadow

---

## 4. CHECKOUT

1. App bar: panah kembali kiri 24, judul "Checkout" tengah Playfair 22 Bold primary.
2. **Header total:** gradient `#FFF2E0` → `#F8E1CC` (diagonal), radius bawah 32, tinggi ±150, ada dekorasi blur tipis di pojok. "TOTAL PEMBAYARAN" overline 13 letterSpacing 1.5 textMuted, tengah. "Rp" Playfair 24 + "40.000" Playfair 56 Bold primary.
3. "Pilih Metode Pembayaran" Playfair 22 Bold, margin atas 28.
4. **Kartu metode:** radius 16, padding 20, jarak 12.
   - Terpilih (QRIS): bg `#F8ECE9`, border 2 `#7C1036`, radio kanan terisi primary dalam ring primary.
   - Tak terpilih: bg `#FFE3B1`, radio outline `#E1BEC1`.
   - Judul 14 Bold, deskripsi 15 textMuted lineHeight 1.35. Kanan atas: logo kecil dalam kotak putih radius 4 (QRIS: ikon QR primary; Virtual Account: chip "BCA", "MDR"; E-Wallet: 3 lingkaran Ø24 warna cyan/ungu/oranye berhuruf G/O/S).
5. **Bottom bar tetap:** bg `#FFF8F3`, padding 16-20. Baris "Total Tagihan" 15 textMuted kiri + "Rp 40.000" 15 Bold kanan. Tombol "Bayar Sekarang" + ikon gembok: tinggi 52, radius 8, primary, shadow tombol.

**Checklist:** [ ] gradient header [ ] border 2 kartu terpilih [ ] logo kecil kanan atas [ ] bottom bar tetap

---

## 5. HISTORY

1. Ikon profil kanan atas.
2. Tile ikon struk 64x64, radius 16, bg `#FFEBCD`, ikon primary 28, tengah.
3. "Riwayat Pesanan" Playfair 28 Bold tengah. "Total Seluruh Ketring:" 15 textMuted tengah. "Rp 1.200.000" 16 Medium primary tengah.
4. **Filter chip** (horizontal scroll, padding kiri 28, gap 12): tinggi 36, radius 12, padding horizontal 24, teks 14 SemiBold. Terpilih: bg primary, teks putih. Tak terpilih: bg `#FFEBCD`, teks textDark, shadow tipis.
5. **HistoryCard:** bg putih, radius 16, shadow lembut, padding 16, jarak antar kartu 16. Garis kiri lebar 4: success (lunas) / danger (belum lunas), mengikuti lengkungan kiri kartu.
   - Baris atas: tanggal 12 textMuted ("27 Okt 2009 • 11:06 WIB"), kanan **StatusPill** (±44x24, radius 12): lunas bg `#E8F8EE` + ikon centang-lingkaran success; belum lunas bg `#FFDAD6` + ikon jam danger.
   - Judul "Oktober, Minggu 1" Playfair 20 Bold textDark.
   - Dua baris info: bg `#FFE3B1`, radius 8, tinggi 36, padding horizontal 10, jarak 8. Ikon kiri primary 18 (garpu-sendok / uang), label 14 textDark, nominal kanan 14 Bold (belum lunas: warna danger).
   - Belum lunas saja: tombol "Bayar Sekarang →" lebar penuh, tinggi 44, radius 8, primary.

**Checklist:** [ ] garis kiri ikut radius [ ] status pill [ ] baris info peach [ ] chip scroll

---

## 6. PROFILE

1. Avatar 124x124, radius 20, border tipis `#E8DADA`, foto cover. Tengah, top ±90.
2. Nama Playfair 28 Bold tengah. Chip: "Class XII IPS 2", "Major: MIPA": bg `#FFDEA5`, radius 14, padding 12x6, teks 12 Medium textDark, jarak 8. Nomor telepon 16 textMuted letterSpacing 1, tengah.
3. **ProfileMenuTile** (3 item, jarak 12): bg `#FFEBCD`, radius 12, padding 16.
   - Tile ikon 40x40, radius 12: Edit Profile `#A40B42` (ikon pensil putih), Ubah Password `#FECF15` (ikon gembok gelap), Hubungi Admin `#9B0053` (ikon headset putih).
   - Judul 15 Bold textDark, subtitle 13 textMuted, chevron kanan 20.
4. Logout: tengah, ikon keluar + teks 15 SemiBold warna danger, margin atas 40.

**Checklist:** [ ] avatar radius+border [ ] chip kecil [ ] 3 warna tile ikon [ ] logout merah

---

## 7. BOTTOM NAVIGATION

- Container: bg `#FFF8F3`, radius 16, shadow/border sangat tipis, tinggi ±72, margin horizontal 28 dari tepi, mengambang.
- 4 item rata: Home, Order, History, Profile. Ikon 24 + label 12 (jarak 4).
- Aktif: ikon & label warna primaryDark `#7C1036`, ikon versi filled/bold (label Medium). Tak aktif: `#4A3A3A`, ikon outline.
- Ikon: Home (rumah), Order (garpu-sendok silang), History (jam dengan panah memutar), Profile (orang).

**Checklist:** [ ] aktif filled [ ] jarak ikon-label [ ] konsisten di 4 halaman

---

## Catatan
- Teks placeholder/typo di desain ("lorem", "autr pesanan...", tahun 2009) boleh diganti teks wajar.
- Jika Figma bisa diakses dan nilainya berbeda dari angka di atas, **Figma menang**; catat selisihnya di log.