import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelebara_mobile/features/beneficiaries/domain/entities/beneficiary_entity.dart';
import 'package:yelebara_mobile/features/beneficiaries/presentation/providers/beneficiary_provider.dart';
import 'package:yelebara_mobile/features/home/presentation/widgets/client_bottom_nav.dart';

class BeneficiaryDirectoryPage extends ConsumerStatefulWidget {
  const BeneficiaryDirectoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BeneficiaryDirectoryPage> createState() =>
      _BeneficiaryDirectoryPageState();
}

class _BeneficiaryDirectoryPageState
    extends ConsumerState<BeneficiaryDirectoryPage> {
  String _query = '';
  String _selectedQuartier = 'Tous';

  @override
  Widget build(BuildContext context) {
    final beneficiariesAsyncValue = ref.watch(beneficiaryProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
          onPressed: () => context.go('/home'),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Pressing',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            onPressed: () => ref.refresh(beneficiaryProvider),
          ),
        ],
      ),
      body: beneficiariesAsyncValue.when(
        data: (allBeneficiaries) {
          final quartiers = [
            'Tous',
            ...allBeneficiaries
                .map((e) => e.quartier.trim())
                .where((e) => e.isNotEmpty)
                .toSet()
                .toList(),
          ];

          final filtered = allBeneficiaries.where((b) {
            final matchQuery = _query.isEmpty ||
                b.name.toLowerCase().contains(_query.toLowerCase()) ||
                b.phone.contains(_query) ||
                b.email.contains(_query);
            final matchQuartier = _selectedQuartier == 'Tous' ||
                b.quartier.trim() == _selectedQuartier;
            return matchQuery && matchQuartier;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final isNarrow = constraints.maxWidth < 360;
                    return isNarrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSearchField(),
                              const SizedBox(height: 8),
                              _buildDropdown(quartiers),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: _buildSearchField()),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 160,
                                child: _buildDropdown(quartiers),
                              ),
                            ],
                          );
                  },
                ),
              ),
              Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final b = filtered[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(b.initials)),
                      title: Text(
                        b.name.isEmpty ? b.email : b.name,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        b.quartier.isEmpty ? '—' : b.quartier,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: SizedBox(
                        width: 110,
                        child: Text(
                          b.phone,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      bottomNavigationBar: const ClientBottomNav(activeIndex: 1),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: (v) => setState(() => _query = v),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Rechercher un bénéficiaire...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> quartiers) {
    // Ensure selected value is valid
    if (!quartiers.contains(_selectedQuartier)) {
      _selectedQuartier = 'Tous';
    }
    
    return DropdownButtonFormField<String>(
      value: _selectedQuartier,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        filled: true,
      ),
      items: quartiers
          .map(
            (q) => DropdownMenuItem(
              value: q,
              child: Text(
                q,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _selectedQuartier = v ?? 'Tous'),
    );
  }
}
