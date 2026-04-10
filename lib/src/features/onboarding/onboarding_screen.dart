import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/providers.dart';
import '../../models/app_models.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final locationCtrl = TextEditingController(); // Combined field for UI
  
  final List<Map<String, dynamic>> envOptions = [
    {'name': 'Mountains', 'icon': Icons.terrain},
    {'name': 'Beaches', 'icon': Icons.beach_access},
    {'name': 'Historical', 'icon': Icons.account_balance},
    {'name': 'Urban Jungle', 'icon': Icons.business},
    {'name': 'Rainforest', 'icon': Icons.park},
    {'name': 'Desert Oasis', 'icon': Icons.landscape},
  ];
  
  List<String> selectedEnvs = [];
  bool isLoading = false;

  final Color primaryBlue = const Color(0xFF004781);
  final Color bgColor = const Color(0xFFF8F9FA);

  Future<void> _completeOnboarding() async {
    if (nameCtrl.text.isEmpty || locationCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out your name and location')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw Exception("No authenticated user found. Please log in again.");
      }
      
      // Splitting the single UI field into the expected model structure if needed, 
      // or just saving the whole string to country for now.
      final locationParts = locationCtrl.text.split(',');
      final city = locationParts.isNotEmpty ? locationParts[0].trim() : '';
      final country = locationParts.length > 1 ? locationParts[1].trim() : locationCtrl.text.trim();

      final model = UserModel(
        uid: user.uid, 
        email: user.email ?? 'no-email@provided.com', 
        name: nameCtrl.text.trim(),
        age: int.tryParse(ageCtrl.text) ?? 18,
        preferredEnvironments: selectedEnvs,
        country: country, 
        state: city, 
        visitedPlaces: [],
      );
      
      await ref.read(userControllerProvider.notifier).saveUser(model);
      
      if (mounted) {
        context.go('/home'); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Header
                    Row(
                      children: [
                        Icon(Icons.explore, color: primaryBlue, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Explorist AI',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    
                    // Title & Subtitle
                    const Text(
                      'Create your profile',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tell us about yourself so we can curate the perfect itineraries for your travel style.',
                      style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.4),
                    ),
                    const SizedBox(height: 40),

                    // Inputs
                    _buildInputLabel('Full Name'),
                    _buildTextField(nameCtrl, 'e.g. Alex Walker'),
                    const SizedBox(height: 24),

                    _buildInputLabel('Age'),
                    _buildTextField(ageCtrl, '28', isNumber: true),
                    const SizedBox(height: 24),

                    _buildInputLabel('Current Base (City/Country)'),
                    _buildTextField(locationCtrl, 'Search for your home city...', icon: Icons.location_on),
                    const SizedBox(height: 32),

                    // Environments
                    _buildInputLabel('Preferred Environments'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: envOptions.map((env) {
                        final isSelected = selectedEnvs.contains(env['name']);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isSelected ? selectedEnvs.remove(env['name']) : selectedEnvs.add(env['name']);
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryBlue : const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  env['icon'], 
                                  size: 18, 
                                  color: isSelected ? Colors.white : Colors.black87
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  env['name'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              color: bgColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress Dots
                  Row(
                    children: [
                      _buildDot(true),
                      _buildDot(false),
                      _buildDot(false),
                    ],
                  ),
                  
                  // Next Button
                  isLoading 
                    ? const Padding(
                        padding: EdgeInsets.only(right: 24.0),
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: _completeOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Next Step', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text, 
        style: TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.bold, 
          color: primaryBlue,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {IconData? icon, bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 22) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      height: 6,
      width: isActive ? 24 : 6,
      decoration: BoxDecoration(
        color: isActive ? primaryBlue : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}