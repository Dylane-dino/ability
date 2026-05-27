import 'package:flutter/material.dart';
import '../app_components.dart';

class ReportScreen extends AbilityScreen {
  const ReportScreen() : super("Report an Issue");

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield, color: Colors.red),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "AbilityBridge is a safe space. All reports are confidential and reviewed by human admins.",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            "What type of issue are you reporting?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const TextField(
            decoration: InputDecoration(
              hintText: "e.g., Inaccessible Job Post, Harassment",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Description",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const TextField(
            maxLines: 6,
            decoration: InputDecoration(
              hintText: "Please provide as much detail as possible...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30),
          CustomButton(
            label: "Submit Secure Report",
            primary: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Report sent securely to Admin.")),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
