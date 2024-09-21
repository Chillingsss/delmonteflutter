import 'package:delmonteflutter/candidate/jobdetails.dart';
import 'package:delmonteflutter/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For JSON decoding
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delmonteflutter/candidate/sideBar/sidebar.dart'; // Import your sidebar
// Import the JobDetails page

class CandidateDashboard extends StatefulWidget {
  const CandidateDashboard({Key? key}) : super(key: key);

  @override
  _CandidateDashboardState createState() => _CandidateDashboardState();
}

class _CandidateDashboardState extends State<CandidateDashboard> {
  String userName = '';
  String userEmail = '';
  List<dynamic> jobList = []; // To store the list of jobs

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchJobs(); // Fetch jobs on init
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

  Future<void> _fetchJobs() async {
    final String url =
        "http://localhost/php-delmonte/api/users.php"; // Your URL

    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };

    Map<String, dynamic> body = {
      'operation': 'getActiveJob', // No cand_id needed
    };

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      setState(() {
        jobList = json.decode(response.body); // Decode the JSON response
      });
    } else {
      // Handle errors if needed
      print('Failed to load jobs');
    }
  }

  Future<bool> _onWillPop() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    return !isLoggedIn; // Prevent back navigation if logged in
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/delmonte.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          title: const Text('Candidate Dashboard'),
        ),
        drawer: Drawer(
          child: SideBar(
            userName: userName,
            userEmail: userEmail,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $userName!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                userEmail,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              const Text(
                'Active Jobs:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: jobList.length,
                  itemBuilder: (context, index) {
                    return _buildApplicationItem(jobList[index]);
                  },
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

  Widget _buildApplicationItem(Map<String, dynamic> job) {
    return Card(
      child: ListTile(
        title: Text(job['jobM_title']),
        subtitle: Text('Posted on: ${job['jobM_createdAt']}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetails(jobDetails: job),
            ),
          );
        },
      ),
    );
  }
}
