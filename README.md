# Demonica Tool 2.5

**Demonica Tool 2.5** adalah sebuah script shell yang menyediakan beberapa metode enkripsi untuk melindungi file script. Tool ini dirancang untuk lingkungan Termux atau Linux dan mendukung beberapa mode enkripsi, yaitu:

- **Enkripsi EVAL**  
  Mengubah file script menjadi Base64 yang kemudian dieksekusi melalui perintah `eval` setelah didekode.

- **Enkripsi XOR (32-byte key) dengan Progress Real-Time**  
  Menggunakan enkripsi XOR dengan kunci 32-byte untuk mengamankan file. Proses enkripsi menampilkan progress bar real-time dengan warna.

- **Enkripsi SHC**  
  Mengompilasi file script menggunakan `shc` sehingga menghasilkan binary.

- **Enkripsi DEMONIC (Berlapis)**  
  Metode berlapis yang menggabungkan Base64, obfuscation (menggunakan `bash-obfuscate`), dan kompilasi dengan `shc` untuk perlindungan ekstra.

## Fitur Utama

- **Multi Mode Encryption:**  
  Pilih metode enkripsi sesuai kebutuhan.

- **Progress Bar Real-Time:**  
  Pada mode XOR, terdapat progress bar berwarna yang menginformasikan status enkripsi secara real-time.

- **Instalasi Otomatis Dependensi:**  
  Script ini akan menginstall dependensi seperti `coreutils`, `bash-obfuscate`, `shc`, `rustc`, dan `git` (jika belum terpasang).

- **Pengaturan Izin Otomatis:**  
  Semua folder dan file yang dibuat oleh tool ini akan diatur permission-nya agar siap digunakan.

## Prasyarat

Pastikan Anda telah menginstal aplikasi [Termux](https://f-droid.org/id/packages/com.termux/) (untuk pengguna Android) atau memiliki akses ke terminal Linux. Tool ini memerlukan:
- **coreutils** (untuk `realpath` dan `sha256sum`)
- **Node.js** dan **bash-obfuscate**
- **shc**
- **Rust** (untuk kompilasi dekripsi XOR)

## Instalasi & Setup

1. **Clone Repository**  
   Buka Termux atau terminal Anda, lalu clone repository:
   ```bash
   git clone https://github.com/DEMONICCA/Demonica-Tool.git
   cd demonica-tool && bash wongbrebes.sh

> [![Telegram URL](https://img.shields.io/badge/Telegram-Join-2CA5E?style=social&logo=telegram)](https://t.me/modulkuntul)
> <img src="https://github.com/Anmol-Baranwal/Cool-GIFs-For-GitHub/assets/74038190/34376b0e-4ae2-4278-9d3d-82e8016a87d6" width="40">&nbsp;
> 
> [![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/illumi666)
> <img src="https://raw.githubusercontent.com/innng/innng/master/assets/kyubey.gif" height="30" />
<hr/>
