# Outline & Roadmap: Harness Engineering Article

**Title:** Harness Engineering: Designing Codebases for the Agent-First Era  
**Target File:** `_WIP/2026-08-24_article_harness_engineering.md`  
**Tone:** First-person, builder-first, craftsmanship & systems-oriented (ala Mitchell Hashimoto / Brandur Leach)

---

## Daftar Isi & Poin Bahasan (Article Roadmap)

### 1. Pembuka: Realita AI Coding & Lahirnya Kebutuhan Harness `[DONE]`
- [x] **Euforia awal vs bumerang erosi arsitektur:** Kecepatan tinggi di awal berujung pada waktu yang habis untuk membersihkan *architectural leaks*, dependency liar, dan duplikasi mikro.
- [x] **Kegagalan solusi teks/prompt:** Mengapa menambah panduan panjang di `AGENTS.md` atau system prompt gagal ketika context window penuh dan task makin rumit (model memilih *path of least resistance*).
- [x] **Titik balik (Discovery):** Menemukan diskursus engineer di X dan artikel OpenAI tentang *Harness Engineering* (prinsip *Human steers, AI executes*).
- [x] **Definisi inti Harness:** Mengubah repositori dari "tempat pasif penyimpan file" menjadi "lingkungan aktif berpagar mekanis".

---

### 2. Apa itu Harness Engineering? (The Mental Model) `[DONE]`
- [x] **Analogi & Filosofi:** Bukan cuma buat satu stack, tapi disiplin universal di Mobile, Frontend, dan Backend agar AI nggak ngalor-ngidul.
- [x] **Diagram 4 Komponen:** Scope Controls, Mechanical Sensors, Independent Ground Truth, dan Unified Verification.

---

### 3. Lapisan 1: Otoritas & Batasan Tugas (Execution Plans sebagai Kontrak Mesin) `[DONE]`
- [x] **Masalah Scope Creep:** AI ngubah global config atau schema db saat dikasih task login.
- [x] **Execution Plan sebagai Task Contract:**
  - `allowed_paths`: Daftar spesifik file/folder yang boleh disentuh.
  - `allowed_actions`: Pemisahan izin `edit`, `verify`, `commit`, `push`.
  - `risk_ceiling` & `repair_budget`: Menjaga AI agar tidak infinite loop.
- [x] **Dua Bagian Dokumen:** Metadata atas untuk parsing mesin/CLI, dan bodi bawah untuk AI planning & human review.

---

### 4. Lapisan 2: Menjaga Arsitektur Secara Mekanis (Architectural & Anti-Entropy Sensors) `[DONE]`
- [x] **POV Old-School vs AI Era:** Review manual oleh senior engineer jadi bottleneck saat velocity tinggi.
- [x] **4 Pendekatan Sensor Mekanis:**
  - Boundary & Layer Lints (Custom AST lints, ESLint, Dependency-Cruiser).
  - Design Token & UI Governance (Larang raw hex, raw font, raw widget, paksa i18n).
  - Duplication Sensors (`jscpd` untuk cegah helper kembar).
  - Smells & Drift Checkers.
- [x] **Diagnostics as Prompt:** Pesan error linter otomatis mendidik AI melakukan *self-correction*.

---

### 5. Lapisan 3: Menghindari Jebakan "Test Buatan AI" (Behavioral Oracles & API Contracts) `[DONE]`
- [x] **Jebakan "Test-Oracle Circularity":** AI salah paham requirement -> AI nulis kode salah -> AI nulis unit test yang memvalidasi kesalahan logikanya itu sendiri -> Test hijau, tapi fitur rusak di produksi.
- [x] **Pinned OpenAPI Snapshot & Lockfile (`docs/contracts/openapi/`):**
  - Mobile menyimpan snapshot kontrak backend dengan SHA-256 lockfile (`backend.openapi.lock.json`).
  - AI dan CI bisa memvalidasi endpoint dan DTO secara independen tanpa tergantung server backend yang sedang aktif (Zero codegen).
- [x] **Behavioral Oracles Registry (`harness/oracles.yaml`):**
  - Menetapkan kriteria dan test penerimaan (*acceptance test*) yang sudah terdaftar sebelum AI mulai menulis kode.
  - Task berisiko tinggi wajib mengaitkan oracle resmi (misal: tes integrasi auth/startup) yang dikunci di luar `allowedPaths`.
  - Menempatkan human review sebagai final gate yang jujur untuk UI visual.

---

### 6. Lapisan 4: Memerangi Entropi & Duplikasi (Duplication Sensors) `[DONE]`
- [x] **Kelemahan Bawaan AI:** Kecenderungan menulis fungsi helper lokal baru (date formatter, error mapper, string parser) daripada mencari fungsi yang sudah ada di core.
- [x] **Sensor Klon Kode (`jscpd` + CLI Filtering):**
  - Profil `core`: Memindai duplikasi logika mapper, model translator, dan workflow tails.
  - Profil `small-helpers`: Memindai duplikasi helper kecil formatting.
  - Profil `presentation`: Memindai duplikasi boilerplate UI (self-review).
  - Integrasi allowlist per profil (`duplication/*_allowlist.json`) dan laporan kelompok pasangan file (actionable duplicate groups).

---

### 7. Lapisan 5: Satu Pintu Verifikasi yang Jujur (Single CLI & Verification Profiles) `[DONE]`
- [x] **Masalah Banyak Perintah Bash:** AI bingung jika harus menebak kombinasi `flutter test`, `build_runner`, `dart fix`, `gen-l10n`.
- [x] **Satu CLI Khusus Repositori (`mobilekit`):**
  - *Profile Fast:* Inner loop cepat saat coding (~1 menit).
  - *Profile Full:* Verifikasi pre-merge komprehensif (semua test, codegen check, linter, duplikasi).
  - *Profile CI:* Parity 100% antara verifikasi lokal dan GitHub Actions CI.
- [x] **Menolak Skip Flags:** Profil eksplisit menolak opsi seperti `--skip-tests` atau `--skip-format`, sehingga AI tidak bisa "memalsukan" status lolos.
- [x] **Expanded CLI Commands & Infinity Gauntlet Analogy:** Pusat kendali repositori untuk scaffolding, runtime evidence, task verification, dan auto-fixes.

---

### 8. Penutup: Rekap & Jembatan ke Depan `[DONE]`
- [x] **Feedforward vs Feedback:** Sintesis bahwa teks/panduan (`AGENTS.md`, OpenAPI) memberi arah di awal (*feedforward*), sedangkan pagar mekanis (linter, oracles, `jscpd`, CLI) memaksa koreksi mandiri (*feedback*).
- [x] **Pesan Utama:** *"Berhenti buang waktu bikin prompt 2.000 kata; mulailah meng-engineer repositorimu."*
- [x] **Pemberhentian Human Reviewer:** *"Semakin terasa boring fase review, maka dari situ kita tahu bahwa sistem otomatis yang kita buat sudah berjalan dengan baik."*
- [x] **Tahap Berikutnya:** Menjembatani Harness Engineering menuju *Loop Engineering* (task state machines, bounded repair loops, cryptographic handoff challenges, multi-agent coordination).
