import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'create_society_screen.dart';
import 'join_society_screen.dart';

class SocietyChoiceScreen extends StatelessWidget {
  const SocietyChoiceScreen({super.key});

  static const routeName = '/society-choice';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Society\nawaits',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: AppColors.gray900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Create a new society or join an existing one to get started with your community.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.gray500,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              _ChoiceCard(
                icon: Icons.add_business_rounded,
                title: 'Create Society',
                subtitle: 'Register your society and become the admin',
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                textColor: AppColors.white,
                iconBgColor: Colors.white24,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateSocietyScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ChoiceCard(
                icon: Icons.group_add_rounded,
                title: 'Join Society',
                subtitle: 'Browse and request to join your society',
                gradient: null,
                backgroundColor: AppColors.gray50,
                textColor: AppColors.gray900,
                subtitleColor: AppColors.gray500,
                iconBgColor: AppColors.primaryBg,
                iconColor: AppColors.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JoinSocietyScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.gradient,
    this.backgroundColor,
    this.textColor = AppColors.white,
    this.subtitleColor,
    this.iconBgColor = Colors.white24,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color textColor;
  final Color? subtitleColor;
  final Color iconBgColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? backgroundColor : null,
          borderRadius: BorderRadius.circular(20),
          border: gradient == null
              ? Border.all(color: AppColors.gray200, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor ?? textColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor ?? textColor.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: textColor.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
