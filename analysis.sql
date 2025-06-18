-- Analisis RFM dengan Segmentasi Pelanggan
WITH reference AS (
    SELECT MAX(order_date) AS max_date FROM e_commerce_transactions
),
rfm_data AS (
    SELECT 
        customer_id,
        DATEDIFF((SELECT max_date FROM reference), MAX(order_date)) AS recency,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(payment_value) AS monetary
    FROM e_commerce_transactions
    GROUP BY customer_id
),
rfm_score AS (
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM rfm_data
),
rfm_combined AS (
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        ROUND((f_score + m_score) / 2) AS fm_score
    FROM rfm_score
),
rfm_segment AS (
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        fm_score,
        CASE 
            WHEN r_score IN (4,5) AND fm_score IN (4,5) THEN 'Champions'
            WHEN (r_score = 5 AND fm_score = 2) 
                OR (r_score = 4 AND fm_score = 2) 
                OR (r_score = 3 AND fm_score = 3) 
                OR (r_score = 4 AND fm_score = 3) THEN 'Potential Loyalists'
            WHEN (r_score = 5 AND fm_score = 3) 
                OR (r_score = 4 AND fm_score = 4) 
                OR (r_score = 3 AND fm_score = 5) 
                OR (r_score = 3 AND fm_score = 4) THEN 'Loyal Customers'
            WHEN r_score = 5 AND fm_score = 1 THEN 'Recent Customers'
            WHEN r_score IN (3,4) AND fm_score = 1 THEN 'Promising'
            WHEN (r_score = 3 AND fm_score = 2) 
                OR (r_score = 2 AND fm_score = 3) 
                OR (r_score = 2 AND fm_score = 2) THEN 'Customers Needing Attention'
            WHEN (r_score = 2 AND fm_score = 5) 
                OR (r_score = 2 AND fm_score = 4) 
                OR (r_score = 1 AND fm_score = 3) THEN 'At Risk'
            WHEN r_score = 1 AND fm_score IN (4,5) THEN 'Cant Lose Them'
            WHEN r_score = 1 AND fm_score = 2 THEN 'Hibernation'
            WHEN r_score = 1 AND fm_score = 1 THEN 'Lost'
            ELSE 'Others'
        END AS segment
    FROM rfm_combined
)
SELECT * FROM rfm_segment;

-- ========================================================================
-- Analisis Repeat-Purchase Bulanan
SELECT 
    YEAR(order_date) AS tahun,
    MONTH(order_date) AS bulan,
    COUNT(DISTINCT customer_id) AS total_pelanggan,
    SUM(CASE WHEN jumlah_transaksi > 1 THEN 1 ELSE 0 END) AS pelanggan_repeat,
    ROUND(
        SUM(CASE WHEN jumlah_transaksi > 1 THEN 1 ELSE 0 END) / 
        COUNT(DISTINCT customer_id) * 100, 2
    ) AS persentase_repeat
FROM (
    SELECT 
        customer_id,
        order_date,
        COUNT(order_id) AS jumlah_transaksi
    FROM e_commerce_transactions
    GROUP BY customer_id, YEAR(order_date), MONTH(order_date)
) bulanan
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY tahun, bulan;

-- ========================================================================
-- Penjelasan Query Repeat-Purchase
EXPLAIN
SELECT 
    YEAR(order_date) AS tahun,
    MONTH(order_date) AS bulan,
    COUNT(DISTINCT customer_id) AS total_pelanggan,
    SUM(CASE WHEN jumlah_transaksi > 1 THEN 1 ELSE 0 END) AS pelanggan_repeat
FROM (
    SELECT 
        customer_id,
        order_date,
        COUNT(order_id) AS jumlah_transaksi
    FROM e_commerce_transactions
    GROUP BY customer_id, YEAR(order_date), MONTH(order_date)
) bulanan
GROUP BY YEAR(order_date), MONTH(order_date);