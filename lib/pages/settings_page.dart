import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invapp/models/product.dart';
import 'package:invapp/widgets/logout_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'admin/activity_log_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Box _settingsBox;
  
  String _email = 'admin@invapp.com';
  String _phone = '+1 234 567 890';

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box('settings');
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _email = _settingsBox.get('profile_email', defaultValue: 'admin@invapp.com');
      _phone = _settingsBox.get('profile_phone', defaultValue: '+1 234 567 890');
    });
  }

  void _editProfile() {
    final emailController = TextEditingController(text: _email);
    final phoneController = TextEditingController(text: _phone);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Edit Profile Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              _settingsBox.put('profile_email', emailController.text);
              _settingsBox.put('profile_phone', phoneController.text);
              _loadProfile();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated!")));
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'fr': return 'Français';
      case 'es': return 'Español';
      default: return 'English';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Choose Language"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("English"),
              onTap: () {
                _settingsBox.put('locale', 'en');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text("Français"),
              onTap: () {
                _settingsBox.put('locale', 'fr');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text("Español"),
              onTap: () {
                _settingsBox.put('locale', 'es');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settingsTitle,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _SectionHeader(title: AppLocalizations.of(context)!.accountSection),
                // Profile Section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0,4))
                    ]
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        child: Icon(Icons.person, size: 32, color: Theme.of(context).primaryColor),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Admin User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.email, size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(_email, style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(_phone, style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor), 
                        onPressed: _editProfile
                      ),
                    ],
                  ),
                ),
                
                _SectionHeader(title: AppLocalizations.of(context)!.systemSection),
                ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Activity Log'),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityLogPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Notifications'),
                  trailing: Switch(value: true, onChanged: (val) {}),
                ),
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text(AppLocalizations.of(context)!.language),
                  trailing: Text(
                    _getLanguageName(_settingsBox.get('locale', defaultValue: 'en')),
                    style: TextStyle(color: Colors.grey)
                  ),
                  onTap: _showLanguageDialog,
                ),
                
                _SectionHeader(title: AppLocalizations.of(context)!.dataSection),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  title: Text('Clear All Inventory', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    // Confirm dialog
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Clear Inventory'),
                        content: Text('Are you sure you want to delete all products? This action cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              Hive.box<Product>('products').clear();
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inventory cleared')));
                            },
                            child: Text('Clear', style: TextStyle(color: Colors.red)),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Logout at the very bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LogoutSection(),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
