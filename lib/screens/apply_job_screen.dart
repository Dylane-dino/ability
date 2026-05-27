// lib/screens/apply_job_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/application_service.dart';

class ApplyJobScreen extends StatefulWidget {
  const ApplyJobScreen({super.key});

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _coverLetterController = TextEditingController();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve arguments passed from JobDetailScreen
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['jobId'] != null) {
      _jobId = args['jobId'] as int;
      _jobTitle = args['jobTitle'] as String?;
      _companyName = args['companyName'] as String?;
    } else {
      // No jobId provided, pop back
      Future.microtask(() => Navigator.maybePop(context));
    }
  }

  late int _jobId;
  String? _jobTitle;
  String? _companyName;

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final seekerId = prefs.getInt('userId');

      if (seekerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found. Please log in again.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final success = await ApplicationService().submitApplication(
        jobId: _jobId,
        seekerId: seekerId,
        coverLetter: _coverLetterController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application submitted successfully!")),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit application. Try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apply for Job")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_jobTitle != null && _companyName != null) ...[
                Text(
                  _jobTitle!,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  "at $_companyName",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
              ],
              const Text(
                "Tell the employer why you're a great fit. This will be visible only to the hiring team.",
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _coverLetterController,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: "Cover Letter (Optional)",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (val) {
                  if (val != null && val.length > 1000) {
                    return 'Cover letter is too long (max 1000 chars)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Application", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
