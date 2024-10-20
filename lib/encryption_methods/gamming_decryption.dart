import 'encryption_methods.dart';


//генератор псевдослучайных чисел/гаммы // линейный конгруэнтный генератор (LCG)
class LCG {
  int A;
  int C;
  int T0;
  int B;

  LCG(this.A, this.C, this.T0, this.B);

  int generate() {
    T0 = (A * T0 + C) % B;
    return T0;
  }

  List<int> generateSequence(int length) {
    List<int> sequence = [];
    for (int i = 0; i < length; i++) {
      sequence.add(generate());
    }
    return sequence;
  }
}

//загоммированный текст
class Gamir {
  final LCG lcg;

  Gamir(this.lcg);

  String encrypt(List <int> textCodes, List <int> cipherCodes, List<int> gamma) {
    for (int i = 0; i < textCodes.length; i++) {
      int encrypted = (textCodes[i] + gamma[i]) % lcg.B;
      cipherCodes.add(encrypted);
    }
    return String.fromCharCodes(cipherCodes);
  }

  String decrypt(List <int> decipherCodes, List <int> textCodes, List<int> gamma) {
    for (int i = 0; i < decipherCodes.length; i++) {
      int decrypted = decipherCodes[i] - gamma[i];
      if (decrypted < 0) decrypted += lcg.B;
      textCodes.add(decrypted);
    }
    return String.fromCharCodes(textCodes);
  }
}

class GammingDecryption implements EncryptionMethods {

  @override
  String get keyMessage => _keyMessage;

  @override
  String get resultMessage => _resultMessage;

  String _keyMessage = '';
  late String _resultMessage = '';
  String _lastKey = '';

  // Параметры ПСЧ
  int A = 41;
  int C = 13;
  int T0 = 11;
  int B = 256;

  late LCG lcg;
  late List<int> _gamma;

  GammingDecryption() {
    lcg = LCG(A, C, T0, B);
  }

  bool _isKeyChanged(String key, String lastK) {
    // Функция для подсчета элементов в строке ключа
    Map<int, int> countOccurrences(String key) {
      Map<int, int> countMap = {};
      for (var number in key.split(',')) {
        int parsedNumber = int.tryParse(number.trim()) ?? 0;
        if (parsedNumber >= 0 && parsedNumber <= 255) {
          countMap[parsedNumber] = (countMap[parsedNumber] ?? 0) + 1;
        }
      }
      return countMap;
    }

    Map<int, int> inputKeyCounts = countOccurrences(key);
    Map<int, int> lastKeyCounts = countOccurrences(lastK);

    // Сравниваем подсчеты
    return !inputKeyCounts.entries.every((entry) =>
    lastKeyCounts[entry.key] == entry.value) ||
        !lastKeyCounts.entries.every((entry) =>
        inputKeyCounts[entry.key] == entry.value);
  }

  @override
  String processMessage(String message, bool isEncryption, String key) {
    // Генерация гаммы для длины текста
    if (_isKeyChanged(key, _lastKey) || key.isEmpty) {
      _gamma = lcg.generateSequence(message.length);
      _keyMessage = _gamma.join(', ');
      _lastKey = _keyMessage;

      _resultMessage = '\n\n$_keyMessage';
    }

    // в диапазоне 0-255 UTF-16 = ASCII-коду
    List<int> textCodes = message.codeUnits.toList();
    List<int> futureResult = [];

    Gamir gamir = Gamir(lcg);

    String result = isEncryption
        ? gamir.decrypt(textCodes, futureResult, _gamma) // истина
        : gamir.encrypt(textCodes, futureResult, _gamma); // ложь
    return result;
  }
}