import 'package:flutter/material.dart';
import 'encryption_methods/encryption_methods.dart';
import 'encryption_methods/substitution_decryption.dart';
import 'encryption_methods/permutation_decryption.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Криптография',
      home: EncryptionDecryptionPage(),
    );
  }
}

class EncryptionDecryptionPage extends StatefulWidget {
  const EncryptionDecryptionPage({super.key});

  @override
  _EncryptionDecryptionPageState createState() => _EncryptionDecryptionPageState();
}

class _EncryptionDecryptionPageState extends State<EncryptionDecryptionPage> {
  final TextEditingController _messageEncryptController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _messageDecryptController = TextEditingController();
  late String _resultMessage = '';

  late final EncryptionContext _contextMethods = EncryptionContext();
  late final PermutationDecryption _permutationDecryption = PermutationDecryption();
  late final SubstitutionDecryption _substitutionDecryption = SubstitutionDecryption();

  void _encryptMessage() {
    String encrypted = _contextMethods.encrypt(_messageEncryptController.text, false, _keyController.text);
    _messageDecryptController.text = encrypted;
    _fillingFields();
  }

  void _decryptMessage() {
    String decrypted = _contextMethods.encrypt(_messageDecryptController.text, true, _keyController.text);
    _messageEncryptController.text = decrypted;
    _fillingFields();
  }

  void _fillingFields() {
    _keyController.text = _contextMethods.setKeyMessage();
    setState(() {
      _resultMessage = _contextMethods.setResultMessage();
    });
  }

  void _setEncryptionMethod(int index) {
    _keyController.clear();
    _messageEncryptController.clear();
    _messageDecryptController.clear();

    switch (index) {
      case 0:
        _contextMethods.setEncryptionMethods(_substitutionDecryption);
        break;
      case 1:
        _contextMethods.setEncryptionMethods(_permutationDecryption);
        break;
      default:
        _contextMethods.setEncryptionMethods(_substitutionDecryption);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Криптография'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _setEncryptionMethod(index),
                      child: Text('Метод ${index + 1}'),
                    ),
                    const SizedBox(width: 16), // Измените ширину по желанию
                  ],
                );
              }),
            ),
            TextField(
              controller: _messageEncryptController,
              decoration: const InputDecoration(labelText: 'Исходное сообщение'),
            ),
            TextField(
              controller: _keyController,
              decoration: const InputDecoration(labelText: 'Ключ (дешифровка, 36 слов, незаполненые места будут дополнены автогенерацией)'),
            ),
            TextField(
              controller: _messageDecryptController,
              decoration: const InputDecoration(labelText: 'Зашифрованное сообщение'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _encryptMessage,
                  child: const Text('Зашифровать'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _decryptMessage,
                  child: const Text('Расшифровать'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Алфавит и ключ (пары через |): $_resultMessage',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}