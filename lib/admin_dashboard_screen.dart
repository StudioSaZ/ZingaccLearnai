import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0A1C14); // Deep Dark Green
    const panel = Color(0xFF112A20); // Dark Green Panel
    const gold = Color(0xFFD4AF37); // Premium Gold

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: gold)),
        backgroundColor: background,
        foregroundColor: gold,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: gold));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('භාවිත කරන්නන් හමු නොවීය.', style: TextStyle(color: Colors.white70)),
            );
          }

          final users = snapshot.data!.docs;
          int totalUsers = users.length;
          int totalCoins = 0;
          int totalPaymentsCount = 0;
          int freeUsersCount = 0;

          // ගණනය කිරීම් (Calculations)
          for (var doc in users) {
            var data = doc.data() as Map<String, dynamic>;
            totalCoins += (data['coins'] ?? 0) as int;

            // isPremium හෝ package එකක් ඇक्टිව් ද බලමු
            bool isPremium = (data['isPremium'] == true) ||
                (data['subscription_expires_at'] != null &&
                    DateTime.tryParse(data['subscription_expires_at'].toString())?.isAfter(DateTime.now()) == true);

            if (isPremium) {
              totalPaymentsCount++;
            } else {
              freeUsersCount++;
            }
          }

          // සෙවුම් කිරීම සඳහා (Search Filtering)
          final filteredUsers = users.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String email = (data['email'] ?? '').toString().toLowerCase();
            return email.contains(searchQuery.toLowerCase());
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📊 පද්ධති සාරාංශය (System Statistics)',
                  style: TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Stats Cards Row 1
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('මුළු ළමයි (Downloads)', '$totalUsers', Colors.blueAccent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('ප්‍රීමියම් ගෙවීම් කළ', '$totalPaymentsCount', Colors.greenAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stats Cards Row 2
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard('නොමිලේ (Free Users)', '$freeUsersCount', Colors.orangeAccent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard('මුළු Coins', '$totalCoins', gold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ශිෂ්‍යයාගේ Email එක මඟින් සොයන්න...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: gold),
                    filled: true,
                    fillColor: panel,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: gold.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: gold, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  '👥 ලියාපදිංචි ළමයින්ගේ ලැයිස්තුව',
                  style: TextStyle(color: gold, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Users List
                Expanded(
                  child: filteredUsers.isEmpty
                      ? const Center(
                    child: Text('ගැලපෙන පරිශීලකයින් හමු නොවීය.', style: TextStyle(color: Colors.white70)),
                  )
                      : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      var userData = filteredUsers[index].data() as Map<String, dynamic>;
                      String email = userData['email'] ?? 'No Email';
                      int coins = userData['coins'] ?? 0;

                      bool isPremium = (userData['isPremium'] == true) ||
                          (userData['subscription_expires_at'] != null &&
                              DateTime.tryParse(userData['subscription_expires_at'].toString())?.isAfter(DateTime.now()) == true);

                      return Card(
                        color: panel,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: gold.withOpacity(0.3)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isPremium ? Colors.green.withOpacity(0.2) : gold.withOpacity(0.15),
                            child: Icon(
                              isPremium ? Icons.workspace_premium_rounded : Icons.person_rounded,
                              color: isPremium ? Colors.greenAccent : gold,
                            ),
                          ),
                          title: Text(email, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Text('Coins: $coins', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isPremium ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isPremium ? Colors.greenAccent : Colors.orangeAccent,
                              ),
                            ),
                            child: Text(
                              isPremium ? 'PREMIUM' : 'FREE',
                              style: TextStyle(
                                color: isPremium ? Colors.greenAccent : Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    const panel = Color(0xFF112A20);
    const gold = Color(0xFFD4AF37);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: gold.withOpacity(0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}