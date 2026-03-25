import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../shared/widgets/bottom_nav.dart';
import 'widgets/user_history_list.dart';
import 'widgets/global_stats_grid.dart';
import '../../routes/app_routes.dart';
import '../../core/storage/auth_storage.dart'; 
import '../../core/providers/analysis_queue_provider.dart'; 

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Key _historyKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    // 🟢 🟢 🟢 เพิ่มบล็อกนี้: ดักฟังการอัปเดตของคิว 🟢 🟢 🟢
    ref.listen<List<AnalysisTask>>(analysisQueueProvider, (previous, next) {
      // ถ้าจำนวนคิวน้อยลง (แปลว่ามีงานส่งขึ้น Cloud สำเร็จและถูกลบออกไป)
      if (previous != null && previous.length > next.length) {
        setState(() {
          _historyKey = UniqueKey(); // สั่งรีเฟรชให้ UserHistoryList ยิง API ใหม่ทันทีแบบเรียลไทม์
        });
      }
    });
    // =========================================================

    final bool isLoggedIn = AuthStorage.isLoggedIn();
    
    final queueTasks = ref.watch(analysisQueueProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 22, 27, 50),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Hero(
          tag: 'app-logo',
          child: Image.asset(
            'assets/images/whiteLogo.png',
            width: 48,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const GlobalStatsGrid(),
            const SizedBox(height: 32),

            _sectionTitle(isLoggedIn ? 'RECENT HISTORY' : 'PERSONAL HISTORY'),
            const SizedBox(height: 12),

            if (queueTasks.isNotEmpty) ...[
              ...queueTasks.reversed.map((task) => _buildQueueCard(task)),
              const SizedBox(height: 8), 
            ],

            if (isLoggedIn) ...[
              UserHistoryList(
                key: _historyKey,
                hideEmptyState: queueTasks.isNotEmpty, 
              ),
            ] else ...[
              _buildGuestCard(context),
            ],
            
            const SizedBox(height: 80), 
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.white,
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.upload);
        },
        child: const Icon(Icons.add_rounded, color: Colors.black),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.4),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildQueueCard(AnalysisTask task) {
    IconData icon;
    Color iconColor;
    String statusText;
    Widget? statusWidget;

    // เช็คสถานะเพื่อกำหนด UI
    switch (task.status) {
      case TaskStatus.pending:
        icon = Icons.hourglass_empty_rounded;
        iconColor = Colors.orangeAccent;
        statusText = 'Waiting in queue...';
        statusWidget = null;
        break;
      case TaskStatus.processing:
        icon = Icons.sync_rounded;
        iconColor = Colors.blueAccent;
        statusText = 'AI is analyzing...';
        statusWidget = const SizedBox(
          width: 16, height: 16, 
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent)
        );
        break;
      case TaskStatus.completed:
        icon = Icons.check_circle_rounded;
        iconColor = Colors.greenAccent;
        statusText = 'Analysis complete! Tap to view.';
        statusWidget = null;
        break;
      case TaskStatus.error:
        icon = Icons.error_rounded;
        iconColor = Colors.redAccent;
        statusText = 'Failed: ${task.errorMessage}';
        statusWidget = null;
        break;
    }

    return Card(
      color: Colors.white.withOpacity(0.05),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(task.image, width: 48, height: 48, fit: BoxFit.cover),
        ),
        title: Text(
          task.hn != null ? 'HN: ${task.hn}' : 'Unknown Patient',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Row(
          children: [
            if (statusWidget != null) ...[
              statusWidget,
              const SizedBox(width: 8),
            ] else ...[
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                statusText,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        // ✅ ปรับส่วน Trailing ใหม่ให้ชัดเจน
        trailing: _buildTrailingWidget(context, task),
        onTap: task.status == TaskStatus.completed 
          ? () async { 
              await Navigator.pushNamed(context, AppRoutes.result, arguments: {
                'image': task.image.path, 
                'model': 'YOLOv8', 
                'hn': task.hn,
                'positive': task.isPositive, 
                'confidence': task.confidence, 
                'boxes': task.boxes, 
              });
              
              // 🟢 ลบบรรทัด removeTask ออกไปเลยครับ!
              // ให้การซิงค์ข้อมูล (Auto-Sync) เป็นคนจัดการลบการ์ดใบนี้แทนเวลาเน็ตมา
              
              setState(() { _historyKey = UniqueKey(); });
            }
          : null,
      ),
    );
  }

  // ✅ แยกฟังก์ชันปุ่มด้านขวาออกมาเพื่อความไม่งง
  Widget _buildTrailingWidget(BuildContext context, AnalysisTask task) {
    if (task.status == TaskStatus.completed) {
      return const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16);
    }

    // ถ้ายังไม่เสร็จ ให้โชว์ปุ่มกากบาท (ยกเลิก)
    return IconButton(
      icon: const Icon(Icons.cancel_rounded, color: Colors.white38, size: 24), // เปลี่ยนไอคอนให้เด่นขึ้น
      onPressed: () async {
        final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1C223D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Cancel Analysis?', style: TextStyle(color: Colors.white)),
            content: const Text('Do you want to stop this process?', style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('NO')),
              TextButton(
                onPressed: () => Navigator.pop(context, true), 
                child: const Text('YES', style: TextStyle(color: Colors.redAccent))
              ),
            ],
          ),
        ) ?? false;

        if (confirm) {
          ref.read(analysisQueueProvider.notifier).removeTask(task.id);
        }
      },
    );
  }

  Widget _buildGuestCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded, 
            color: Colors.white.withOpacity(0.3), 
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Log in to track your diagnostic records',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}