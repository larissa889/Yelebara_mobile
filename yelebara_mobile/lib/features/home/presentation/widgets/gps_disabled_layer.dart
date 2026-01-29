import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelebara_mobile/features/home/presentation/providers/home_provider.dart';

class GpsDisabledLayer extends ConsumerWidget {
  const GpsDisabledLayer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGpsEnabled = ref.watch(homeProvider).isGpsEnabled;
    if (isGpsEnabled) return const SizedBox.shrink();

    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'La localisation est désactivée pour un meilleur service.',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () {
                Geolocator.openLocationSettings();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
              child: const Text('ACTIVER'),
            ),
          ],
        ),
      ),
    );
  }
}
