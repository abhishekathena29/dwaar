import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../provider/noticeboard_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _postType = 'GENERAL';
  bool _saving = false;

  static const _types = [
    'GENERAL',
    'ANNOUNCEMENT',
    'DISCUSSION',
    'BUY_SELL',
    'RECOMMENDATION',
    'HELP_NEEDED',
    'EVENT_INVITE',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      return;
    }
    setState(() => _saving = true);
    await context.read<NoticeboardProvider>().createPost(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          postType: _postType,
        );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _postType,
            items: _types
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.replaceAll('_', ' ')),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => _postType = value ?? 'GENERAL'),
            decoration: const InputDecoration(labelText: 'Post type'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            minLines: 6,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'What do you want to share?',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
            ),
            child: _saving
                ? const CircularProgressIndicator(color: AppColors.white)
                : const Text('Publish'),
          ),
        ],
      ),
    );
  }
}
