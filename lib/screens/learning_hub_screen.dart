import 'package:flutter/material.dart';
import '../services/community_service.dart';

class LearningHubScreen extends StatefulWidget {
  const LearningHubScreen({super.key});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  Future<List<Map<String, dynamic>>> _fetchResources() => CommunityService.fetchLearningResources();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learning Hub"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.report_gmailerrorred),
            onPressed: () => Navigator.pushNamed(context, '/report'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchResources(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildStaticGrid();
              }
              return _buildResourceGrid(snapshot.data!);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResourceGrid(List<Map<String, dynamic>> resources) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final r = resources[index];
        return _courseCard(r['title'], _getIcon(r['icon_name']), r['lessons_count']);
      },
    );
  }

  Widget _buildStaticGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _courseCard("Interview Prep", Icons.mic, "4 Lessons"),
        _courseCard("Negotiating Accommodations", Icons.handshake, "2 Lessons"),
        _courseCard("Screen Reader Mastery", Icons.keyboard, "10 Lessons"),
        _courseCard("Legal Rights (ADA)", Icons.gavel, "Readings"),
      ],
    );
  }

  IconData _getIcon(String? iconName) {
    if (iconName == null) return Icons.book;
    switch (iconName) {
      case 'mic': return Icons.mic;
      case 'handshake': return Icons.handshake;
      case 'keyboard': return Icons.keyboard;
      case 'gavel': return Icons.gavel;
      default: return Icons.book;
    }
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