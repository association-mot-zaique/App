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
      throw ArasaacException(statusCode: response.statusCode);
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
          // Skip corrupted pictograms to keep the search stable.
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
          // Skip corrupted pictograms to keep the search stable.
        }
      }
    }

    return pictograms;
  }

  void dispose() {
    _client.close();
  }
}

/// Internal failure marker for ARASAAC access. Its fields are **developer
/// diagnostics only and are never displayed** — the UI always shows a
/// localized string (`serviceUnavailable`). [statusCode] holds the HTTP status
/// when the failure came from a response; [debugInfo] is an optional dev note.
class ArasaacException implements Exception {
  const ArasaacException({this.statusCode, this.debugInfo});

  final int? statusCode;
  final String? debugInfo;

  @override
  String toString() {
    final parts = <String>[
      if (statusCode != null) 'status $statusCode',
      ?debugInfo,
    ];
    return 'ArasaacException(${parts.isEmpty ? 'unreachable' : parts.join(', ')})';
  }
}
