import 'package:flutter/material.dart';

// 1. Common & Seeker Screens
import 'package:ability/screens/welcome_screen.dart';
import 'package:ability/screens/login_screen.dart';
import 'package:ability/screens/seeker_dashboard.dart';
import 'package:ability/screens/job_detail_screen.dart';
import 'package:ability/screens/apply_job_screen.dart';
import 'package:ability/screens/messages_screen.dart';
import 'package:ability/screens/chat_screen.dart';
import 'package:ability/screens/profile_settings_screen.dart';
import 'package:ability/screens/report_screen.dart';
import 'package:ability/screens/signup_screen.dart';
import 'package:ability/screens/about_us_screen.dart';
// 2. Employer Screens
import 'package:ability/screens/employer_dashboard.dart';
import 'package:ability/screens/post_job_screen.dart';
import 'package:ability/screens/applicant_review_screen.dart';

// 3. Community & Impact Screens
import 'package:ability/screens/mentorship_screen.dart';
import 'package:ability/screens/learning_hub_screen.dart';
import 'package:ability/screens/community_forum_screen.dart';
import 'package:ability/screens/impact_report_screen.dart';

void main() => runApp(const AbilityBridge());

class AbilityBridge extends StatelessWidget {
  const AbilityBridge({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AbilityBridge',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        fontFamily: 'sans-serif',
      ),

      // Starting point of the app
      initialRoute: '/',

      // ROUTE MAP (All 14 Screens Registered)
      routes: {
        // Core Flow
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/about': (context) => const AboutUsScreen(),

        // 🚀 UPDATED: Changed from '/seeker-home' to '/seeker'
        '/seeker': (context) => const SeekerDashboard(),
        '/employer': (context) => const EmployerDashboard(),
        '/job-detail': (context) => const JobDetailScreen(),
        '/post-job': (context) => const PostJobScreen(),
        '/profile': (context) => const ProfileSettingsScreen(),
        '/report': (context) => const ReportScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/applicants': (context) => const ApplicantReviewScreen(),
        '/apply-job': (context) => const ApplyJobScreen(),
        '/chat': (context) => const ChatScreen(),
        '/applicant-review': (context) => const ApplicantReviewScreen(),

        // Community & Personal Growth
        '/mentors': (context) => const MentorshipScreen(),
        '/learning': (context) => const LearningHubScreen(),
        '/forum': (context) => const CommunityForumScreen(),
        '/impact': (context) => const ImpactReportScreen(),
      },
    );
  }
}
