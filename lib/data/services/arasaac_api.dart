import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pictogram.dart';

class ArasaacApi {
  ArasaacApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://api.arasaac.org/api/pictograms';

  Future<List<Pictogram>> searchPictograms(
    String query, {
    String language = 'es',
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return const [];
    }

    final encodedQuery = Uri.encodeComponent(cleanQuery);
    final uri = Uri.parse('$_baseUrl/$language/search/$encodedQuery');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw ArasaacException(
        'ARASAAC devolvio ${response.statusCode}. Intenta de nuevo.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return const [];
    }

    final pictograms = <Pictogram>[];
    for (final item in decoded) {
      if (item is Map<String, dynamic>) {
        try {
          pictograms.add(Pictogram.fromArasaacJson(item, language: language));
        } on FormatException {
          // Ignora pictogramas corruptos para mantener la busqueda estable.
        }
      } else if (item is Map) {
        try {
          pictograms.add(
            Pictogram.fromArasaacJson(
              Map<String, dynamic>.from(item),
              language: language,
            ),
          );
        } on FormatException {
          // Ignora pictogramas corruptos para mantener la busqueda estable.
        }
      }
    }

    return pictograms;
  }

  void dispose() {
    _client.close();
  }
}

class ArasaacException implements Exception {
  const ArasaacException(this.message);

  final String message;

  @override
  String toString() => message;
}
