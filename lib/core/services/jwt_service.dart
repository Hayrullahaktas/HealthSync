import 'package:jwt_decoder/jwt_decoder.dart';
import '../constants/auth_constants.dart';

class JwtService {
  // Token'ı decode et ve içindeki bilgileri al
  Map<String, dynamic> decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print('Token decode hatası: $e');
      return {};
    }
  }

  // Token'ın geçerlilik süresini kontrol et
  bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      print('Token süre kontrolü hatası: $e');
      return true; // Hatalı token'ı expired olarak değerlendir
    }
  }

  // Token'dan user ID'yi al
  String? getUserIdFromToken(String token) {
    try {
      final decodedToken = decodeToken(token);
      if (decodedToken.isEmpty) return null;
      return decodedToken[AuthConstants.userIdClaim]?.toString();
    } catch (e) {
      print('User ID alınamadı: $e');
      return null;
    }
  }

  // Token'dan email'i al
  String? getEmailFromToken(String token) {
    try {
      final decodedToken = decodeToken(token);
      if (decodedToken.isEmpty) return null;
      return decodedToken[AuthConstants.emailClaim]?.toString();
    } catch (e) {
      print('Email alınamadı: $e');
      return null;
    }
  }

  // Token'dan kullanıcı rollerini al
  List<String> getRolesFromToken(String token) {
    try {
      final decodedToken = decodeToken(token);
      if (decodedToken.isEmpty) return [];
      final roles = decodedToken[AuthConstants.rolesClaim] as List?;
      return roles?.cast<String>() ?? [];
    } catch (e) {
      print('Roller alınamadı: $e');
      return [];
    }
  }

  // Token'ın geçerlilik süresini al
  DateTime? getTokenExpirationDate(String token) {
    try {
      return JwtDecoder.getExpirationDate(token);
    } catch (e) {
      print('Token süresi alınamadı: $e');
      return null;
    }
  }

  // Token'ın yenilenme zamanı gelmiş mi kontrol et
  bool shouldRefreshToken(String token, {Duration threshold = const Duration(minutes: 5)}) {
    try {
      final expirationDate = getTokenExpirationDate(token);
      if (expirationDate == null) return true;

      final now = DateTime.now();
      final difference = expirationDate.difference(now);
      return difference <= threshold;
    } catch (e) {
      print('Token yenileme kontrolü hatası: $e');
      return true; // Hata durumunda token'ı yenilemeyi öner
    }
  }
}