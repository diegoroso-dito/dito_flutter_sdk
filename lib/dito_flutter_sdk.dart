library dito_flutter_sdk;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class DitoSDK {
  String? _cpf;
  String? _apiKey;
  String? _secretKey;
  String? _userID;
  String? _name;
  String? _email;
  String? _gender;
  String? _birthday;
  String? _location;
  Map<String, String>? _customData;

  static final DitoSDK _instance = DitoSDK._internal();

  factory DitoSDK() {
    return _instance;
  }

  DitoSDK._internal();

  void initialize({required String apiKey, required String secretKey}) {
    _apiKey = apiKey;
    _secretKey = secretKey;
  }

  String convertToSHA1(String input) {
    final bytes = utf8.encode(input);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

  void identify({
    String? cpf,
    String? name,
    String? email,
    String? gender,
    String? birthday,
    String? location,
    Map<String, String>? customData,
  }) {
    if (cpf != null) {
      _cpf = cpf;
    }
    if (name != null) {
      _name = name;
    }
    if (email != null) {
      _email = email;
    }
    if (gender != null) {
      _gender = gender;
    }
    if (birthday != null) {
      _birthday = birthday;
    }
    if (location != null) {
      _location = location;
    }
    if (customData != null) {
      _customData = customData;
    }

    print("Identify registered!");
  }

  Future<void> registerUser() async {
    if (_apiKey == null || _secretKey == null) {
      throw Exception(
          'As chaves de API e Secret Key não foram inicializadas. Chame o método initialize() primeiro.');
    }

    if (_cpf == null && _email == null) {
      throw Exception(
          'Você não cadastrou o minimo de informações com o identify.');
    }

    _userID = _cpf ?? convertToSHA1(_email!);

    final signature = convertToSHA1(_secretKey!);

    final params = {
      'platform_api_key': _apiKey,
      'sha1_signature': signature,
      'user_data': jsonEncode({
        'name': _name,
        'email': _email,
        'gender': _gender,
        'location': _location,
        'birthday': _birthday,
        'data': json.encode(_customData)
      }),
    };

    final url = Uri.parse(
        "https://login.plataformasocial.com.br/users/portal/$_userID/signup");

    final response = await http.post(
      url,
      body: params,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode == 201) {
      // Requisição bem sucedida
      print("Requisição bem-sucedida: ${response.body}");
    } else {
      // Requisição com erro
      print("Erro na requisição: ${response.statusCode}");
    }
  }

  // void trackEvent(String eventName, Map<String, String>? properties) {
  //   if (_userID != null) {
  //     print("Tracking event $eventName with $properties for user $_userID");
  //   } else {
  //     print("UserID doesn't exist");
  //   }
  // }
}
