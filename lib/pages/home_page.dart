// ignore_for_file: use_build_context_synchronously
import 'package:chatapp/auth/main_page.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> searchResults = [];
  bool isSearching = false;
  String? currentUserName;

  // 🔍 Firestore search method
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> searchUsers(
    String query,
  ) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return [];
    }

    final result =
        await FirebaseFirestore.instance
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: query.toLowerCase())
            .where('name', isLessThan: '${query.toLowerCase()}z')
            .get();

    setState(() {
      isSearching = true;
      searchResults = result.docs;
    });

    return result.docs;
  }

  // Get all users (realtime)
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return FirebaseFirestore.instance
        .collection("users")
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Logout with confirmation
  void confirmLogout() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainPage()),
                      (route) => false,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to Sign Out')),
                    );
                  }
                },
                child: const Text('Log Out'),
              ),
            ],
          ),
    );
  }

  //get current user name
  Future<String?> getCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (doc.exists && doc.data()!.containsKey('name')) {
      return doc['name'];
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    loadCurrentUserName();
  }

  void loadCurrentUserName() async {
    currentUserName = await getCurrentUserName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) => searchUsers(value),
          decoration: InputDecoration(
            hintText: ' Search user by name...',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(50),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ),
      body:
          isSearching
              ? ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final user = searchResults[index];
                  if (!user.data().containsKey('uid')) {
                    return const SizedBox.shrink();
                  }
                  if (user['uid'] == currentUser?.uid) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    title: Text(
                      user.data().containsKey('name')
                          ? user['name']
                          : 'No Name',
                    ),
                    subtitle: Text(
                      user.data().containsKey('email')
                          ? user['email']
                          : 'No Email',
                    ),
                    onTap: () {
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
              )
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                      if (user['uid'] == currentUser?.uid) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(Icons.person)),
                          title: Text(
                            user.data().containsKey('name')
                                ? user['name']
                                : 'No Name',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(user['email'] ?? 'No Email'),
                          onTap: () {
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
                        ),
                      );
                    },
                  );
                },
              ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.grey),
              child: Center(
                child: Text(
                  currentUserName ?? 'Loading...',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ListTile(
                  onTap: confirmLogout,
                  title: const Text('L O G O U T'),
                  leading: const Icon(Icons.logout),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
