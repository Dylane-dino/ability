import 'package:flutter/material.dart';
import '../app_components.dart';

class MentorshipScreen extends AbilityScreen {
  const MentorshipScreen() : super("Mentorship");

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Connect with experienced professionals who share your journey.",
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: [
              _mentorCard(
                "Alex Rivera",
                "Senior Dev @ Microsoft",
                "Blind/Low Vision",
                "10 yrs exp",
              ),
              _mentorCard(
                "Jamie Smith",
                "HR Director",
                "Wheelchair User",
                "15 yrs exp",
              ),
              _mentorCard(
                "Taylor Doe",
                "UX Designer",
                "Neurodivergent",
                "5 yrs exp",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mentorCard(String name, String role, String tag, String exp) {
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
                onPressed: () {},
                child: const Text("Request Mentorship"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
