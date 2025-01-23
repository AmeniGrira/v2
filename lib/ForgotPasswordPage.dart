import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false;

  // Method to handle password reset request
  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() {
        _emailError = 'Please enter a valid email';
      });
      return;
    }

    // Clear previous error
    setState(() {
      _emailError = null;
    });

    setState(() {
      _isLoading = true; // Set loading state
    });

    try {
      final url = Uri.parse('https://vkvywnlosqfvezxlzyci.supabase.co/auth/v1/recover');
      final headers = {
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZrdnl3bmxvc3FmdmV6eGx6eWNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY0Mjk3MjcsImV4cCI6MjA1MjAwNTcyN30.jf3rjzwtrEYobMHkfB6Ha9EAf1w18OLjU5MqV1Pstyo', // Replace with your actual Supabase API key
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        'email': _emailController.text.trim(),
      });

      // Make the HTTP POST request to reset the password
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent successfully.')),
        );
        Navigator.pop(context); // Return to the previous page after success
      } else {
        setState(() {
          _emailError = 'Failed to send reset email. Please try again later.';
        });
      }
    } catch (e) {
      debugPrint('Password reset error: $e');
      setState(() {
        _emailError = 'An error occurred while sending the reset email. Please try again later.';
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading state once the process completes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05), // 5% of screen width for padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email input field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Enter your email",
                hintStyle: const TextStyle(color: Colors.grey),
                errorText: _emailError,
                prefixIcon: const Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),

            // Loading indicator while the request is being processed
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),

            // Reset password button
            if (!_isLoading)
              ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  minimumSize: Size(double.infinity, screenHeight * 0.06), // 6% of screen height for the button
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // Adjust padding based on screen size
                ),
                child: const Text('Send Password Reset Email'),
              ),
          ],
        ),
      ),
    );
  }
}
