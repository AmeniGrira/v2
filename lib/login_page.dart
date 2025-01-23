import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'package:ameny/ForgotPasswordPage.dart';
class LoginPage extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(String?) onLanguageChanged;

  const LoginPage({
    Key? key,
    required this.onThemeChanged,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _loginError;
  bool _isPasswordVisible = false;

  bool _validateLogin() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _loginError = null;
    });

    bool isValid = true;

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _emailError = 'Please enter a valid email';
      isValid = false;
    }

    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _passwordError = 'Password must be at least 6 characters long';
      isValid = false;
    }

    return isValid;
  }

  Future<void> _logLogin(String userId, String email) async {
    try {
      final ip = '127.0.0.1';
      final loginTime = DateTime.now();

      final response = await Supabase.instance.client
          .from('login_logs')
          .insert({
        'user_id': userId,
        'login_time': loginTime.toIso8601String(),
        'ip_address': ip,
        'email': email,
      })
          .execute();

      if (response.error != null) {
        debugPrint('Error logging login: ${response.error!.message}');
      }
    } catch (e) {
      debugPrint('Logging error: $e');
    }
  }

  Future<void> _login() async {
    if (_validateLogin()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final response = await Supabase.instance.client.auth.signIn(
          email: email,
          password: password,
        );

        if (response.error != null) {
          setState(() {
            _loginError = "Invalid credentials: ${response.error!.message}";
            _showErrorSnackBar(_loginError!);
          });
        } else if (response.user != null) {
          await _logLogin(response.user!.id, email);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                onModeChanged: widget.onThemeChanged,
                onLanguageChanged: widget.onLanguageChanged,
              ),
            ),
          );
        }
      } catch (error) {
        setState(() {
          _loginError = "An error occurred during login: $error";
          _showErrorSnackBar(_loginError!);
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
    );
  }


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade800,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.1),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text("Login", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Welcome Back", style: TextStyle(color: Colors.white, fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.08),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.05),
                        _buildInputFields(),
                        SizedBox(height: screenHeight * 0.03),
                        TextButton(
                          onPressed: _forgotPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            minimumSize: Size(double.infinity, screenHeight * 0.06),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpPage()),
                            );
                          },
                          child: const Text(
                            "Create an account",
                            style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: "Email",
              hintStyle: const TextStyle(color: Colors.grey),
              errorText: _emailError,
              prefixIcon: const Icon(Icons.email, color: Colors.blue),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: "Password",
              hintStyle: const TextStyle(color: Colors.grey),
              errorText: _passwordError,
              prefixIcon: const Icon(Icons.lock, color: Colors.blue),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
