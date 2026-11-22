--  Transaksi Bersih
DROP TABLE IF EXISTS transaksi_bersih;
CREATE TABLE transaksi_bersih AS
SELECT Invoice AS invoice,
       CAST(CAST("Customer ID" AS REAL) AS INTEGER) AS customer_id,
       DATE(InvoiceDate) AS tanggal,
       strftime('%Y-%m', InvoiceDate) AS bulan,
       CAST(Quantity AS INTEGER) * CAST(Price AS REAL) AS revenue
FROM online_retail_II
WHERE "Customer ID" IS NOT NULL AND "Customer ID" <> ''
  AND Invoice NOT LIKE 'C%'
  AND CAST(Quantity AS INTEGER) > 0
  AND CAST(Price AS REAL) > 0
  AND strftime('%Y-%m', InvoiceDate) <= '2011-11';
  
SELECT * FROM transaksi_bersih;

-- tabel retensi per cohort bulanan
DROP TABLE IF EXISTS retensi_cohort;
CREATE TABLE retensi_cohort AS
WITH cohort AS (
  SELECT customer_id, MIN(bulan) AS bulan_cohort
  FROM transaksi_bersih GROUP BY customer_id
),
aktivitas AS (
  SELECT DISTINCT customer_id, bulan FROM transaksi_bersih
),
gabung AS (
  SELECT c.bulan_cohort,
         (CAST(substr(a.bulan,1,4) AS INTEGER)*12 + CAST(substr(a.bulan,6,2) AS INTEGER))
       - (CAST(substr(c.bulan_cohort,1,4) AS INTEGER)*12 + CAST(substr(c.bulan_cohort,6,2) AS INTEGER)) AS bulan_ke,
         a.customer_id
  FROM aktivitas a JOIN cohort c USING (customer_id)
),
ukuran AS (
  SELECT bulan_cohort, COUNT(*) AS ukuran_cohort FROM cohort GROUP BY bulan_cohort
)
SELECT g.bulan_cohort, g.bulan_ke, u.ukuran_cohort,
       COUNT(DISTINCT g.customer_id) AS pelanggan_aktif,
       ROUND(100.0 * COUNT(DISTINCT g.customer_id) / u.ukuran_cohort, 1) AS retensi_persen
FROM gabung g JOIN ukuran u USING (bulan_cohort)
GROUP BY g.bulan_cohort, g.bulan_ke
ORDER BY g.bulan_cohort, g.bulan_ke;

SELECT * FROM retensi_cohort;

-- ringkasan rata-rata retensi
SELECT bulan_ke,
       COUNT(*) AS jumlah_cohort,
       ROUND(100.0 * SUM(pelanggan_aktif) / SUM(ukuran_cohort), 1) AS retensi_rata2
FROM retensi_cohort
WHERE bulan_cohort > '2009-12'
GROUP BY bulan_ke
HAVING COUNT(*) >= 3
ORDER BY bulan_ke;

-- Cohort
SELECT bulan_cohort,
       MAX(ukuran_cohort) AS ukuran_cohort,
       MAX(CASE WHEN bulan_ke=1  THEN retensi_persen END) AS m1,
       MAX(CASE WHEN bulan_ke=2  THEN retensi_persen END) AS m2,
       MAX(CASE WHEN bulan_ke=3  THEN retensi_persen END) AS m3,
       MAX(CASE WHEN bulan_ke=6  THEN retensi_persen END) AS m6,
       MAX(CASE WHEN bulan_ke=12 THEN retensi_persen END) AS m12
FROM retensi_cohort
GROUP BY bulan_cohort
ORDER BY bulan_cohort;

SELECT bulan_cohort,
       MAX(ukuran_cohort) AS ukuran_cohort,
       MAX(CASE WHEN bulan_ke=1  THEN retensi_persen END) AS m1,
       MAX(CASE WHEN bulan_ke=2  THEN retensi_persen END) AS m2,
       MAX(CASE WHEN bulan_ke=3  THEN retensi_persen END) AS m3,
       MAX(CASE WHEN bulan_ke=4  THEN retensi_persen END) AS m4,
       MAX(CASE WHEN bulan_ke=5  THEN retensi_persen END) AS m5,
       MAX(CASE WHEN bulan_ke=6  THEN retensi_persen END) AS m6,
       MAX(CASE WHEN bulan_ke=7  THEN retensi_persen END) AS m7,
       MAX(CASE WHEN bulan_ke=8  THEN retensi_persen END) AS m8,
       MAX(CASE WHEN bulan_ke=9  THEN retensi_persen END) AS m9,
       MAX(CASE WHEN bulan_ke=10 THEN retensi_persen END) AS m10,
       MAX(CASE WHEN bulan_ke=11 THEN retensi_persen END) AS m11,
       MAX(CASE WHEN bulan_ke=12 THEN retensi_persen END) AS m12
FROM retensi_cohort
WHERE bulan_cohort > '2009-12'   -- hapus baris ini kalau mau menampilkan cohort Des 2009
GROUP BY bulan_cohort
ORDER BY bulan_cohort;