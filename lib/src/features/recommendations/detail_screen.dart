import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/app_models.dart';
import '../../services/providers.dart';
import '../home/home_screen.dart';

class DetailScreen extends ConsumerWidget {
  final PlaceRecommendationModel place;
  const DetailScreen({super.key, required this.place});

  final Color primaryBlue = const Color(0xFF003461);
  final Color darkBg = const Color(0xFF071A2B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003461)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Explorist AI',
          style: TextStyle(color: Color(0xFF003461), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF003461),
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                _buildDarkHeader(context),
                _buildContentBody(context, ref),
              ],
            ),
          ),
          
          // Fixed Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: darkBg,
      padding: const EdgeInsets.only(top: 40, bottom: 80, left: 24, right: 24),
      child: Column(
        children: [
          // Circular Graphic Element
          Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              image: DecorationImage(
                image: CachedNetworkImageProvider(place.imageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(darkBg.withOpacity(0.5), BlendMode.srcOver),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // DYNAMIC TAGS FROM AI
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: place.tags.map((tag) => _buildTag(tag)).toList(),
          ),
          const SizedBox(height: 16),
          
          // DYNAMIC TITLE
          Text(
            place.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'DESTINATION',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              letterSpacing: 4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildContentBody(BuildContext context, WidgetRef ref) {
    return Container(
      transform: Matrix4.translationValues(0, -40, 0),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Info Card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The Curated Horizon', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue)),
                const SizedBox(height: 16),
                Text(
                  place.summary,
                  style: const TextStyle(color: Colors.black87, height: 1.6, fontSize: 15),
                ),
                const SizedBox(height: 24),
                
                // DYNAMIC STATS GRID
                Row(
                  children: [
                    Expanded(child: _buildStatBox(Icons.thermostat, 'Avg Temp', place.avgTemp)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatBox(Icons.hiking, 'Difficulty', place.difficulty)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatBox(Icons.calendar_month, 'Best Visit', place.bestVisit)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatBox(Icons.visibility, 'Popularity', place.popularity)),
                  ],
                ),
              ],
            ),
          ),

          // DYNAMIC ACTIVITIES SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: place.activities.map((act) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildImageCard(act['tag'] ?? 'Activity', act['title'] ?? 'Explore'),
              )).toList(),
            ),
          ),
          
          const SizedBox(height: 24),

          // DYNAMIC PRICING CARD
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: darkBg, size: 20),
                    const SizedBox(width: 8),
                    const Text('Travel & Pricing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildPriceRow(Icons.flight_takeoff, 'Flights (Est.)', place.flightCost),
                const SizedBox(height: 12),
                _buildPriceRow(Icons.bed, 'Stay (Nightly)', place.stayCost),
                const SizedBox(height: 12),
                _buildPriceRow(Icons.two_wheeler, 'Motorcycle Rental', place.rentalCost),
                
                const SizedBox(height: 32),
                
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/planner'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Plan My Trip', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(userControllerProvider.notifier).markAsVisited(place.name);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as visited!')));
                        context.pop();
                      }
                      ref.invalidate(recommendationsProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC8E6C9),
                      foregroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: const Text('Already visited', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'AI-POWERED PRICE PREDICTIONS FOR NEXT 30 DAYS',
                    style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildImageCard(String tag, String title) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: CachedNetworkImageProvider(place.imageUrl), 
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tag.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(IconData icon, String label, String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.push('/planner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('Plan Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                icon: const Icon(Icons.bookmark),
                color: Colors.black87,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to bookmarks!')));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}