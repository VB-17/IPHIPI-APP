import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class NewEditScreen extends StatelessWidget {
  const NewEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
          return;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('MinerEdit'),
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          
        ),
      ),
    );
  }
}
