import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:yelebara_mobile/features/orders/presentation/providers/order_provider.dart';
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
      appBar: AppBar(
        title: Text(widget.existingOrder == null 
          ? 'Nouvelle commande' 
          : 'Modifier la commande'
        ),
        backgroundColor: widget.serviceColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
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
              _buildSubmitButton(),
              const SizedBox(height: 40), // Extra padding for bottom safe area/OS gestures
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.serviceColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.serviceIcon, color: widget.serviceColor),
        ),
        title: Text(
          widget.serviceTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(widget.servicePrice ?? 'Prix sur demande'),
      ),
    );
  }

  Widget _buildPickupSwitch() {
    return Card(
      elevation: 1,
      child: SwitchListTile(
        title: const Text('Ramassage à domicile'),
        subtitle: const Text('Un livreur viendra chercher votre linge'),
        value: _pickupAtHome,
        onChanged: (value) => setState(() => _pickupAtHome = value),
        secondary: const Icon(Icons.home),
      ),
    );
  }

  Widget _buildDateTimePickers() {
    return Column(
      children: [
        Card(
          elevation: 1,
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Date'),
            subtitle: Text(
              _selectedDate == null
                  ? 'Sélectionner une date'
                  : DateFormat('dd/MM/yyyy').format(_selectedDate!),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _selectDate,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 1,
          child: ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Heure'),
            subtitle: Text(
              _selectedTime == null
                  ? 'Sélectionner une heure'
                  : _selectedTime!.format(context),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _selectTime,
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
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      maxLines: 4,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _validateAndProceed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.serviceColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.existingOrder == null ? 'Continuer' : 'Modifier la commande',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
