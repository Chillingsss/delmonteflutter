class SessionManager {
  static bool _isLoggedIn = false;
  static Map<String, dynamic>? _userData;
  static String? _userType;
  static String? _userId;
  static String? _userName;
  static String? _userEmail;

  static bool get isLoggedIn => _isLoggedIn;
  static set isLoggedIn(bool value) => _isLoggedIn = value;

  static Map<String, dynamic>? get userData => _userData;
  static set userData(Map<String, dynamic>? value) => _userData = value;

  static String? get userType => _userType;
  static set userType(String? value) => _userType = value;

  static String? get userId => _userId;
  static set userId(String? value) => _userId = value;

  static String? get userName => _userName;
  static set userName(String? value) => _userName = value;

  static String? get userEmail => _userEmail;
  static set userEmail(String? value) => _userEmail = value;

  static void clear() {
    _isLoggedIn = false;
    _userData = null;
    _userType = null;
    _userId = null;
    _userName = null;
    _userEmail = null;
  }
}