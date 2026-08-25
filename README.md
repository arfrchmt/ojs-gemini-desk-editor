# 🤖 Gemini Universal Desk Screener for OJS 3.3

**Gemini Universal Desk Screener** adalah plugin generik Open Journal Systems (OJS 3.3) yang mengotomatisasi proses **Desk Screening & Validasi Kepatuhan Template Manuskrip** menggunakan Google Gemini API.

Plugin ini memungkinkan pengelola jurnal/editor menentukan aturan pengecekan template (panjang judul, struktur abstrak, kata kunci, sitasi IEEE/APA, dan larangan bullet point) secara dinamis tanpa perlu mengubah baris kode program.

---

## 📸 Screenshots

### 1. Pengaturan Prompt & Validation Rules
Kustomisasi penuh aturan validasi template naskah langsung dari dashboard pengaturan plugin:

<p align="center">
  <img src="docs/screenshot3.png" alt="OJS Gemini Reviewer Preview" width="550">
</p>

---

### 2. Tombol Eksekusi di Submission Workflow
Tombol tindakan editorial langsung terintegrasi di halaman alur kerja naskah OJS:

<p align="center">
  <img src="docs/screenshot1.png" alt="OJS Gemini Reviewer Preview" width="550">
</p>


---

### 3. Modal Laporan Skor & Checklist Kepatuhan Template
Hasil evaluasi komprehensif menampilkan skor kelulusan, tabel checklist per elemen, serta draf email perbaikan siap kirim ke penulis:

<p align="center">
  <img src="docs/screenshot2.png" alt="OJS Gemini Reviewer Preview" width="550">
</p>


---

## ✨ Fitur Utama

- **Universal Prompt Rule Engine:** Tidak ada aturan yang di-hardcode. Semua instruksi evaluasi dapat diubah secara bebas melalui panel *Settings*.
- **Comprehensive Template Checklist:** Memvalidasi panjang judul, struktur abstrak, pemisah kata kunci, kepatuhan subheadings, larangan bullet point, dan gaya sitasi.
- **Score & Recommendation:** Memberikan skor kepatuhan (0–100) dan rekomendasi keputusan awal (*Pass*, *Minor Revision*, *Major Revision*, atau *Desk Decline*).
- **Ready-to-Send Author Feedback:** Menghasilkan catatan evaluasi profesional siap salin untuk dikirimkan kepada penulis.
- **Dual Persistent Storage:** Menyimpan konfigurasi prompt di database OJS (`plugin_settings`) serta file cadangan lokal (`prompt_rule.txt`).

---

## 🚀 Panduan Instalasi

### 1. Clone / Salin Berkas ke Direktori OJS
Letakkan folder plugin di path generic plugins OJS:
```bash
git clone [https://github.com/username/geminiDeskScreener.git](https://github.com/username/geminiDeskScreener.git) /var/www/pndpub/html/plugins/generic/geminiDeskScreener
