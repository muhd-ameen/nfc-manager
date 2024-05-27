// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class WriteNFCPage extends StatefulWidget {
  const WriteNFCPage({super.key});

  @override
  _WriteNFCPageState createState() => _WriteNFCPageState();
}

class _WriteNFCPageState extends State<WriteNFCPage> {
  String encryptPassword(String password, String keyString, String ivString) {
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromUtf8(ivString);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  void _writeNFC() {
    const password = 'Ameen@2';
    const key = 'my32lengthsupersecretnooneknows1'; // 32 chars
    const iv = '8bytesiv8bytesiv'; // 16 chars

    final encryptedPassword = encryptPassword(password, key, iv);
    print('Encrypted Password: $encryptedPassword');

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        Ndef? ndef = Ndef.from(tag);
        if (ndef == null) return;
        final ndefMessage = NdefMessage([
          NdefRecord.createText(encryptedPassword),
        ]);

        await ndef.write(ndefMessage);
        print('NFC tag written successfully');
        NfcManager.instance.stopSession();
      } catch (e) {
        print('Error writing NFC tag: $e');
        NfcManager.instance.stopSession(errorMessage: e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write to NFC'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _writeNFC,
          child: const Text('Write Encrypted Password to NFC'),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: WriteNFCPage()));
}
