import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverUid;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverUid,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _messageController = TextEditingController();

  late final String chatId;

  @override
  void initState() {
    super.initState();
    // Create a unique chatId using both user UIDs (sorted to avoid duplicates)
    final ids = [user.uid, widget.receiverUid];
    ids.sort();
    chatId = ids.join('_');
  }

  // Send a message
  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': user.uid,
          'receiverId': widget.receiverUid,
          'message': text,
          'timestamp': FieldValue.serverTimestamp(),
        });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverEmail)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final time = message['timestamp'] ?? Timestamp.now();

                    final isMe = message['senderId'] == user.uid;

                    return ChatMessage(
                      message: message['message'],
                      isMe: isMe,
                      time: time,
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable ChatMessage Widget
class ChatMessage extends StatelessWidget {
  final String message;
  final bool isMe;
  final Timestamp time;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime dateTime = time.toDate(); // Convert Timestamp to DateTime
    final String formattedTime = DateFormat(
      'hh:mm a',
    ).format(dateTime); // Format

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : const Color(0xf1f1f1f1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              formattedTime,
              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
