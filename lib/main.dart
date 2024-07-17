import 'package:flutter/material.dart';
import 'package:iphipi/common/routes/route_generator.dart';
import 'package:iphipi/common/routes/routes.dart';
import 'package:iphipi/providers/audio_player_provider.dart';
import 'package:iphipi/providers/audio_selection_provider.dart';

import 'package:toastification/toastification.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) =>
                AudioSelectionState()), // Your existing provider
        ChangeNotifierProvider(
            create: (context) => AudioPlayerProvider()), // The new provider
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ToastificationWrapper(
      child: MaterialApp(
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: Routes.dataMiningLogin,
      ),
    );
  }
}
