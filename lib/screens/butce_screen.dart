import 'package:flutter/material.dart';
import '../services/api_service.dart'; // JAVA KÖPRÜSÜNÜ BURAYA BAĞLADIK

class ButceScreen extends StatelessWidget {
  const ButceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Aylık Bütçem',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Mayıs 2026",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              // İŞTE FÜZEYİ ATEŞLEDİĞİMİZ YER!
              onPressed: () async {
                // Java'ya fırlatılacak test paketi
                Map<String, dynamic> testIslemi = {
                  "baslik": "Netflix Üyeliği",
                  "tutar": 120.0,
                  "kategori": "Eğlence",
                  "islemTipi": "GIDER",
                  "tarih": "2026-05-30"
                };

                // Füzeyi Java'ya fırlat!
                print("FLUTTER: Paket hazırlandı, Java'ya gönderiliyor...");
                bool basarili = await ApiService.islemEkle(testIslemi);
                
                if(basarili) {
                   print("FLUTTER: İşlem Java tarafından onaylandı!");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C4D3E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "İşlem Ekle",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ozetMetinGrup("Toplam Bütçe", "₺20.000"), // Burayı da yakında dinamik yapacağız
                      _ozetMetinGrup("Harcanan", "₺13.940"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.69,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "%69 kullanıldı",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // İŞTE CANLI VERİTABANI BAĞLANTIMIZ (SİHİR BURADA BAŞLIYOR)
            FutureBuilder<List<dynamic>>(
              future: ApiService.islemleriGetir(),
              builder: (context, snapshot) {
                // 1. Veri bekleniyorsa dönen yuvarlak ikon göster
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                // 2. Spring Boot kapalıysa veya hata varsa
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Sunucuya bağlanılamadı!\nBackend çalışıyor mu?", 
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade400)
                    )
                  );
                }

                // 3. Veritabanı boşsa
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Henüz hiç işlem girmediniz."),
                  );
                }

                // 4. Veriler başarıyla geldiyse listeyi çiz!
                var islemler = snapshot.data!;
                
                return ListView.builder(
                  shrinkWrap: true, // Ekranın kaydırma yapısını bozmaması için şart
                  physics: const NeverScrollableScrollPhysics(), // İç içe kaydırmayı engeller
                  itemCount: islemler.length,
                  itemBuilder: (context, index) {
                    var islem = islemler[index];
                    
                    // Kategoriye göre dinamik ikon ve renk belirleme
                    IconData ikon = Icons.receipt_long;
                    Color renk = Colors.blue;
                    
                    if(islem['kategori'] == 'Gıda') {
                      ikon = Icons.restaurant;
                      renk = Colors.orange;
                    } else if (islem['kategori'] == 'Eğlence') {
                      ikon = Icons.sports_esports;
                      renk = Colors.purple;
                    }

                    return _canliIslemSatiri(
                      ikon,
                      renk,
                      islem['baslik'], // "Gece Yarısı Kahvesi"
                      islem['kategori'], // "Gıda"
                      "₺${islem['tutar']}", // "₺95.0"
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _ozetMetinGrup(String baslik, String miktar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          baslik,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          miktar,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // Arkadaşının tasarımını koruyarak canlı veriye uyarladığımız yeni satır widget'ı
  Widget _canliIslemSatiri(
    IconData ikon,
    Color renk,
    String baslik,
    String kategori,
    String tutar,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: renk.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(ikon, color: renk, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baslik,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      kategori,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Text(
                  tutar,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}