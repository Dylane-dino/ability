import 'package:flutter/material.dart';
import '../app_components.dart';

class WelcomeScreen extends AbilityScreen {
  const WelcomeScreen() : super("AbilityBridge");

  @override
  Widget buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.all_inclusive, size: 80, color: Colors.blueAccent),
        const SizedBox(height: 20),
        const Text(
          "Empowering Every Ability",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),
        CustomButton(
          label: "Get Started",
          onTap: () => Navigator.pushNamed(context, '/login'),
        ),
      ],
    );
  }
}
