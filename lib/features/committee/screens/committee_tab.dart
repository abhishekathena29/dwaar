import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../widgets/common_widgets.dart';
import '../provider/committee_provider.dart';

class CommitteeTab extends StatelessWidget {
  const CommitteeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommitteeProvider>(
      builder: (context, provider, _) {
        if (provider.members.isEmpty) {
          return const Center(child: Text('No committee members found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.members.length,
          itemBuilder: (context, index) {
            final member = provider.members[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: AppAvatar(
                  name: member.name,
                  imageUrl: member.avatarUrl,
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Flat ${member.flatNumber}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    member.role.replaceAll('_', ' '),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
