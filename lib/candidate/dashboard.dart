import 'package:delmonteflutter/candidate/jobdetails.dart';
import 'package:delmonteflutter/candidate/viewProfile/viewProfile.dart';
import 'package:delmonteflutter/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delmonteflutter/candidate/sideBar/sidebar.dart';

class CandidateDashboard extends StatefulWidget {
  const CandidateDashboard({Key? key}) : super(key: key);

  @override
  _CandidateDashboardState createState() => _CandidateDashboardState();
}

class _CandidateDashboardState extends State<CandidateDashboard> {
  String userName = '';
  String userEmail = '';
  List<dynamic> jobList = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchJobs();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LandingPage()),
      );
    }

    setState(() {
      userName = prefs.getString('user_name') ?? 'Candidate';
      userEmail = prefs.getString('user_email') ?? 'No email';
    });
  }

  Future<void> _fetchJobs() async {
    const String url = "http://localhost/php-delmonte/api/users.php";

    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };

    Map<String, dynamic> body = {
      'operation': 'getActiveJob',
    };

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      setState(() {
        jobList = json.decode(response.body);
      });
    } else {
      print('Failed to load jobs');
    }
  }

  Future<bool> _onWillPop() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    return !isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: Drawer(
          child: SideBar(
            userName: userName,
            userEmail: userEmail,
          ),
        ),
        body: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer(); // Open sidebar
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          child: Image.asset(
                            'assets/images/delmonte.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Explore Exciting Careers at Del Monte",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewProfile(userId: userName),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Active Jobs:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9E9E9E),
                  ),
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
        ),
      ),
    );
  }

  Widget _buildApplicationItem(Map<String, dynamic> job) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetails(jobDetails: job),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A6338),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                job['jobM_title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Posted on: ${job['jobM_createdAt']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Total Applied: ${job['Total_Applied']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, bottom: 16),
                child: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
