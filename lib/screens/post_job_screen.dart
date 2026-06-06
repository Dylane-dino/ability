// lib/screens/post_job_screen.dart
import 'package:flutter/material.dart';
import '../models/job_listing.dart';
import '../services/job_services.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _jobType = 'full-time';
  bool _isRemote = false;
  bool _isLoading = false;

  Future<void> _submitJob() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // 🚀 FIX: Removed the SharedPreferences query for 'employerId' 
      // The backend handles user verification directly via the JWT header token.
      final JobListing newJob = JobListing(
        title: _titleController.text,
        description: _descController.text,
        jobType: _jobType,
        isRemote: _isRemote,
        accommodations: const {"wheelchair": true},
      );

      bool success = await JobService().postJob(newJob);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Job posted successfully! 🎉")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to post job. Please try again."),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post a New Job")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Job Title",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter a job title' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Job Description",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _jobType,
                decoration: const InputDecoration(
                  labelText: "Job Type",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'full-time',
                    child: Text("Full-Time"),
                  ),
                  DropdownMenuItem(
                    value: 'part-time',
                    child: Text("Part-Time"),
                  ),
                  DropdownMenuItem(
                    value: 'micro-task',
                    child: Text("Micro-Task"),
                  ),
                ],
                onChanged: (val) => setState(() => _jobType = val!),
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text("Remote Role"),
                subtitle: const Text("Can this job be done from home?"),
                value: _isRemote,
                onChanged: (val) => setState(() => _isRemote = val),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _submitJob,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Post Job",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}