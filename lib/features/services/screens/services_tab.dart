import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../provider/services_provider.dart';
import 'service_detail_screen.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  final _searchController = TextEditingController();

  static const _categories = [
    [null, 'All'],
    ['PLUMBER', 'Plumber'],
    ['ELECTRICIAN', 'Electrician'],
    ['MAID', 'Maid'],
    ['CARPENTER', 'Carpenter'],
    ['AC_REPAIR', 'AC Repair'],
    ['TUTOR', 'Tutor'],
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search services...',
                  suffixIcon: IconButton(
                    onPressed: () {
                      provider.setFilters(
                        query: _searchController.text.trim(),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
                onSubmitted: (value) =>
                    provider.setFilters(query: value),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: _categories
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(item[1]!),
                          selected: provider.selectedCategory == item[0],
                          onSelected: (_) =>
                              provider.setFilters(category: item[0]),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: provider.services.isEmpty
                  ? const Center(child: Text('No services found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.services.length,
                      itemBuilder: (context, index) {
                        final service = provider.services[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailScreen(
                                    serviceId: service.id),
                              ),
                            ),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.work_outline,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (service.isVerified)
                                  const Icon(
                                    Icons.verified,
                                    color: AppColors.secondary,
                                    size: 18,
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(service.contactName),
                                const SizedBox(height: 4),
                                Text(
                                  service.avgRating > 0
                                      ? '${service.avgRating.toStringAsFixed(1)} (${service.totalReviews} reviews)'
                                      : 'New',
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () => launchUrl(
                                Uri.parse('tel:${service.contactPhone}'),
                              ),
                              icon: const Icon(
                                Icons.call,
                                color: AppColors.secondary,
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
