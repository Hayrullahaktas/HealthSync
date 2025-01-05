# HealthSync - Fitness ve Beslenme Takip Uygulaması

## Projenin Amacı ve Kapsamı
HealthSync, kullanıcıların fitness ve beslenme aktivitelerini takip etmelerine olanak sağlayan bir mobil uygulamadır.
https://drive.google.com/drive/folders/1TzST0WX6a02jAxE8z0Cl7-v89GfZmzR7

## Geliştirme Süreci ve Branch Stratejisi

### Branch Yapısı
- `main`: Ana branch
- `develop`: Main branch'inden türetilen geliştirme branch'i
- Feature branch'leri:
  - `develop-storage`: Storage ve Basic Data özellikleri
  - `develop-database`: Local Database özellikleri
  - `develop-ui`: Kullanıcı arayüzü özellikleri
  - `develop-api`: RESTful API
  - `develop-auth`: Authorization sistemi
  - `develop-notification`: Bildirim sistemi

### Geliştirme Süreci
#### Storage / Basic Data
- Storage servisi implementasyonu
  - SharedPreferences entegrasyonu
  - SecureStorage entegrasyonu
  - FileSystem işlemleri
- Basic Data yapısı
  - Model sınıfları
  - Utility fonksiyonları
- Storage Provider
  - State management
  - Veri işleme metodları

#### Local Database
- Veritabanı yapılandırması
  - SQLite entegrasyonu
  - Tablo şemalarının oluşturulması
- DAO katmanı implementasyonu
  - UserDao
  - ExerciseDao
  - NutritionDao
- Repository katmanı
  - CRUD operasyonları
  - Veri ilişkilendirme

#### UI
- Temel UI bileşenleri
  - Custom widgets
  - Tema yapılandırması
- Ana ekranlar
  - Dashboard
  - Statistics
  - Settings
- UI polish ve optimizasyon
  - Performans iyileştirmeleri
  - Hata düzeltmeleri

## Teknik Detaylar

### 1. Storage / Basic Data Implementasyonu
```dart
// Dosya Yapısı
lib/
├── core/
│   ├── constants/
│   │   └── storage_constants.dart    // Storage sabitleri
│   └── utils/
│       └── storage_utils.dart        // Yardımcı fonksiyonlar
└── data/
    ├── datasources/
    │   └── local/
    │       └── storage/
    │           ├── secure_storage.dart    // Güvenli depolama
    │           └── shared_prefs.dart      // Tercih yönetimi
    └── repositories/
        └── storage_repository.dart        // Storage repository
```

### 2. Local Database Implementasyonu
```dart
// Veritabanı Şeması
// app_database.dart
final users = '''
  CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    height REAL NOT NULL,
    weight REAL NOT NULL,
    age INTEGER NOT NULL,
    created_at TEXT NOT NULL
  )
''';

final exercises = '''
  CREATE TABLE exercises (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    duration INTEGER NOT NULL,
    calories_burned INTEGER NOT NULL,
    date TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id)
  )
''';

final nutrition = '''
  CREATE TABLE nutrition (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    food_name TEXT NOT NULL,
    calories REAL NOT NULL,
    protein REAL NOT NULL,
    carbs REAL NOT NULL,
    fat REAL NOT NULL,
    consumed_at TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id)
  )
''';
```

### 3. UI Implementasyonu
- Material Design 3 kullanımı
- Responsive tasarım
- State management (Provider)
- Custom widget'lar
- İstatistik grafikleri (fl_chart)


### 4. RESTful API Geliştirmesi

#### a. API İstemci Yapısı
- Performans odaklı bir istemci yapısı için Dio kütüphanesi entegre edilmiştir.
- ApiClient sınıfı ile API istek/yanıt döngüsü kolaylaştırılmıştır.

#### b. API Modelleri ve Servisler
- ApiResponse modeli ile API yanıtları yapılandırılmıştır.
- CRUD işlemleri için aşağıdaki servisler geliştirilmiştir:
  - ExerciseApi: Egzersiz yönetimi.
  - HealthMetricsApi: Sağlık verilerinin kaydı ve takibi.

#### c. Hata Yönetimi
- Sistem genelinde hata yönetimi için özel istisna sınıfları tanımlanmıştır:
  - NetworkException: Ağ bağlantısı hataları.
  - ServerException: Sunucu hataları.
  - ValidationException: Veri doğrulama hataları.
- Global hata yakalama mekanizması ile kullanıcı deneyimi iyileştirilmiştir.

#### d. Entegrasyon
- API sistemi mevcut model ve depolama çözümleriyle entegre edilmiştir.
- Repository Pattern ile veri yönetimi daha modüler hale getirilmiştir.

### 5. Authorization Sistemi

#### a. OAuth Entegrasyonu
- Google ve Facebook OAuth desteği ile kolay ve hızlı oturum açma sağlanmıştır.
- Güvenli yetkilendirme işlemleri başarıyla uygulanmıştır.

#### b. JWT Token Yönetimi
- JWT (JSON Web Token) kullanılarak güvenli bir oturum yönetimi oluşturulmuştur:
  - Token yenileme mekanizması ile oturum süresi uzatılmıştır.
  - Kullanıcı verilerinin güvenliği artırılmıştır.

