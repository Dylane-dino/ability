import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  // This is the data for your 5 developers.
  final List<Map<String, String>> teamMembers = const [
    {
      "name": "YOUNGA TCHAPPI DYLANE",
      "role": "Project Manager & Backend Developer ",
      "image": "assets/dylane.jpg",
      "bio":
          "Passionate about building inclusive technology and connecting people.",
    },
    {
      "name": "TCHIGUI MAKOUFEU SHELA",
      "role": "Leader backend developer",
      "image": "assets/soft.jpg",
      "bio": "Designs beautiful, accessible, and user-friendly interfaces.",
    },
    {
      "name": "MBANGUE TSHUNGBOVE MARIE",
      "role": "Frontend Flutter Engineer",
      "image": "assets/marie.jpg",
      "bio": "Turns designs into smooth, functional mobile applications.",
    },
    {
      "name": "BIHINA DIBANJO TONY",
      "role": "Database Administrator",
      "image": "assets/tony.jpg",
      "bio": "Ensures all user data is secure, fast, and reliable.",
    },
    {
      "name": "NIMBA CARREL",
      "role": "Quality Assurance & Testing",
      "image": "assets/carel.jpg",
      "bio": "Squashes bugs and ensures the app runs perfectly on all devices.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About the Team"), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          return Card(
            elevation: 4, // Adds a nice drop shadow
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Developer Picture
                  // 🛠️ FIXED: Replaced standard CircleAvatar with a clean, explicit image loader container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors
                          .grey[200], // Smooth placeholder background tint
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        member['image']!,
                        fit: BoxFit.cover,
                        // 🚀 If the system can't resolve the file path, this handles the fallback gracefully
                        errorBuilder: (context, error, stackTrace) {
                          print(
                            "⚠️ Unable to load asset path: ${member['image']}. Error: $error",
                          );
                          return const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Developer Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['name']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          member['role']!,
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          member['bio']!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
