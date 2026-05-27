import 'package:flutter/material.dart';
import '../app_components.dart';

class ProfileSettingsScreen extends AbilityScreen {
  const ProfileSettingsScreen() : super("Ability Profile");

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SECTION 1: USER HEADER ---
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Alex Johnson",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Job Seeker Account",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // --- SECTION 2: ACCESSIBILITY NEEDS ---
          const Text(
            "Accessibility Needs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _settingSwitch("High Contrast Mode", true),
          _settingSwitch("Voice Navigation", false),
          _settingSwitch("Wheelchair Access Required", true),

          const Divider(height: 40),

          // --- SECTION 3: PRIVACY & SECURITY ---
          const Text(
            "Privacy",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _settingSwitch("Anonymous Mode", true),
          _settingSwitch("Hide Profile from Recruiters", false),

          const Divider(height: 40),

          // --- SECTION 4: IMPACT & LOGOUT ---
          const Text(
            "Actions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // LINK TO IMPACT REPORT
          CustomButton(
            label: "View My Impact Report",
            primary: false,
            onTap: () => Navigator.pushNamed(context, '/impact'),
          ),

          const SizedBox(height: 10),

          // LOGOUT BUTTON (Clears Navigation Stack)
          CustomButton(
            label: "Logout",
            primary: true, // blueAccent
            onTap: () {
              // This removes all previous screens so user can't "Go Back" after logging out
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _settingSwitch(String title, bool val) {
    return SwitchListTile(
      title: Text(title),
      value: val,
      onChanged: (v) {
        // In a real app, this would update the State
      },
      contentPadding: EdgeInsets.zero,
      activeColor: Colors.blueAccent,
    );
  }
}
