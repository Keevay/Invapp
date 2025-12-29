import 'package:flutter/material.dart';
import 'product_management_page.dart';
import 'user_management_page.dart';
import 'supplier_management_page.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminManagePage extends StatelessWidget {
  const AdminManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Management', 
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)
          ),
          bottom: TabBar(
            padding: EdgeInsets.zero, // Remove padding to use full width
            isScrollable: false, // Make tabs fill the width
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).primaryColor,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Products'),
              Tab(text: 'Users'),
              Tab(text: 'Suppliers'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProductManagementPage(),
            UserManagementPage(),
            SupplierManagementPage(),
          ],
        ),
      ),
    );
  }
}
