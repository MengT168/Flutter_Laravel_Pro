import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class AuthService with ChangeNotifier {

  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  factory AuthService() {
    return _instance;
  }

  List<dynamic> _favorites = [];
  List<dynamic> get favorites => _favorites;
  List<int> get favoriteProductIds => _favorites.map((p) => p['id'] as int).toList();

  Future<void> _fetchUserAndDependencies() async {
    await Future.wait([
      getFavorites(),
    ]);
  }

  Map<String, dynamic>? _cartData;
  Map<String, dynamic>? get cartData => _cartData;


  final String _baseUrl = kIsWeb
      ? 'http://127.0.0.1:8000/api'
      : 'http://10.0.2.2:8000/api';
  final String serverUrl = kIsWeb
      ? 'http://127.0.0.1:8000'
      : 'http://10.0.2.2:8000';


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


  // Future<Map<String, dynamic>?> login(String name, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/loginSubmit'),
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Accept': 'application/json',
  //       },
  //       body: jsonEncode({'name': name, 'password': password}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       print('RAW API RESPONSE FOR LOGIN: $data');
  //
  //       // 3. Check for the access_token from your API response
  //       if (data['access_token'] != null) {
  //         await _storeToken(data['access_token']);
  //
  //         final bool isAdmin = data['is_admin'] == 1;
  //
  //         return {'name': data['username'], 'is_admin': isAdmin};
  //       }
  //     }
  //     print('Login failed with status: ${response.statusCode}');
  //     print('Response: ${response.body}');
  //     return null;
  //   } catch (e) {
  //     print('Error during login: $e');
  //     return null;
  //   }
  // }

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get user => _currentUser;

  get cart => null;



  // Future<Map<String, dynamic>?> login(String name, String password) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$_baseUrl/loginSubmit'),
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Accept': 'application/json',
  //       },
  //       body: jsonEncode({'name': name, 'password': password}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //
  //       if (data['access_token'] != null) {
  //         await _storeToken(data['access_token']);
  //
  //         // Safely check the admin status
  //         final dynamic adminValue = data['is_admin'];
  //         final bool isAdmin = (adminValue == 1 || adminValue == true);
  //
  //         // Create the user map that the rest of the app will use
  //         final userMap = {
  //           'id': data['id'], // Make sure your API sends the user's ID
  //           'name': data['username'],
  //           'is_admin': isAdmin,
  //           // You can add 'email' here too if your API sends it
  //         };
  //
  //         // THE FIX: Save the user data to the service
  //         _currentUser = userMap;
  //         await _fetchUserAndDependencies();
  //         notifyListeners();
  //
  //         return userMap;
  //       }
  //     }
  //
  //     print('Login failed with status: ${response.statusCode}');
  //     print('Response: ${response.body}');
  //     return null;
  //
  //   } catch (e) {
  //     print('Error during login: $e');
  //     return null;
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

        if (data['access_token'] != null) {
          await _storeToken(data['access_token']);

          // Safely check the admin status
          final dynamic adminValue = data['is_admin'];
          final bool isAdmin = (adminValue == 1 || adminValue == true);

          // Create the user map that the rest of the app will use
          final userMap = {
            'id': data['id'],
            'name': data['username'],
            'is_admin': isAdmin,
            'email': data['email'],
          };

          _currentUser = userMap;
          await _fetchUserAndDependencies(); // Fetch cart/favorites
          notifyListeners();

          return userMap;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUsers() async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _currentUser = jsonDecode(response.body);
        await _fetchUserAndDependencies();
        notifyListeners();
        return _currentUser;
      }
      return null;
    } catch (e) {
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
    _currentUser = null;
    _favorites = [];
    notifyListeners();
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

    final response = await http.put(
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

  Future<List<dynamic>> getLogos() async {
    final token = await getToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse('$_baseUrl/admin/list-logo'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body)['data'] as List<dynamic>;
    }
    return [];
  }

  Future<bool> addLogo(XFile imageFile) async {
    final token = await getToken();
    if (token == null) return false;
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/admin/add-logo'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes('thumbnail', await imageFile.readAsBytes(), filename: imageFile.name));
    } else {
      request.files.add(await http.MultipartFile.fromPath('thumbnail', imageFile.path));
    }

    var response = await request.send();
    return response.statusCode == 200;
  }

  Future<bool> updateLogo(int id, XFile imageFile) async {
    final token = await getToken();
    if (token == null) return false;
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/admin/logo/update/$id'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes('thumbnail', await imageFile.readAsBytes(), filename: imageFile.name));
    } else {
      request.files.add(await http.MultipartFile.fromPath('thumbnail', imageFile.path));
    }

    var response = await request.send();
    return response.statusCode == 200;
  }

  Future<bool> toggleLogoStatus(int id) async {
    final token = await getToken();
    if (token == null) return false;
    final response = await http.patch(
      Uri.parse('$_baseUrl/admin/logo/toggle-status/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteLogo(int id) async {
    final token = await getToken();
    if (token == null) return false;
    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/logo/delete/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
  // Future<List<dynamic>> getProducts() async {
  //   final token = await getToken();
  //   if (token == null) return [];
  //   final response = await http.get(
  //     Uri.parse('$_baseUrl/admin/list-product'),
  //     headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
  //   );
  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body)['data'] as List<dynamic>;
  //   }
  //   return [];
  // }

  Future<List<dynamic>> getProducts() async {
    final token = await getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/list-product'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
          return jsonResponse['data'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }


  Future<bool> deleteProduct(int id) async {
    final token = await getToken();
    if (token == null) return false;
    final response = await http.delete(
      Uri.parse('$_baseUrl/admin/product/delete/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<bool> addProduct(Map<String, String> fields, List<int> sizeIds, List<int> colorIds, XFile? image) async {
    final token = await getToken();
    if (token == null) return false;

    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/admin/add-product-submit'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields.addAll(fields);

    request.fields['size'] = jsonEncode(sizeIds);
    request.fields['color'] = jsonEncode(colorIds);

    if (image != null) {
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes('thumbnail', await image.readAsBytes(), filename: image.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('thumbnail', image.path));
      }
    }

    var response = await request.send();
    return response.statusCode == 200;
  }

  Future<bool> updateProduct(int id, Map<String, String> fields, List<int> sizeIds, List<int> colorIds, XFile? image) async {
    final token = await getToken();
    if (token == null) return false;

    var request = http.MultipartRequest('PATCH', Uri.parse('$_baseUrl/admin/product/update/$id'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields.addAll(fields);

    request.fields['size'] = jsonEncode(sizeIds);
    request.fields['color'] = jsonEncode(colorIds);

    if (image != null) {
      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes('thumbnail', await image.readAsBytes(), filename: image.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('thumbnail', image.path));
      }
    }

    var response = await request.send();
    return response.statusCode == 200;
  }


  Future<Map<String, dynamic>?> getHomeData() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/home'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      }
      return null;
    } catch (e) {
      print('Error fetching home data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProductDetail(String slug) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products/detail/$slug'));
      if (response.statusCode == 200) {

        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching product detail: $e');
      return null;
    }
  }

  Future<bool> addToCart(int productId, int quantity) async {
    if (user == null) return false;
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/cart/add'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'userId': user!['id'], 'proId': productId, 'qty': quantity}),
    );

    if (response.statusCode == 200) {
      await getCartItems();
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> getCartItems() async {
    if (user == null) {
      _cartData = null;
      return null;
    }
    final token = await getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/cart/items?userId=${user!['id']}'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      _cartData = jsonDecode(response.body);
      notifyListeners();
      return _cartData;
    }
    return null;
  }

  // Future<bool> placeOrder({required String phone, required String address}) async {
  //   if (user == null) return false;
  //   final token = await getToken();
  //   if (token == null) return false;
  //
  //   final response = await http.post(
  //     Uri.parse('$_baseUrl/place-order'),
  //     headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
  //     body: jsonEncode({
  //       'userId': user!['id'],
  //       'phone': phone,
  //       'address': address,
  //     }),
  //   );
  //
  //   // ADD THESE LINES TO DEBUG
  //   print('PLACE ORDER STATUS CODE: ${response.statusCode}');
  //   print('PLACE ORDER RESPONSE BODY: ${response.body}');
  //
  //   return response.statusCode == 200;
  // }

  // Future<bool> placeOrder({required String phone, required String address}) async {
  //   if (user == null) return false;
  //   final token = await getToken();
  //   if (token == null) return false;
  //
  //   final response = await http.post(
  //     Uri.parse('$_baseUrl/place-order'),
  //     headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
  //     body: jsonEncode({
  //       'userId': user!['id'],
  //       'phone': phone,
  //       'address': address,
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     await getCartItems();
  //     return true;
  //   }
  //
  //   return false;
  // }
  Future<bool> placeOrder({required String phone, required String address}) async {
    if (user == null) return false;
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/place-order'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'userId': user!['id'],
        'phone': phone,
        'address': address,
      }),
    );

    // ADD THESE LINES TO DEBUG
    print('PLACE ORDER STATUS CODE: ${response.statusCode}');
    print('PLACE ORDER RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      await getCartItems();
      return true;
    }

    return false;
  }

  Future<bool> removeCartItem(int cartItemId) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.get(
      Uri.parse('$_baseUrl/cart-item/$cartItemId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('DELETE ITEM STATUS CODE: ${response.statusCode}');
    print('DELETE ITEM RESPONSE BODY: ${response.body}');

    return response.statusCode == 200;
  }

  Future<List<dynamic>> getMyOrders() async {
    final token = await getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$_baseUrl/my-orders'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'] as List<dynamic>;
    }
    return [];
  }

  Future<bool> cancelOrder(int orderId) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/cancel-order/$orderId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  Future<bool> increaseCartItemQuantity(int cartItemId) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/cart-item/increase/$cartItemId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      await getCartItems();
      return true;
    }
    return false;
  }

  Future<bool> decreaseCartItemQuantity(int cartItemId) async {
    final token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/cart-item/decrease/$cartItemId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      await getCartItems(); // Refresh cart data and notify listeners
      return true;
    }
    return false;
  }
  Future<List<dynamic>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/search?q=$query'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }



  Future<void> getFavorites() async {
    if (user == null) {
      _favorites = [];
      return;
    }
    final token = await getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('$_baseUrl/favorites'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      _favorites = jsonDecode(response.body)['data'] as List;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int productId) async {
    if (user == null) return;
    final token = await getToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse('$_baseUrl/favorites/toggle'),
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode({'product_id': productId}),
    );

    print('TOGGLE FAVORITE STATUS CODE: ${response.statusCode}');
    print('TOGGLE FAVORITE RESPONSE BODY: ${response.body}');

    // Re-fetch the official list from the server to ensure consistency
    await getFavorites();
  }
}


