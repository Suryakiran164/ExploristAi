import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/app_models.dart';
import '../../services/providers.dart';
import '../home/home_screen.dart';

class DetailScreen extends ConsumerWidget {
  final PlaceRecommendationModel place;
  const DetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(place.name),
              background: Image.network(place.imageUrl, fit: BoxFit.cover,
                errorBuilder: (c,e,s) => Container(color: Colors.grey[300])),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Text(place.summary, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Travel & Pricing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.schedule),
                          title: const Text('Estimated Time'),
                          trailing: Text(place.estimatedTime),
                        ),
                        ListTile(
                          leading: const Icon(Icons.payments),
                          title: const Text('Budget Estimate'),
                          trailing: Text(place.estimatedTravelCost),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF466649)),
                      onPressed: () async {
                        await ref.read(userControllerProvider.notifier).markAsVisited(place.name);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as visited!')));
                        context.pop();
                        ref.invalidate(recommendationsProvider); // Refresh recommendations
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Already visited ✅'),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}