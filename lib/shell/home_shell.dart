import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../features/admin/provider/admin_provider.dart';
import '../features/admin/screens/admin_requests_screen.dart';
import '../features/auth/provider/auth_provider.dart';
import '../features/committee/provider/committee_provider.dart';
import '../features/committee/screens/committee_tab.dart';
import '../features/complaints/provider/complaints_provider.dart';
import '../features/complaints/screens/complaints_tab.dart';
import '../features/complaints/screens/create_complaint_screen.dart';
import '../features/events/provider/events_provider.dart';
import '../features/events/screens/create_event_screen.dart';
import '../features/events/screens/events_tab.dart';
import '../features/noticeboard/provider/noticeboard_provider.dart';
import '../features/noticeboard/screens/create_post_screen.dart';
import '../features/noticeboard/screens/noticeboard_tab.dart';
import '../features/services/screens/services_tab.dart';
import '../widgets/common_widgets.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static const routeName = '/home';

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = [
    'Noticeboard',
    'Complaints',
    'Events',
    'Services',
    'Committee',
  ];

  static const _pages = <Widget>[
    NoticeboardTab(),
    ComplaintsTab(),
    EventsTab(),
    ServicesTab(),
    CommitteeTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeboardProvider>().load();
      context.read<ComplaintsProvider>().load();
      context.read<EventsProvider>().load();
      context.read<CommitteeProvider>().load();
      context.read<AdminProvider>().load();
    });
  }

  void _openComposer() {
    Widget page;
    if (_index == 1) {
      page = const CreateComplaintScreen();
    } else if (_index == 2) {
      page = const CreateEventScreen();
    } else {
      page = const CreatePostScreen();
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final admin = context.watch<AdminProvider>();
    final societyName = auth.membership?.societyName ?? 'Select Society';
    final showFab = _index <= 2;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              societyName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.gray900,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              _titles[_index],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        actions: [
          if (admin.isAdmin)
            Stack(
              children: [
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminRequestsScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.person_add_outlined, size: 22),
                ),
                if (admin.pendingCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '${admin.pendingCount}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
          ),
          IconButton(
            onPressed: () => _showSettings(context),
            icon: const Icon(Icons.settings_outlined, size: 22),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton:
          showFab ? FloatingCreateButton(onPressed: _openComposer) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Noticeboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Services',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Committee',
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    final auth = context.read<AuthProvider>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    AppAvatar(
                      name: auth.profile?.displayName ?? 'U',
                      size: 48,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.profile?.displayName ?? 'Profile',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: AppColors.gray900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            auth.profile?.phoneNumber ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.logout_rounded,
                        color: AppColors.error, size: 20),
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().logout();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
