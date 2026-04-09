import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/providers.dart';
import '../../models/app_models.dart';
import 'app_drawer.dart';

final recommendationsProvider = FutureProvider<List<PlaceRecommendationModel>>((ref) async {
  final user = await ref.watch(userControllerProvider.future);
  if (user == null) return [];
  return ref.read(geminiServiceProvider.notifier).getRecommendations(user);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationsProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Explorist AI', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.add_location_alt), onPressed: () => context.push('/planner')),
        ],
      ),
      body: recsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (recs) => ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: recs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final place = recs[index];
            return GestureDetector(
              onTap: () => context.push('/detail', extra: place),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(place.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(height: 200, color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(place.name, style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Text(place.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/planner'),
        icon: const Icon(Icons.flight_takeoff),
        label: const Text('Plan Trip'),
      ),
    );
  }
}