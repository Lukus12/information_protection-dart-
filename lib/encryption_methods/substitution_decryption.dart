import 'dart:math';

import 'package:information_protection/encryption_methods/encryption_methods.dart';

class SubstitutionDecryption implements EncryptionMethods {

  @override
  String get keyMessage => _keyMessage;

  @override
  String get resultMessage => _resultMessage;

  late Map<String, String> _myMap;
  late Map<String, String> _myReverseMap;
  late Map<String, String> _myActiveMap;
  late String _lastMessage = '';

  String _keyMessage = '';
  late String _resultMessage = '';
  final String _alphabet = 'ааабавагадаебабббвбгбдбевавбвввгвдвегагбгвгггдгедадбдвдгдддееаeбевегедее';

  SubstitutionDecryption();

  String _makeEvenLength(String message) {
    return (message.length % 2 == 0) ? message : '$message ';
  }

  String _generateEncryptionKey(String userInput) {
    // Удаляем дубликаты из пользовательского ввода
    Set<String> usedWords = Set.from(userInput.split(''));
    // Проверяем длину пользовательского ввода
    if (userInput.length >= 72) {
      return userInput.substring(0, 72); // Ограничиваем до 72 символов
    }

    // Генерируем все возможные слова
    String miniAlphabet = 'абвгде';
    List<String> allPossibleWords = [];
    for (int i = 0; i < miniAlphabet.length; i++) {
      for (int j = 0; j < miniAlphabet.length; j++) {
        String word = miniAlphabet[i] + miniAlphabet[j];
        if (!usedWords.contains(word)) {
          allPossibleWords.add(word);
        }
      }
    }

    StringBuffer keyBuffer = StringBuffer(userInput);
    Random random = Random();

    // Генерируем недостающие слова
    while (keyBuffer.length < 72 && allPossibleWords.isNotEmpty) {
      // Выбираем случайное слово из доступных
      int randomIndex = random.nextInt(allPossibleWords.length);
      String nextWord = allPossibleWords[randomIndex];

      // Добавляем слово в ключ
      keyBuffer.write(nextWord);

      // Удаляем слово из доступных
      allPossibleWords.removeAt(randomIndex);
    }

    return keyBuffer.toString();
  }


  bool _checkChanges(String key){
    if(key != _lastMessage) return true;
    return false;
  }

  @override
  String processMessage(String message, bool isEncryption, String key) {
    String myMessage = _makeEvenLength(message);

    if(_checkChanges(key)||key.isEmpty) {
      _keyMessage = _generateEncryptionKey(key);
      _lastMessage = _keyMessage;

      _myMap = _createMap(_alphabet,_keyMessage);
      _myReverseMap = _createMap(_keyMessage, _alphabet);

      _resultMessage = '\n${_myMap.keys.join('|')}\n${_myMap.values.join('|')}';
    }

    _myActiveMap = isEncryption ? _myReverseMap : _myMap;

    StringBuffer result = StringBuffer();
    for (int i = 0; i < myMessage.length; i += 2) {
      String block = myMessage[i]+myMessage[i+1];
      result.write(_myActiveMap[block] ?? block); // Заменяем или оставляем
    }
    return result.toString();
  }

  Map<String, String> _createMap(String s1, String s2) {
    Map<String, String> result = {};

    List<String> words1 = _splitIntoTwoChars(s1);
    List<String> words2 = _splitIntoTwoChars(s2);

    // общая длина двух строк
    int minLength = (words1.length < words2.length) ? words1.length : words2.length;

    for (int i = 0; i < minLength; i++) {
      result[words1[i]] = words2[i];
    }

    return result;
  }

  List<String> _splitIntoTwoChars(String str) {
    List<String> result = [];
    for (int i = 0; i < str.length; i += 2) {
      if (i + 1 < str.length) {
        result.add(str.substring(i, i + 2));
      }
    }
    return result;
  }
}
