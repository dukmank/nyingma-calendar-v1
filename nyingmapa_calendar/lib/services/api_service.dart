import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String baseUrl = 'http://localhost:8000'; // iOS / Web

  // ─── Calendar ──────────────────────────────────
  static Future<List<Map<String, dynamic>>> getCalendarMonth(int year, int month) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/calendar/$year/$month'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getCalendarDay(String date) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/calendar/day/$date'));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (_) {}
    return null;
  }

  // ─── Events ────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getEvents({String? lineage, int? month}) async {
    try {
      final params = <String, String>{};
      if (lineage != null) params['lineage'] = lineage;
      if (month != null) params['month'] = month.toString();
      final uri = Uri.parse('$baseUrl/events/').replace(queryParameters: params.isNotEmpty ? params : null);
      final response = await http.get(uri);
      if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    } catch (_) {}
    return [];
  }

  // ─── Auspicious Days ───────────────────────────
  static Future<List<Map<String, dynamic>>> getAuspiciousDays() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/auspicious/'));
      if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getNextAuspiciousDay() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/auspicious/next'));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (_) {}
    return null;
  }

  // ─── Astrology ─────────────────────────────────
  static Future<List<Map<String, dynamic>>> getHairCuttingDays() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/astrology/hair-cutting'));
      if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> getGuruManifestation(int month) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/astrology/guru-rinpoche/$month'));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> getNagaDays(int month) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/astrology/naga-days/$month'));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> getFlagAvoidance(int month) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/astrology/flag-avoidance/$month'));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<List<Map<String, dynamic>>> getDailyRestrictions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/astrology/daily-restrictions'));
      if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    } catch (_) {}
    return [];
  }

  // ─── Practices ─────────────────────────────────
  static Future<List<Map<String, dynamic>>> getUserPractices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/practices/'));
      if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    } catch (_) {}
    return [];
  }

  static Future<bool> trackPractice(String name, String date, bool completed) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/practices/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'practice_name': name, 'date': date, 'completed': completed, 'streak': 0}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {}
    return false;
  }

  static Future<bool> updatePractice(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/practices/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // ─── User Events ──────────────────────────────
  static Future<List<Map<String, dynamic>>> getUserEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user-events/'));
      if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    } catch (_) {}
    return [];
  }

  static Future<bool> createUserEvent(Map<String, dynamic> event) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user-events/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(event),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {}
    return false;
  }

  static Future<bool> deleteUserEvent(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/user-events/$id'));
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  // ─── Profile ───────────────────────────────────
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile/'));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (_) {}
    return null;
  }

  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<Map<String, dynamic>?> getPracticeStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/profile/stats'));
      if (response.statusCode == 200) return json.decode(response.body);
    } catch (_) {}
    return null;
  }

  // ─── Bodhisattva Practices ─────────────────────
  static Future<List<Map<String, dynamic>>> getBodhisattvaPractices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/practices/37-practices'));
      if (response.statusCode == 200) return List<Map<String, dynamic>>.from(json.decode(response.body));
    } catch (_) {}
    return [];
  }
}
