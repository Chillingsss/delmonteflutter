import 'dart:convert';
import 'dart:math' as math;
import 'package:delmonteflutter/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SideBar extends StatefulWidget {
  final String userName;
  final String userEmail;

  const SideBar({super.key, required this.userName, required this.userEmail});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> appliedJobs = [];
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fetchAppliedJobs();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchAppliedJobs() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final candId = prefs.getInt('cand_id');

      if (candId == null) {
        throw Exception('cand_id not found in SharedPreferences');
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
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          appliedJobs = data
              .map((job) => {
                    'title': job['jobM_title'] as String? ?? 'Unknown Title',
                    'status': job['status_name'] as String? ?? 'Unknown Status',
                  })
              .toList();
          isLoading = false;
        });

        if (appliedJobs.isEmpty) {
          // print('No applied jobs found');
        }
      } else {
        throw Exception('HTTP error ${response.statusCode}');
      }
    } catch (e) {
      // print('Exception in fetchAppliedJobs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time; // Changed to a clock icon
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'process':
        return Icons.hourglass_bottom;
      default:
        return Icons.info;
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : appliedJobs.isEmpty
                    ? _buildEmptyJobsWidget()
                    : SingleChildScrollView(
                        child: Column(
                          children: appliedJobs
                              .map((job) => _buildJobTile(job))
                              .toList(),
                        ),
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

  Widget _buildEmptyJobsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text('No applied jobs found', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildJobTile(Map<String, dynamic> job) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      title: Text(
        job['title'] ?? '',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            _buildStatusIcon(job['status'] ?? ''),
            SizedBox(width: 8),
            Text(
              job['status'] ?? '',
              style: TextStyle(
                color: _getStatusColor(job['status'] ?? ''),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Color(0xFF0A6338)),
      onTap: () {
        // Navigate to job details
      },
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData iconData = _getStatusIcon(status);
    Color color = _getStatusColor(status);

    switch (status.toLowerCase()) {
      case 'process':
        return RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
          child: Icon(iconData, size: 16, color: color),
        );
      case 'pending':
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + 0.2 * _animationController.value,
              child: Icon(iconData, size: 16, color: color),
            );
          },
        );
      default:
        return Icon(iconData, size: 16, color: color);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'process':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
