import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'educationalBackground.dart';
import 'employmentHistory.dart';
import 'knowledge.dart';
import 'license.dart';
import 'profileInformation.dart';
import 'resume.dart';
import 'skills.dart';
import 'training.dart';

class ViewProfile extends StatefulWidget {
  final String userId;

  const ViewProfile({Key? key, required this.userId}) : super(key: key);

  @override
  _ViewProfileState createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  Map<String, dynamic> profile = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    const String url = "http://localhost/php-delmonte/api/users.php";

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('cand_id');

    if (userId == null) {
      print('user_id is null');
      setState(() {
        isLoading = false;
      });
      return;
    }

    Map<String, dynamic> jsonData = {
      'cand_id': userId,
    };

    Map<String, dynamic> body = {
      'operation': 'getCandidateProfile',
      'json': json.encode(jsonData),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          profile = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print(
            'Failed to load profile data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF0A6338),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile.isEmpty
              ? const Center(child: Text('No profile data available'))
              : ListView(
                  children: [
                    _buildProfileSection('Profile Information', Icons.person,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileInformation(
                            data: profile['candidateInformation'] ?? {},
                          ),
                        ),
                      );
                    }),
                    _buildProfileSection('Educational Background', Icons.school,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EducationalBackground(
                            data: profile['educationalBackground'] ?? [],
                          ),
                        ),
                      );
                    }),
                    _buildProfileSection('Employment History', Icons.work, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmploymentHistory(
                            data: profile['employmentHistory'] ?? {},
                          ),
                        ),
                      );
                    }),
                    _buildProfileSection('Skills', Icons.psychology, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Skills(
                            data: profile['skills'] ?? [],
                          ),
                        ),
                      );
                    }),
                    _buildProfileSection('Training', Icons.book, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Training(
                            data: profile['training'] ?? [],
                          ),
                        ),
                      );
                    }),
                    _buildProfileSection('Knowledge', Icons.lightbulb, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Knowledge(
                            data: profile['knowledge'] ?? [],
                          ),
                        ),
                      );
                    }),
                    _buildProfileSection('License', Icons.card_membership, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => License(
                            data: profile['license'] ?? [],
                          ),
                        ),
                      );
                    }),
                    _buildProfileSection('Resume', Icons.description, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Resume(
                            data: profile['resume'] ?? [],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }

  Widget _buildProfileSection(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0A6338)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
