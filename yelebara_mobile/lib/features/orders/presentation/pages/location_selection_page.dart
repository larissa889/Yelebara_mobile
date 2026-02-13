import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'clothing_selection_page.dart';
import 'payment_page.dart';
import 'package:yelebara_mobile/features/orders/presentation/widgets/order_step_footer.dart';

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
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      
      String address = "Position actuelle";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address = "${place.street}, ${place.subLocality}, ${place.locality}";
          // Clean up address
          address = address.replaceAll(RegExp(r'^, | , '), '');
        }
      } catch (e) {
        debugPrint("Error reverse geocoding: $e");
      }

      if (mounted) {
        setState(() {
          _currentPosition = position;
          if (_useCurrentLocation) {
             _newAddress = address;
          }
        });
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  // Fonction pour obtenir l'image du service
  Widget _getServiceImage(String serviceTitle) {
    switch (serviceTitle.toLowerCase()) {
      case 'lavage simple':
        return Image.asset(
          'assets/images/lavage_simple.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.local_laundry_service, color: Colors.white);
          },
        );
      case 'repassage':
        return Image.asset(
          'assets/images/repassage.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.iron_rounded, color: Colors.white);
          },
        );
      case 'pressing complet':
        return Image.asset(
          'assets/images/pressing_complet.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.checkroom, color: Colors.white);
          },
        );
      default:
        return Icon(widget.serviceIcon, color: Colors.white, size: 24);
    }
  }

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
        ? (_newAddress ?? "Position actuelle (GPS)") 
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
          latitude: _useCurrentLocation && _currentPosition != null ? _currentPosition!.latitude : null,
          longitude: _useCurrentLocation && _currentPosition != null ? _currentPosition!.longitude : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Localisation de livraison', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                  ],
                ),
              ),
            ),
            
            // Bouton de validation (via Footer)
            OrderStepFooter(
              currentStep: 2,
              totalSteps: 3,
              onPressed: _validateOrder,
              buttonText: 'Valider la localisation',
              isEnabled: true,
            ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: RadioListTile<bool>(
              title: const Text('Utiliser mon adresse actuelle', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: _isLoadingLocation
                  ? const Text('Recherche de votre position...', style: TextStyle(fontSize: 13, color: Colors.blue))
                  : Text(
                      _currentPosition != null 
                          ? (_newAddress ?? 'Position GPS trouvée')
                          : 'Impossible de trouver la position',
                      style: TextStyle(fontSize: 13, color: _currentPosition != null ? Colors.green : Colors.orange),
                    ),
              value: true,
              groupValue: _useCurrentLocation,
              onChanged: (value) {
                setState(() {
                  _useCurrentLocation = value!;
                });
              },
              activeColor: widget.serviceColor,
              secondary: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: widget.serviceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Icon(Icons.home, color: widget.serviceColor)
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          
          const SizedBox(height: 12),

          // Option nouvelle adresse
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: RadioListTile<bool>(
              title: const Text('Changer d\'adresse', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                _useCurrentLocation ? '' : 'Nouvelle adresse de livraison',
                style: TextStyle(
                  color: _useCurrentLocation ? Colors.grey : null,
                  fontSize: 13
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
              secondary: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: Icon(Icons.edit_location, color: Colors.grey.shade700)
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _housePhoto != null ? widget.serviceColor : Colors.grey.shade300,
              style: _housePhoto != null ? BorderStyle.solid : BorderStyle.none,
              width: 2,
            ),
            boxShadow: [
              if (_housePhoto == null)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
            ],
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
    return Container(); // Removed, in footer
  }
}
