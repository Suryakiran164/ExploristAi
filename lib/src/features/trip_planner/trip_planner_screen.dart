import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/providers.dart';
import '../../models/app_models.dart';

class TripPlannerScreen extends ConsumerStatefulWidget {
  const TripPlannerScreen({super.key});
  @override
  ConsumerState<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends ConsumerState<TripPlannerScreen> {
  final startCtrl = TextEditingController();
  final destCtrl = TextEditingController();
  final daysCtrl = TextEditingController();
  double budget = 2500;
  bool isGenerating = false;
  Map<String, dynamic>? generatedItinerary;

  Future<void> _generate() async {
    setState(() => isGenerating = true);
    try {
      final result = await ref.read(geminiServiceProvider.notifier).generateItinerary(
        start: startCtrl.text, destination: destCtrl.text,
        days: int.parse(daysCtrl.text), budget: budget
      );
      setState(() => generatedItinerary = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => isGenerating = false);
  }

  Future<void> _saveTrip() async {
    final user = ref.read(firebaseAuthProvider).currentUser!;
    final trip = TripModel(
      tripId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.uid, startingPoint: startCtrl.text, destination: destCtrl.text,
      durationDays: int.parse(daysCtrl.text), budget: budget,
      itinerary: List<Map<String,dynamic>>.from(generatedItinerary?['itinerary'] ?? []),
      createdAt: DateTime.now()
    );

    await ref.read(firestoreProvider).collection('trips').doc(trip.tripId).set(trip.toMap());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip Saved!')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (generatedItinerary != null) {
      final items = generatedItinerary!['itinerary'] as List;
      return Scaffold(
        appBar: AppBar(title: const Text('Your Itinerary')),
        body: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: items.length,
          itemBuilder: (c, i) {
            final day = items[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Day ${day['day']}: ${day['title']}', style: Theme.of(context).textTheme.headlineSmall),
                    const Divider(),
                    Text('Lodging: ${day['lodging']}'),
                    Text('Est Cost: \$${day['estimatedDailyCost']}'),
                    const SizedBox(height: 8),
                    ...List<String>.from(day['activities'] ?? []).map((a) => Text('• $a'))
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _saveTrip, icon: const Icon(Icons.bookmark), label: const Text('Save Trip')
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Plan Your Next Adventure')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Starting Point', prefixIcon: Icon(Icons.my_location))),
          const SizedBox(height: 16),
          TextField(controller: destCtrl, decoration: const InputDecoration(labelText: 'Destination', prefixIcon: Icon(Icons.location_on))),
          const SizedBox(height: 16),
          TextField(controller: daysCtrl, decoration: const InputDecoration(labelText: 'Duration (Days)'), keyboardType: TextInputType.number),
          const SizedBox(height: 32),
          Text('Total Budget: \$${budget.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: budget, min: 500, max: 10000, divisions: 95,
            onChanged: (v) => setState(() => budget = v),
          ),
          const SizedBox(height: 48),
          isGenerating 
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.bolt),
                label: const Text('Generate AI Itinerary')
              )
        ],
      ),
    );
  }
}