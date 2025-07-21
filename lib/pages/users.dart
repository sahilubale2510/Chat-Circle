import 'package:chatapp/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Users extends StatelessWidget {
  const Users({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return FirebaseFirestore.instance
        .collection("users")
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data?.docs ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              // skip current user
              if (user['uid'] == currentUser?.uid) {
                return const SizedBox.shrink();
              }

              return ListTile(
                title: Text(user['email'] ?? 'No Email'),
                subtitle: Text(user['uid'] ?? ''),
                onTap: () {
                  // 👉 Open chat screen with this user in future
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ChatPage(
                            receiverEmail: user['email'],
                            receiverUid: user['uid'],
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
