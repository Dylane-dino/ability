import 'package:flutter/material.dart';
import '../services/community_service.dart';

class CommunityForumScreen extends StatefulWidget {
  const CommunityForumScreen({super.key});

  @override
  State<CommunityForumScreen> createState() => _CommunityForumScreenState();
}

class _CommunityForumScreenState extends State<CommunityForumScreen> {
  Future<List<Map<String, dynamic>>> _fetchPosts() => CommunityService.fetchForumPosts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Forum"),
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
            future: _fetchPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildStaticPosts();
              }
              return _buildPostList(snapshot.data!);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPostList(List<Map<String, dynamic>> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final p = posts[index];
        return _forumPost(p['title'], p['category'], p['upvotes'], p['replies']);
      },
    );
  }

  Widget _buildStaticPosts() {
    return ListView(
      children: [
        _forumPost("Best ergonomic chairs for long hours?", "General", 45, 12),
        _forumPost("Companies with great neurodivergent policies", "Careers", 120, 34),
        _forumPost("How to request a sign language interpreter for an interview?", "Advice", 88, 15),
      ],
    );
  }

  Widget _forumPost(String title, String category, int upvotes, int replies) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Chip(
              label: Text(category, style: const TextStyle(fontSize: 10)),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text("$upvotes", style: const TextStyle(color: Colors.grey)),
                const SizedBox(width: 15),
                const Icon(
                  Icons.comment_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  "$replies replies",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}