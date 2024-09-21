import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class JobDetails extends StatelessWidget {
  final Map<String, dynamic> jobDetails;

  const JobDetails({Key? key, required this.jobDetails}) : super(key: key);

  Future<void> _applyForJob(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('cand_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to log in to apply for jobs.')),
      );
      return;
    }

    final String url = "http://localhost/php-delmonte/api/users.php";
    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    };

    Map<String, dynamic> body = {
      'operation': 'applyForJob',
      'user_id': userId.toString(),
      'jobId': jobDetails['jobM_id'].toString(),
    };

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['success'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['success'])),
        );
      } else if (result['status'] == 'duplicate') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      } else if (result['error'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to apply for the job.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        elevation: 0,
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextButton(
              onPressed: () => _applyForJob(context),
              child: const Text(
                'Apply',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildDetailsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jobDetails['jobM_title'],
            style: Theme.of(context)
                .textTheme
                .headline5
                ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Total Applied: ${jobDetails['Total_Applied']}',
            style: Theme.of(context)
                .textTheme
                .subtitle1
                ?.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem(
              context, 'Description', jobDetails['jobM_description']),
          _buildDetailItem(context, 'Duties', jobDetails['duties_text'],
              isList: true),
          _buildDetailItem(context, 'Education', jobDetails['jeduc_text']),
          _buildDetailItem(context, 'Work Responsibilities',
              jobDetails['jwork_responsibilities']),
          _buildDetailItem(
              context, 'Work Duration', jobDetails['jwork_duration']),
          _buildDetailItem(context, 'Knowledge', jobDetails['jknow_text']),
          _buildDetailItem(
              context, 'Knowledge Name', jobDetails['knowledge_name']),
          _buildDetailItem(context, 'Skills', jobDetails['jskills_text']),
          _buildDetailItem(context, 'Training', jobDetails['jtrng_text']),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String title, dynamic content,
      {bool isList = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .subtitle1
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          if (content != null)
            if (isList)
              ...content.toString().split('|').map((item) => Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                            child: Text(item.trim(),
                                style: Theme.of(context).textTheme.bodyText2)),
                      ],
                    ),
                  ))
            else
              Text(content.toString(),
                  style: Theme.of(context).textTheme.bodyText2)
          else
            Text('Not specified',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.copyWith(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
