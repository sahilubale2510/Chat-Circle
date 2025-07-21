// ignore_for_file: use_build_context_synchronously
import 'package:chatapp/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  //register function
  Future _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _pwController.text.trim();
    final confirmPassword = _confirmPwController.text.trim();

    if (name.isEmpty) {
      _showMessage('Name cannot be empty');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Email cannot be empty');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Password cannot be empty');
      return;
    }

    if (password == confirmPassword) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Add user to Firestore "users" collection
        final user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({
              'name': name.toLowerCase(),
              'uid': user.uid,
              'email': user.email,
              'createdAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } on FirebaseAuthException catch (e) {
        _showMessage(e.message ?? 'An error occurred');
        return;
      } catch (e) {
        _showMessage('An unexpected error occurred');
        return;
      }
    } else {
      _showMessage('Password do not match');
      return;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    _confirmPwController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(19.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message, size: 100, color: Colors.black87),
                SizedBox(height: 10),
                Text("Hello There!", style: TextStyle(fontSize: 24)),
                Text(
                  "Register to get started!",
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 30),

                //name
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter Full Name',
                    labelText: 'Name',
                  ),
                ),
                SizedBox(height: 20),

                //email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter Email',
                    labelText: 'Email',
                  ),
                ),
                SizedBox(height: 20),

                //password
                TextField(
                  controller: _pwController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter Password',
                    labelText: 'Password',
                  ),
                ),
                SizedBox(height: 20),

                //confirm password
                TextField(
                  obscureText: true,
                  controller: _confirmPwController,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    labelText: 'Confirm Password',
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _register,
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 18, color: Colors.grey[200]),
                  ),
                ),
                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?  '),
                    GestureDetector(
                      onTap: () {
                        //
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login Now!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
