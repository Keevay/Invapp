import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'register_page.dart';
import 'admin/admin_home_page.dart';
import 'user/user_home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<User>('users');
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final users = box.values.where(
      (user) => user.username == username && user.password == password,
    );

    final user = users.isNotEmpty ? users.first : null;

    if (user == null) {
      setState(() {
        _errorMessage = 'Invalid username or password';
      });
    } else {
      // Navigate based on role
      if (user.role == 'admin') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => AdminHomePage()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => UserHomePage()));
      }
    }
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
                color: Theme.of(context).primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'InvApp',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Manage your inventory with ease.',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Right side - Login Form
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
                        // Mobile Logo
                        if (MediaQuery.of(context).size.width <= 800) ...[
                             Center(
                               child: Icon(
                                Icons.inventory_2_rounded,
                                size: 64,
                                color: Theme.of(context).primaryColor,
                               ),
                             ),
                            SizedBox(height: 16),
                            Center(
                              child: Text(
                                'InvApp',
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
                          AppLocalizations.of(context)!.loginTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 28, fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.loginSubtitle,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
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
                            labelText: AppLocalizations.of(context)!.username,
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? AppLocalizations.of(context)!.enterUsername : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password,
                             prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                          validator: (val) =>
                              val == null || val.isEmpty ? AppLocalizations.of(context)!.enterPassword : null,
                        ),
                        SizedBox(height: 24),
                        
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _login,
                            child: Text(AppLocalizations.of(context)!.loginButton, style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.noAccountPrompt),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => RegisterPage()));
                              },
                              child: Text('Create account'),
                            )
                          ],
                        )
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
