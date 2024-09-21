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
    fetchAppliedJobs(); // Fetch jobs when the sidebar is initialized
  }

  // Fetch applied jobs from backend using cand_id from SharedPreferences
  Future<void> fetchAppliedJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final candId = prefs.getInt('cand_id');

      print('Candidate ID from SharedPreferences: $candId');

      if (candId == null) {
        print('Error: cand_id is null');
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

      // Define the body with the operation and cand_id
      Map<String, dynamic> body = {
        'operation': 'getAppliedJobs',
        'cand_id': candId.toString(),
      };

      // Send POST request
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      // Check if the response is successful
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
          print('Error from server: ${data['error']}');
          setState(() {
            hasError = true;
            isLoading = false;
          });
        } else {
          print('Unexpected response format: $data');
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF0A6338),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/delmonte.png',
                    width: 100,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Centered Applied Jobs Section
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : hasError
                    ? const Center(child: Text('Error loading jobs'))
                    : appliedJobs.isEmpty
                        ? const Center(child: Text('No applied jobs found'))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: appliedJobs.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(appliedJobs[index]),
                                leading: Icon(Icons.work),
                              );
                            },
                          ),
          ),

          Spacer(),

          // Settings and Logout at the bottom
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  // Navigate to settings page
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  // Handle logout functionality
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
        ],
      ),
    );
  }
}
