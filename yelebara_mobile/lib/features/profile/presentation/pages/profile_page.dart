import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yelebara_mobile/features/home/presentation/widgets/client_bottom_nav.dart';
import 'package:yelebara_mobile/features/orders/presentation/pages/create_order_page.dart';
import 'package:yelebara_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:yelebara_mobile/features/profile/presentation/providers/profile_provider.dart';
import 'package:go_router/go_router.dart';

class ClientProfilePage extends ConsumerStatefulWidget {
  const ClientProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends ConsumerState<ClientProfilePage> {
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Mon profil',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colorScheme.onSurface),
            onPressed: () {}, // Settings placeholder
          ),
        ],
      ),
      body: Stack(
        children: [
          profileState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _showPhotoOptions,
                            child: Hero(
                              tag: 'profile_pic',
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colorScheme.primary, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: colorScheme.primaryContainer,
                                  backgroundImage: (profile.photoBytes != null)
                                      ? MemoryImage(profile.photoBytes!)
                                      : null,
                                  child: (profile.photoBytes == null)
                                      ? Icon(Icons.person, size: 50, color: colorScheme.onPrimaryContainer)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile.name ?? 'Utilisateur',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Text('Mes informations', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _ProfileField(
                      title: 'Numéro de téléphone',
                      value: profile.phone ?? '',
                      icon: Icons.phone_outlined,
                    ),
                    _EditableProfileField(
                      title: '2nd numéro de téléphone',
                      value: profile.phone2 ?? '',
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                      onSaved: (val) async {
                        await ref.read(profileProvider.notifier).updateProfile(
                              profile.copyWith(phone2: val),
                            );
                      },
                    ),
                    _ProfileField(title: 'Email', value: profile.email ?? '', icon: Icons.email_outlined),
                    _ProfileField(
                        title: 'Adresse', value: profile.address1 ?? '', icon: Icons.location_on_outlined),
                    _EditableProfileField(
                      title: '2nde adresse',
                      value: profile.address2 ?? '',
                      icon: Icons.add_location_outlined,
                      keyboardType: TextInputType.streetAddress,
                      onSaved: (val) async {
                        await ref.read(profileProvider.notifier).updateProfile(
                              profile.copyWith(address2: val),
                            );
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    Text('Préférences', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _OptionItem(
                      icon: Icons.edit_note_rounded,
                      iconColor: Colors.blueAccent,
                      title: 'Modifier mes informations',
                      onTap: () => _editMainInfo(profile),
                    ),
                    _OptionItem(
                      icon: Icons.support_agent_rounded,
                      iconColor: Colors.green,
                      title: 'Contactez-nous',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contact: support@yelebara.app'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                     _OptionItem(
                      icon: Icons.star_border_rounded,
                      iconColor: Colors.amber,
                      title: 'Notez l\'application',
                      onTap: () {},
                    ),
                     _OptionItem(
                      icon: Icons.share_rounded,
                      iconColor: Colors.indigo,
                      title: 'Partager l\'application',
                      onTap: () {},
                    ),
                    
                    const SizedBox(height: 32),
                    _OptionItem(
                      icon: Icons.logout_rounded,
                      iconColor: colorScheme.error,
                      title: 'Se déconnecter',
                      onTap: _logout,
                      trailingColor: colorScheme.error,
                      isDestructive: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Delete Account Button
                    TextButton.icon(
                      onPressed: _confirmDeleteAccount,
                      icon: Icon(Icons.delete_forever, color: colorScheme.error.withOpacity(0.7), size: 20),
                      label: Text('Supprimer mon compte définitivement', style: TextStyle(color: colorScheme.error.withOpacity(0.7))),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
          // Bouton d'action rapide / FAB
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateOrderPage(
                      serviceTitle: 'Nouvelle commande',
                      servicePrice: '',
                      serviceIcon: Icons.local_laundry_service,
                      serviceColor: colorScheme.primary,
                    ),
                  ),
                );
              },
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 4,
              icon: const Icon(Icons.add),
              label: const Text('Passer une commande'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ClientBottomNav(activeIndex: 3),
    );
  }

  Future<void> _showPhotoOptions() async {
    final profile = ref.read(profileProvider).profile;
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              if (profile.photoBytes != null)
                ListTile(
                  leading: const Icon(Icons.visibility, color: Colors.blue),
                  title: const Text('Voir la photo'),
                  onTap: () => Navigator.of(ctx).pop('view'),
                ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.orange),
                title: Text(
                  profile.photoBytes == null
                      ? 'Ajouter une photo'
                      : 'Modifier la photo',
                ),
                onTap: () => Navigator.of(ctx).pop('change'),
              ),
              if (profile.photoBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Supprimer la photo'),
                  onTap: () => Navigator.of(ctx).pop('delete'),
                ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Annuler'),
                onTap: () => Navigator.of(ctx).pop('cancel'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (choice == null || choice == 'cancel') return;

    if (choice == 'view') {
      await _viewPhoto(profile.photoBytes);
    } else if (choice == 'change') {
      await _pickPhoto();
    } else if (choice == 'delete') {
      await _deletePhoto();
    }
  }

  Future<void> _viewPhoto(Uint8List? bytes) async {
    if (bytes == null) return;
    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.7,
                  maxWidth: MediaQuery.of(ctx).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    await ref.read(profileProvider.notifier).updatePhoto(bytes);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deletePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Supprimer la photo'),
          content: const Text(
            'Voulez-vous vraiment supprimer votre photo de profil ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await ref.read(profileProvider.notifier).deletePhoto();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil supprimée'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _logout() async {
    await ref.read(profileProvider.notifier).logout();
    if (mounted) {
      context.go('/login');
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Supprimer mon compte'),
          content: const Text(
            'Cette action supprimera vos données locales sur cet appareil. Continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await ref.read(profileProvider.notifier).deleteAccount();
    if (mounted) {
      context.go('/login');
    }
  }

  Future<void> _editMainInfo(ProfileEntity profile) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _EditProfilePage(profile: profile),
      ),
    );
    // Provider updates state automatically, no need to reload manually
  }
}

class _ProfileField extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;

  const _ProfileField({
    Key? key,
    required this.title,
    required this.value,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableProfileField extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final TextInputType keyboardType;
  final Future<void> Function(String value) onSaved;

  const _EditableProfileField({
    Key? key,
    required this.title,
    required this.value,
    required this.keyboardType,
    required this.onSaved,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () async {
        final controller = TextEditingController(text: value);
        final newValue = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          backgroundColor: theme.colorScheme.surface,
          builder: (ctx) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Saisir ici...',
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
        if (newValue != null) {
          await onSaved(newValue);
        }
      },
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          _ProfileField(title: title, value: value, icon: icon),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Color? trailingColor;
  final bool isDestructive;

  const _OptionItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailingColor,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
             color: isDestructive ? Colors.red.withOpacity(0.1) : iconColor.withOpacity(0.1),
             borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isDestructive ? Colors.red : iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15, 
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: trailingColor ?? Colors.grey.shade400,
          size: 16,
        ),
      ),
    );
  }
}

class _EditProfilePage extends ConsumerStatefulWidget {
  final ProfileEntity profile;

  const _EditProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  ConsumerState<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<_EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _phone2Ctrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addr1Ctrl;
  late final TextEditingController _addr2Ctrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _phoneCtrl = TextEditingController(text: widget.profile.phone);
    _phone2Ctrl = TextEditingController(text: widget.profile.phone2);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _addr1Ctrl = TextEditingController(text: widget.profile.address1);
    _addr2Ctrl = TextEditingController(text: widget.profile.address2);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _phone2Ctrl.dispose();
    _emailCtrl.dispose();
    _addr1Ctrl.dispose();
    _addr2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LabeledField(
            label: 'Nom & Prénom',
            icon: Icons.person_outline,
            controller: _nameCtrl,
          ),
          _LabeledField(
            label: 'Numéro de téléphone',
            icon: Icons.phone,
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          _LabeledField(
            label: '2nd numéro de téléphone',
            icon: Icons.phone,
            controller: _phone2Ctrl,
            keyboardType: TextInputType.phone,
          ),
          _LabeledField(
            label: 'Email',
            icon: Icons.mail_outline,
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: 'Adresse de livraison',
            icon: Icons.home_outlined,
            controller: _addr1Ctrl,
            keyboardType: TextInputType.streetAddress,
            maxLines: 2,
          ),
          _LabeledField(
            label: '2nde Adresse de livraison',
            icon: Icons.home_outlined,
            controller: _addr2Ctrl,
            keyboardType: TextInputType.streetAddress,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final updatedProfile = widget.profile.copyWith(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      phone2: _phone2Ctrl.text.trim(),
      email: _emailCtrl.text.trim(),
      address1: _addr1Ctrl.text.trim(),
      address2: _addr2Ctrl.text.trim(),
    );

    await ref.read(profileProvider.notifier).updateProfile(updatedProfile);
    
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  const _LabeledField({
    Key? key,
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
