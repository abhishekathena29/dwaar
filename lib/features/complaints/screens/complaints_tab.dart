import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../noticeboard/screens/thread_detail_screen.dart';
import '../provider/complaints_provider.dart';

class ComplaintsTab extends StatelessWidget {
  const ComplaintsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ComplaintsProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _FilterTab(
                      label: 'Active',
                      active: !provider.resolvedOnly,
                      onTap: () => provider.setMode(false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _FilterTab(
                      label: 'Resolved',
                      active: provider.resolvedOnly,
                      onTap: () => provider.setMode(true),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.complaints.isEmpty
                  ? const Center(child: Text('No complaints'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.complaints.length,
                      itemBuilder: (context, index) {
                        final complaint = provider.complaints[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ThreadDetailScreen(
                                    threadId: complaint.id),
                              ),
                            ),
                            title: Text(
                              complaint.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    complaint.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _StatusBadge(label: complaint.status),
                                      const Spacer(),
                                      Text(
                                        DateTimeUtils.timeAgo(
                                          complaint.createdAt,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray200),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.white : AppColors.gray500,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.error;
    Color bg = AppColors.errorBg;
    if (label == 'RESOLVED') {
      color = AppColors.secondary;
      bg = AppColors.secondaryBg;
    } else if (label == 'ASSIGNED') {
      color = AppColors.primary;
      bg = AppColors.primaryBg;
    } else if (label == 'POLLING') {
      color = const Color(0xFF8B5CF6);
      bg = const Color(0xFFEDE9FE);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
