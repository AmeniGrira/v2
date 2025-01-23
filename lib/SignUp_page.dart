import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Fonction pour sélectionner la date et vérifier l'âge
  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime eighteenYearsAgo = now.subtract(Duration(days: 18 * 365));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: eighteenYearsAgo,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (pickedDate != null && pickedDate != now) {
      setState(() {
        _dobController.text = '${pickedDate.toLocal()}'.split(' ')[0];
      });
    }
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Inscription de l'utilisateur dans auth.users via Supabase
        final response = await Supabase.instance.client.auth.signUp(
          _emailController.text,
          _passwordController.text,
        );

        if (response.error == null) {
          // Si l'utilisateur est inscrit avec succès dans auth.users, insérez dans la table users
          final user = {
            'username': _usernameController.text,
            'email': _emailController.text,
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'address': _addressController.text,
            'postal_code': _postalCodeController.text,
            'city': _cityController.text,
            'country': _countryController.text,
            'dob': _dobController.text,
            'cin': _cinController.text,
            'phone': _phoneController.text,
            'supabase_user_id': response.user?.id, // Ajouter l'ID de l'utilisateur créé
          };

          final insertResponse = await Supabase.instance.client.from('users').insert([user]).execute();

          if (insertResponse.error == null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Account successfully created!'),
              backgroundColor: Colors.green,
            ));
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error inserting data into users table: ${insertResponse.error!.message}'),
              backgroundColor: Colors.red,
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: ${response.error!.message}'),
            backgroundColor: Colors.red,
          ));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error during account creation: $error'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  void dispose() {
    // Libérer les contrôleurs
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _cinController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir les dimensions de l'écran
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create an Account'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Sign Up', style: TextStyle(fontSize: screenWidth * 0.08, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                SizedBox(height: screenHeight * 0.03),
                _buildTextField('Username', _usernameController, hint: 'Enter your username'),
                _buildTextField('Email', _emailController, isEmail: true, hint: 'Enter a valid email (e.g., user@example.com)'),
                _buildTextField('Password', _passwordController, obscureText: true, hint: 'Password must be at least 6 characters'),
                _buildTextField('Confirm Password', _confirmPasswordController, obscureText: true, hint: 'Confirm your password'),
                _buildTextField('First Name', _firstNameController, hint: 'Enter your first name'),
                _buildTextField('Last Name', _lastNameController, hint: 'Enter your last name'),
                _buildTextField('Address', _addressController, hint: 'Enter your address'),
                _buildTextField('Postal Code', _postalCodeController, hint: 'Enter postal code (e.g., 12345)'),
                _buildTextField('City', _cityController, hint: 'Enter your city'),
                _buildTextField('Country', _countryController, hint: 'Enter your country'),
                _buildTextField('CIN', _cinController, hint: 'Enter your CIN (8 digits)'),
                _buildTextField('Phone Number', _phoneController, hint: 'Enter phone number (8 digits)'),
                _buildDateOfBirthField(),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: _createAccount,
                  child: Text('Create Account'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    textStyle: TextStyle(fontSize: screenWidth * 0.04),
                    backgroundColor: Colors.blue.shade900,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false, bool isEmail = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue.shade900),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.blue.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: controller.text.isEmpty ? Colors.grey.shade300 : Colors.blue.shade100,
        ),
        onChanged: (text) {
          setState(() {});
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field cannot be empty';
          }
          if (isEmail && !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zAZ0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(value)) {
            return 'Please enter a valid email';
          }
          if (label == 'Password' && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          if (label == 'Password' && !RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(value)) {
            return 'Password must contain at least 6 characters, a letter, and a number';
          }
          if (label == 'Confirm Password' && value != _passwordController.text) {
            return 'Passwords do not match';
          }
          if (label == 'Postal Code' && !RegExp(r'^\d+$').hasMatch(value)) {
            return 'Postal Code must contain only numbers';
          }
          if (label == 'CIN' && !RegExp(r'^\d{8}$').hasMatch(value)) {
            return 'CIN must be exactly 8 digits';
          }
          if (label == 'Phone Number' && !RegExp(r'^\d{8}$').hasMatch(value)) {
            return 'Phone number must be exactly 8 digits';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _dobController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          labelStyle: TextStyle(color: Colors.blue.shade900),
          hintText: 'Select your date of birth',
          hintStyle: TextStyle(color: Colors.blue.shade300),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.blue.shade100,
        ),
        onTap: () => _selectDate(context),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select your date of birth';
          }
          return null;
        },
      ),
    );
  }
}
