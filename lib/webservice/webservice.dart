import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:milma_group/const.dart';
import 'package:milma_group/model/eventmodel.dart';
import 'package:milma_group/model/insightmodel.dart';
import 'package:milma_group/model/loginmodel.dart';
import 'package:milma_group/session/shared_preferences.dart';

class Webservice {
  Future<Map<String, dynamic>> login(String email, String password) async {
    var result3;

    Map<String, dynamic> data = {'email': email, 'password': password};

    final response = await http.post(
      Uri.parse("${baseurl}login"),
      body: jsonEncode(data),
      headers: {'Content-type': 'application/json'},
    );
    log("respons login===${response.body}");
   

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      LoginResponse authUser = LoginResponse.fromJson(responseData);

      result3 = {
        'status': true,
        'message': 'successful',
        'responsedata': authUser,
      };
    } else {
      result3 = {
        'status': false,
        'message': json.decode(response.body)['message'],
        'responsedata': null,
      };
    }
    return result3;
  }

  Future<Map<String, dynamic>> getallevents() async {
    var result3;

    String? accestoken = await Store.getToken();

    final response = await http.get(
      Uri.parse("${baseurl}getallevents"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accestoken',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      EventResponse authUser = EventResponse.fromJson(responseData);
      result3 = {
        'status': true,
        'message': 'successful',
        'eventlistdata': authUser.event,
      };
    } else {
      result3 = {
        'status': false,
        'message': json.decode(response.body)['error'],
      };
    }
    return result3;
  }

  Future<Map<String, dynamic>> getinsights(int id) async {
    var result3;

    String? accestoken = await Store.getToken();

    final response = await http.get(
      Uri.parse("${baseurl}getinsights/$id"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accestoken',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      InsightResponse authUser = InsightResponse.fromJson(responseData);
      result3 = {
        'status': true,
        'message': 'successful',
        'insightlistdata': authUser.insights,
      };
    } else {
      result3 = {
        'status': false,
        'message': json.decode(response.body)['error'],
      };
    }
    return result3;
  }

  static Future<Map<String, String>> _headers() async {
    String? token = await Store.getToken();
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  static Future<List<dynamic>> getDistricts() async {
    final url = Uri.parse("${baseurl}getdistrict");
    final res = await http.get(url, headers: await _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"] ?? [];
    }
    throw Exception("Failed to fetch districts");
  }

  static Future<List<dynamic>> getPA() async {
    final url = Uri.parse("${baseurl}getpa");
    final res = await http.get(url, headers: await _headers());
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["data"] ?? [];
    }
    throw Exception("Failed to fetch PA list");
  }

  static Future<Map<String, dynamic>> getReport({
    required String eventId,
    String? district,
    String? pa,
  }) async {
    try {
      final queryParams = {
        "event_id": eventId,
        if (district != null && district != "ALL") "district": district,
        if (pa != null && pa != "ALL") "pa": pa,
      };

      final url = Uri.parse(
        "${baseurl}getreport",
      ).replace(queryParameters: queryParams);
      final res = await http.get(url, headers: await _headers());

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["data"] ?? {};
      } else {
        throw Exception("Server returned status code: ${res.statusCode}");
      }
    } catch (e) {
      print("Report fetch error: $e");
      rethrow;
    }
  }
}
