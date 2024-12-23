
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/storage_constants.dart';


class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService() : _storage = const FlutterSecureStorage();

  Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> saveUserCredentials({
    required String userId,
    required String email,
    required String token,
  }) async {
    await saveSecureData(StorageConstants.keyUserId, userId);
    await saveSecureData(StorageConstants.keyUserEmail, email);
    await saveSecureData(StorageConstants.keyUserToken, token);
  }

  Future<Map<String, String?>> getUserCredentials() async {
    return {
      'userId': await getSecureData(StorageConstants.keyUserId),
      'email': await getSecureData(StorageConstants.keyUserEmail),
      'token': await getSecureData(StorageConstants.keyUserToken),
    };
  }
}