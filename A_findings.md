1. Nilai Negatif pada decoy_noise
   Terdapat 15 transaksi dengan decoy_noise negatif (contoh: order_id 101022, 101116), padahal payment_value positif. Seharusnya decoy_noise non-negatif.

2. Selisih Ekstrem antara payment_value dan decoy_noise
   Terdeteksi 500 anomali dengan selisih signifikan antara decoy_noise dan payment_value, melebihi ambang batas 74.98 (contoh: order_id 101033, 101113). Pada order_id 101033: payment_value = 611.16, decoy_noise = 727.26 (selisih 116.1).
