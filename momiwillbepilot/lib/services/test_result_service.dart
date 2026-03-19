import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:momiwillbepilot/models/test_result.dart';

class TestResultService {
  static const String _testResultsKey = 'testResults';

  static Future<List<TestResult>> _readTestResultsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_testResultsKey);
      if (jsonString == null) {
        return [];
      }
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => TestResult.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> _writeTestResultsToPrefs(List<TestResult> results) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = results.map((result) => result.toJson()).toList();
    await prefs.setString(_testResultsKey, json.encode(jsonList));
  }

  static Future<void> saveTestResult(TestResult result) async {
    final allResults = await _readTestResultsFromPrefs();
    allResults.add(result);
    await _writeTestResultsToPrefs(allResults);
  }

  static Future<List<TestResult>> loadAllTestResults() async {
    return await _readTestResultsFromPrefs();
  }

  static Future<String> exportTestResults(List<TestResult> results) async {
    final jsonList = results.map((result) => result.toJson()).toList();
    return json.encode(jsonList);
  }

  static Future<void> importTestResults(String jsonString) async {
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      final List<TestResult> importedResults =
          jsonList.map((json) => TestResult.fromJson(json)).toList();

      final currentResults = await _readTestResultsFromPrefs();
      currentResults.addAll(importedResults);
      await _writeTestResultsToPrefs(currentResults);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> clearAllResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_testResultsKey);
  }
}
