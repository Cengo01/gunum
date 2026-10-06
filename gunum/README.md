# Günüm — Kurulum (Windows)

## 1) Web/PWA sürümü (ücretsiz, hemen)
1. github.com'da ücretsiz hesap aç. "New repository" → adı `gunum`, Public.
2. "Add file → Upload files": bu klasördeki index.html, manifest.json, sw.js, hadis.json ve icon-*.png dosyalarını yükle (widget klasörü şart değil).
3. Settings → Pages → Branch: main / root → Save. 1-2 dk sonra adres: https://KULLANICI_ADIN.github.io/gunum/
4. iPhone'da SAFARİ ile aç → Paylaş → "Ana Ekrana Ekle". Sonra bir kez internetle açıp kapat; çevrimdışı önbellek o zaman oluşur.
5. Bilgisayarda test: klasörde `python -m http.server 8000` → http://localhost:8000

## 2) Bildirim gerçekleri
- iOS'ta bildirim yalnızca Ana Ekrana eklenmiş PWA'da, iOS 16.4+ ile ve izin verilirse çalışır.
- Bu sürümde hatırlatıcılar UYGULAMA AÇIKKEN tetiklenir. Kapalıyken güvenilir alarm için sunucudan Web Push (kurulum gerektirir) veya yerel iOS uygulaması lazım. Kritik işler için iPhone'un Saat/Hatırlatıcılar uygulamasını da kullan.
- Konum yalnızca namaz vakti için, butona basınca istenir. Namaz vakitleri api.aladhan.com'a gönderilir (konum/şehir bilgisi bu servise gider).

## 3) Kilit ekranı widget'ı (yerel iOS gerekir)
Web uygulaması kilit ekranı widget'ı ekleyemez. `widget/GunumWidget.swift` bir WidgetKit eklentisidir; hadis.json'u yukarıdaki GitHub Pages adresinden çeker (aynı formülle günü seçer).
- Windows'ta yapabileceklerin: dosyaları düzenlemek, hadis.json'u güncellemek.
- Derlemek için macOS + Xcode gerekir (Mac yoksa Codemagic gibi bulut Mac servisleri veya kiralık Mac). Cihaza kurmak için Apple Developer hesabı gerekir; ücretsiz kişisel imza kısa süreli ve kısıtlıdır, ücretli üyelik yıllıktır (güncel fiyatı Apple'dan kontrol et).
- Xcode: File → New → Project → App ("Gunum"); sonra File → New → Target → Widget Extension; şablon dosyayı GunumWidget.swift ile değiştir, `hadisURL` adresini düzelt.
- Bu Swift kodu Linux'ta derlenemediği için DERLENMEDİ ve test edilmedi.

## Ücretsiz / ücretli
Ücretsiz: GitHub Pages, Aladhan API (kullanım sınırı için sitesine bak). Ücretli olabilir: Apple Developer, Mac bulut derleme.

## 4) Yapay zekâ sohbeti (Cloudflare Workers AI, ücretsiz plan)
Ücretsiz plan: günde 10.000 Neuron (00:00 UTC'de sıfırlanır), kredi kartı gerekmez. Büyük modelde günde kabaca 80 kısa cevap. Limit dolarsa o gün sohbet durur; diğer özellikler çalışır. Limitler değişebilir: developers.cloudflare.com/workers-ai/platform/pricing
1. dash.cloudflare.com → ücretsiz hesap aç.
2. Workers & Pages → Create → "Hello World" şablonu → ad: `gunum-ai` → Deploy → Edit code.
3. Açılan koddaki her şeyi sil, `worker.js` içeriğini yapıştır → Deploy.
4. Worker → Settings → Bindings → Add → Workers AI → değişken adı: `AI` → kaydet.
5. (Önerilir, ilk testten sonra) Settings → Variables → `ALLOWED_ORIGIN` = https://KULLANICI_ADIN.github.io (sonunda / ve yol olmadan). Böylece yalnızca senin siten kullanabilir.
6. Worker adresini (https://gunum-ai.XXXX.workers.dev) kopyala → Günüm → Ayarlar → Yapay zekâ kutusuna yapıştır.
Gizlilik: yazdıkların ve bugünkü görev başlıkların Cloudflare'a gider. API anahtarı yoktur; uygulama kodunda gizli bilgi bulunmaz. Adres herkese açık olduğundan başkası bulursa günlük limitini tüketebilir; bu yüzden 5. adımı yap.
