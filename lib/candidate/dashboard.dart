import 'package:delmonteflutter/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CandidateDashboard extends StatefulWidget {
  const CandidateDashboard({Key? key}) : super(key: key);

  @override
  _CandidateDashboardState createState() => _CandidateDashboardState();
}

class _CandidateDashboardState extends State<CandidateDashboard> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }

    setState(() {
      userName = prefs.getString('user_name') ?? 'Candidate';
      userEmail = prefs.getString('user_email') ?? 'No email';
    });
  }

  Future<bool> _onWillPop() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    // If the user is logged in, prevent going back
    if (isLoggedIn) {
      return false; // Prevent the back navigation
    }

    return true; // Allow back navigation if not logged in
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/delmonte.png', // Path to your logo image
              fit: BoxFit.contain,
            ),
          ),
          title: const Text('Candidate Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Navigate to LoginPage
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome, $userName!',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(userEmail, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              const Text('Your Applications:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    // TODO: Replace with actual application data
                    _buildApplicationItem('Software Developer', 'Applied'),
                    _buildApplicationItem('Data Analyst', 'Under Review'),
                    _buildApplicationItem('UX Designer', 'Rejected'),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement new application functionality
            print('New application button pressed');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildApplicationItem(String jobTitle, String status) {
    return Card(
      child: ListTile(
        title: Text(jobTitle),
        subtitle: Text('Status: $status'),
        trailing:
            const Icon(Icons.arrow_forward_ios), // Keep or remove if necessary
        onTap: () {
          // TODO: Navigate to application details
          print('Tapped on $jobTitle application');
        },
      ),
    );
  }
}
