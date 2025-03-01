import 'package:dio/dio.dart'; // Importing Dio for HTTP requests
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importing dotenv for environment variables
import 'package:shared_preferences/shared_preferences.dart'; // Importing SharedPreferences for local storage

// API Service class for handling network requests
class ApiService {
  // Initialize Dio instance with base URL from environment variables
  final Dio _dio = Dio(BaseOptions(
    baseUrl: dotenv.env['API_BASE_URL'] != null
        ? "${dotenv.env['API_BASE_URL']}/api/v1" // If API_BASE_URL is set, use it
        : 'http://localhost:8000/api/v1', // Default to localhost if no env variable is found
  ));

  // Generic POST request
  Future<Response> postRequest(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(endpoint, data: data); // Make POST request
      return response; // Return the response
    } catch (e) {
      throw Exception("Failed to connect to API"); // Handle errors
    }
  }

  // Generic GET request
  Future<Response> getRequest(String endpoint) async {
    try {
      final response = await _dio.get(endpoint); // Make GET request
      return response; // Return the response
    } catch (e) {
      throw Exception("Failed to connect to API"); // Handle errors
    }
  }

  // Save authentication token to local storage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
    await prefs.setString('auth_token', token); // Save token as a string
  }

  // Retrieve authentication token from local storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
    return prefs.getString('auth_token'); // Retrieve token from local storage
  }

  // Logout: Remove authentication token from storage
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
    await prefs.remove('auth_token'); // Remove token
  }

  // Fetch product details by ID
  Future<Response> getProductDetails(int productId) async {
    try {
      final response = await _dio.get("/products/$productId"); // GET request
      return response;
    } catch (e) {
      throw Exception("Failed to load product details"); // Handle errors
    }
  }

  // Add a new product
  Future<Response> addProduct(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post("/products", data: productData); // POST request
      return response;
    } catch (e) {
      throw Exception("Failed to add product"); // Handle errors
    }
  }

  // Update existing product by ID
  Future<Response> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      final response = await _dio.put("/products/$productId", data: productData); // PUT request
      return response;
    } catch (e) {
      throw Exception("Failed to update product"); // Handle errors
    }
  }

  // Delete product by ID
  Future<Response> deleteProduct(int productId) async {
    try {
      final response = await _dio.delete("/products/$productId"); // DELETE request
      return response;
    } catch (e) {
      throw Exception("Failed to delete product"); // Handle errors
    }
  }

  // Create a new comparison
  Future<Response> createComparison(Map<String, dynamic> comparisonData) async {
    try {
      final response = await _dio.post("/comparisons", data: comparisonData); // POST request
      return response;
    } catch (e) {
      throw Exception("Failed to create comparison"); // Handle errors
    }
  }

  // Get all comparisons
  Future<Response> getComparisons() async {
    try {
      final response = await _dio.get("/comparisons"); // GET request
      return response;
    } catch (e) {
      throw Exception("Failed to fetch comparisons"); // Handle errors
    }
  }

  // Get comparison details by ID
  Future<Response> getComparisonDetails(int comparisonId) async {
    try {
      final response = await _dio.get("/comparisons/$comparisonId"); // GET request
      return response;
    } catch (e) {
      throw Exception("Failed to load comparison details"); // Handle errors
    }
  }

  // Get sorted comparison details by attribute
  Future<Response> getSortedComparisonDetails(int comparisonId, String sortBy) async {
    try {
      final response = await _dio.get(
        "/comparisons/$comparisonId",
        queryParameters: {"sort_by": sortBy}, // Pass sorting attribute as a query parameter
      );
      return response;
    } catch (e) {
      throw Exception("Failed to load sorted comparison details"); // Handle errors
    }
  }

  // Caching API responses using SharedPreferences
  Future<Response> getCachedData(String endpoint) async {
    final prefs = await SharedPreferences.getInstance(); // Get SharedPreferences instance
    String? cachedData = prefs.getString(endpoint); // Retrieve cached data

    if (cachedData != null) {
      // If cached data exists, return it as a Response object
      return Response(
          requestOptions: RequestOptions(path: endpoint), data: cachedData);
    }

    // Otherwise, make API request and cache the result
    final response = await _dio.get(endpoint);
    await prefs.setString(endpoint, response.data.toString()); // Save to cache
    return response;
  }

  // Authenticate user (Login)
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post("/auth/login", data: {
        "email": email, // Send email
        "password": password, // Send password
      });

      final token = response.data["token"]; // Extract token from response
      await saveToken(token); // Save token locally
      return response;
    } catch (e) {
      throw Exception("Failed to login"); // Handle login errors
    }
  }

  // Fetch user settings (Profile Data)
  Future<Map<String, dynamic>> fetchUserSettings() async {
    try {
      final response = await _dio.get("/user/settings"); // GET user settings
      return response.data; // Return user data
    } catch (e) {
      throw Exception("Failed to fetch user settings"); // Handle errors
    }
  }

  // Update user settings (Profile Data)
  Future<void> updateUserSettings(Map<String, dynamic> updatedData) async {
    try {
      await _dio.put("/user/settings", data: updatedData); // PUT request
    } catch (e) {
      throw Exception("Failed to update settings"); // Handle errors
    }
  }
}
