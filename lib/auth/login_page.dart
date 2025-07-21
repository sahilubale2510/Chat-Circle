import 'package:chatapp/auth/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _pwController = TextEditingController();

  Future _login() async {
    final email = _emailController.text.trim();
    final password = _pwController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        _showMessage(e.message ?? 'An error occurred');
        return;
      } catch (e) {
        _showMessage('An unexpected error occurred');
        return;
      }
    } else {
      _showMessage('Enter valid credentials');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xf5f5f5f5),
      // appBar: AppBar(title: Text("Login page")),
      body: Padding(
        padding: const EdgeInsets.all(19.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 100, color: Colors.black87),
            SizedBox(height: 10),
            Text("Welcome Back!", style: TextStyle(fontSize: 24)),
            Text("Glad To see you, Again!", style: TextStyle(fontSize: 24)),
            SizedBox(height: 30),
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

            // //login button
            // GestureDetector(
            //   onTap: _login,
            //   child: Container(
            //     height: 50,
            //     decoration: BoxDecoration(
            //       color: Colors.grey[500],
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: Center(
            //       child: Text(
            //         'Login',
            //         style: TextStyle(fontSize: 18, color: Colors.grey[200]),
            //       ),
            //     ),
            //   ),
            // ),
            // SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text(
                'Login',
                style: TextStyle(fontSize: 18, color: Colors.grey[200]),
              ),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Dont have any account?  '),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text(
                    'Register Now!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
