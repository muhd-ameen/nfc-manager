// ignore_for_file: avoid_print, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _nfcPassword;

  @override
  void initState() {
    super.initState();
    _startNFC();
  }

  void _startNFC() {
    print('Starting NFC session...');
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        print('NFC tag discovered');
        Ndef? ndef = Ndef.from(tag);
        if (ndef == null) {
          print('No NDEF message found');
          return;
        }
        NdefMessage message = ndef.cachedMessage!;
        String encryptedPassword =
            String.fromCharCodes(message.records.first.payload)
                .substring(3); // removing language code
        print('Encrypted password read from NFC tag: $encryptedPassword');

        const key = 'my32lengthsupersecretnooneknows1'; // 32 chars
        const iv = '8bytesiv8bytesiv'; // 16 chars

        String password = decryptPassword(encryptedPassword, key, iv);
        print('Decrypted password: $password');
        setState(() {
          _nfcPassword = password;
        });
        NfcManager.instance.stopSession();
        print('NFC session stopped successfully');
      } catch (e) {
        print('Error during NFC session: $e');
        NfcManager.instance.stopSession(errorMessage: e.toString());
      }
    });
  }

  String decryptPassword(
      String encryptedPassword, String keyString, String ivString) {
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromUtf8(ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final decrypted = encrypter.decrypt64(encryptedPassword, iv: iv);
    return decrypted;
  }

  void _login() {
    print('Login button pressed with password: $_nfcPassword');
    // Implement your login logic here using _nfcPassword
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tap your NFC card to login'),
            const SizedBox(height: 20),
            if (_nfcPassword != null) Text('Password: $_nfcPassword'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _nfcPassword != null ? _login : null,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: LoginPage()));
}
