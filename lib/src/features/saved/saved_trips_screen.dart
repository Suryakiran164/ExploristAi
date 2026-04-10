import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/providers.dart';
import '../../models/app_models.dart';

final savedTripsProvider = StreamProvider<List<TripModel>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  if (user == null) return Stream.value([]);
  
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('trips')
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => TripModel.fromMap(doc.data()))
          .toList()
          .cast<TripModel>()); // Cast ensures it's List<TripModel>
});

class SavedTripsScreen extends ConsumerWidget {
  const SavedTripsScreen({super.key});

  final Color primaryBlue = const Color(0xFF003461);
  final Color greenAccent = const Color(0xFF4A7D59);
  final Color bgLight = const Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(savedTripsProvider);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBlue),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Saved Itineraries',
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading trips: $err')),
        data: (trips) {
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No saved trips yet.', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Start planning your next adventure!', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: trips.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final trip = trips[index];
              return _buildTripCard(context, trip);
            },
          );
        },
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripModel trip) {
    String tripTitle = 'Trip to ${trip.destination}';
    if (trip.itinerary.isNotEmpty && trip.itinerary.first['tripTitle'] != null) {
      tripTitle = trip.itinerary.first['tripTitle'];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE5F0FF), borderRadius: BorderRadius.circular(8)),
                child: Text('${trip.durationDays} Days', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryBlue)),
              ),
              Text(
                '₹${trip.budget.toInt()}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: greenAccent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(tripTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryBlue)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.my_location, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(trip.startingPoint, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
              ),
              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(trip.destination, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Saved on ${trip.createdAt.day}/${trip.createdAt.month}/${trip.createdAt.year}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}