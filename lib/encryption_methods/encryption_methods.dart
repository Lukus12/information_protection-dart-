export 'substitution_decryption.dart';
export 'permutation_decryption.dart';
export 'gamming_decryption.dart';

abstract class EncryptionMethods {
  String processMessage(String message, bool isEncryption, String key);

  String get keyMessage;
  String get resultMessage;
}

class EncryptionContext {
  late EncryptionMethods _methods;

  String setKeyMessage(){
    return _methods.keyMessage;
  }
  String setResultMessage(){
    return _methods.resultMessage;
  }

  void setEncryptionMethods(EncryptionMethods methods) {
    _methods = methods;
  }

  String encrypt(String message, bool isEncryption, String key) {
    return _methods.processMessage(message, isEncryption, key);
  }
}