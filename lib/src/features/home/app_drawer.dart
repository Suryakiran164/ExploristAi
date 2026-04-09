import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userControllerProvider);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF003461)),
            accountName: Text(userState.value?.name ?? 'Explorer'),
            accountEmail: Text(userState.value?.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Visited Places'),
            onTap: () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Visited Places'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: userState.value?.visitedPlaces.map((p) => ListTile(title: Text(p))).toList() ?? [],
                  ),
                )
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              ref.read(firebaseAuthProvider).signOut();
            },
          ),
        ],
      ),
    );
  }
}