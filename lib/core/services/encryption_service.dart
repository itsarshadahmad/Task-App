import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class EncryptionService {
  final String userId;
  final SharedPreferences prefs;

  EncryptionService({
    required this.userId,
    required this.prefs,
  });

  static const String _encryptionKey = 'encryption_key';
  static const String _ivKey = 'encryption_iv';

  Future<String> _getEncryptionKey() async {
    final key = prefs.getString('$_encryptionKey$userId');
    if (key != null) return key;
    
    // Generate new key
    final newKey = Key.fromSecureRandom(32).base64;
    await prefs.setString('$_encryptionKey$userId', newKey);
    return newKey;
  }

  Future<String> _getIV() async {
    final iv = prefs.getString('$_ivKey$userId');
    if (iv != null) return iv;
    
    // Generate new IV
    final newIV = IV.fromSecureRandom(16).base64;
    await prefs.setString('$_ivKey$userId', newIV);
    return newIV;
  }

  Future<String> encrypt(String plainText) async {
    try {
      final key = await _getEncryptionKey();
      final iv = await _getIV();
      
      final encrypter = Encrypter(AES(Key.fromBase64(key), mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: IV.fromBase64(iv));
      
      return encrypted.base64;
    } catch (e) {
      throw Exception('Failed to encrypt: $e');
    }
  }

  Future<String> decrypt(String encryptedText) async {
    try {
      final key = await _getEncryptionKey();
      final iv = await _getIV();
      
      final encrypter = Encrypter(AES(Key.fromBase64(key), mode: AESMode.cbc));
      final decrypted = encrypter.decrypt64(encryptedText, iv: IV.fromBase64(iv));
      
      return decrypted;
    } catch (e) {
      throw Exception('Failed to decrypt: $e');
    }
  }

  Future<Map<String, dynamic>> encryptMap(Map<String, dynamic> data) async {
    final jsonString = jsonEncode(data);
    final encrypted = await encrypt(jsonString);
    return {'encrypted': encrypted, 'timestamp': DateTime.now().toIso8601String()};
  }

  Future<Map<String, dynamic>> decryptMap(Map<String, dynamic> encryptedData) async {
    final encrypted = encryptedData['encrypted'] as String;
    final decrypted = await decrypt(encrypted);
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }

  Future<void> clearKeys() async {
    await prefs.remove('$_encryptionKey$userId');
    await prefs.remove('$_ivKey$userId');
  }
}

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  throw Exception('EncryptionService must be initialized with userId');
});

final encryptionServiceFactoryProvider = Provider.family<EncryptionService, String>((ref, userId) {
  final prefs = ref.read(sharedPreferencesProvider);
  return EncryptionService(
    userId: userId,
    prefs: prefs,
  );
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw Exception('SharedPreferences not initialized');
});