#### c. Auth Provider
- Yetkilendirme işlemlerini kolaylaştıran Auth Provider sistemi geliştirilmiş ve entegre edilmiştir.

## 📂 Proje Yapısı

```
HealthSync/
├── lib/
│   ├── core/
│   │   ├── services/
│   │   │   ├── api_client.dart
│   │   │   ├── exercise_api.dart
│   │   │   ├── health_metrics_api.dart
│   │   ├── models/
│   │   │   ├── api_response.dart
│   │   ├── exceptions/
│   │   │   ├── network_exception.dart
│   │   │   ├── server_exception.dart
│   │   │   ├── validation_exception.dart
├── pubspec.yaml
└── README.md
```


### 6. Broadcast Receiver ve Bildirim Sistemi

#### a. Eklenen Dosyalar
- **notification_service.dart**: Bildirimlerin yönetimi için kullanılan servis sınıfı
- **notification_models.dart**: Bildirimlerin veri modellerini tanımlayan yapı
- **fitness_receiver.dart**: Fitness aktiviteleriyle ilgili bildirimlerin yönetildiği sınıf

#### b. Temel Özellikler
- **Egzersiz Bildirimleri**
  - Kullanıcının günlük egzersiz hedeflerini hatırlatan bildirimler
  - Aktivite takibi ve motivasyon mesajları

- **Hedef Tamamlama Bildirimleri**
  - Kullanıcının belirli hedeflere ulaştığında aldığı tebrik mesajları
  - Başarı rozetleri ve ödül bildirimleri

- **Hareketsizlik Uyarıları**
  - Uzun süre hareketsiz kalan kullanıcılar için hatırlatıcı uyarılar
  - Kişiselleştirilmiş aktivite önerileri

- **Zamanlanmış Bildirimler**
  - Kullanıcı tercihine göre önceden ayarlanmış zamanlarda gönderilen bildirimler
  - Özelleştirilebilir bildirim sıklığı ve içeriği

#### c. Teknik Detaylar
- **Awesome Notifications** entegrasyonu
  - Özelleştirilebilir bildirim desteği
  - Zengin medya içeriği desteği
  - İnteraktif bildirim aksiyonları

- **Android Bildirim Kanalları**
  - Önemli bildirimler için ayrı kanallar
  - Kullanıcı tercihleri doğrultusunda özelleştirilebilir kanal ayarları

- **Event-based Mimari**
  - Modüler bildirim sistemi
  - Kolay genişletilebilir yapı
  - Etkin olay yönetimi

## 📂 Projenin Yapısı

```plaintext
HealthSync/
├── lib/
│   ├── core/
│   │   ├── services/
│   │   │   ├── notification_service.dart
│   │   ├── models/
│   │   │   ├── notification_models.dart
│   │   ├── receivers/
│   │   │   ├── fitness_receiver.dart
```

## 💡 Kullanım Örnekleri

```dart
// Bildirim servisinin başlatılması
await NotificationService.initialize();

// Egzersiz bildirimi gönderme
await NotificationService.sendExerciseReminder(
  title: 'Egzersiz Zamanı!',
  body: 'Günlük hedefinize ulaşmak için 2000 adım kaldı.',
);

// Özel bildirim kanalı oluşturma
await NotificationService.createNotificationChannel(
  id: 'exercise_channel',
  name: 'Egzersiz Bildirimleri',
  description: 'Günlük egzersiz hatırlatmaları',
);
```

## 📝 Önemli Notlar

- Bildirim izinlerinin kullanıcıdan alınması gereklidir
- Android ve iOS platformları için farklı yapılandırmalar mevcuttur
- Arka plan servisleri için gerekli izinlerin manifest dosyasına eklenmesi gerekir

## 🔧 Geliştirici Notları

1. **Bildirim Kanalları**
  - Her bir bildirim türü için ayrı kanal oluşturulmalıdır
  - Kanal ayarları kullanıcı tarafından değiştirilebilir olmalıdır

2. **Performans Optimizasyonu**
  - Gereksiz bildirimlerden kaçınılmalıdır
  - Bildirim sıklığı kullanıcı deneyimini etkilemeyecek şekilde ayarlanmalıdır

3. **Platform Özellikleri**
  - Android ve iOS için platform-spesifik özellikler dikkate alınmalıdır
  - Her platform için ayrı test süreçleri yürütülmelidir

## Kurulum ve Geliştirme

### Gereksinimler
- Flutter SDK (3.0.0 veya üzeri)
- Dart SDK (3.0.0 veya üzeri)
- Android Studio / VS Code
- Git
- Gradle version : 8.3
### Kurulum Adımları
1. Flutter'ı yükleyin
```bash
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

2. Projeyi klonlayın
```bash
git clone https://github.com/username/health_sync.git
cd health_sync
```

3. Bağımlılıkları yükleyin
```bash
flutter pub get
```

4. Geliştirme ortamını hazırlayın
```bash
# Android Studio için
flutter config --android-studio-dir=<your_android_studio_path>

# iOS için
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### Build Alma
```bash
# Android için
flutter build apk

# iOS için
flutter build ios
```
