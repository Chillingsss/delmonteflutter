import 'package:delmonteflutter/candidate/dashboard.dart';
import 'package:delmonteflutter/candidate/notficationService.dart';
import 'package:delmonteflutter/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

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
  final _calculationController = TextEditingController();
  String userName = '';
  String userEmail = '';
  int _num1 = 0;
  int _num2 = 0;
  bool _isCalculationCorrect = true;

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
    _generateCalculation();
  }

  void _generateCalculation() {
    setState(() {
      _num1 = Random().nextInt(10) + 1; // 1 to 10
      _num2 = Random().nextInt(10) + 1; // 1 to 10
    });
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty && _passwordController.text.isEmpty) {
      NotificationService.showNotification(
          context, 'Please enter your username and password',
          isSuccess: false);
      return;
    }

    if (_usernameController.text.isEmpty) {
      NotificationService.showNotification(
          context, 'Please enter your username',
          isSuccess: false);
      return;
    }

    // Check if password is empty
    if (_passwordController.text.isEmpty) {
      NotificationService.showNotification(
          context, 'Please enter your password',
          isSuccess: false);
      return;
    }

    // Check if calculation is empty
    if (_calculationController.text.isEmpty) {
      NotificationService.showNotification(
          context, 'Please answer the calculation',
          isSuccess: false);
      return;
    }

    // Verify calculation
    int userAnswer = int.tryParse(_calculationController.text) ?? 0;
    if (userAnswer != _num1 + _num2) {
      NotificationService.showNotification(context, 'Incorrect answer',
          isSuccess: false);
      _generateCalculation(); // Generate a new calculation
      _calculationController.clear(); // Clear the input field
      return;
    }

    // Existing login logic
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

  void _validateCalculation(String value) {
    int? userAnswer = int.tryParse(value);
    setState(() {
      _isCalculationCorrect = userAnswer == (_num1 + _num2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF014D30),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF014D30),
                    const Color(0xFF013720),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/delmonte.png',
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Del Monte',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    _buildTextField(
                        _usernameController, 'Username', Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildTextField(
                        _passwordController, 'Password', Icons.lock_outline,
                        isPassword: true),
                    const SizedBox(height: 16),
                    _buildCalculationField(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008C44),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'SIGN IN',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Navigate to register page
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to forgot password page
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
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
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: const Color(0xFF008C44), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationField() {
    return Container(
      height: 50, // Reduced height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the row contents
        children: [
          _buildNumberCard(_num1.toString()),
          SizedBox(width: 8), // Reduced spacing
          _buildOperatorCard('+'),
          SizedBox(width: 8), // Reduced spacing
          _buildNumberCard(_num2.toString()),
          SizedBox(width: 8), // Reduced spacing
          _buildOperatorCard('='),
          SizedBox(width: 8), // Reduced spacing
          _buildAnswerCard(),
        ],
      ),
    );
  }

  Widget _buildNumberCard(String number) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: EdgeInsets.zero,
      child: Container(
        width: 80, // Fixed width for number cards
        height: 80, // Fixed height for number cards
        alignment: Alignment.center,
        child: Text(
          number,
          style:
              TextStyle(color: Colors.white, fontSize: 18), // Reduced font size
        ),
      ),
    );
  }

  Widget _buildOperatorCard(String operator) {
    return Text(
      operator,
      style: TextStyle(color: Colors.white, fontSize: 18), // Reduced font size
    );
  }

  Widget _buildAnswerCard() {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _isCalculationCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Container(
        width: 80, // Fixed width for answer card
        height: 80, // Fixed height for answer card
        child: TextField(
          controller: _calculationController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '?',
            hintStyle: TextStyle(color: Colors.white54, fontSize: 18),
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            _validateCalculation(value);
          },
        ),
      ),
    );
  }
}
