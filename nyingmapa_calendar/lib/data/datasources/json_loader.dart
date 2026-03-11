import 'package:flutter/services.dart';
import 'dart:convert';

/// Load a JSON asset and return raw decoded data
Future<dynamic> loadJsonAsset(String path) async {
  final raw = await rootBundle.loadString(path);
  return json.decode(raw);
}

/// Load JSON asset as Map
Future<Map<String, dynamic>> loadJsonMap(String path) async {
  final data = await loadJsonAsset(path);
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return data.cast<String, dynamic>();
  return <String, dynamic>{};
}

/// Load JSON asset as List
Future<List<dynamic>> loadJsonList(String path) async {
  final data = await loadJsonAsset(path);
  if (data is List) return data;
  return [];
}

/// Static class for backward compatibility
class JsonLoader {
  static Future<dynamic> load(String path) => loadJsonAsset(path);
  static Future<Map<String, dynamic>> loadMap(String path) => loadJsonMap(path);
  static Future<List<dynamic>> loadList(String path) => loadJsonList(path);
}