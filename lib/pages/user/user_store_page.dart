import 'package:flutter/material.dart';
import 'package:invapp/pages/user/user_products_view.dart';
import 'package:invapp/pages/user/user_suppliers_view.dart';
import 'package:google_fonts/google_fonts.dart';

class UserStorePage extends StatelessWidget {
  const UserStorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Store', 
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)
          ),
          bottom: TabBar(
            padding: EdgeInsets.symmetric(horizontal: 16),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).primaryColor,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Products'),
              Tab(text: 'Suppliers'), 
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            UserProductsView(),
            UserSuppliersView(),
          ],
        ),
      ),
    );
  }
}
