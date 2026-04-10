import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/providers.dart';
import '../../models/app_models.dart';
import 'app_drawer.dart'; 

// FIXED: Removed the invalid .keepAlive constructor. Standard FutureProviders 
// are kept alive in memory by default unless you use .autoDispose.
final recommendationsProvider = FutureProvider<List<PlaceRecommendationModel>>((ref) async {
  final user = await ref.watch(userControllerProvider.future);
  if (user == null) return [];
  return ref.read(geminiServiceProvider.notifier).getRecommendations(user);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  final Color primaryBlue = const Color(0xFF004781);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationsProvider);
    
    final userState = ref.watch(userControllerProvider);
    final String fullName = userState.value?.name ?? 'Explorer';
    final String firstName = fullName.split(' ').first.toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AppDrawer(), 
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildAppBar(context)),
            SliverToBoxAdapter(child: _buildHeader(firstName)),
            
            recsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $err')),
              ),
              data: (recs) {
                if (recs.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text("No recommendations found.")),
                  );
                }
                
                final trendingList = recs.take(2).toList();
                final personalizedList = recs.skip(2).toList();

                return SliverList.list(
                  children: [
                    _buildSectionHeader('Trending Now', 'Based on global wanderlust data', true),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 320,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: trendingList.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          return _buildTrendingCard(context, trendingList[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader('AI Picks for You', 'Personalized based on your preferences', false),
                    const SizedBox(height: 16),
                    
                    // The AI Picks list built cleanly without shrinkWrap
                    ...List.generate(
                      personalizedList.isNotEmpty ? personalizedList.length : recs.length,
                      (index) {
                        final place = personalizedList.isNotEmpty ? personalizedList[index] : recs[index];
                        return Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                          child: _buildAIPickCard(context, place),
                        );
                      }
                    ),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Builder(
        builder: (innerContext) {
          return GestureDetector(
            onTap: () => Scaffold.of(innerContext).openDrawer(),
            child: Row(
              mainAxisSize: MainAxisSize.min, 
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF004781),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Explorist AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildHeader(String firstName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GOOD MORNING, $firstName', 
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Where shall we\nexplore today?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: primaryBlue,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, bool showViewAll) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (showViewAll)
            Text(
              'View all',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue),
            ),
        ],
      ),
    );
  }

  Widget _buildTrendingCard(BuildContext context, PlaceRecommendationModel place) {
    return GestureDetector(
      onTap: () => context.push('/detail', extra: place),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: CachedNetworkImageProvider(place.imageUrl), 
            fit: BoxFit.cover
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(4)),
                child: const Text('MUST VISIT', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Text(place.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2)),
              const SizedBox(height: 8),
              Text(place.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIPickCard(BuildContext context, PlaceRecommendationModel place) {
    return GestureDetector(
      onTap: () => context.push('/detail', extra: place),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: place.imageUrl, 
                width: 100, 
                height: 100, 
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(width: 100, height: 100, color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(width: 100, height: 100, color: Colors.grey[300], child: const Icon(Icons.error)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: primaryBlue),
                      const SizedBox(width: 4),
                      Text('98% MATCH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryBlue, letterSpacing: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(place.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue)),
                  const SizedBox(height: 4),
                  Text(place.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTag('Scenic'),
                      const SizedBox(width: 8),
                      _buildTag('Adventure'),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Icons.explore, 'Explore', true, () {}),
            _buildNavItem(Icons.add_circle_outline, 'Plan', false, () => context.push('/planner')),
            _buildNavItem(Icons.bookmark_outline, 'Saved', false, () => context.push('/saved')),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    final color = isActive ? primaryBlue : Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: isActive
            ? BoxDecoration(
                color: const Color(0xFFE5F0FF),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}