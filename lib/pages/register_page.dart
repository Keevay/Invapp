import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'user';

  String? _errorMessage;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    final box = Hive.box<User>('users');

    final existingUsers = box.values.where(
      (user) => user.username == username,
    );
    final existingUser = existingUsers.isNotEmpty ? existingUsers.first : null;

    if (existingUser != null) {
      setState(() {
        _errorMessage = 'Username already exists';
      });
      return;
    }

    final newUser = User(username: username, password: password, role: role);
    await box.add(newUser);

    Navigator.pop(context); // back to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
           // Left side - Content/Image (Hidden on mobile)
          if (MediaQuery.of(context).size.width > 800)
            Expanded(
              flex: 1,
              child: Container(
                color: Theme.of(context).secondaryHeaderColor, // Use a different color or same primary
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF14B8A6), const Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Join Us',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Create your account to get started.',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Right side - Form
          Expanded(
            flex: 1,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mobile Header
                        if (MediaQuery.of(context).size.width <= 800) ...[
                             Center(
                               child: Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 64,
                                color: Theme.of(context).primaryColor,
                               ),
                             ),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                'Join Us',
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 48),
                        ],

                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 32),

                        if (_errorMessage != null) ...[
                           Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: 24),
                        ],

                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Enter username' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                             prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (val) =>
                              val == null || val.isEmpty ? 'Enter password' : null,
                        ),
                        
                        SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _register,
                            child: Text('Register'),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Back to Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
