// lib/screens/messages_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_components.dart';
import '../services/message_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  late int _currentUserId;
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndConversations();
  }

  Future<void> _loadUserAndConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _currentUserId = userId;
    });

    await _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    final convos = await MessageService().getUserConversations(_currentUserId);
    setState(() {
      _conversations = convos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Messages")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? const Center(child: Text("No conversations yet."))
              : ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final convo = _conversations[index];
                    final name = convo['other_user_name'] ?? 'Unknown';
                    final lastMsg = convo['last_message'] ?? 'No messages yet';
                    final time = convo['last_message_time'] != null
                        ? DateTime.parse(convo['last_message_time']).toLocal().toString().substring(0, 16)
                        : '';

                    return _chatTile(
                      name,
                      lastMsg,
                      time,
                      true,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/chat',
                          arguments: {
                            'otherUserId': convo['other_user_id'],
                            'otherUserName': name,
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }

  Widget _chatTile(String name, String msg, String time, bool unread, {VoidCallback? onTap}) {
    return Card(
      elevation: 0,
      color: unread ? Colors.blue.shade50 : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(
          name,
          style: TextStyle(fontWeight: unread ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (unread) const SizedBox(height: 4),
            if (unread) const CircleAvatar(radius: 5, backgroundColor: Colors.blueAccent),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
