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
          .cast<TripModel>()); 
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
              
              // 1. Wrap in Dismissible for Swipe-to-Delete functionality
              return Dismissible(
                key: Key(trip.tripId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                // Show a confirmation dialog before deleting
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Trip'),
                      content: const Text('Are you sure you want to remove this itinerary?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  // Call the delete method in your provider
                  ref.read(userControllerProvider.notifier).deleteTrip(trip.tripId);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip deleted')));
                },
                // 2. Wrap in GestureDetector for "View Details" functionality
                child: GestureDetector(
                  onTap: () {
                    // Navigate to planner and pass the existing trip as 'extra'
                    context.push('/planner', extra: trip);
                  },
                  child: _buildTripCard(context, trip, ref),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripModel trip, WidgetRef ref) {
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
              // Delete Icon Button as an alternative to swiping
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                onPressed: () async {
                   bool? confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Trip'),
                      content: const Text('Remove this itinerary?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(userControllerProvider.notifier).deleteTrip(trip.tripId);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(tripTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryBlue))),
              Text(
                '₹${trip.budget.toInt()}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: greenAccent),
              ),
            ],
          ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved on ${trip.createdAt.day}/${trip.createdAt.month}/${trip.createdAt.year}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const Row(
                children: [
                  Text('View Details', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF003461))),
                  Icon(Icons.chevron_right, size: 14, color: Color(0xFF003461)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}