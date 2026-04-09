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
  final countryCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final List<String> environments = ['Mountains', 'Beaches', 'Historical', 'Urban', 'Forest', 'Desert'];
  List<String> selectedEnvs = [];
  
  bool isLoading = false; // <-- Added loading state

  Future<void> _completeOnboarding() async {
    // Basic validation
    if (nameCtrl.text.isEmpty || countryCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out your name and country')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null) {
        throw Exception("No authenticated user found. Please log in again.");
      }
      
      final model = UserModel(
        uid: user.uid, 
        email: user.email ?? 'no-email@provided.com', 
        name: nameCtrl.text.trim(),
        age: int.tryParse(ageCtrl.text) ?? 18,
        preferredEnvironments: selectedEnvs,
        country: countryCtrl.text.trim(), 
        state: stateCtrl.text.trim(), 
        visitedPlaces: [],
      );
      
      // Save to Firebase
      await ref.read(userControllerProvider.notifier).saveUser(model);
      
      // Explicitly navigate to home after saving
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
      appBar: AppBar(title: const Text('Create your profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
          const SizedBox(height: 16),
          TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age'), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          TextField(controller: countryCtrl, decoration: const InputDecoration(labelText: 'Country')),
          const SizedBox(height: 16),
          TextField(controller: stateCtrl, decoration: const InputDecoration(labelText: 'State/City')),
          const SizedBox(height: 24),
          const Text('Preferred Environments', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: environments.map((env) {
              final isSelected = selectedEnvs.contains(env);
              return ChoiceChip(
                label: Text(env),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    val ? selectedEnvs.add(env) : selectedEnvs.remove(env);
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primary,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
              );
            }).toList(),
          ),
          const SizedBox(height: 48),
          
          // Toggle between button and loading spinner
          isLoading 
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: _completeOnboarding, 
                child: const Text('Next Step'),
              )
        ],
      ),
    );
  }
}