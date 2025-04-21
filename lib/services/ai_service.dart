import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = 'AIzaSyAtfIUjuW7dcWm_t9ruosCaT93pR-Gh594';
  final GenerativeModel _model;

  AIService() : _model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: _apiKey,
    generationConfig: GenerationConfig(
      temperature: 0.4,
      topP: 0.9,
      topK: 40,
      maxOutputTokens: 1024,
    ),
    safetySettings: [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
    ],
  );

  Future<String> getWaterResponse(String prompt, String concession) async {
    final fullPrompt = """
Eres un experto en gestión hídrica en Ecuador, especializado en análisis de 
concesiones de agua. Responde de manera técnica pero comprensible, con 
recomendaciones prácticas basadas en datos reales.

Concesión: $concession
Consulta del usuario: $prompt

Instrucciones:
1. Proporciona información precisa y verificable
2. Si mencionas datos, indica la fuente
3. Ofrece recomendaciones prácticas
4. Usa un lenguaje profesional pero accesible
5. Mantén respuestas concisas pero completas
6. Formatea con saltos de línea cuando sea necesario
""";

    try {
      final response = await _model.generateContent([Content.text(fullPrompt)]);
      return response.text ?? "No pude generar una respuesta en este momento.";
    } catch (e) {
      return "Error al conectar con el servicio: ${e.toString()}";
    }
  }
}