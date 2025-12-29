import 'package:flutter/material.dart';
import 'user_store_page.dart';
import 'user_billing_page.dart';
import 'package:invapp/widgets/logout_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    UserStorePage(),
    UserBillingPage(),
    LogoutSection(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: AppLocalizations.of(context)!.store),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: AppLocalizations.of(context)!.billing),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: AppLocalizations.of(context)!.settingsTitle),
        ],
      ),
    );
  }
}


