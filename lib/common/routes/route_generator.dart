import 'package:flutter/material.dart';
import 'package:iphipi/screens/data_mining/edit_screen.dart';
import 'package:iphipi/screens/data_mining/login_screen.dart';
import 'package:iphipi/screens/data_mining/new_edit_screen.dart';
import 'routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.dataMiningLogin:
        return MaterialPageRoute(builder: (context) {
          return const DataMiningLoginScreen();
        });

      case Routes.dataMiningHome:
        return MaterialPageRoute(builder: (context) {
          return const MinerEditScreen();
        });

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}
