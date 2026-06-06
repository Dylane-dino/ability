import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Live dynamic counter stats mapped directly from your database
  int _totalPosts = 0;
  int _totalApps = 0;
  int _interviews = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardPayload();
  }

  // 🚀 FETCH LIVE METRICS AND LISTINGS FROM BACKEND FILTERED BY EMPLOYER ID
  Future<void> _fetchDashboardPayload() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      // 🛠️ Read saved identifier from login screen (Fall back to ID 1 for testing purposes)
      final employerId = prefs.getInt('employerId') ?? 1;

      // Pulls clean telemetry data mapping from your updated JobService stream, passing the employerId
      final Map<String, dynamic> dashboardData = await JobService()
          .fetchEmployerDashboardData(employerId);

      setState(() {
        _myJobs = dashboardData['jobs'] as List<JobListing>;

        // Extract live summary totals sent down by Node.js express routers
        final Map<String, dynamic> stats = dashboardData['stats'] ?? {};
        _totalPosts = stats['totalPosts'] ?? 0;
        _totalApps = stats['totalApps'] ?? 0;
        _interviews = stats['interviews'] ?? 0;

        _isLoading = false;
      });
    } catch (e) {
      print("💥 Error loading employer dashboard UI elements: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _fetchDashboardPayload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employer Portal"),
        actions: [
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh dashboard metrics",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📊 LIVE STATS COUNTER BAR
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _topStat("Total Posts", _totalPosts.toString()),
                      _topStat("Total Apps", _totalApps.toString()),
                      _topStat("Interviews", _interviews.toString()),
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

                // 📝 JOB ACTIVE LISTING DYNAMIC BUILDER
                Expanded(
                  child: _myJobs.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              "No jobs posted yet. Tap 'Post New Job' to get started.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _onRefresh,
                          child: ListView.builder(
                            itemCount: _myJobs.length,
                            itemBuilder: (context, index) {
                              final job = _myJobs[index];
                              return _jobStatCard(job);
                            },
                          ),
                        ),
                ),

                // ➕ POST JOB NAVIGATION BUTTON ACTION CONTAINER
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.pushNamed(context, '/post-job');
                        _fetchDashboardPayload(); // Refresh automatically upon returning
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        "Post New Job",
                        style: TextStyle(fontSize: 16),
                      ),
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
        const SizedBox(height: 4),
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
        title: Text(
          job.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "${job.jobType.toUpperCase()} • ${job.isRemote ? 'Remote' : 'On-Site'}",
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              // 🛠️ FIXED: Pulling live individual counts dynamically per card listing if your model exposes it
              "${job.applicantCount ?? 0} Applicants",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent.shade700,
              ),
            ),
            const Text(
              "active listing",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        // 🛠️ ROUTE ALIGNMENT: Points to your review screen route name ('/applicant-review')
        onTap: () => Navigator.pushNamed(
          context,
          '/applicant-review',
          arguments: {'jobId': job.jobId, 'jobTitle': job.title},
        ),
      ),
    );
  }
}
