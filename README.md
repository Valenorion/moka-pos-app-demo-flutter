# ☕ MOKA - Y2K Pixel Art POS (Point of Sale) & Cafe E-Commerce

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Netlify](https://img.shields.io/badge/Netlify-%2300C7B7.svg?style=for-the-badge&logo=netlify&logoColor=white)

**Aplikasi Kasir / Point of Sale (POS) & Cafe bersgaya Retro Y2K Pixel Art yang dikembangkan dengan Flutter untuk Ujian Tengah Semester (UTS).**

[🌐 Coba Demo Live di Netlify](https://YOUR-NETLIFY-SITE.netlify.app) *(Ganti dengan link Netlify Anda)*

</div>

---

## 📖 Tentang Project
**MOKA** adalah aplikasi Point of Sale (POS) berbasis web desktop dan mobile yang dirancang dengan estetika *Retro Y2K Pixel Art* yang unik dan ramah operator. Mengambil sudut pandang (*POV*) staf kasir toko/cafe, aplikasi ini mengintegrasikan katalog produk, manajemen keranjang belanja, kalkulasi pajak PB1 (10%), opsi pembayaran fleksibel (QRIS & Tunai dengan hitung kembalian otomatis), pencetakan struk termal digital, hingga rekapitulasi riwayat transaksi harian yang persisten.

---

## ✨ Fitur Utama
- **🎨 Y2K Pixel Art & Retro Theme**: Desain antarmuka kustom menggunakan *Pixelify Sans* & *VT323 fonts*, dipadu dengan palet warna khas cokelat hangat (`#48291F`) dan pastel pink (`#F4A5B8`).
- **🔐 Portal Autentikasi Staf**: Halaman login & registrasi kasir terpadu yang terhubung dengan manajemen sesi lokal.
- **☕ Katalog POS Interaktif**: Filter kategori menu (*Signature, Coffee, Non-coffee*), tombol tambah/kurang cepat, pratinjau detail produk, serta fitur *Pull-to-Refresh*.
- **🧾 Terminal Checkout & Struk Termal**: 
  - Kalkulasi subtotal, pajak PB1 (10%), dan total otomatis.
  - Simulasi pemindaian QRIS interaktif.
  - Pembayaran tunai dengan tombol cepat (*Uang Pas, Rp 100rb, Rp 200rb*) beserta validasi uang kurang dan perhitungan kembalian.
  - Dialog cetak struk bergaya printer termal kasir lengkap dengan *scroll* aman anti-overflow.
- **📊 Log Riwayat Transaksi**: Penyimpanan data transaksi real-time menggunakan `shared_preferences` dengan efek kartu *hover* interaktif dan opsi cetak ulang struk.
- **🖥️ Splash Screen Animatif**: Layar pembuka dengan logo berdenyut (*pulsing scale*), indikator titik *loading* piksel bergerak, dan lencana sambutan.

---

## 📂 Struktur Direktori Project
```text
lib/
│
├── main.dart             # Titik masuk aplikasi & routing utama
├── splash_screen.dart    # Layar pembuka beranimasi Y2K & cek sesi
├── auth_page.dart        # Halaman Login & Registrasi Staf Kasir
├── dashboard_page.dart   # Navigasi utama (Bottom/Side Navigation)
├── menu_page.dart        # Katalog menu POS interaktif & filter kategori
├── checkout_page.dart    # Terminal pembayaran, kalkulasi kas, & struk termal
├── pesanan_page.dart     # Log riwayat transaksi kasir tersimpan
├── akun_page.dart        # Panel informasi operator/kasir & pengaturan
├── menu_data.dart        # Model data produk & daftar menu cafe
└── moka_theme.dart       # Konfigurasi warna, tipografi, dan tema global
