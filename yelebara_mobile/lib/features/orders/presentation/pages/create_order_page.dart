import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:yelebara_mobile/features/orders/presentation/providers/order_provider.dart';
import 'package:yelebara_mobile/features/orders/presentation/widgets/order_step_footer.dart';
import 'location_selection_page.dart';

class CreateOrderPage extends ConsumerStatefulWidget {
  final String serviceTitle;
  final String? servicePrice;
  final IconData serviceIcon;
  final Color serviceColor;
  final OrderEntity? existingOrder;

  const CreateOrderPage({
    Key? key,
    required this.serviceTitle,
    this.servicePrice,
    required this.serviceIcon,
    required this.serviceColor,
    this.existingOrder,
  }) : super(key: key);

  @override
  ConsumerState<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends ConsumerState<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _instructionsController = TextEditingController();
  
  bool _pickupAtHome = true;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Fonction pour obtenir l'image du service
  Widget _getServiceImage(String serviceTitle) {
    switch (serviceTitle.toLowerCase()) {
      case 'lavage simple':
        return Image.asset(
          'assets/images/lavage_simple.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.local_laundry_service, color: widget.serviceColor);
          },
        );
      case 'repassage':
        return Image.asset(
          'assets/images/repassage.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.iron_rounded, color: widget.serviceColor);
          },
        );
      case 'pressing complet':
        return Image.asset(
          'assets/images/pressing_complet.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.checkroom, color: widget.serviceColor);
          },
        );
      default:
        return Icon(widget.serviceIcon, color: widget.serviceColor);
    }
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existingOrder;
    if (e != null) {
      _selectedDate = e.date;
      _selectedTime = e.time;
      _pickupAtHome = e.pickupAtHome;
      _instructionsController.text = e.instructions;
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.existingOrder == null 
          ? 'Nouvelle commande' 
          : 'Modifier la commande',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildServiceCard(),
                    const SizedBox(height: 20),
                    _buildPickupSwitch(),
                    const SizedBox(height: 16),
                    _buildDateTimePickers(),
                    const SizedBox(height: 16),
                    _buildInstructionsField(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            OrderStepFooter(
              currentStep: 1,
              totalSteps: 3,
              onPressed: _validateAndProceed,
              buttonText: 'Continuer',
              isEnabled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.serviceColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _getServiceImage(widget.serviceTitle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.servicePrice ?? 'Prix sur demande',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: const Text('Ramassage à domicile', style: TextStyle(fontWeight: FontWeight.w600),),
        subtitle: const Text('Un livreur viendra chercher votre linge', style: TextStyle(fontSize: 13),),
        value: _pickupAtHome,
        onChanged: (value) => setState(() => _pickupAtHome = value),
        secondary: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(Icons.home, color: widget.serviceColor)
        ),
        activeColor: widget.serviceColor,
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate == null
                            ? 'Choisir'
                            : DateFormat('dd/MM').format(_selectedDate!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: _selectTime,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Heure', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedTime == null
                            ? 'Choisir'
                            : _selectedTime!.format(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsField() {
    return TextFormField(
      controller: _instructionsController,
      decoration: InputDecoration(
        labelText: 'Instructions particulières',
        hintText: 'Ex: Taches difficiles, repassage soigné...',
        prefixIcon: const Icon(Icons.note_alt_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: widget.serviceColor),
        ),
      ),
      maxLines: 4,
    );
  }

  Widget _buildSubmitButton() {
    return Container(); // Removed, moved to footer
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.serviceColor, 
              onPrimary: Colors.white,       
              surface: Colors.white,         
              onSurface: Colors.black,       
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (date != null && mounted) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: widget.serviceColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _validateAndProceed() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner la date et l\'heure'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Navigation vers la page de localisation (avec photo)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationSelectionPage(
          serviceTitle: widget.serviceTitle,
          serviceIcon: widget.serviceIcon,
          serviceColor: widget.serviceColor,
          selectedDate: _selectedDate!,
          selectedTime: _selectedTime!,
          pickupAtHome: _pickupAtHome,
          instructions: _instructionsController.text.trim(),
          clothingSelection: {},
          totalItems: 0,
          finalPrice: 0,
          formattedPrice: '0 FCFA',
        ),
      ),
    );
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner la date et l\'heure'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final notifier = ref.read(orderProvider.notifier);

    if (widget.existingOrder != null) {
      // Modification
      final updatedOrder = OrderEntity(
        id: widget.existingOrder!.id,
        serviceTitle: widget.serviceTitle, 
        servicePrice: widget.servicePrice ?? 'Prix sur demande',
        amount: 0,
        date: _selectedDate!,
        time: _selectedTime!,
        pickupAtHome: _pickupAtHome,
        instructions: _instructionsController.text.trim(),
        serviceIcon: widget.serviceIcon,
        serviceColor: widget.serviceColor,
        status: widget.existingOrder!.status,
        createdAt: widget.existingOrder!.createdAt,
        paymentMethod: widget.existingOrder!.paymentMethod,
        transactionId: widget.existingOrder!.transactionId,
      );
      await notifier.updateOrder(updatedOrder);
    } else {
      // Création
      final order = OrderEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        serviceTitle: widget.serviceTitle,
        servicePrice: widget.servicePrice ?? 'Prix sur demande',
        amount: 0,
        date: _selectedDate!,
        time: _selectedTime!,
        pickupAtHome: _pickupAtHome,
        instructions: _instructionsController.text.trim(),
        serviceIcon: widget.serviceIcon,
        serviceColor: widget.serviceColor,
        createdAt: DateTime.now(),
      );
      await notifier.addOrder(order);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingOrder != null
              ? 'Commande modifiée avec succès'
              : 'Commande créée avec succès',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    Navigator.of(context).pop(true); // Return true implicitly handled by navigation flow usually, or we can assume provider is source of truth
  }
}
