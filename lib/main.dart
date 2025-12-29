import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';
import 'models/user.dart';
import 'models/supplier.dart';
import 'models/sale.dart';
import 'models/sales_report.dart';
import 'models/activity_log.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'pages/login_page.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('users');
  
  Hive.registerAdapter(ProductAdapter());
  await Hive.openBox<Product>('products');

  Hive.registerAdapter(SupplierAdapter());
  await Hive.openBox<Supplier>('suppliers');

  Hive.registerAdapter(SaleAdapter());
  Hive.registerAdapter(SaleItemAdapter());
  await Hive.openBox<Sale>('sales');

  Hive.registerAdapter(SalesReportAdapter());
  await Hive.openBox<SalesReport>('sales_reports');

  Hive.registerAdapter(ActivityLogAdapter());
  await Hive.openBox<ActivityLog>('activity_logs');
  
  await Hive.openBox('settings');


  var usersBox = Hive.box<User>('users');
  if (usersBox.isEmpty) {
    usersBox.add(User(username: 'admin', password: 'admin123', role: 'admin'));
    usersBox.add(User(username: 'user1', password: 'user123', role: 'user'));
  }
  var suppliersBox = Hive.box<Supplier>('suppliers');
  if (suppliersBox.isEmpty) {
    suppliersBox.add(Supplier(name: 'Phone case supplier', email: 'case@contact.com', phone: '0123456789'));
    suppliersBox.add(Supplier(name: 'Console supplier', email: 'console@contact.com', phone: '0198765432'));
  }
  var productsBox = Hive.box<Product>('products');
  if (productsBox.isEmpty) {
    productsBox.add(Product(name: 'Iphone 15 case', quantity: 22, price: 18, createdAt: DateTime(2025, 5, 23), supplierId: 0));
    productsBox.add(Product(name: 'Iphone 14 pro case', quantity: 12, price: 20, createdAt: DateTime(2025, 5, 24), supplierId: 0));
    productsBox.add(Product(name: 'Galaxy S24 case', quantity: 22, price: 20, createdAt: DateTime(2025, 5, 26), supplierId: 0));
    productsBox.add(Product(name: 'Clear case', quantity: 12, price: 15, createdAt: DateTime(2025, 5, 27), supplierId: 0));
    productsBox.add(Product(name: 'Play Station 5', quantity: 2, price: 580, createdAt: DateTime(2025, 5, 28), supplierId: 1));
    productsBox.add(Product(name: 'Xbox series S', quantity: 4, price: 350, createdAt: DateTime(2025, 5, 30), supplierId: 1));
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, _) {
        final String savedLocale = box.get('locale', defaultValue: 'en');
        return MaterialApp(
          title: 'Invapp',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: Locale(savedLocale),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('fr'), // French
            Locale('es'), // Spanish
          ],
          home: LoginPage(),
        );
      },
    );
  }
}
