import 'package:flutter/material.dart';
import '../app_components.dart';

class ImpactReportScreen extends AbilityScreen {
  const ImpactReportScreen() : super("My Impact Report");

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 80, color: Colors.orange),
          const SizedBox(height: 10),
          const Text(
            "Great Job, Alex!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Here is your journey so far.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statBox("32", "Jobs Applied", Colors.blueAccent),
              _statBox("5", "Interviews", Colors.green),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statBox("12", "Forum Posts", Colors.purple),
              _statBox("3", "Courses Done", Colors.orange),
            ],
          ),

          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              children: [
                Icon(Icons.lightbulb, color: Colors.blueAccent),
                SizedBox(height: 10),
                Text(
                  "Tip: Users who complete their profile are 40% more likely to get an interview match!",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String number, String label, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
