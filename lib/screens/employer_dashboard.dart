// lib/screens/employer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_components.dart';
import '../services/job_services.dart';
import '../models/job_listing.dart';

class EmployerDashboard extends StatefulWidget {
  const EmployerDashboard({super.key});

  @override
  State<EmployerDashboard> createState() => _EmployerDashboardState();
}

class _EmployerDashboardState extends State<EmployerDashboard> {
  List<JobListing> _myJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyJobs();
  }

  Future<void> _fetchMyJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getInt('companyId');
    if (companyId == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Fetch all jobs and filter by companyId
    final allJobs = await JobService().fetchJobs();
    final myJobs = allJobs.where((j) => j.companyId == companyId).toList();

    setState(() {
      _myJobs = myJobs;
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchMyJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employer Portal"),
        actions: [
          IconButton(onPressed: _onRefresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _topStat("Total Posts", _myJobs.length.toString()),
                      _topStat("Total Apps", "12"),
                      _topStat("Interviews", "3"),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Your Active Listings",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                // Job List
                Expanded(
                  child: _myJobs.isEmpty
                      ? const Center(child: Text("No jobs posted yet. Tap 'Post New Job' to get started."))
                      : ListView.builder(
                          itemCount: _myJobs.length,
                          itemBuilder: (context, index) {
                            final job = _myJobs[index];
                            return _jobStatCard(job);
                          },
                        ),
                ),
                // Post Job Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/post-job'),
                      icon: const Icon(Icons.add),
                      label: const Text("Post New Job", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _topStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _jobStatCard(JobListing job) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${job.jobType} • ${job.isRemote ? 'Remote' : 'On-Site'}"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "12 Applicants",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
            const Text("total", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        onTap: () => Navigator.pushNamed(
          context,
          '/applicants',
          arguments: {'jobId': job.jobId, 'jobTitle': job.title},
        ),
      ),
    );
  }
}
