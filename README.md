**# health_sync

Kocaeli Üniversitesi Bilgisayar Mühendisliği Mobil Programlama dersi projesi


# HealthSync - Fitness ve Beslenme Takip Uygulaması

## Projenin Amacı ve Kapsamı
HealthSync, kullanıcıların fitness ve beslenme aktivitelerini takip etmelerine olanak sağlayan bir mobil uygulamadır.
## Geliştirme Süreci ve Kuralları

### Branch Yapısı
- `main`: Ana branch
- `develop`: Main branch'inden türetilen geliştirme branch'i
- Feature branch'leri:
    - `develop-storage`: Storage ve Basic Data özellikleri
    - `develop-database`: Local Database özellikleri
    - `develop-ui`: Kullanıcı arayüzü özellikleri

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
