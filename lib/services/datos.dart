import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

Future<List<dynamic>> loadConcesionarios() async {
  final String response = await rootBundle.loadString('assets/concesionarios.json');
  return json.decode(response);
}