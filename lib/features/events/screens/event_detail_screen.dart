import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/app_models.dart';
import '../../../core/utils/date_time_utils.dart';
import '../provider/events_provider.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventItem? _event;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final event =
        await context.read<EventsProvider>().fetchDetail(widget.threadId);
    if (!mounted) return;
    setState(() {
      _event = event;
      _loading = false;
    });
  }

  Future<void> _rsvp(String status) async {
    await context
        .read<EventsProvider>()
        .updateRsvp(threadId: widget.threadId, status: status);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final event = _event;
    if (event == null) {
      return const Scaffold(body: Center(child: Text('Event not found')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateTimeUtils.format(event.eventDate, 'MMM')
                              .toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          DateTimeUtils.format(event.eventDate, 'd'),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('by ${event.ownerName}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            text:
                DateTimeUtils.format(event.eventDate, 'EEEE, MMMM d, yyyy'),
          ),
          _DetailRow(
            icon: Icons.access_time_outlined,
            text: DateTimeUtils.format(event.eventDate, 'h:mm a'),
          ),
          _DetailRow(
            icon: Icons.location_on_outlined,
            text: event.eventLocation,
          ),
          _DetailRow(
            icon: Icons.group_outlined,
            text: '${event.goingCount} going',
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text(event.description),
                  ],
                ),
              ),
            ),
          ],
          if (!event.isPast) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RSVP',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _RsvpButton(
                            label: 'Going',
                            active: event.userRsvp == 'GOING',
                            onTap: () => _rsvp('GOING'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _RsvpButton(
                            label: 'Maybe',
                            active: event.userRsvp == 'MAYBE',
                            onTap: () => _rsvp('MAYBE'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _RsvpButton(
                            label: 'Not Going',
                            active: event.userRsvp == 'NOT_GOING',
                            onTap: () => _rsvp('NOT_GOING'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(text),
      ),
    );
  }
}

class _RsvpButton extends StatelessWidget {
  const _RsvpButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: active ? AppColors.white : AppColors.primary,
        backgroundColor: active ? AppColors.primary : AppColors.white,
        side:
            BorderSide(color: active ? AppColors.primary : AppColors.gray200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}
