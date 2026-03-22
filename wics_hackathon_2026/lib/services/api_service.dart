import 'dart:convert';
import 'package:http/http.dart' as http;

class HobbyData {
  final List<String> daily;
  final List<String> weekly;

  HobbyData({required this.daily, required this.weekly});

  factory HobbyData.fromJson(Map<String, dynamic> json) {
    return HobbyData(
      daily: List<String>.from(json['daily'] ?? []),
      weekly: List<String>.from(json['weekly'] ?? []),
    );
  }
}

class LLMService {
  final String baseUrl = "http://10.0.2.2:8000/ask";

  Future<Map<String, dynamic>?> fetchHobbyTasks(List<String> selectedHobbies) async { 
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"hobbies": selectedHobbies}),
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        return decoded as Map<String, dynamic>;
      } else {
        print("LLM Server Error: ${res.statusCode}");
        return null;
      }
    } catch (e) {
      print("Check if Python Server is running: $e");
      return null;
    }
  }
}