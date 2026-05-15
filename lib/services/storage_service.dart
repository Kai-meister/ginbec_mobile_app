import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyUserEmail = 'user_email';
  static const _keyUserName = 'user_name';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccessToken);

  Future<String?> getRefreshToken() =>
      _storage.read(key: _keyRefreshToken);

  Future<void> saveUserId(int userId) =>
      _storage.write(key: _keyUserId, value: userId.toString());

  Future<int?> getUserId() async {
    final val = await _storage.read(key: _keyUserId);
    return val == null ? null : int.tryParse(val);
  }

  Future<void> saveUserEmail(String email) =>
      _storage.write(key: _keyUserEmail, value: email);

  Future<String?> getUserEmail() =>
      _storage.read(key: _keyUserEmail);

  Future<void> saveUserName(String name) =>
      _storage.write(key: _keyUserName, value: name);

  Future<String?> getUserName() =>
      _storage.read(key: _keyUserName);

  Future<void> clearAll() => _storage.deleteAll();
}