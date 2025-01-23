import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ContactServicePage extends StatefulWidget {
  @override
  _ContactServicePageState createState() => _ContactServicePageState();
}

class _ContactServicePageState extends State<ContactServicePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  String _status = "";
  bool _isLoading = false;
  double _scale = 1.0;
  double _rating = 0.0;

  Future<void> _sendMessage() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      setState(() {
        _status = "Please fill in all fields for the message!";
      });
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
      setState(() {
        _status = "Please enter a valid email address.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = "";
    });

    try {
      final response = await Supabase.instance.client.from('messages').insert({
        'client_name': name,
        'client_email': email,
        'content': message,
      }).execute();

      if (response.error != null) {
        setState(() {
          _status = "Error sending the message: ${response.error!.message}";
        });
      } else {
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
        setState(() {
          _status = "Message sent successfully!";
        });
      }
    } catch (error) {
      setState(() {
        _status = "Error: $error";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendFeedback() async {
    final feedback = _feedbackController.text.trim();
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (feedback.isEmpty || _rating == 0.0) {
      setState(() {
        _status = "Please provide both feedback and a rating!";
      });
      return;
    }

    if (userId == null) {
      setState(() {
        _status = "User is not logged in.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = "";
    });

    try {
      final response = await Supabase.instance.client.from('feedback').insert({
        'user_id': userId,
        'content': feedback,
        'rating': _rating,
      }).execute();

      if (response.error != null) {
        setState(() {
          _status = "Error sending the feedback: ${response.error!.message}";
        });
      } else {
        _feedbackController.clear();
        setState(() {
          _status = "Feedback sent successfully!";
        });
      }
    } catch (error) {
      setState(() {
        _status = "Error: $error";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Service'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a Message',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
            SizedBox(height: 20),
            _buildTextField('Enter your name', Icons.person, _nameController),
            SizedBox(height: 10),
            _buildTextField('Enter your email', Icons.email, _emailController),
            SizedBox(height: 10),
            _buildTextField('Enter your message', Icons.message, _messageController, maxLines: 4),
            SizedBox(height: 20),
            _buildSendButton(_sendMessage, 'Send Message'),
            SizedBox(height: 20),
            Text(
              'Provide Your Feedback',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
            SizedBox(height: 20),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemSize: 40.0,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20),
            _buildTextField('Enter your feedback', Icons.comment, _feedbackController, maxLines: 3),
            SizedBox(height: 20),
            _buildSendButton(_sendFeedback, 'Send Feedback'),
            SizedBox(height: 20),
            _buildStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, IconData icon, TextEditingController controller, {int maxLines = 1}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSendButton(Function() onPressed, String label) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade800,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5.0,
      ),
      child: _isLoading
          ? CircularProgressIndicator(
        color: Colors.white,
      )
          : Text(
        label,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildStatus() {
    return Text(
      _status,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _status == "Message sent successfully!" || _status == "Feedback sent successfully!" ? Colors.green : Colors.red,
      ),
    );
  }
}
