// lib/screens/applicant_review_screen.dart
import 'package:flutter/material.dart';
import '../services/application_service.dart';
import '../models/application.dart';

class ApplicantReviewScreen extends StatefulWidget {
  const ApplicantReviewScreen({super.key});

  @override
  State<ApplicantReviewScreen> createState() => _ApplicantReviewScreenState();
}

class _ApplicantReviewScreenState extends State<ApplicantReviewScreen> {
  late int _jobId;
  String? _jobTitle;
  List<Application> _applications = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['jobId'] != null) {
      _jobId = args['jobId'] as int;
      _jobTitle = args['jobTitle'] as String?;
      _fetchApplications();
    } else {
      setState(() {
        _applications = [];
        _isLoading = false;
      });
      Future.microtask(() => Navigator.maybePop(context));
    }
  }

  Future<void> _fetchApplications() async {
    setState(() => _isLoading = true);
    try {
      final apps = await ApplicationService().getJobApplications(_jobId);
      setState(() {
        _applications = apps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching applications: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateStatus(int applicationId, String status) async {
    final success = await ApplicationService().updateApplicationStatus(
      applicationId: applicationId,
      status: status,
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status successfully updated to: $status"),
          backgroundColor: Colors.green,
        ),
      );
      _fetchApplications(); // Reloads list from Node backend instantly
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${_jobTitle ?? 'Applicants'} • ${_applications.length} Total",
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
          ? const Center(child: Text("No applications yet for this job."))
          : ListView(
              padding: const EdgeInsets.all(12),
              children: _applications
                  .map((app) => _applicantTile(app))
                  .toList(),
            ),
    );
  }

  Widget _applicantTile(Application app) {
    Color matchColor;
    String matchLabel;

    // 🛠️ FIXED: Convert to lowercase to prevent database casing mismatches from breaking UI labels
    final normalizedStatus = app.status.toLowerCase().trim();

    switch (normalizedStatus) {
      case 'accepted':
        matchColor = Colors.green;
        matchLabel = "Accepted";
        break;
      case 'rejected':
        matchColor = Colors.red;
        matchLabel = "Rejected";
        break;
      case 'interview_offered':
      case 'interview offered':
        matchColor = Colors.blue;
        matchLabel = "Interview Offered";
        break;
      case 'viewed':
        matchColor = Colors.orange;
        matchLabel = "Viewed";
        break;
      default:
        matchColor = Colors.grey;
        matchLabel = "Pending";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.grey),
        ),
        title: Text(
          app.seekerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          matchLabel,
          style: TextStyle(color: matchColor, fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (app.seekerBio != null) ...[
                  const Text(
                    "About Seeker",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(app.seekerBio!),
                  const SizedBox(height: 12),
                ],
                if (app.coverLetter != null) ...[
                  const Text(
                    "Cover Letter Note",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(app.coverLetter!),
                  const SizedBox(height: 12),
                ],
                Text(
                  "Applied: ${app.appliedAt.toLocal()}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: {
                            'otherUserId': app.seekerId,
                            'otherUserName': app.seekerName,
                            'jobId': app.jobId,
                          },
                        ),
                        icon: const Icon(Icons.chat),
                        label: const Text("Message"),
                      ),
                      const SizedBox(width: 8),
                      // 🛠️ FIXED: Check against normalized string to make sure status management shows consistently
                      if (normalizedStatus == 'pending' ||
                          normalizedStatus == 'viewed') ...[
                        if (normalizedStatus == 'pending') ...[
                          ElevatedButton.icon(
                            onPressed: () =>
                                _updateStatus(app.applicationId, 'viewed'),
                            icon: const Icon(Icons.visibility),
                            label: const Text("Mark Viewed"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton.icon(
                          onPressed: () => _updateStatus(
                            app.applicationId,
                            'interview_offered',
                          ),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text("Offer Interview"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _updateStatus(app.applicationId, 'accepted'),
                          icon: const Icon(Icons.check),
                          label: const Text("Accept"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _updateStatus(app.applicationId, 'rejected'),
                          icon: const Icon(Icons.close),
                          label: const Text("Reject"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ] else ...[
                        TextButton.icon(
                          onPressed: () =>
                              _updateStatus(app.applicationId, 'pending'),
                          icon: const Icon(Icons.undo),
                          label: const Text("Reset Status"),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
