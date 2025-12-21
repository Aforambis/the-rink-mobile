# 🚀 Mobile Project Development Plan

**Project Status:** Planning Phase

## 📱 Download APK

[![Download APK](https://img.shields.io/badge/Download-APK-green?style=for-the-badge&logo=android)](https://app.bitrise.io/app/c8dfaa2d-434c-4b08-9cd8-6bd19aa0e207/installable-artifacts/23b8acb3c55f037d/public-install-page/5d372876d58f0f6aa727c43bb30be5b0)

---

Dokumen ini berisi detail perencanaan kerja individu dan kelompok untuk pengembangan aplikasi mobile hingga **21 Desember 2025**.

---

## 🗓️ Perencanaan Kerja Individual

### **Pekan 1: Backend & Initial Setup (17 - 24 November 2025)**

| Individu | Tugas Kunci | Keterangan / Fokus |
|---------|-------------|--------------------|
| Yafi | **Membuat Design System** | Menyiapkan panduan dan komponen desain dasar. |
| Rusydan | **Menginisiasi Flutter Project** | Setup awal proyek Flutter dan struktur folder. |
| Rusydan | **Membuat Deskripsi Github** | Menulis deskripsi proyek dan petunjuk dasar di `README.md`. |
| Yafi | **Membuat API Auth** | Mengembangkan endpoint untuk Login/Register. |
| Derriel | **Membuat API Fitur 1** | Mengembangkan endpoint untuk fitur utama pertama. |

---

### **Pekan 2: API Lanjutan & Pengembangan UI (24 November – 1 Desember 2025)**

| Individu | Tugas Kunci | Keterangan / Fokus |
|---------|-------------|--------------------|
| Waldan | **Membuat API Fitur 2** | Pengembangan endpoint fitur kedua. |
| Rusydan | **Membuat API Fitur 3** | Pengembangan endpoint fitur ketiga. |
| Angga | **Membuat API Fitur 4** | Pengembangan endpoint fitur keempat. |
| Yafi | **Membuat Halaman Auth (Flutter)** | Implementasi UI & logic login/register. |
| Derriel | **Membuat Halaman Fitur 1 (Flutter)** | Implementasi UI & logic yang menggunakan API Fitur 1. |

---

## 👥 Tugas Kelompok

| Tipe Tugas | Deskripsi |
|-----------|-----------|
| **Integrasi Fitur** | Integrasi **seluruh API** (dari D & E) ke proyek Flutter. |

---

Anggota:
1. Muhammad Derriel Ramadhan - 2406345186
2. Yafi Alifuddin - 2406437155
3. Angga Tri Setiawan - 2406350614
4. Rusydan Mujtaba Ibnu Ramadhan - 2406421081
5. Waldan Rafid - 2406346693

Sebuah platform web untuk destinasi olahraga es (ice skate, hockey, curling) premium yang menargetkan audiens di wilayah urban. Website ini berfungsi sebagai pusat digital untuk semua layanan, mulai dari pembelian e-ticket, penyewaan alat perlengkapan, pemesanan jasa coaching, reservasi experience package, hingga informasi seputar olahraga es, seperti tips dan trik bermain ice skate bagi pemula.

Daftar Modul
1. Authentication & User Management, Admin Dashboard
Modul ini adalah gerbang utama bagi pengguna, menangani semua proses terkait akun mulai dari registrasi, login, hingga manajemen profil. Selain itu, modul ini juga mencakup Admin Dashboard yang berfungsi sebagai pusat kendali bagi staf untuk mengelola seluruh data dan aktivitas di website. (Yafi)

2. Gear Rental
Modul ini menyediakan fungsionalitas e-commerce untuk penyewaan peralatan. Pengguna dapat menelusuri katalog gear yang tersedia, menggunakan filter untuk pencarian, memasukkan item ke keranjang sewa (cart), dan menyelesaikan transaksi melalui proses checkout yang simpel. (Derriel)

3. Arena Booking
Sebagai inti dari layanan, modul ini menawarkan sistem penjadwalan berbasis kalender yang interaktif. Pengguna dapat secara visual memeriksa ketersediaan slot waktu, memilih jadwal yang diinginkan, dan melakukan booking secara online dengan sistem yang otomatis mencegah penjadwalan ganda. (Waldan)

4. Experience Package & Event
Modul ini berfungsi sebagai papan pengumuman dan platform pendaftaran untuk berbagai kegiatan khusus, seperti kelas pelatihan atau acara komunitas. Pengguna dapat menemukan informasi detail mengenai setiap event dan melakukan pendaftaran (RSVP) langsung dari halaman tersebut. (Rusydan)

5. Community and Forum Module
Modul ini bertujuan membangun interaksi sosial antar pengguna melalui sebuah forum diskusi. Pengguna dapat memulai topik baru (post), berpartisipasi dalam diskusi dengan membalas (reply), dan memberikan apresiasi melalui fitur upvote untuk menciptakan komunitas yang aktif. (Angga)

Peran atau Aktor Pengguna Aplikasi:
1. Guest: Bisa melihat-lihat gear, event, arena. Tetapi, tidak bisa booking dan ikut mengisi forum komunitas
2. Customer: Sama dengan guest ditambah bisa booking arena, membeli gear, dan bisa mengisi forum komunitas, serta memiliki manajemen profil tersendiri
3. Seller: Sama dengan guest ditambah bisa membuat produk baru yang ingin dijual. Memiliki profil penjual tersendiri yang juga melihat list produk yang ia buat
4. Admin: Bisa melakukan semua hal yang bisa dilakukan semua pengguna, ditamah dengan dashboard admin tersendiri

Alur Pengintegrasian:

Aplikasi mobile The Rink terhubung langsung dengan backend web Django yang sudah dideploy di PWS. Flutter di sini berfungsi sebagai client, dia yang mengirim request HTTP ke endpoint backend lewat base URL PWS. Backend mengembalikan response dalam format JSON, lalu Flutter melakukan decoding dan mengubahnya menjadi model Dart. Dengan cara ini data akan lebih aman secara tipe (null-safety), lebih enak dikelola, dan lebih jelas saat dipakai untuk membangun tampilan UI di tiap fitur.

Untuk autentikasi, Flutter berkomunikasi dengan endpoint login dan register dari modul Authentication. Saat pengguna login atau registrasi lewat aplikasi, Flutter mengirim request ke backend dan jika berhasil akan menerima session/cookie sebagai bukti autentikasi. Session ini kemudian disimpan dan diproses oleh CookieRequest, sehingga request berikutnya otomatis membawa kredensial pengguna tanpa perlu login ulang. Dengan begitu, backend bisa membedakan apakah yang akses itu guest, customer, seller, atau admin berdasarkan status login dan role yang tersimpan di server.

Setelah user terautentikasi, tiap modul berjalan dengan pola integrasi yang serupa sesuai fungsinya. Di modul Gear Rental, Flutter mengambil daftar gear dari endpoint katalog lalu menampilkannya. Ketika user checkout penyewaan gear, Flutter mengirim request transaksi ke backend untuk diproses. Di modul Arena Booking, Flutter meminta data slot arena yang tersedia untuk ditampilkan (misalnya dalam kalender atau list). Saat user memilih jadwal, Flutter mengirim request booking dan backend akan mengecek terlebih dahulu agar tidak terjadi double booking sebelum menyimpan reservasi arena. Di modul Experience Package & Event, Flutter menampilkan daftar event/kelas dari endpoint event, lalu mengirim request pendaftaran ketika user join. Terakhir, di modul Community & Forum, Flutter mengambil data post dan reply, mengirim request untuk membuat post/reply baru, serta memanggil endpoint upvote untuk interaksi. Semua aksi di forum ini dibatasi hanya untuk pengguna yang sudah login.

Link Figma: https://www.figma.com/design/YBczn72Ok2p8p6iRfV51Re/The-RInk?node-id=0-1&t=FCiY8sKuNed8Obd9-1

Link Flutter: https://app.bitrise.io/app/c8dfaa2d-434c-4b08-9cd8-6bd19aa0e207/installable-artifacts/23b8acb3c55f037d/public-install-page/5d372876d58f0f6aa727c43bb30be5b0
