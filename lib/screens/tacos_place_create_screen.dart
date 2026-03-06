import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/api_config.dart';
import '../services/location_service.dart';
import '../services/tacos_place_service.dart';
import '../theme/app_theme.dart';

class TacosPlaceCreateScreen extends StatefulWidget {
  const TacosPlaceCreateScreen({super.key});

  @override
  State<TacosPlaceCreateScreen> createState() => _TacosPlaceCreateScreenState();
}

class _TacosPlaceCreateScreenState extends State<TacosPlaceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final MapController _mapController = MapController();

  DateTime? _selectedDate;
  XFile? _photo;
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  bool _hasLocation = false;
  LatLng _deviceLatLng = const LatLng(48.8566, 2.3522);

  void _setSelectedLocation(LatLng location, {bool moveMap = false}) {
    _deviceLatLng = location;
    _latitudeController.text = _deviceLatLng.latitude.toStringAsFixed(7);
    _longitudeController.text = _deviceLatLng.longitude.toStringAsFixed(7);
    _hasLocation = true;

    if (moveMap) {
      _mapController.move(_deviceLatLng, 13);
    }
  }

  @override
  void initState() {
    super.initState();
    _latitudeController.text = _deviceLatLng.latitude.toStringAsFixed(7);
    _longitudeController.text = _deviceLatLng.longitude.toStringAsFixed(7);
    _loadDeviceLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _loadDeviceLocation() async {
    setState(() => _isLoadingLocation = true);
    final locationService = context.read<LocationService>();
    try {
      final position = await locationService.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() => _setSelectedLocation(location, moveMap: true));
      }
    } catch (e) {
      _hasLocation = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _pickPhotoFromSource(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (image != null) {
      setState(() {
        _photo = image;
      });
    }
  }

  Future<void> _takePhoto() => _pickPhotoFromSource(ImageSource.camera);

  Future<void> _pickPhoto() => _pickPhotoFromSource(ImageSource.gallery);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }
    if (!_hasLocation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map.')),
      );
      return;
    }
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo.')),
      );
      return;
    }
    final photoSize = await File(_photo!.path).length();
    if (photoSize > 3 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo too large (max 3 MB).')),
      );
      return;
    }

    final lat = double.tryParse(_latitudeController.text);
    final lng = double.tryParse(_longitudeController.text);
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid geolocation.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = context.read<TacosPlaceService>();
      final dateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate!);

      await service.createTacosPlace(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        date: dateStr,
        price: int.parse(_priceController.text.trim()),
        latitude: lat,
        longitude: lng,
        contactName: _contactNameController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        photoPath: _photo!.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('TacosPlace created.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _selectedDate == null
        ? 'Select a date'
        : DateFormat('dd/MM/yyyy HH:mm').format(_selectedDate!);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(title: const Text('Create TacosPlace')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionLabel('GENERAL'),
              const SizedBox(height: 10),
              _formCard([
                _fieldLabel('Name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Ex: Tacos Lyon Centre'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Name required.' : null,
                ),
                const SizedBox(height: 14),
                _fieldLabel('Description'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(hintText: 'Describe this place...'),
                  maxLines: 3,
                  validator: (v) => (v == null || v.isEmpty) ? 'Description required.' : null,
                ),
                const SizedBox(height: 14),
                _fieldLabel('Price (int)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(hintText: 'Ex: 10'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Price required.';
                    final price = int.tryParse(v);
                    if (price == null) return 'Invalid integer.';
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 20),
              _sectionLabel('DATE'),
              const SizedBox(height: 10),
              _formCard([
                InkWell(
                  onTap: _pickDateTime,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedDate != null ? AppTheme.primary : AppTheme.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.cardSurface,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: _selectedDate != null ? AppTheme.primary : AppTheme.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedDate != null ? AppTheme.textPrimary : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionLabel('LOCATION'),
              const SizedBox(height: 10),
              _formCard([
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Latitude'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _latitudeController,
                            readOnly: true,
                            decoration: const InputDecoration(hintText: '-'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Longitude'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _longitudeController,
                            readOnly: true,
                            decoration: const InputDecoration(hintText: '-'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _deviceLatLng,
                        initialZoom: 13,
                        onTap: (_, point) {
                          setState(() => _setSelectedLocation(point));
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: '${ApiConfig.baseUrl}/tiles/{z}/{x}/{y}',
                          maxZoom: 19,
                          userAgentPackageName: 'com.example.tacomap_mobile',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _deviceLatLng,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLoadingLocation
                      ? 'Retrieving device location...'
                      : 'Tap on the map to set latitude and longitude.',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isLoadingLocation ? null : _loadDeviceLocation,
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text('Refresh device location'),
                ),
              ]),
              const SizedBox(height: 20),
              _sectionLabel('CONTACT'),
              const SizedBox(height: 10),
              _formCard([
                _fieldLabel('Contact name'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _contactNameController,
                  decoration: const InputDecoration(hintText: 'Ex: Alice Martin'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Contact name required.' : null,
                ),
                const SizedBox(height: 14),
                _fieldLabel('Contact email'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _contactEmailController,
                  decoration: const InputDecoration(hintText: 'contact@example.com'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Contact email required.';
                    if (!v.contains('@')) return 'Invalid email.';
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 20),
              _sectionLabel('PHOTO'),
              const SizedBox(height: 10),
              _formCard([
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _takePhoto,
                        icon: const Icon(Icons.photo_camera_outlined, size: 16),
                        label: const Text('Take photo'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.photo_library_outlined, size: 16),
                        label: const Text('Gallery'),
                      ),
                    ),
                  ],
                ),
                if (_photo != null) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Photo selected.',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (_photo == null) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Take a photo or pick one from gallery.',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ]),
              const SizedBox(height: 12),
              _formCard([
                const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppTheme.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Native components used: Camera + Device geolocation.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _formCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

