import 'dart:convert';
import 'package:delmonteflutter/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SideBar extends StatefulWidget {
  final String userName;
  final String userEmail;

  const SideBar({Key? key, required this.userName, required this.userEmail})
      : super(key: key);

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  List<String> appliedJobs = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchAppliedJobs();
  }

  Future<void> fetchAppliedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final candId = prefs.getInt('cand_id');

      if (candId == null) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
        return;
      }

      String url = "http://localhost/php-delmonte/api/users.php";

      Map<String, String> headers = {
        "Content-Type": "application/x-www-form-urlencoded",
      };

      Map<String, dynamic> body = {
        'operation': 'getAppliedJobs',
        'cand_id': candId.toString(),
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          setState(() {
            appliedJobs =
                List<String>.from(data.map((job) => job['jobM_title']));
            isLoading = false;
          });
        } else if (data is Map<String, dynamic> &&
            data.containsKey('message')) {
          setState(() {
            appliedJobs = [];
            isLoading = false;
          });
        } else if (data is Map<String, dynamic> && data.containsKey('error')) {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      // print('Exception: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Adjust the width as needed
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0A6338),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/images/delmonte.png'),
                          fit: BoxFit.contain,
                        ),
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Del Monte",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.dashboard, color: Color(0xFF0A6338)),
                  title: const Text('Dashboard'),
                  onTap: () {
                    // Navigate to dashboard
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Applied Jobs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A6338),
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : hasError
                          ? const Center(child: Text('Error loading jobs'))
                          : appliedJobs.isEmpty
                              ? const Center(
                                  child: Text('No applied jobs found'))
                              : ListView.builder(
                                  itemCount: appliedJobs.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          appliedJobs[index],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        leading: const Icon(Icons.work,
                                            color: Color(0xFF0A6338)),
                                        trailing:
                                            const Icon(Icons.chevron_right),
                                        onTap: () {
                                          // Navigate to job details
                                        },
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF0A6338)),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings page
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LandingPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
