// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
        String password = String.fromCharCodes(message.records.first.payload)
            .substring(3); // removing language code
        print('Password read from NFC tag: $password');
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

  void _login() {
    log('Login with password: $_nfcPassword');
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
