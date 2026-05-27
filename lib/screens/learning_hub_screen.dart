import 'package:flutter/material.dart';
import '../app_components.dart';

class LearningHubScreen extends AbilityScreen {
  const LearningHubScreen() : super("Learning Hub");

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Skill Building & Resources",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _courseCard("Interview Prep", Icons.mic, "4 Lessons"),
              _courseCard(
                "Negotiating Accommodations",
                Icons.handshake,
                "2 Lessons",
              ),
              _courseCard(
                "Screen Reader Mastery",
                Icons.keyboard,
                "10 Lessons",
              ),
              _courseCard("Legal Rights (ADA)", Icons.gavel, "Readings"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _courseCard(String title, IconData icon, String subtitle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade50,
                child: Icon(icon, size: 30, color: Colors.blueAccent),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
