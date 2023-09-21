library dito_flutter_sdk;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class DitoSDK {
  String? _userID;
  String? _name;
  String? _email;
  String? _gender;
  String? _birthday;
  String? _registrationDate;
  String? _city;
  Map<String, String>? _customData;

  static final DitoSDK _instance = DitoSDK._internal();

  factory DitoSDK() {
    return _instance;
  }

  DitoSDK._internal();

  void setUserId(String userID) {
    _userID = userID;
  }

  void deleteUserId() {
    _userID = null;
  }

  void identify({
    String? name,
    String? email,
    String? gender,
    String? birthday,
    String? registrationDate,
    String? city,
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
    if (registrationDate != null) {
      _registrationDate = registrationDate;
    }
    if (city != null) {
      _city = city;
    }
    if (customData != null) {
      _customData = customData;
    }
    print("Identify: Name: $_name, Email: $_email, Custom Data: $_customData");
  }

  void trackEvent(String eventName, Map<String, String>? properties) {
    if (_userID != null) {
      print("Tracking event $eventName with $properties for user $_userID");
    } else {
      print("UserID doesn't exist");
    }
  }

  String convertToSHA1(String input) {
    final bytes = utf8.encode(input); // data being hashed
    final digest = sha1.convert(bytes);

    return digest.toString();
  }

  Future<void> _registerUser() async {
    final secretKey = 'SECRET_KEY';
    final apiKey = 'API_KEY';

    final signature = convertToSHA1(secretKey);

    final params = {
      'platform_api_key': apiKey,
      'sha1_signature': signature,
      'encoding': 'base64',
      'user_data': jsonEncode({
        'name': '',
        'email': '',
        'gender': '',
        'location': '',
        'birthday': '',
        'created_at': '',
        'data': {} //customData
      }),
    };

    final url = Uri.parse(
        "https://login.plataformasocial.com.br/users/portal/$_userID/signup");

    final response = await http.post(
      url,
      body: params,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    if (response.statusCode == 200) {
      // Requisição bem-sucedida
      print("Requisição bem-sucedida: ${response.body}");
    } else {
      // Requisição com erro
      print("Erro na requisição: ${response.statusCode}");
    }
  }
}
