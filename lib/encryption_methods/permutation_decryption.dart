import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:information_protection/encryption_methods/encryption_methods.dart';

class PermutationDecryption implements EncryptionMethods {

  @override
  String get keyMessage => _keyMessage; // Пример реализации

  @override
  String get resultMessage => _resultMessage; // Пример реализации

  late String _resultMessage = '';
  String _keyMessage = '';
  late String _lastKey = '';
  late List<int> _key;
  late List<String> _messageBlockList;

  late Map<int, int> _myMap;
  late Map<int, int> _myReverseMap;
  late Map<int, int> _myActiveMap;

  PermutationDecryption();

  String _makeEvenLength(String message) {
    int paddingLength = 17 - (message.length % 17);
    return paddingLength < 17 ? message + '_' * paddingLength : message;
  }

  List<int> _generateEncryptionKey(String userInput) {
    // Преобразуем ввод в список уникальных чисел
    List<int> inputNumbers = userInput.split(',')
        .map((number) => int.tryParse(number.trim()) ?? 0)
        .where((number) => number >= 1 && number <= 17)
        .toSet() // Используем Set для уникальности
        .toList();

    // Если все числа уже введены, возвращаем пустой список
    if (inputNumbers.length == 17) {
      return [];
    }

    // Создаем набор чисел от 1 до 17
    List<int> allNumbers = List.generate(17, (index) => index + 1);
    List<int> miniAlphabet = List.generate(17, (index) => index + 1);

    // Убираем уже введенные числа
    for (var num in inputNumbers) {
      allNumbers.remove(num);
    }

    // Перемешиваем оставшиеся числа
    allNumbers.shuffle(Random());

    // Объединяем введенные и оставшиеся числа
    _key = [...inputNumbers, ...allNumbers];

    // Сохраняем строку ключа
    _keyMessage = _key.join(', ');

    /*
    //создать мапки прямую и ревёрс
     */
    _myMap = _createMap(miniAlphabet, _key);
    _myReverseMap = _createMap(_key, miniAlphabet);

    return _key;
  }

  bool _isKeyChanged(String key, String lastK) {
    Set<int> inputKey = key.split(',')
        .map((number) => int.tryParse(number.trim()) ?? 0)
        .where((number) => number >= 1 && number <= 17)
        .toSet(); // Используем Set для уникальности

    Set<int> lastKey = lastK.split(',')
        .map((number) => int.tryParse(number.trim()) ?? 0)
        .where((number) => number >= 1 && number <= 17)
        .toSet(); // Используем Set для уникальности

    // Сравниваем множества
    return !inputKey.containsAll(lastKey) || !lastKey.containsAll(inputKey);
  }

  Map<int, int> _createMap(List<int> list1, List<int> list2) {
    Map<int, int> result = {};

    int minLength = (list1.length < list2.length) ? list1.length : list2.length;

    for (int i = 0; i < minLength; i++) {
      result[list1[i]] = list2[i];
    }

    return result;
  }

  @override
  String processMessage(String message, bool isEncryption, String key) {
    String myMessage = _makeEvenLength(message);

    if (_isKeyChanged(key, _lastKey) || key.isEmpty) {
      _generateEncryptionKey(key);
      _lastKey = _keyMessage;
      _resultMessage = '\n1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17\n$_keyMessage';
    }

    _myActiveMap = isEncryption ? _myReverseMap : _myMap;

    StringBuffer result = StringBuffer();
    int segments = (myMessage.length / 17).ceil();

    for (int i = 0; i < segments; i++) {
      _messageBlockList = List.generate(17, (j) {
        int index = i * 17 + j;
        // Проверяем, не выходит ли индекс за пределы
        return index < myMessage.length ? myMessage[index] : '!';
      });

      for (int j = 1; j <= 17; j++) {
        int? value = _myActiveMap[j];
        // Проверяем, что значение не равно null перед использованием
        if (value != null) {
          result.write(_messageBlockList[value-1]);
        } else {
          continue;
          //result.write('!');
        }
      }
      if (kDebugMode) {
        print(_messageBlockList);
      }
    }
    return result.toString();
  }
}
