import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_models.dart';
import '../../../core/utils/date_time_utils.dart';
import '../../../widgets/common_widgets.dart';
import '../provider/noticeboard_provider.dart';

class ThreadDetailScreen extends StatefulWidget {
  const ThreadDetailScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<ThreadDetailScreen> createState() => _ThreadDetailScreenState();
}

class _ThreadDetailScreenState extends State<ThreadDetailScreen> {
  ThreadDetail? _thread;
  bool _loading = true;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final thread = await context
        .read<NoticeboardProvider>()
        .fetchThreadDetail(widget.threadId);
    if (!mounted) return;
    setState(() {
      _thread = thread;
      _loading = false;
    });
  }

  Future<void> _send() async {
    if (_messageController.text.trim().isEmpty) return;
    await context.read<NoticeboardProvider>().sendThreadMessage(
          threadId: widget.threadId,
          content: _messageController.text.trim(),
        );
    _messageController.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final thread = _thread;
    if (thread == null) {
      return const Scaffold(body: Center(child: Text('Thread not found')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(thread.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          thread.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('by ${thread.ownerName}'),
                        const SizedBox(height: 4),
                        Text(DateTimeUtils.timeAgo(thread.createdAt)),
                        if (thread.description != null) ...[
                          const SizedBox(height: 12),
                          Text(thread.description!),
                        ],
                      ],
                    ),
                  ),
                ),
                if (thread.polls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...thread.polls.map(_PollCard.new),
                ],
                const SizedBox(height: 8),
                ...thread.posts.map(
                  (post) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      DateTimeUtils.timeAgo(post.createdAt),
                                      style: const TextStyle(
                                        color: AppColors.gray500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(post.content),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write a message...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _send,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(52, 52),
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PollCard extends StatelessWidget {
  const _PollCard(this.poll);

  final PollItem poll;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.poll, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Poll',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                if (poll.isClosed) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Closed'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              poll.question,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...poll.options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(option.text)),
                        Text('${option.percentage}%'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: option.percentage / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.gray100,
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 4),
                    Text('${option.voteCount} votes'),
                  ],
                ),
              ),
            ),
            Text('${poll.totalVotes} total votes'),
          ],
        ),
      ),
    );
  }
}
