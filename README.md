# Brighter

MacBook Pro'nun yerleşik Liquid Retina XDR ekranında normal SDR parlaklık sınırının üstündeki HDR/EDR alanını kullanan küçük bir menü çubuğu uygulaması.

## Kurulum

```sh
brew install --cask developcu/apps/brighter
```

Alternatif olarak [GitHub Releases](https://github.com/developcu/brighter/releases/latest) sayfasından `Brighter.zip` dosyasını indirin, ZIP'i açıp `Brighter.app` dosyasını **Uygulamalar** klasörüne taşıyın.

**Gereksinimler:** Apple silicon, macOS 14 veya üzeri ve uyumlu yerleşik XDR ekran. 14 ve 16 inç Apple silicon MacBook Pro'nun Liquid Retina XDR ekranları desteklenen ekranlara örnektir. M1 işlemci tek başına yeterli değildir; harici ve SDR ekranlar desteklenmez.

[Homebrew kurulum, güncelleme ve yayın bilgileri](docs/homebrew.md).

## Kullanım

 Menü çubuğundaki güneş simgesinden **HDR parlaklığı artır** anahtarını açın ve kaydırıcıyla düzeyi ayarlayın. Uygulama her açılışta kapalı başlar; anahtarı kapatmak veya uygulamadan çıkmak normal parlaklığa döndürür. macOS'un kendi parlaklık ayarı ayrı çalışır; en yüksek etki için onu da artırın.

Paket kimliği `com.developcu.brighter`'dır. Bu uygulama Mac App Store dışında Developer ID ile dağıtılır. 9 Ekim 2026'da Apple noter onayı **Accepted** olarak doğrulandı. Onay bileti uygulamaya eklendi ve ZIP güncellendi. İmza, onay bileti ve Gatekeeper denetimleri başarılıdır. Paket Apple silicon (arm64) ve macOS 14 veya üzeri içindir; HDR artışı için desteklenen yerleşik XDR ekran gerekir.

## Derleme ve paketleme

macOS 14 veya üzeri ve Swift 6 destekleyen Xcode araçları gerekir. Paylaşılan Xcode projesi için uygulama simgesi kaynaklara dahildir; yeniden üretmek için `scripts/generate-icon.swift` kullanılabilir.

```sh
xcrun swift test
./scripts/build-app.sh
```

Paketleme betiği varsayılan olarak yerel kullanım için geçici imza atar. Developer ID ile dağıtım imzası için:

```sh
SIGN_IDENTITY='Developer ID Application: Ad Soyad (TAKIMKODU)' ./scripts/build-app.sh
```

Developer ID imzalı uygulamayı başka Mac'lere sorunsuz dağıtmak için Apple noter onayı gerekir. Bu depoda hesap bilgisi tutulmaz. `notarytool` kimlik bilgisi Keychain'e kaydedildikten sonra:

```sh
xcrun notarytool store-credentials brighter-notary --apple-id 'APPLE_ID_EPOSTANIZ' --team-id TAKIMKODUNUZ
NOTARY_PROFILE=brighter-notary ./scripts/notarize.sh
```

İlk komut uygulamaya özel Apple parolasını Terminal'de güvenli biçimde ister; parolayı depoya yazmayın. Betik ZIP'i Apple'a gönderir, başvuru kimliğini kaydeder ve onayı bekler. Bekleme süresi varsayılan olarak 10 dakikadır; `NOTARY_TIMEOUT=24h` ile uzatılabilir. Bekleme süresi dolarsa aynı komutu tekrar çalıştırmak aynı ZIP'in başvurusunu sürdürür. Onaydan sonra bileti `.app` üzerine ekler, ZIP'i günceller ve Gatekeeper denetimini çalıştırır.

## Sınırlar

Yalnızca EDR desteği bildiren yerleşik ekranda çalışır. Fiziksel panelin, güç yönetiminin veya ısı sınırlarının ötesine geçemez. EDR artışı pil tüketimini ve ekran ısısını yükseltebilir. Ekran görüntüsü ve ekran paylaşımı uygulamaları, katmanın etkisini görüntüde de gösterebilir.

Uygulama ekran kaydı veya erişilebilirlik izni istemez. Tasarım Apple'ın [EDR desteği](https://developer.apple.com/documentation/metal/determining-support-for-edr-values) ve [EDR Metal katmanı](https://developer.apple.com/documentation/metal/performing-your-own-tone-mapping) belgelerine dayanır.

## Kaynak ve hazır paket

GitHub Release v1.0.0 ve Homebrew, mevcut noter onaylı **doğrudan dağıtım build 1** paketini kurar. Kaynak kodunda ayrıca daha sonra eklenen Türkçe/İngilizce arayüz ve App Store sandbox paketleme hazırlıkları bulunur; bunlar mevcut ZIP'e dahil değildir. [Sürüm notları](docs/releases/1.0.0.md).

## Mac App Store

Ayrı sandbox sürümü **1.0.0 (2)**, 9 Ekim 2026'da incelemeye gönderildi. Gönderim sırasında durum **Waiting for Review** idi; bu kayıt güncel mağaza durumunu garanti etmez. Ücretsiz, Türkçe/İngilizce, Utilities ve 4+ olarak hazırlandı. App Store kimliği `6820998550`, paket kimliği `com.developcu.brighter`.

Çalışan `multiply` compositor preset adı belgelenmemiştir ve Apple inceleme notlarında açıklanmıştır. Sonraki macOS güncellemelerinde davranışı değişebilir.

Xcode'da `Brighter.xcodeproj` ve paylaşılan `Brighter` scheme'ini açın. Kendi Development Team'inizi ayarlayın. Komut satırından mevcut hesapla sandbox arşivi oluşturmak için:

```sh
ruby scripts/generate-xcode-project.rb
./scripts/archive-app-store.sh
```

Proje üreticisi için Ruby `xcodeproj` gem'i gerekir. Üretici ve export plist'lerinde bu projenin mevcut takım kimliği kullanılır; başka hesapla imzalamak için bu değerleri değiştirin.

[Destek](https://brighter-support.pages.dev/) · [Gizlilik](https://brighter-support.pages.dev/privacy/)
