import 'package:delmonteflutter/candidate/dashboard.dart';
import 'package:delmonteflutter/candidate/notficationService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ExamPage extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  final String appId;

  const ExamPage(
      {Key? key,
      required this.jobId,
      required this.jobTitle,
      required this.appId})
      : super(key: key);

  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  List<dynamic>? examData;
  bool loading = true;
  String? error;
  Map<String, String> selectedAnswers = {};
  int? examId;
  List<int> questionPoints = []; // Define questionPoints as a list of integers

  @override
  void initState() {
    super.initState();
    fetchExamData();
  }

  Future<void> fetchExamData() async {
    const url = 'http://localhost/php-delmonte/api/users.php';
    final jsonData = {'jobM_id': widget.jobId};

    // Create FormData
    final formData = {
      'operation': 'getJobExam',
      'json': json.encode(jsonData),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: formData,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          examData = data['examQuestions'];
          loading = false;

          // Set examId from the first question if available

          examId = examData?[0]['exam_id'];

          print('Exam ID: $examId');

          // Populate questionPoints based on the fetched exam data
          questionPoints =
              (data['examQuestions'] as List<dynamic>).map<int>((q) {
            // Ensure that 'examQ_points' is an integer
            return (q['examQ_points'] is int)
                ? q['examQ_points']
                : 0; // Default to 0 if not an int
          }).toList();
          print(questionPoints);
        });
      } else {
        // Log the response body for debugging
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load exam data');
      }
    } catch (e) {
      // Log the error for debugging
      print('Exception: $e');
      setState(() {
        error = 'Failed to load exam data: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam for ${widget.jobTitle}'),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : examData != null
                  ? Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: examData!.length,
                            itemBuilder: (context, index) {
                              final question = examData![index];
                              return Card(
                                child: ListTile(
                                  title: Text(question['examQ_text']),
                                  subtitle: Column(
                                    children: question['choices']
                                        .map<Widget>((choice) {
                                      return RadioListTile<String>(
                                        title: Text(choice['examC_text']),
                                        value: choice['examC_id'].toString(),
                                        groupValue: selectedAnswers[
                                            question['examQ_id'].toString()],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedAnswers[question['examQ_id']
                                                .toString()] = value!;
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              await handleSubmit();
                            },
                            child: Text('Submit Exam'),
                          ),
                        ),
                      ],
                    )
                  : Center(child: Text('No exam data found.')),
    );
  }

  Future<void> handleSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    final candidateId = prefs.getInt('cand_id');
    const url = 'http://localhost/php-delmonte/api/users.php';

    try {
      int totalScore = 0;

      // Map selectedAnswers to create a list of answers
      List<Map<String, dynamic>> answers =
          selectedAnswers.keys.map((questionId) {
        final question =
            examData!.firstWhere((q) => q['examQ_id'].toString() == questionId);

        final selectedChoiceId =
            int.tryParse(selectedAnswers[questionId] ?? '');

        if (question == null) {
          print('Question with ID $questionId not found in examData.');
          return {
            'question_id': questionId,
            'multiple_choice_answer': selectedChoiceId,
            'essay_answer': null,
            'points_earned': 0,
          };
        }

        // Debug: Print the full choices for the question
        print('Choices for Question ID $questionId: ${question['choices']}');

        // Try to find the selected choice in the question's choices
        final selectedChoice = question['choices'].firstWhere(
            (choice) => choice['examC_id'] == selectedChoiceId, orElse: () {
          print('Error: Selected choice not found for ID $selectedChoiceId');
          return null; // If not found, return null
        });
        int pointsEarned = 0;

        if (selectedChoice != null) {
          print('Selected choice data: $selectedChoice');
          print(
              'Is Correct: ${selectedChoice['examC_isCorrect']}, Choice ID: ${selectedChoice['examC_id']}');

          if (selectedChoice['examC_isCorrect'] == 1) {
            final questionIndex = examData!
                .indexWhere((q) => q['examQ_id'].toString() == questionId);

            if (questionIndex != -1) {
              print(
                  'Question Points for ID $questionId: ${questionPoints[questionIndex]}');
              totalScore += questionPoints[questionIndex];
              pointsEarned = questionPoints[questionIndex];
            } else {
              print('Error: Question index not found for ID $questionId');
            }
          } else {
            print('Selected answer is incorrect, no points awarded.');
          }
        }

        return {
          'question_id': questionId,
          'multiple_choice_answer': selectedChoiceId,
          'essay_answer': null,
          'points_earned': pointsEarned,
        };
      }).toList();

      // Debugging: print total score
      print('Total Score Calculated: $totalScore');

      // Prepare result data
      final resultData = {
        'examR_candId': candidateId,
        'examR_examId': examId,
        'examR_score': totalScore,
        'app_id': widget.appId, // Add app_id to the result data
      };

      print('Result data: $resultData');

      // Prepare result form data
      var resultFormData = new http.MultipartRequest('POST', Uri.parse(url))
        ..fields['operation'] = 'insertExamResult'
        ..fields['json'] = json.encode(resultData);

      final resultResponse = await resultFormData.send();
      final resultResponseData =
          json.decode(await resultResponse.stream.bytesToString());

      final success = resultResponseData['success'];
      final examR_id = resultResponseData['examR_id'];

      if (!success || examR_id == null) {
        throw Exception('Failed to insert exam result.');
      }

      // Prepare answer data
      final answerData = {
        'examR_id': examR_id,
        'answers': answers,
      };

      // Prepare answer form data
      var answerFormData = new http.MultipartRequest('POST', Uri.parse(url))
        ..fields['operation'] = 'insertCandidateAnswers'
        ..fields['json'] = json.encode(answerData);

      final answerResponse = await answerFormData.send();
      final answerResponseData =
          json.decode(await answerResponse.stream.bytesToString());

      if (answerResponseData['success']) {
        print('Exam submitted successfully!');
        // Show notification on success
        NotificationService.showNotification(
            context, 'Exam submitted successfully!',
            isSuccess: true);
        // Navigate to CandidateDashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CandidateDashboard()),
        );
      } else {
        print('Error submitting answers: ${answerResponseData['message']}');
      }
    } catch (error) {
      print('Failed to submit exam and answers: $error');
    }
  }
}
