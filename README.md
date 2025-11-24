# 🚀 Mobile Project Development Plan

**Project Status:** Planning Phase

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
Aplikasi mobile The Rink terintegrasi dengan backend web Django yang telah dideploy di PWS. Flutter berperan sebagai client yang mengirim request HTTP ke endpoint backend menggunakan base URL dari PWS. Setiap response dari backend dikembalikan dalam format JSON, kemudian Flutter melakukan decoding dan memetakan data tersebut ke model Dart agar aman secara tipe data (null-safety) dan mudah dikelola. Data yang sudah menjadi objek model lalu digunakan sebagai sumber tampilan UI pada setiap halaman fitur.

Proses autentikasi dilakukan melalui endpoint login dan register yang disediakan oleh modul Authentication. Ketika pengguna melakukan login atau registrasi dari Flutter, aplikasi mengirim request ke endpoint backend dan menerima session/cookie sebagai tanda autentikasi berhasil. Session ini disimpan dan dikelola oleh CookieRequest sehingga request berikutnya otomatis membawa kredensial pengguna tanpa perlu login ulang. Dengan cara ini, backend dapat membedakan akses antara guest, customer, seller, dan admin berdasarkan status login serta role pengguna yang tersimpan di server.

Setelah autentikasi, integrasi fitur berjalan sesuai modul masing-masing. Pada modul Gear Rental, Flutter mengambil daftar gear dari endpoint katalog, menampilkannya ke pengguna, lalu mengirim request transaksi (checkout) saat pengguna menyelesaikan penyewaan. Pada modul Arena Booking, Flutter meminta data slot ketersediaan arena dari backend untuk ditampilkan dalam bentuk kalender atau daftar booking, kemudian mengirim request booking ketika pengguna memilih jadwal tertentu dan backend memvalidasi agar tidak terjadi double booking sebelum menyimpan data reservasi. Pada modul Experience Package & Event, Flutter menampilkan daftar event/kelas yang diambil dari endpoint event, lalu mengirim request ketika pengguna mendaftar. Pada modul Community & Forum, Flutter mengambil daftar post dan reply dari endpoint forum, mengirim request membuat post/reply baru, serta memanggil endpoint upvote untuk interaksi komunitas dan seluruh aksi ini hanya dapat dilakukan oleh pengguna yang sudah login saja.

Secara keseluruhan, alur integrasi dilakukan dengan pola -> Flutter memanggil endpoint untuk membaca data (GET), memproses JSON menjadi model, lalu menampilkan ke UI, sedangkan untuk aksi pengguna (POST/PUT/READ/DELETE), Flutter mengirimkan data input ke backend, backend memvalidasi dan menyimpan ke database, kemudian mengembalikan status sukses/gagal yang diterjemahkan Flutter menjadi notifikasi atau pembaruan tampilan. Dengan arsitektur ini, aplikasi mobile dan web berbagi satu sumber data yang sama, sehingga seluruh informasi pengguna, transaksi, booking, event, dan forum tetap sinkron antara Flutter dan PWS.

Link Figma: https://www.figma.com/design/YBczn72Ok2p8p6iRfV51Re/The-RInk?node-id=0-1&t=FCiY8sKuNed8Obd9-1

