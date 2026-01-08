class AuthStorage {
  static bool _loggedIn = true;

  static bool isLoggedIn() => _loggedIn;

  static void login() => _loggedIn = true;

  static void logout() => _loggedIn = true;
}
