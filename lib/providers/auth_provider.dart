import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comparathor_device/core/api_service.dart';

class AuthState {
  final String? userEmail;
  final String? username;
  final bool isAuthenticated;

  AuthState({this.userEmail, this.username, this.isAuthenticated = false});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  final ApiService _apiService = ApiService();

  // Login & Fetch User Data
  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      await fetchUserSettings(); // Fetch user details after login
    } catch (e) {
      throw Exception("Login failed");
    }
  }

  // Fetch User Settings
  Future<void> fetchUserSettings() async {
    try {
      final data = await _apiService.fetchUserSettings();
      state = AuthState(
        userEmail: data["email"],
        username: data["username"],
        isAuthenticated: true,
      );
    } catch (e) {
      print("Error fetching user settings: $e");
    }
  }

  // Update User Settings
  Future<void> updateUser(String email, String username) async {
    try {
      await _apiService.updateUserSettings({"email": email, "username": username});
      state = AuthState(userEmail: email, username: username, isAuthenticated: state.isAuthenticated);
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  // Logout (Ensure Token is Removed & State Updates)
  Future<void> logout() async {
    await _apiService.logout(); // Remove token from SharedPreferences
    state = AuthState(userEmail: null, username: null, isAuthenticated: false); // Update state

    print("User logged out, token removed."); // Debugging log
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
