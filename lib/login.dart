import 'package:delmonteflutter/candidate/dashboard.dart';
import 'package:delmonteflutter/candidate/notficationService.dart';
import 'package:delmonteflutter/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String userName = '';
  String userEmail = '';

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CandidateDashboard()),
      );
    }

    setState(() {
      userName = prefs.getString('user_name') ?? 'Candidate';
      userEmail = prefs.getString('user_email') ?? 'No email';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _login() async {
    String url = "http://localhost/php-delmonte/api/users.php";

    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded"
    };

    Map<String, dynamic> body = {
      'operation': 'login',
      'json': jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        if (userData != null) {
          await _storeUserData(userData);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);

          NotificationService.showNotification(context, 'Login successful!',
              isSuccess: true);

          if (userData.containsKey('cand_id')) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CandidateDashboard(),
              ),
            );
          } else if (userData.containsKey('adm_id')) {
            // Navigate to admin dashboard
          } else if (userData.containsKey('sup_id')) {
            // Navigate to supervisor dashboard
          }
        } else {
          NotificationService.showNotification(context, 'Invalid credentials',
              isSuccess: false);
        }
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error connecting to server')),
      );
    }
  }

  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));

    if (userData.containsKey('adm_id')) {
      await prefs.setString('user_type', 'admin');
      await prefs.setString('user_id', userData['adm_id'].toString());
      await prefs.setString('user_name', userData['adm_name']);
      await prefs.setString('user_email', userData['adm_email']);
    } else if (userData.containsKey('sup_id')) {
      await prefs.setString('user_type', 'supervisor');
      await prefs.setString('user_id', userData['sup_id'].toString());
      await prefs.setString('user_name', userData['sup_name']);
      await prefs.setString('user_email', userData['sup_email']);
    } else if (userData.containsKey('cand_id')) {
      await prefs.setString('user_type', 'applicant');
      await prefs.setInt('cand_id', userData['cand_id']);
      await prefs.setString('user_name',
          '${userData['cand_firstname']} ${userData['cand_lastname']}');
      await prefs.setString('user_email', userData['cand_email']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF014D30),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Center(
                    child: Image.asset(
                      'assets/images/delmonte.png',
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Welcome to',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                    ),
                  ),
                  const Text(
                    'DELMONTE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF013720),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: const Color(0xFF013720),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008C44),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to register page
                        },
                        child: const Text(
                          'Create account here',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to forgot password page
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LandingPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
