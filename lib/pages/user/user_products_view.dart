import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/product.dart';
import '../../models/supplier.dart';

class UserProductsView extends StatefulWidget {
  const UserProductsView({super.key});

  @override
  State<UserProductsView> createState() => _UserProductsViewState();
}

class _UserProductsViewState extends State<UserProductsView> {
  String _searchQuery = '';
  late Box<Product> _productBox;
  late Box<Supplier> _supplierBox;

  @override
  void initState() {
    super.initState();
    _productBox = Hive.box<Product>('products');
    _supplierBox = Hive.box<Supplier>('suppliers');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _productBox.listenable(),
            builder: (context, Box<Product> box, _) {
              var products = box.values.toList();
              
              if (_searchQuery.isNotEmpty) {
                products = products.where((p) => 
                  p.name.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();
              }

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                      SizedBox(height: 16),
                      Text('No products found', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  // Using 'key' or finding index if needed, but for display values are enough
                  final supplierName = _supplierBox.get(product.supplierId)?.name ?? 'Unknown';

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('\$${product.price.toStringAsFixed(2)}', 
                                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: product.quantity > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  product.quantity > 0 ? 'In Stock: ${product.quantity}' : 'Out of Stock',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: product.quantity > 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              Spacer(),
                              Icon(Icons.store, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(supplierName, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
