// Penerapan AES menggunakan library encrypt di Flutter
// Kemudahan Penggunaan dan Keamanan: Library seperti `encrypt` menyediakan antarmuka yang mudah digunakan untuk enkripsi dan dekripsi,
// mengurangi kompleksitas kode, serta didedikasikan untuk menyediakan implementasi enkripsi yang aman dan teruji di Flutter,
// membantu menghindari kesalahan implementasi yang umumnya terjadi.

import 'package:encrypt/encrypt.dart';

class AESHelper {
  static final key = Key.fromUtf8('my32lengthsupersecretnooneknows1');
  static final iv = IV.fromLength(16);

  // Fungsi untuk melakukan enkripsi menggunakan AES
  static String encrypt(String plainText) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  // Fungsi untuk melakukan dekripsi menggunakan AES
  static String decrypt(String encryptedText) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    try {
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
      return decrypted;
    } catch (e) {
      print('Error decrypting data: $e');
      return 'Error';
    }
  }

  static bool checkPassword(String storedPassword, String enteredPassword) {
    return encrypt(enteredPassword) == storedPassword;
  }
}
