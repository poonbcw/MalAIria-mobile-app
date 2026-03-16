import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import '../../../core/api/api_config.dart'; 
import '../../../core/storage/auth_storage.dart';
import '../../../core/models/history_item.dart';
import '../../../routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserHistoryList extends StatefulWidget {
  final bool hideEmptyState; 

  const UserHistoryList({
    super.key, 
    this.hideEmptyState = false, 
  });

  @override
  State<UserHistoryList> createState() => _UserHistoryListState();
}

class _UserHistoryListState extends State<UserHistoryList> {
  Future<List<HistoryItem>>? _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory(); 
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = _fetchHistoryFromApi();
    });
  }

  Future<List<HistoryItem>> _fetchHistoryFromApi() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return []; 
    
    try {
      final token = await user.getIdToken(); 

      final url = Uri.parse('${ApiConfig.baseUrl}/api/history');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        var historyList = data.map((json) {
          String imgUrl = '';
          if (json['images'] != null && json['images'].isNotEmpty) {
            imgUrl = json['images'][0]['imageUrl'] ?? '';
          }

          // ✅ ดึงข้อมูลกล่องออกมาจาก detectMetadata
          List<dynamic> parsedBoxes = [];
          if (json['detectMetadata'] != null && json['detectMetadata'] is List) {
            parsedBoxes = json['detectMetadata'];
          }

          return HistoryItem(
            patientId: json['hn']?.toString() ?? 'Unknown',
            model: json['modelUsed'] ?? 'MALARIA-NET', 
            result: json['result'] ?? 'NEGATIVE',
            imagePath: imgUrl, 
            date: json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now(),
            boxes: parsedBoxes, // ✅ แนบกล่องเข้าไปด้วย
          );
        }).toList();

        historyList.sort((a, b) => b.date.compareTo(a.date));

        return historyList;
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      debugPrint("❌ Fetch History Error: $e");
      return []; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthStorage.isLoggedIn();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isLoggedIn)
          _buildPlaceholder(
            icon: Icons.lock_person_outlined,
            title: 'Authentication Required',
            subtitle: 'Sign in to sync and view your clinical history.',
          )
        else
          FutureBuilder<List<HistoryItem>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              if (snapshot.hasError) {
                return _buildPlaceholder(
                  icon: Icons.error_outline,
                  title: 'Connection Error',
                  subtitle: 'Could not load your history. Please try again.',
                );
              }

              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                if (widget.hideEmptyState) {
                  return const SizedBox.shrink(); 
                }
                
                return _buildPlaceholder(
                  icon: Icons.biotech_outlined,
                  title: 'No Records Found',
                  subtitle: 'Start your first analysis to see results here.',
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildHistoryTile(context, items[index]),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.black12),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.4),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(BuildContext context, HistoryItem item) {
    final bool isPositive = item.result.toUpperCase() == 'POSITIVE';
    final Color statusColor = isPositive
        ? const Color(0xFFFF3B30)
        : const Color(0xFF34C759);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.result,
          arguments: {
            'image': item.imagePath,
            'model': item.model,
            'hn': item.patientId,
            'positive': isPositive,
            'fromHistory': true,
            'boxes': item.boxes, // ✅ ส่งข้อมูลกล่องไปให้หน้า Result เพื่อวาดกรอบ
          },
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.model.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.patientId != null && item.patientId != 'Unknown'
                        ? 'HN: ${item.patientId}'
                        : 'General Patient',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.result.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.date.day}/${item.date.month}/${item.date.year}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }
}