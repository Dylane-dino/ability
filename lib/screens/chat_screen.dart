// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/message_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late int _currentUserId;
 late int _otherUserId;
  String? _otherUserName;
  int? _jobId;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  final TextEditingController _msgController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['otherUserId'] != null) {
      _otherUserId = args['otherUserId'] as int;
      _otherUserName = args['otherUserName'] as String?;
      _jobId = args['jobId'] as int?;
      _loadCurrentUser();
    } else {
      Future.microtask(() => Navigator.maybePop(context));
    }
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _currentUserId = userId;
    });
    await _loadConversation();
  }

  Future<void> _loadConversation() async {
    final msgs = await MessageService().getConversation(
      userId: _currentUserId,
      otherUserId: _otherUserId,
      jobId: _jobId,
    );
    setState(() {
      _messages = msgs;
      _isLoading = false;
    });
  }

  Future<void> _sendMessage() async {
    final content = _msgController.text.trim();
    if (content.isEmpty) return;

    final success = await MessageService().sendMessage(
      senderId: _currentUserId,
      receiverId: _otherUserId,
      content: content,
      jobId: _jobId,
    );

    if (success) {
      _msgController.clear();
      await _loadConversation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_otherUserName ?? 'Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversation,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text("Start the conversation!"))
                    : ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg['sender_id'] == _currentUserId;
                          return _messageBubble(msg, isMe);
                        },
                      ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageBubble(Map<String, dynamic> msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                msg['sender_name'] ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            Text(msg['content'] ?? ''),
            const SizedBox(height: 4),
            Text(
              DateTime.parse(msg['sent_at']).toLocal().toString().substring(11, 16),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
