import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  final Color primaryBlue = const Color(0xFF004781);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userControllerProvider);
    final user = userState.value;

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              color: primaryBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF004781)),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Explorer',
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                
                // Personalized Travel Style Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Travel Style: AI Curated', 
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildDrawerItem(
                  icon: Icons.history, 
                  title: 'Visited Places', 
                  onTap: () => _showVisitedPlaces(context, user?.visitedPlaces ?? []),
                ),
                _buildDrawerItem(
                  icon: Icons.edit_note, 
                  title: 'Edit Preferences', 
                  onTap: () {
                    // Close the drawer first
                    Navigator.of(context).pop(); 
                    
                    // Tiny delay to allow the drawer animation to finish so it doesn't swallow the push
                    Future.delayed(const Duration(milliseconds: 150), () {
                      if (context.mounted) {
                        context.push('/onboarding');
                      }
                    });
                  }, 
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Divider(),
                ),
                _buildDrawerItem(
                  icon: Icons.logout, 
                  title: 'Logout', 
                  color: Colors.redAccent,
                  onTap: () {
                    ref.read(firebaseAuthProvider).signOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color ?? Colors.black87)),
      onTap: onTap,
    );
  }

  void _showVisitedPlaces(BuildContext context, List<String> places) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Visited Places', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: places.isEmpty 
            ? const Text("No places visited yet. Time to hit the road!")
            : ListView.builder(
                shrinkWrap: true,
                itemCount: places.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.location_on, color: Color(0xFF004781)),
                    title: Text(places[index]),
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close', style: TextStyle(color: Color(0xFF004781), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}