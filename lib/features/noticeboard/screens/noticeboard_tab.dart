import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_models.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../widgets/common_widgets.dart';
import '../provider/noticeboard_provider.dart';
import 'thread_detail_screen.dart';

class NoticeboardTab extends StatelessWidget {
  const NoticeboardTab({super.key});

  static const Map<String, String> _labels = {
    'all': 'All',
    'announcements': 'Announcements',
    'marketplace': 'Marketplace',
    'community': 'Community',
    'civic': 'Civic Issues',
    'alerts': 'Alerts & Help',
    'general': 'General',
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<NoticeboardProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            SizedBox(
              height: 62,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                scrollDirection: Axis.horizontal,
                children: _labels.entries
                    .map(
                      (entry) => SectionChip(
                        label: entry.value,
                        active: provider.activeSection == entry.key,
                        onTap: () => provider.setSection(entry.key),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: provider.posts.isEmpty
                  ? const Center(child: Text('No posts yet'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.posts.length,
                      itemBuilder: (context, index) {
                        final post = provider.posts[index];
                        return _PostCard(post: post);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final FeedPost post;

  static const _typeLabels = {
    'ANNOUNCEMENT': 'Announcement',
    'EMERGENCY': 'Emergency',
    'BUY_SELL': 'Buy/Sell',
    'RECOMMENDATION': 'Recommendation',
    'HOBBY': 'Hobby',
    'GENERAL': 'General',
    'DISCUSSION': 'Discussion',
    'POLL': 'Poll',
  };

  @override
  Widget build(BuildContext context) {
    final reactionTotal = post.reactionCounts.values.fold<int>(
      0,
      (a, b) => a + b,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ThreadDetailScreen(threadId: post.threadId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.isPinned)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Pinned',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  AppAvatar(
                    name: post.author.name,
                    imageUrl: post.author.avatarUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          DateTimeUtils.timeAgo(post.createdAt),
                          style: const TextStyle(color: AppColors.gray500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _typeLabels[post.postType] ?? post.postType,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (post.threadTitle.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  post.threadTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(post.content, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 18,
                    color: AppColors.gray400,
                  ),
                  const SizedBox(width: 4),
                  Text('$reactionTotal'),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: AppColors.gray400,
                  ),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
