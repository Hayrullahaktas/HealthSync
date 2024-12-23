import 'package:jwt_decoder/jwt_decoder.dart';
import '../constants/auth_constants.dart';

class JwtService {
  // Token'ı decode et ve içindeki bilgileri al
  Map<String, dynamic> decodeToken(String token) {
    return JwtDecoder.decode(token);
  }

  // Token'ın geçerlilik süresini kontrol et
  bool isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  // Token'dan user ID'yi al
  String? getUserIdFromToken(String token) {
    try {
      final decodedToken = decodeToken(token);
      return decodedToken[AuthConstants.userIdClaim]?.toString();
    } catch (e) {
      return null;
    }
  }

  // Token'dan email'i al
  String? getEmailFromToken(String token) {
    try {
      final decodedToken = decodeToken(token);
      return decodedToken[AuthConstants.emailClaim]?.toString();
    } catch (e) {
      return null;
    }
  }

  // Token'dan kullanıcı rollerini al
  List<String> getRolesFromToken(String token) {
    try {
      final decodedToken = decodeToken(token);
      final roles = decodedToken[AuthConstants.rolesClaim] as List?;
      return roles?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }

  // Token'ın geçerlilik süresini al
  DateTime? getTokenExpirationDate(String token) {
    return JwtDecoder.getExpirationDate(token);
  }

  // Token'ın yenilenme zamanı gelmiş mi kontrol et
  bool shouldRefreshToken(String token, {Duration threshold = const Duration(minutes: 5)}) {
    final expirationDate = getTokenExpirationDate(token);
    if (expirationDate == null) return true;

    final now = DateTime.now();
    final difference = expirationDate.difference(now);
    return difference <= threshold;
  }
}