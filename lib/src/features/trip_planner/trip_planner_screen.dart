import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  final budgetCtrl = TextEditingController(text: "25000"); // Default budget in INR
  
  final List<String> prefOptions = ['Adventure Riding', 'Foodie', 'Culture', 'Relaxation', 'Off-Road'];
  List<String> selectedPrefs = ['Adventure Riding']; // Pre-selected
  
  bool isGenerating = false;
  Map<String, dynamic>? generatedItinerary;

  final Color primaryBlue = const Color(0xFF003461);
  final Color greenAccent = const Color(0xFF4A7D59);
  final Color bgLight = const Color(0xFFF8F9FA);

  Future<void> _generate() async {
    if (startCtrl.text.isEmpty || destCtrl.text.isEmpty || daysCtrl.text.isEmpty || budgetCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => isGenerating = true);
    try {
      final result = await ref.read(geminiServiceProvider.notifier).generateItinerary(
        start: startCtrl.text.trim(), 
        destination: destCtrl.text.trim(),
        days: int.parse(daysCtrl.text.trim()), 
        budget: double.parse(budgetCtrl.text.trim()),
        preferences: selectedPrefs,
      );
      setState(() => generatedItinerary = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
    setState(() => isGenerating = false);
  }

  Future<void> _saveTrip() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;
    
    final trip = TripModel(
      tripId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.uid, 
      startingPoint: startCtrl.text, 
      destination: destCtrl.text,
      durationDays: int.parse(daysCtrl.text), 
      budget: double.parse(budgetCtrl.text),
      itinerary: List<Map<String,dynamic>>.from(generatedItinerary?['itinerary'] ?? []),
      createdAt: DateTime.now()
    );

    await ref.read(firestoreProvider).collection('trips').doc(trip.tripId).set(trip.toMap());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip Saved Successfully!')));
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    // Show Itinerary View if generated
    if (generatedItinerary != null) {
      return _buildItineraryView();
    }

    // Otherwise, show Input View
    return _buildInputView();
  }

  // ==========================================
  // VIEW 1: THE INPUT SCREEN
  // ==========================================
  Widget _buildInputView() {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: primaryBlue), onPressed: () => context.pop()),
        actions: [
          const CircleAvatar(radius: 14, backgroundColor: Color(0xFF003461), child: Icon(Icons.person, size: 18, color: Colors.white)),
          const SizedBox(width: 24),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Center(
            child: Column(
              children: [
                Text('Plan Your Next', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: primaryBlue)),
                Text('Adventure', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: greenAccent)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Let our AI curate a personalized journey tailored to your style, budget, and curiosity. Start by telling us where you are and where you want to go.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 32),

          // Form Fields
          _buildFormLabel('Starting Point'),
          _buildTextField(startCtrl, 'Current city or airport', Icons.my_location),
          const SizedBox(height: 16),
          
          _buildFormLabel('Destination'),
          _buildTextField(destCtrl, 'Where to?', Icons.location_on_outlined),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormLabel('Duration (Days)'),
                    _buildTextField(daysCtrl, 'e.g. 7', Icons.calendar_today, isNumber: true),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormLabel('Total Budget'),
                    // TYPABLE BUDGET INPUT
                    _buildTextField(budgetCtrl, '25000', Icons.currency_rupee, isNumber: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Preferences Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE2EAD3), // Light greenish background from mockup
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Travel Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Personalize your journey experience with AI insights.', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: prefOptions.map((pref) {
                    final isSelected = selectedPrefs.contains(pref);
                    return ChoiceChip(
                      label: Text(pref, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          val ? selectedPrefs.add(pref) : selectedPrefs.remove(pref);
                        });
                      },
                      selectedColor: const Color(0xFF2E3D2A), // Dark green selected state
                      backgroundColor: Colors.white.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Main Action
          isGenerating 
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton.icon(
                onPressed: _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                icon: const Icon(Icons.bolt, color: Colors.white),
                label: const Text('Generate AI Itinerary', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }


  // ==========================================
  // VIEW 2: THE ITINERARY RESULT SCREEN
  // ==========================================
  Widget _buildItineraryView() {
    final title = generatedItinerary?['tripTitle'] ?? 'Your AI Itinerary';
    final items = generatedItinerary?['itinerary'] as List? ?? [];

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBlue), 
          onPressed: () => setState(() => generatedItinerary = null) // Go back to edit
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 180), // Padding for bottom bar
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFD5E8D4), borderRadius: BorderRadius.circular(20)),
                child: const Text('ITINERARY GENERATED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 1)),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text('${daysCtrl.text} Days', style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                  const SizedBox(width: 16),
                  Icon(Icons.payments, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text('₹${budgetCtrl.text}', style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 4),
                  Text(destCtrl.text, style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 32),

              // Build the Timeline
              ...items.map((dayData) => _buildTimelineDay(dayData)).toList(),
            ],
          ),

          // Fixed Bottom Action Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ready to explore?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'This itinerary fits your ₹${budgetCtrl.text} budget. Save it to access offline and start booking.',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => generatedItinerary = null),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Edit Details', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _saveTrip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          icon: const Icon(Icons.bookmark),
                          label: const Text('Save Trip', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- TIMELINE UI WIDGETS ---

  Widget _buildTimelineDay(Map<String, dynamic> dayData) {
    final events = dayData['events'] as List? ?? [];
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Vertical Line & Dot
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12, height: 12,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(color: greenAccent, shape: BoxShape.circle),
                ),
                Expanded(
                  child: Container(width: 2, color: greenAccent.withOpacity(0.3)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Day Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Day ${dayData['day']}: ${dayData['dayTitle']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue)),
                  const SizedBox(height: 4),
                  Text(dayData['daySummary'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 20),
                  
                  // Lodging Card
                  if (dayData['lodging'] != null)
                    _buildLodgingCard(dayData['lodging']),
                  
                  // Event Cards (Food, Activities, Transport)
                  ...events.map((event) => _buildEventCard(event)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLodgingCard(Map<String, dynamic> lodging) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.bed, size: 18, color: primaryBlue),
                const SizedBox(width: 8),
                const Text('Lodging Suggestion', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (lodging['imageUrl'] != null && lodging['imageUrl'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(imageUrl: lodging['imageUrl'], height: 120, width: double.infinity, fit: BoxFit.cover, errorWidget: (c,u,e) => const SizedBox.shrink()),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lodging['name'] ?? 'Hotel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(lodging['description'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(lodging['costPerNight'] ?? '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                    const Text('/ night', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    IconData icon;
    if (event['type'] == 'food') icon = Icons.restaurant;
    else if (event['type'] == 'transport') icon = Icons.directions_bus;
    else icon = Icons.hiking;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(event['description'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 4,
                  children: [
                    if (event['cost'] != null)
                      _buildMiniBadge(event['cost'], isHighlight: true),
                    if (event['bestTime'] != null)
                      _buildMiniBadge(event['bestTime']),
                    if (event['entryTicket'] != null && event['entryTicket'] != 'Not Applicable')
                      _buildMiniBadge('Ticket: ${event['entryTicket']}'),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFE5F0FF) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isHighlight ? primaryBlue : Colors.grey[700])),
    );
  }
}