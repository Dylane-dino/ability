import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  // This is the data for your 5 developers. 
  // Just update the text and image paths here!
  final List<Map<String, String>> teamMembers = const [
    {
      "name": "Developer One",
      "role": "Project Manager & Backend",
      "image": "assets/dev1.jpg",
      "bio": "Passionate about building inclusive technology and connecting people."
    },
    {
      "name": "Developer Two",
      "role": "Lead UI/UX Designer",
      "image": "assets/dev2.jpg",
      "bio": "Designs beautiful, accessible, and user-friendly interfaces."
    },
    {
      "name": "Developer Three",
      "role": "Frontend Flutter Engineer",
      "image": "assets/dev3.jpg",
      "bio": "Turns designs into smooth, functional mobile applications."
    },
    {
      "name": "Developer Four",
      "role": "Database Administrator",
      "image": "assets/dev4.jpg",
      "bio": "Ensures all user data is secure, fast, and reliable."
    },
    {
      "name": "Developer Five",
      "role": "Quality Assurance & Testing",
      "image": "assets/dev5.jpg",
      "bio": "Squashes bugs and ensures the app runs perfectly on all devices."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About the Team"),
        centerTitle: true,
      ),
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
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    backgroundImage: AssetImage(member['image']!),
                    // If the image is missing, it shows a default person icon
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: member['image']!.isEmpty 
                        ? const Icon(Icons.person, size: 40, color: Colors.blueAccent) 
                        : null,
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
                            fontSize: 18, 
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