import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  // Future<bool> login(String name, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/loginSubmit'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(<String, String>{
  //         'name': name,
  //         'password': password,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data['access_token'] != null) {
  //         await _storeToken(data['access_token']);
  //         return true;
  //       }
  //     }
  //     return false;
  //   } catch (e) {
  //     print('Error during login: $e');
  //     return false;
  //   }
  // }

  Future<Map<String, dynamic>?> login(String name, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/loginSubmit'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({'name': name, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 3. Check for the access_token from your API response
        if (data['access_token'] != null) {
          await _storeToken(data['access_token']);

          final bool isAdmin = data['is_admin'] == 1;

          return {'name': data['username'], 'is_admin': isAdmin};
        }
      }
      print('Login failed with status: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<List<dynamic>> getUsers() async {
    final token = await getToken();
    if (token == null) {
      print('No authentication token found.');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get-user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to load users: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getToken();

    print('TOKEN: $token');

    if (token == null) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/current-user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching current user: $e');
      return null;
    }
  }

  Future<List<dynamic>> getCategories() async {
    final token = await getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/admin/list-category'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // **FIX 1: Access the "category" key from the response**
      final data = jsonDecode(response.body);
      return data['category'] as List<dynamic>;
    }
    return [];
  }

  Future<bool> addCategory(String name) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/admin/add-category'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );

    return response.statusCode == 200;
  }

  Future<bool> updateCategory(int id, String name) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/admin/category/update/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteCategory(int id) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/category/delete/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<List<dynamic>> getAttributes() async {
    final token = await getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/admin/list-attribute'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['attribute'] as List<dynamic>;
    }
    return [];
  }

  Future<bool> addAttribute(String type, String value) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/admin/add-attribute-submit'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'type': type, 'value': value}),
    );
    return response.statusCode == 200;
  }

  Future<bool> updateAttribute(int id, String type, String value) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.put(
      Uri.parse('$_baseUrl/admin/attribute/update/$id'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'type': type, 'value': value}),
    );
    print('UPDATE ATTRIBUTE STATUS CODE: ${response.statusCode}');
    print('UPDATE ATTRIBUTE RESPONSE BODY: ${response.body}');

    return response.statusCode == 200;
  }

  Future<bool> deleteAttribute(int id) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/attribute/delete/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
