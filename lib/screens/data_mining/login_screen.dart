import 'package:flutter/material.dart';
import 'package:iphipi/common/routes/routes.dart';
import 'package:iphipi/data/repo/audio_repo.dart';
import 'package:iphipi/widgets/form_input.dart';
import 'package:iphipi/widgets/form_submit_btn.dart';
import 'package:toastification/toastification.dart';

class DataMiningLoginScreen extends StatefulWidget {
  const DataMiningLoginScreen({super.key});

  @override
  State<DataMiningLoginScreen> createState() => _DataMiningLoginScreenState();
}

class _DataMiningLoginScreenState extends State<DataMiningLoginScreen> {
  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  bool isLoading = false;

  void _onTap(BuildContext context) async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      Map<String, dynamic> result =
          await AudioRepo().login(username, password) as Map<String, dynamic>;

      if (result.containsKey('error')) {
        String error = result['error'];
        toastification.show(
          type: ToastificationType.error,
          alignment: Alignment.topCenter,
          style: ToastificationStyle.flat,
          title: Text(error),
          autoCloseDuration: const Duration(seconds: 3),
          showProgressBar: false,
        );
      } else {
        if (context.mounted) {
          // Navigator.pushNamedAndRemoveUntil(
          //   context,
          //   Routes.dataMiningHome,
          //   (Route<dynamic> route) => false,
          // );
          Navigator.pushNamed(context, Routes.dataMiningHome);
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Icon(
                Icons.lock,
                size: 100,
              ),
              const SizedBox(height: 50),
              Text(
                "Data Mining Login",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 25),
              FormInput(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              FormInput(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 25),
              FormSubmitButton(
                onTap: () => _onTap(context),
                text: 'Sign in',
                isLoading: isLoading,
              )
            ],
          ),
        ),
      ),
    );
  }
}
