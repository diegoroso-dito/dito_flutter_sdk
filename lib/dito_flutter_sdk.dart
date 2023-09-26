library dito_flutter_sdk;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class DitoSDK {
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

  void setUserId(String userId) {
    _userID = userId;
  }

  void _checkConfiguration() {
    if (_apiKey == null || _secretKey == null) {
      throw Exception(
          'API key and Secret Key must be initialized before using. Please call the initialize() method first.');
    }

    if (_userID == null) {
      throw Exception(
          'User registration is required. Please call the setUserId() method first.');
    }
  }

  Future<void> registerUser() async {
    _checkConfiguration();

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

  Future<void> trackEvent(
      {required String eventName,
      double? revenue,
      Map<String, String>? customData}) async {
    _checkConfiguration();

    final signature = convertToSHA1(_secretKey!);

    final params = {
      'id_type': 'id',
      'platform_api_key': _apiKey,
      'sha1_signature': signature,
      'encoding': 'base64',
      'network_name': 'pt',
      'event': jsonEncode(
          {'action': eventName, 'revenue': revenue, 'data': customData})
    };

    final url =
        Uri.parse("http://events.plataformasocial.com.br/users/$_userID");

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
}
