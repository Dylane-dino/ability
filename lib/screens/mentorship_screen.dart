import 'package:flutter/material.dart';
import '../app_components.dart';
import '../services/community_service.dart';
import '../providers/notification_provider.dart'; // 🚀 Added import for your new Observer pattern provider

class MentorshipScreen extends AbilityScreen {
  const MentorshipScreen() : super("Mentorship");

  Future<List<Map<String, dynamic>>> _fetchMentors() =>
      CommunityService.fetchMentors();

  @override
  Widget buildBody(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchMentors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildStaticMentors();
        }
        return _buildMentorList(snapshot.data!);
      },
    );
  }

  Widget _buildMentorList(List<Map<String, dynamic>> mentors) {
    return ListView.builder(
      itemCount: mentors.length,
      itemBuilder: (context, index) {
        final m = mentors[index];
        return _mentorCard(
          context,
          m['name'] ?? 'Unknown Mentor',
          m['role'] ?? 'Professional',
          m['expertise'] ?? m['tag'] ?? 'General',
          m['experience'] ?? '',
          m['id'] as int?,
        );
      },
    );
  }

  Widget _buildStaticMentors() {
    return Builder(
      builder: (context) {
        return ListView(
          children: [
            _mentorCard(
              context,
              "Alex Rivera",
              "Senior Dev @ Microsoft",
              "Blind/Low Vision",
              "10 yrs exp",
              null,
            ),
            _mentorCard(
              context,
              "Jamie Smith",
              "HR Director",
              "Wheelchair User",
              "15 yrs exp",
              null,
            ),
            _mentorCard(
              context,
              "Taylor Doe",
              "UX Designer",
              "Neurodivergent",
              "5 yrs exp",
              null,
            ),
          ],
        );
      },
    );
  }

  Widget _mentorCard(
    BuildContext context,
    String name,
    String role,
    String tag,
    String exp,
    int? mentorId,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(role, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Chip(label: Text(tag), backgroundColor: Colors.blue.shade50),
                const SizedBox(width: 10),
                Text(
                  exp,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: mentorId == null
                    ? null
                    : () async {
                        // 1. Capture the structural messenger reference BEFORE the asynchronous execution call
                        final messenger = ScaffoldMessenger.of(context);

                        final result = await CommunityService.requestMentorship(
                          mentorId,
                        );

                        // 2. Safely check if the element's render context remains active in the layout tree
                        if (context.mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(result['message']),
                              backgroundColor: result['success'] == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );

                          // 3. OBSERVER BROADCAST: Notify Subject when mentorship successfully fires
                          if (result['success'] == true) {
                            CommunityNotificationProvider().addNotification(
                              "Mentorship request successfully sent to $name!",
                            );
                          }
                        }
                      },
                child: const Text("Request Mentorship"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
