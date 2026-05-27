import 'package:flutter/material.dart';
import '../app_components.dart';

class CommunityForumScreen extends AbilityScreen {
  const CommunityForumScreen() : super("Community Forum");

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: "Search topics...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: [
              _forumPost(
                "Best ergonomic chairs for long hours?",
                "General",
                45,
                12,
              ),
              _forumPost(
                "Companies with great neurodivergent policies",
                "Careers",
                120,
                34,
              ),
              _forumPost(
                "How to request a sign language interpreter for an interview?",
                "Advice",
                88,
                15,
              ),
            ],
          ),
        ),
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
