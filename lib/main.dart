import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smart_cashier/config/theme.dart';
import 'package:flutter_smart_cashier/config/routes.dart';
import 'package:flutter_smart_cashier/providers/auth_provider.dart';
import 'package:flutter_smart_cashier/providers/product_provider.dart';
import 'package:flutter_smart_cashier/providers/cart_provider.dart';
import 'package:flutter_smart_cashier/providers/report_provider.dart';
import 'package:flutter_smart_cashier/providers/theme_provider.dart';
import 'package:flutter_smart_cashier/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, _) {
          return MaterialApp(
            title: 'Smart Cashier',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: authProvider.isAuthenticated
                ? AppRoutes.home
                : AppRoutes.login,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}