import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'clothing_selection_page.dart';
import 'payment_page.dart';

class LocationSelectionPage extends ConsumerStatefulWidget {
  final String serviceTitle;
  final IconData serviceIcon;
  final Color serviceColor;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final bool pickupAtHome;
  final String instructions;
  final Map<String, dynamic> clothingSelection;
  final int totalItems;
  final int finalPrice;
  final String formattedPrice;

  const LocationSelectionPage({
    Key? key,
    required this.serviceTitle,
    required this.serviceIcon,
    required this.serviceColor,
    required this.selectedDate,
    required this.selectedTime,
    required this.pickupAtHome,
    required this.instructions,
    required this.clothingSelection,
    required this.totalItems,
    required this.finalPrice,
    required this.formattedPrice,
  }) : super(key: key);

  @override
  ConsumerState<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends ConsumerState<LocationSelectionPage> {
  bool _useCurrentLocation = true;
  String? _newAddress;
  File? _housePhoto;
  final ImagePicker _imagePicker = ImagePicker();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _housePhoto = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sélection de la photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 80,
      );
      
      if (photo != null) {
        setState(() {
          _housePhoto = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la prise de photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Photo de la maison'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir dans la galerie'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _validateOrder() {
    if (!_useCurrentLocation && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre nouvelle adresse'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final address = _useCurrentLocation 
        ? "Adresse actuelle (tanghin, Ouagadougou)" 
        : _addressController.text.trim();

    // Navigation vers la page de sélection de vêtements
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ClothingSelectionPage(
          serviceTitle: widget.serviceTitle,
          serviceIcon: widget.serviceIcon,
          serviceColor: widget.serviceColor,
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          pickupAtHome: widget.pickupAtHome,
          instructions: widget.instructions,
          deliveryAddress: address,
          housePhoto: _housePhoto,
          useCurrentLocation: _useCurrentLocation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localisation de livraison'),
        backgroundColor: widget.serviceColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec résumé
            _buildOrderSummary(),
            
            const SizedBox(height: 24),
            
            // Choix de la localisation
            _buildLocationChoice(),
            
            const SizedBox(height: 24),
            
            // Photo de la maison
            _buildHousePhotoSection(),
            
            const SizedBox(height: 32),
            
            // Bouton de validation
            _buildValidateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.serviceColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.serviceColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.serviceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.serviceIcon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.serviceTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year} à ${widget.selectedTime.hour}:${widget.selectedTime.minute.toString().padLeft(2, '0')}',
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.totalItems} articles',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                widget.formattedPrice,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.serviceColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Adresse de livraison',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Option adresse actuelle
        Card(
          elevation: 2,
          child: RadioListTile<bool>(
            title: const Text('Utiliser mon adresse actuelle'),
            subtitle: const Text('tanghin, Ouagadougou'),
            value: true,
            groupValue: _useCurrentLocation,
            onChanged: (value) {
              setState(() {
                _useCurrentLocation = value!;
              });
            },
            activeColor: widget.serviceColor,
            secondary: Icon(Icons.home, color: widget.serviceColor),
          ),
        ),
        
        // Option nouvelle adresse
        Card(
          elevation: 2,
          child: RadioListTile<bool>(
            title: const Text('Changer d\'adresse'),
            subtitle: Text(
              _useCurrentLocation ? '' : 'Nouvelle adresse de livraison',
              style: TextStyle(
                color: _useCurrentLocation ? Colors.grey : null,
              ),
            ),
            value: false,
            groupValue: _useCurrentLocation,
            onChanged: (value) {
              setState(() {
                _useCurrentLocation = value!;
              });
            },
            activeColor: widget.serviceColor,
            secondary: Icon(Icons.edit_location, color: widget.serviceColor),
          ),
        ),
        
        // Champ pour nouvelle adresse
        if (!_useCurrentLocation) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Nouvelle adresse',
              hintText: 'Entrez votre nouvelle adresse complète',
              prefixIcon: const Icon(Icons.location_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.serviceColor, width: 2),
              ),
            ),
            maxLines: 3,
            validator: (value) {
              if (!_useCurrentLocation && (value == null || value.trim().isEmpty)) {
                return 'Veuillez entrer votre adresse';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildHousePhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Photo de la maison',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Recommandé',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Une photo de votre maison aidera le livreur à vous retrouver plus facilement',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        
        // Zone de photo
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: _housePhoto != null ? widget.serviceColor : Colors.grey.shade300,
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _housePhoto != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _housePhoto!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _housePhoto = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ajouter une photo',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Appuyez pour choisir',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
        
        const SizedBox(height: 12),
        
        // Boutons pour ajouter photo
        if (_housePhoto == null) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerie'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: widget.serviceColor),
                    foregroundColor: widget.serviceColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Appareil photo'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: widget.serviceColor),
                    foregroundColor: widget.serviceColor,
                  ),
                ),
              ),
            ],
          ),
        ],
        
        const SizedBox(height: 8),
        
        // Info bulle
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'La photo doit montrer l\'extérieur de votre maison ou un point de repère facile à identifier',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildValidateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _validateOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.serviceColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Valider la localisation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
