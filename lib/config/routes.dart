import 'package:flutter/material.dart';
import 'package:flutter_smart_cashier/screens/auth/login_screen.dart';
import 'package:flutter_smart_cashier/screens/auth/register_screen.dart';
import 'package:flutter_smart_cashier/screens/auth/forgot_password_screen.dart';
import 'package:flutter_smart_cashier/screens/home/home_screen.dart';
import 'package:flutter_smart_cashier/screens/products/products_screen.dart';
import 'package:flutter_smart_cashier/screens/products/add_product_screen.dart';
import 'package:flutter_smart_cashier/screens/products/edit_product_screen.dart';
import 'package:flutter_smart_cashier/screens/transactions/transaction_screen.dart';
import 'package:flutter_smart_cashier/screens/transactions/transaction_history_screen.dart';
import 'package:flutter_smart_cashier/screens/reports/reports_screen.dart';
import 'package:flutter_smart_cashier/screens/settings/settings_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String products = '/products';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product';
  static const String transaction = '/transaction';
  static const String transactionHistory = '/transaction-history';
  static const String reports = '/reports';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    home: (context) => const HomeScreen(),
    products: (context) => const ProductsScreen(),
    addProduct: (context) => const AddProductScreen(),
    editProduct: (context) => const EditProductScreen(),
    transaction: (context) => const TransactionScreen(),
    transactionHistory: (context) => const TransactionHistoryScreen(),
    reports: (context) => const ReportsScreen(),
    settings: (context) => const SettingsScreen(),
  };
}