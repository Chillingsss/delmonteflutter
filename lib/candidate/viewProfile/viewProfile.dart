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
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Professional Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A6338),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile.isEmpty
              ? const Center(child: Text('No profile data available'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildProfileSection('Profile Information', Icons.person,
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileInformation(
                                    data: profile['candidateInformation'] ??
                                        {})));
                      }),
                      _buildProfileSection(
                          'Educational Background', Icons.school, () async {
                        final prefs = await SharedPreferences.getInstance();
                        final candId =
                            prefs.getInt('cand_id')?.toString() ?? '';
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EducationalBackground(
                                    data:
                                        profile['educationalBackground'] ?? [],
                                    candId: int.parse(candId))));
                      }),
                      _buildProfileSection('Employment History', Icons.work,
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EmploymentHistory(
                                    data: profile['employmentHistory'] ?? {})));
                      }),
                      _buildProfileSection('Skills', Icons.psychology, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Skills(data: profile['skills'] ?? [])));
                      }),
                      _buildProfileSection('Training', Icons.book, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Training(data: profile['training'] ?? [])));
                      }),
                      _buildProfileSection('Knowledge', Icons.lightbulb, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Knowledge(
                                    knowledgeList:
                                        profile['knowledge'] ?? [])));
                      }),
                      _buildProfileSection('License', Icons.card_membership,
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => License(
                                    licenses: profile['license'] ?? [])));
                      }),
                      _buildProfileSection('Resume', Icons.description, () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Resume(data: profile['resume'] ?? [])));
                      }),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 60, color: Color(0xFF0A6338)),
          ),
          const SizedBox(height: 10),
          Text(
            '${profile['candidateInformation']?['cand_firstname'] ?? ''} ${profile['candidateInformation']?['cand_lastname'] ?? ''}',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0A6338).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0A6338)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
