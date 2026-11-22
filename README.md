# Analisis Cohort dan Retensi

Analisis cohort bulanan dan retensi pelanggan sebuah toko online grosir, ditulis dengan SQL (SQLite). Project ini menjawab satu pertanyaan: **berapa persen pelanggan baru yang kembali berbelanja pada bulan-bulan berikutnya, dan apakah cohort yang lebih baru lebih baik daripada yang lama?**

Penulis: Hasta Budiawan

## Dataset

[Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii) dari UCI Machine Learning Repository: transaksi sebuah toko online asal Inggris dari Desember 2009 sampai Desember 2011 (1.067.371 baris). Cek halaman dataset untuk lisensi dan ketentuannya.

File CSV mentahnya sekitar 95 MB, jadi **tidak disertakan** di repository ini. Unduh dari tautan di atas dan letakkan di folder `data/`.

## Pertanyaan bisnis

1. Berapa persen pelanggan yang masih berbelanja pada bulan ke-1, ke-3, ke-6, dan ke-12?
2. Apakah kualitas pelanggan dari cohort terbaru membaik?
3. Pada bulan ke berapa pelanggan paling banyak berhenti?

## Metode

1. **Membersihkan data** (`transaksi_bersih`): buang baris tanpa Customer ID (243.007), invoice pembatalan (berawalan "C"), baris dengan Quantity atau Price nol atau negatif, dan Desember 2011 (data hanya sampai tanggal 9, jadi bulannya belum lengkap). Tersisa 788.244 baris dari 5.850 pelanggan.
2. **Membuat cohort**: tiap pelanggan masuk ke cohort bulan pembelian pertamanya. Pelanggan dianggap *aktif* di suatu bulan jika melakukan minimal satu transaksi valid di bulan itu.
3. **Menghitung retensi** (`retensi_cohort`): persentase anggota tiap cohort yang masih aktif pada bulan ke-0, 1, 2, dan seterusnya.
4. **Meringkas**: rata-rata retensi per bulan (dibobot ukuran cohort) dan tabel pivot (cohort per bulan) untuk heatmap.

Cohort Desember 2009 dikeluarkan dari rata-rata dan perbandingan, karena berisi pelanggan lama yang baru terlihat pertama kali di dataset sehingga angkanya terlalu tinggi. Analisis mencakup 4.895 pelanggan dalam 23 cohort (Januari 2010 sampai November 2011).

## Hasil

| Bulan sejak pembelian pertama | 1 | 3 | 6 | 12 |
|---|---|---|---|---|
| Rata-rata retensi | 21,0% | 20,9% | 18,3% | 18,4% |

- Sekitar **79%** pelanggan baru tidak berbelanja lagi di bulan berikutnya. Ini penurunan terbesar.
- Setelah bulan ke-1, retensi turun perlahan sampai sekitar 13-14% di bulan ke-10 dan ke-11.
- **Cohort yang lebih baru lebih baik di bulan pertama**: cohort pertengahan 2010 berkisar 15-20%, sedangkan cohort September dan Oktober 2011 mencapai 27,0% dan 32,1%.
- **Musiman**: retensi dipengaruhi bulan kalender, bukan hanya umur cohort. Cohort September sampai November 2010 naik ke 19-26% di bulan ke-12 karena bulan itu jatuh di musim belanja akhir tahun 2011. Kenaikan di bulan ke-12 jangan ditafsirkan sebagai "retensi naik setelah setahun".

Rekomendasi: fokus pada **pembelian kedua dalam 30 hari pertama** (pengingat dan penawaran khusus untuk pelanggan baru, diuji dengan A/B test), dan siapkan pendekatan terpisah untuk pelanggan yang datang di musim ramai akhir tahun.

## Keterbatasan

- Hanya satu retailer di Inggris dengan data dua tahun, jadi hasilnya belum tentu berlaku untuk bisnis lain.
- Bulan ke-12 ke atas dihitung dari sedikit cohort sehingga kurang stabil.
- Cohort Desember 2010 kecil (76 pelanggan), jadi angkanya mudah berfluktuasi.
- "Aktif" berarti melakukan pembelian. Data tidak memuat kunjungan, jadi penyebab pelanggan berhenti tidak bisa dipastikan, dan penjelasan musiman hanya dugaan.

## Cara menjalankan

Membutuhkan [DB Browser for SQLite](https://sqlitebrowser.org/).

1. **File → New Database**, misalnya `cohort_retensi.db`.
2. **File → Import → Table from CSV file**, pilih `online_retail_II.csv`, centang *Column names in first line*, dan beri nama tabel `online_retail_II`. Lalu **Write Changes** (Ctrl+S).
3. Buka tab **Execute SQL**, muat `sql/cohort_retensi.sql`, lalu jalankan querynya satu per satu (Shift+F5 menjalankan statement yang sedang dipilih).
4. Opsional: ekspor tiap hasil dengan *Save the results view → Export to CSV*.

## Tools

SQL, SQLite, CTE
