import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:loan_poc/models/metadata_models.dart';


class ApiService {

  // Real backend API call
  Future<FormMetadata?> fetchFormMetadata(String stage, {String? versionId, Map<String, dynamic>? values}) async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/form-metadata');
      final context = {
        'stage': stage,
        'version': versionId ?? 'WORKING_V1',
        'values': values ?? {},
      };
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(context),
      );
      // Debug: Log status code and raw response
      debugPrint('[POC][ApiService] Response status: \\${response.statusCode}');
      debugPrint('[POC][ApiService] Response body: \\${response.body}');
      if (response.statusCode == 200) {
        return FormMetadata.fromJson(jsonDecode(response.body));
      } else {
        // Handle error response
        return null;
      }
    } catch (e) {
      // Handle network error gracefully
      debugPrint('[POC][ApiService] Exception: \\${e.toString()}');
      return null;
    }
  }

  // All mock/static JSON removed. Only real backend API is used.
}
