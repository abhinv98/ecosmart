// import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:firebase_auth/firebase_auth.dart';

class SecurityService {
  final _storage = FlutterSecureStorage();
  final _auth = FirebaseAuth.instance;

  Future<void> secureStore(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> secureRetrieve(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> secureDelete(String key) async {
    await _storage.delete(key: key);
  }

  String encryptData(String data) {
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  String decryptData(String encryptedData) {
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
    return decrypted;
  }

  Future<UserCredential> secureSignIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await secureStore('uid', userCredential.user!.uid);
      return userCredential;
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  Future<void> secureSignOut() async {
    await _auth.signOut();
    await secureDelete('uid');
  }
}

// Note: Remove the main() function from this file as it's a service class