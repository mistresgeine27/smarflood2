import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart'; // Adjust this path if needed

class ProfilePage extends StatelessWidget {
  final user = Supabase.instance.client.auth.currentUser;

  void _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to LoginPage after logout
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), // Title color set to white
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 10, // Added shadow for better aesthetics
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture and details
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Logged in as',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  Text(
                    user?.email ?? 'No email',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 30),
                  // Optional Bio or extra profile information

                  SizedBox(height: 20),
                ],
              ),
            ),
            Spacer(),
            // Logout button
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text('Logout', style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5, // Added slight shadow for button
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
