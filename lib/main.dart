import 'package:delmonteflutter/candidate/dashboard.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

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

    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        if (userData != null) {
          // Store user data in session storage
          await _storeUserData(userData);
          print('Login successful: $userData');

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_logged_in', true);

          // Navigate to the appropriate screen based on user type
          if (userData.containsKey('cand_id')) {
            Navigator.push(
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
          // Login failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid credentials')),
          );
        }
      } else {
        // Error in API call
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error connecting to server')),
        );
      }
    }
  }

  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));

    // Store individual fields for easier access
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
      await prefs.setString('user_id', userData['cand_id'].toString());
      await prefs.setString('user_name',
          '${userData['cand_firstname']} ${userData['cand_lastname']}');
      await prefs.setString('user_email', userData['cand_email']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to sign up page
                  print('Navigate to sign up page');
                },
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
