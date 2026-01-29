import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yelebara_mobile/features/auth/presentation/controllers/auth_provider.dart';
import 'package:yelebara_mobile/features/orders/presentation/pages/orders_page.dart';

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Drawer(
      child: Column(
        children: [
          // Custom Header matching design
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF57C00), // Primary Orange
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showImagePickerOptions(context, ref),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: user?.photoUrl != null
                              ? FileImage(File(user!.photoUrl!))
                              : null,
                          child: user?.photoUrl == null
                              ? Icon(Icons.person,
                                  size: 40, color: Colors.orange.shade700)
                              : null,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt,
                            size: 16, color: Colors.orange.shade800),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'Client',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user?.phone != null)
                  Text(
                    user!.phone,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.local_laundry_service_outlined),
                  title: const Text('Nos services'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('Commande'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ClientOrdersPage()),
                    );
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Communication',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.call_outlined, color: Colors.green),
                  title: const Text('Contactez-nous'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Support: +226 xx xx xx xx')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star_outline, color: Colors.orange),
                  title: const Text('Notez-nous'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined, color: Colors.blue),
                  title: const Text('Partagez cette application'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Se déconnecter',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(authProvider.notifier).logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choisir une photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  ref.read(authProvider.notifier).updateProfilePhoto(image.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Prendre une photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  ref.read(authProvider.notifier).updateProfilePhoto(image.path);
                }
              },
            ),
            if (ref.read(authProvider).user?.photoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Supprimer la photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(authProvider.notifier).updateProfilePhoto(null);
                },
              ),
          ],
        ),
      ),
    );
  }
}
