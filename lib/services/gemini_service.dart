import 'package:http/http.dart' as http;
import 'dart:convert';

class GeminiService {
  final String apiKey;
  final String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  GeminiService(this.apiKey);

  Future<String> generateRecommendation(
      String userActivity, String carbonFootprint) async {
    final url = Uri.parse('$baseUrl?key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contents': [
          {
            'parts': [
              {
                'text':
                    'Based on the following user activity and carbon footprint, provide a short, personalized recommendation for reducing environmental impact:\n\nUser Activity: $userActivity\nCarbon Footprint: $carbonFootprint kg CO2e'
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to generate recommendation');
    }
  }
}
