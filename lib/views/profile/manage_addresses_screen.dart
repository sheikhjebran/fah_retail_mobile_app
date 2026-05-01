import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';

/// Manage addresses screen
class ManageAddressesScreen extends StatefulWidget {
  const ManageAddressesScreen({super.key});

  @override
  State<ManageAddressesScreen> createState() => _ManageAddressesScreenState();
}

class _ManageAddressesScreenState extends State<ManageAddressesScreen> {
  final _addressService = AddressService();

  List<AddressModel> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      _addresses = await _addressService.getAddresses();
    } catch (e) {
      if (mounted) {
        Helpers.showError(context, 'Failed to load addresses');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addNewAddress() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
    );
    if (result == true) {
      _loadAddresses();
    }
  }

  void _editAddress(AddressModel address) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditAddressScreen(address: address)),
    );
    if (result == true) {
      _loadAddresses();
    }
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Address'),
            content: Text('Are you sure you want to delete "${address.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _addressService.deleteAddress(address.id);
        if (mounted) {
          Helpers.showSuccess(context, 'Address deleted');
          _loadAddresses();
        }
      } catch (e) {
        if (mounted) {
          Helpers.showError(context, 'Failed to delete address');
        }
      }
    }
  }

  Future<void> _setAsDefault(AddressModel address) async {
    try {
      await _addressService.setDefaultAddress(address.id);
      if (mounted) {
        Helpers.showSuccess(context, 'Default address updated');
        _loadAddresses();
      }
    } catch (e) {
      if (mounted) {
        Helpers.showError(context, 'Failed to set default address');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Addresses')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _addresses.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh: _loadAddresses,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    return _AddressCard(
                      address: address,
                      onEdit: () => _editAddress(address),
                      onDelete: () => _deleteAddress(address),
                      onSetDefault:
                          address.isDefault
                              ? null
                              : () => _setAsDefault(address),
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewAddress,
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No addresses saved',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Add an address for faster checkout',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Address card widget
class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            address.isDefault
                ? Border.all(color: AppColors.primary, width: 2)
                : Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  address.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Building number
          if (address.buildingNumber != null &&
              address.buildingNumber!.isNotEmpty)
            _buildInfoRow(Icons.apartment, 'Building', address.buildingNumber!),
          // Street address
          _buildInfoRow(Icons.location_on_outlined, 'Address', address.address),
          // Landmark
          if (address.landmark != null && address.landmark!.isNotEmpty)
            _buildInfoRow(Icons.place_outlined, 'Landmark', address.landmark!),
          // City & State
          _buildInfoRow(
            Icons.location_city,
            'Location',
            '${address.city}, ${address.state}',
          ),
          // Pincode
          _buildInfoRow(Icons.pin_drop_outlined, 'Pincode', address.pincode),
          // Phone
          _buildInfoRow(Icons.phone_outlined, 'Phone', address.phone),
          // Alternate phone
          if (address.alternatePhone != null &&
              address.alternatePhone!.isNotEmpty)
            _buildInfoRow(
              Icons.phone_android,
              'Alt. Phone',
              address.alternatePhone!,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (onSetDefault != null) ...[
                OutlinedButton(
                  onPressed: onSetDefault,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Set as Default'),
                ),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit,
                color: AppColors.primary,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

/// Add/Edit address screen
class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressService = AddressService();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _buildingNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _alternatePhoneController = TextEditingController();

  bool _isDefault = false;
  bool _isSaving = false;

  bool get isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _nameController.text = widget.address!.name;
      _phoneController.text = widget.address!.phone;
      _buildingNumberController.text = widget.address!.buildingNumber ?? '';
      _addressController.text = widget.address!.address;
      _landmarkController.text = widget.address!.landmark ?? '';
      _cityController.text = widget.address!.city;
      _stateController.text = widget.address!.state;
      _pincodeController.text = widget.address!.pincode;
      _alternatePhoneController.text = widget.address!.alternatePhone ?? '';
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _buildingNumberController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _alternatePhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final request = CreateAddressRequest(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        buildingNumber:
            _buildingNumberController.text.trim().isNotEmpty
                ? _buildingNumberController.text.trim()
                : null,
        address: _addressController.text.trim(),
        landmark:
            _landmarkController.text.trim().isNotEmpty
                ? _landmarkController.text.trim()
                : null,
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        alternatePhone:
            _alternatePhoneController.text.trim().isNotEmpty
                ? _alternatePhoneController.text.trim()
                : null,
        isDefault: _isDefault,
      );

      if (isEditing) {
        await _addressService.updateAddress(widget.address!.id, request);
      } else {
        await _addressService.addAddress(request);
      }

      if (mounted) {
        Helpers.showSuccess(
          context,
          isEditing ? 'Address updated' : 'Address added',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showError(context, 'Failed to save address: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add Address'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAddress,
            child:
                _isSaving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: Contact Details
              _buildSectionHeader('Contact Details'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.trim().length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alternatePhoneController,
                decoration: const InputDecoration(
                  labelText: 'Alternate Phone Number (Optional)',
                  prefixIcon: Icon(Icons.phone_android),
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),
              // Section: Address Details
              _buildSectionHeader('Address Details'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _buildingNumberController,
                decoration: const InputDecoration(
                  labelText: 'Building/Flat/House No. (Optional)',
                  prefixIcon: Icon(Icons.apartment),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Street Address *',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  hintText: 'Street name, Area',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _landmarkController,
                decoration: const InputDecoration(
                  labelText: 'Landmark (Optional)',
                  prefixIcon: Icon(Icons.place_outlined),
                  hintText: 'Near mosque, school, etc.',
                ),
              ),

              const SizedBox(height: 24),
              // Section: Location
              _buildSectionHeader('Location'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City *',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State *',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(
                  labelText: 'Pincode *',
                  prefixIcon: Icon(Icons.pin_drop_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter pincode';
                  }
                  if (value.trim().length != 6) {
                    return 'Please enter a valid 6-digit pincode';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                value: _isDefault,
                onChanged: (value) => setState(() => _isDefault = value),
                title: const Text('Set as Default Address'),
                subtitle: const Text('Use this address for all orders'),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
