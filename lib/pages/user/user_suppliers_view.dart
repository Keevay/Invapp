import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:invapp/models/supplier.dart';

class UserSuppliersView extends StatelessWidget {
  const UserSuppliersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Supplier>('suppliers').listenable(),
      builder: (context, Box<Supplier> box, _) {
        if (box.isEmpty) {
          return const Center(child: Text('No suppliers found.'));
        }

        return ListView.builder(
          itemCount: box.length,
          itemBuilder: (context, index) {
            final supplier = box.getAt(index)!;
            return ListTile(
              leading: const Icon(Icons.business),
              title: Text(supplier.name),
              subtitle: Text('${supplier.email} • ${supplier.phone}'),
            );
          },
        );
      },
    );
  }
}
