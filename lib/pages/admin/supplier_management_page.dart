import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/supplier.dart';

class SupplierManagementPage extends StatefulWidget {
  const SupplierManagementPage({super.key});

  @override
  State<SupplierManagementPage> createState() => _SupplierManagementPageState();
}

class _SupplierManagementPageState extends State<SupplierManagementPage> {
  late Box<Supplier> _supplierBox;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _supplierBox = Hive.box<Supplier>('suppliers');
  }

  List<Supplier> _getFilteredSuppliers() {
    var suppliers = _supplierBox.values.toList();
    if (_searchQuery.isNotEmpty) {
      suppliers = suppliers.where((s) =>
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.email.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return suppliers;
  }

  void _addOrEditSupplier({Supplier? existingSupplier, int? index}) {
    final nameController = TextEditingController(text: existingSupplier?.name ?? '');
    final emailController = TextEditingController(text: existingSupplier?.email ?? '');
    final phoneController = TextEditingController(text: existingSupplier?.phone ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existingSupplier == null ? 'Add Supplier' : 'Edit Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
             const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty) {
                final newSupplier = Supplier(name: name, email: email, phone: phone);
                if (existingSupplier == null) {
                  _supplierBox.add(newSupplier);
                } else if (index != null) {
                  _supplierBox.putAt(index, newSupplier);
                }
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: Text(existingSupplier == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteSupplier(int index) {
    _supplierBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredSuppliers = _getFilteredSuppliers();
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search suppliers...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _addOrEditSupplier(),
                icon: const Icon(Icons.add),
                label: const Text('Add Supplier'),
                 style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredSuppliers.isEmpty
              ? Center(child: Text('No suppliers found', style: TextStyle(color: Colors.grey)))
              : isDesktop
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                             headingRowColor: MaterialStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.1)),
                            columns: const [
                              DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: List.generate(filteredSuppliers.length, (index) {
                              final supplier = filteredSuppliers[index];
                              int boxIndex = _supplierBox.values.toList().indexOf(supplier);
                              return DataRow(cells: [
                                DataCell(Text(supplier.name, style: TextStyle(fontWeight: FontWeight.w500))),
                                DataCell(Text(supplier.email)),
                                DataCell(Text(supplier.phone)),
                                DataCell(Row(children: [
                                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _addOrEditSupplier(existingSupplier: supplier, index: boxIndex)),
                                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSupplier(boxIndex)),
                                ])),
                              ]);
                            }),
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredSuppliers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final supplier = filteredSuppliers[index];
                        int boxIndex = _supplierBox.values.toList().indexOf(supplier);
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                               backgroundColor: Colors.orange.withOpacity(0.1),
                               child: Icon(Icons.store, color: Colors.orange),
                            ),
                            title: Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Row(children: [Icon(Icons.email, size: 12, color: Colors.grey), SizedBox(width: 4), Text(supplier.email, style: TextStyle(fontSize: 12))]),
                                SizedBox(height: 2),
                                Row(children: [Icon(Icons.phone, size: 12, color: Colors.grey), SizedBox(width: 4), Text(supplier.phone, style: TextStyle(fontSize: 12))]),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (ctx) => [
                                PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
                                PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                              ],
                              onSelected: (val) {
                                if (val == 'edit') _addOrEditSupplier(existingSupplier: supplier, index: boxIndex);
                                if (val == 'delete') _deleteSupplier(boxIndex);
                              },
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
