import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/product_model.dart';
import '../../services/admin_service.dart';

/// Admin product form screen for adding/editing products
class AdminProductFormScreen extends StatefulWidget {
  final int? productId;
  final ProductModel? product;

  const AdminProductFormScreen({super.key, this.productId, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminService();
  final _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _qtyController = TextEditingController();

  int? _selectedCategoryId;
  bool _isTrending = false;
  bool _isSaving = false;

  // Images - can add up to 5, one as primary
  final List<XFile> _newImages = [];
  List<String> _existingImageUrls = [];
  int _primaryImageIndex = 0;

  // Shades/Colors - stores Color objects
  List<Color> _selectedColors = [];

  // Hardcoded categories
  final List<Map<String, dynamic>> _hardcodedCategories = [
    {'id': 1, 'name': 'Hair Band'},
    {'id': 2, 'name': 'Hair Pins'},
    {'id': 3, 'name': 'Saree Pins'},
    {'id': 4, 'name': 'Clips'},
    {'id': 5, 'name': 'Necklace'},
    {'id': 6, 'name': 'Bracelet'},
    {'id': 7, 'name': 'Rings'},
    {'id': 8, 'name': 'Watches'},
    {'id': 9, 'name': 'Fancy Mirror'},
    {'id': 10, 'name': 'Earrings'},
    {'id': 11, 'name': 'Earrings - Crystal'},
    {'id': 12, 'name': 'Earrings - Long'},
    {'id': 13, 'name': 'Earrings - Short'},
    {'id': 14, 'name': 'Earrings - Round'},
    {'id': 15, 'name': 'Earrings - Rose Gold'},
    {'id': 16, 'name': 'Earrings - Silver Plated'},
    {'id': 17, 'name': 'Earrings - Gold Plated'},
  ];

  bool get isEditing => widget.productId != null || widget.product != null;

  int get totalImages => _newImages.length + _existingImageUrls.length;

  @override
  void initState() {
    super.initState();
    _populateFormIfEditing();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  void _populateFormIfEditing() {
    final product = widget.product;
    if (product != null) {
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toString();
      if (product.discountPrice != null) {
        _discountPriceController.text = product.discountPrice.toString();
      }
      _qtyController.text = product.qty.toString();
      _selectedCategoryId = product.categoryId;
      _isTrending = product.isTrending;

      // Load existing images
      if (product.images != null) {
        _existingImageUrls =
            product.images!.map((img) => img.imageUrl).toList();
        // Find primary image index
        final primaryIndex = product.images!.indexWhere((img) => img.isPrimary);
        if (primaryIndex >= 0) {
          _primaryImageIndex = primaryIndex;
        }
      }

      // Load shades as colors
      if (product.shades != null && product.shades!.isNotEmpty) {
        _selectedColors =
            product.shades!.map((hex) {
              try {
                // Handle both with and without # prefix
                final cleanHex = hex.startsWith('#') ? hex : '#$hex';
                return Color(int.parse(cleanHex.replaceFirst('#', '0xFF')));
              } catch (_) {
                return Colors.grey;
              }
            }).toList();
      }
    }
  }

  Future<void> _pickImages() async {
    if (totalImages >= 5) {
      Helpers.showError(context, 'Maximum 5 images allowed');
      return;
    }

    final remainingSlots = 5 - totalImages;

    showModalBottomSheet(
      context: context,
      builder:
          (ctx) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final images = await _imagePicker.pickMultiImage(
                      imageQuality: 80,
                      maxWidth: 1200,
                    );
                    if (images.isNotEmpty) {
                      final toAdd = images.take(remainingSlots).toList();
                      setState(() {
                        _newImages.addAll(toAdd);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final image = await _imagePicker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                      maxWidth: 1200,
                    );
                    if (image != null) {
                      setState(() {
                        _newImages.add(image);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _removeImage(int index, bool isExisting) {
    setState(() {
      if (isExisting) {
        _existingImageUrls.removeAt(index);
      } else {
        final adjustedIndex = index - _existingImageUrls.length;
        _newImages.removeAt(adjustedIndex);
      }
      // Adjust primary index if needed
      if (_primaryImageIndex >= totalImages) {
        _primaryImageIndex = totalImages > 0 ? 0 : 0;
      }
    });
  }

  void _setPrimaryImage(int index) {
    setState(() {
      _primaryImageIndex = index;
    });
  }

  void _removeColor(int index) {
    setState(() {
      _selectedColors.removeAt(index);
    });
  }

  void _showColorPicker() {
    Color pickerColor = Colors.red;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pick a Color',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // HSV Color Wheel
                  Expanded(
                    child: _HSVColorPicker(
                      initialColor: pickerColor,
                      onColorChanged: (color) {
                        setModalState(() {
                          pickerColor = color;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Selected color preview
                  Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: pickerColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        '#${pickerColor.value.toRadixString(16).substring(2).toUpperCase()}',
                        style: TextStyle(
                          color:
                              pickerColor.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Add button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedColors.add(pickerColor);
                        });
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add This Color'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _saveProduct() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedCategoryId == null) {
      Helpers.showError(context, 'Please select a category');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final discountPrice =
          _discountPriceController.text.isNotEmpty
              ? double.parse(_discountPriceController.text.trim())
              : null;
      final qty = int.parse(_qtyController.text.trim());

      // Convert colors to hex strings
      final shadeHexList =
          _selectedColors.isNotEmpty
              ? _selectedColors.map((c) => _colorToHex(c)).toList()
              : null;

      int productId;

      if (isEditing) {
        productId = widget.productId ?? widget.product!.id;
        await _adminService.updateProduct(
          productId,
          name: name,
          description: description,
          categoryId: _selectedCategoryId,
          price: price,
          discountPrice: discountPrice,
          qty: qty,
          shades: shadeHexList,
          isTrending: _isTrending,
        );
      } else {
        final product = await _adminService.addProduct(
          name: name,
          description: description,
          categoryId: _selectedCategoryId!,
          price: price,
          discountPrice: discountPrice,
          qty: qty,
          shades: shadeHexList,
          isTrending: _isTrending,
        );
        productId = product.id;
      }

      // Upload new images if any
      if (_newImages.isNotEmpty) {
        final imagePaths = _newImages.map((img) => img.path).toList();
        await _adminService.uploadProductImages(productId, imagePaths);
      }

      if (mounted) {
        Helpers.showSuccess(
          context,
          isEditing
              ? 'Product updated successfully'
              : 'Product added successfully',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showError(context, e.toString());
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
        title: Text(isEditing ? 'Edit Product' : 'Add Product'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProduct,
            child:
                _isSaving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
              // ==================== IMAGES SECTION ====================
              _buildLabel('Product Images (Max 5)'),
              const SizedBox(height: 4),
              Text(
                'Tap the star to set primary image',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              _buildImageSection(),
              const SizedBox(height: 24),

              // ==================== BASIC INFO ====================
              _buildLabel('Product Name *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Enter product name'),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildLabel('Description'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration('Enter product description'),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // ==================== CATEGORY ====================
              _buildLabel('Category *'),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: _inputDecoration('Select category'),
                hint: const Text('Select a category'),
                isExpanded: true,
                items:
                    _hardcodedCategories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat['id'] as int,
                        child: Text(cat['name'] as String),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ==================== PRICING ====================
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Price (₹) *'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          decoration: _inputDecoration('0.00'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Price required';
                            }
                            final price = double.tryParse(value.trim());
                            if (price == null || price <= 0) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Discount Price (₹)'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _discountPriceController,
                          decoration: _inputDecoration('0.00'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            final discountPrice = double.tryParse(value.trim());
                            if (discountPrice == null || discountPrice <= 0) {
                              return 'Invalid';
                            }
                            final price =
                                double.tryParse(_priceController.text) ?? 0;
                            if (discountPrice >= price) {
                              return 'Must be < price';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ==================== QUANTITY ====================
              _buildLabel('Quantity *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qtyController,
                decoration: _inputDecoration('Enter quantity'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  final qty = int.tryParse(value.trim());
                  if (qty == null || qty < 0) {
                    return 'Enter valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ==================== SHADES SECTION ====================
              _buildLabel('Shades / Colors'),
              const SizedBox(height: 4),
              Text(
                'Add available color options for this product',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              _buildShadesSection(),
              const SizedBox(height: 24),

              // ==================== TRENDING TOGGLE ====================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mark as Trending',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Show in trending products section',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isTrending,
                      onChanged: (value) {
                        setState(() => _isTrending = value);
                      },
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ==================== SAVE BUTTON ====================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            isEditing ? 'Update Product' : 'Add Product',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        // Image Grid
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: totalImages + (totalImages < 5 ? 1 : 0),
            itemBuilder: (context, index) {
              // Add button
              if (index == totalImages) {
                return _buildAddImageButton();
              }

              // Existing or new image
              final isExisting = index < _existingImageUrls.length;
              final isPrimary = index == _primaryImageIndex;

              return _buildImageTile(index, isExisting, isPrimary);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Image',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTile(int index, bool isExisting, bool isPrimary) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                isExisting
                    ? Image.network(
                      _existingImageUrls[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, _, _) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.image_not_supported),
                          ),
                    )
                    : Image.file(
                      File(_newImages[index - _existingImageUrls.length].path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
          ),

          // Primary badge
          if (isPrimary)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Primary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Set primary button
          Positioned(
            top: 4,
            right: 28,
            child: GestureDetector(
              onTap: () => _setPrimaryImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isPrimary ? AppColors.warning : Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPrimary ? Icons.star : Icons.star_border,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),

          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index, isExisting),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShadesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add color button
        GestureDetector(
          onTap: _showColorPicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.color_lens, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Pick a Color',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Selected colors display
        if (_selectedColors.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '${_selectedColors.length} color(s) selected:',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                _selectedColors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final color = entry.value;

                  return GestureDetector(
                    onTap: () => _removeColor(index),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                          shadows: [
                            Shadow(blurRadius: 2, color: Colors.black54),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a color to remove it',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

/// HSV Color Picker Widget - Classic circular color wheel
class _HSVColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const _HSVColorPicker({
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<_HSVColorPicker> createState() => _HSVColorPickerState();
}

class _HSVColorPickerState extends State<_HSVColorPicker> {
  late HSVColor _hsvColor;

  @override
  void initState() {
    super.initState();
    _hsvColor = HSVColor.fromColor(widget.initialColor);
  }

  void _updateColor(HSVColor color) {
    setState(() {
      _hsvColor = color;
    });
    widget.onColorChanged(color.toColor());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circular Hue Wheel
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size =
                  constraints.maxWidth < constraints.maxHeight
                      ? constraints.maxWidth
                      : constraints.maxHeight;
              return Center(
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Hue ring
                      _HueRing(
                        hue: _hsvColor.hue,
                        size: size,
                        onHueChanged: (hue) {
                          _updateColor(_hsvColor.withHue(hue));
                        },
                      ),
                      // Saturation/Value square in center
                      SizedBox(
                        width: size * 0.55,
                        height: size * 0.55,
                        child: _SaturationValueBox(
                          hsvColor: _hsvColor,
                          onChanged: _updateColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Brightness slider
        Row(
          children: [
            const Icon(Icons.brightness_6, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 12,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                ),
                child: Slider(
                  value: _hsvColor.value,
                  onChanged: (value) {
                    _updateColor(_hsvColor.withValue(value));
                  },
                  activeColor: _hsvColor.toColor(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Hue Ring Widget
class _HueRing extends StatelessWidget {
  final double hue;
  final double size;
  final ValueChanged<double> onHueChanged;

  const _HueRing({
    required this.hue,
    required this.size,
    required this.onHueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _handleTouch(details.localPosition),
      onPanUpdate: (details) => _handleTouch(details.localPosition),
      onTapDown: (details) => _handleTouch(details.localPosition),
      child: CustomPaint(
        size: Size(size, size),
        painter: _HueRingPainter(hue: hue),
      ),
    );
  }

  void _handleTouch(Offset position) {
    final center = Offset(size / 2, size / 2);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    // Calculate angle using atan2
    final angle = math.atan2(dy, dx);

    // Convert angle to hue (0-360)
    var hue = (angle * 180 / math.pi + 90) % 360;
    if (hue < 0) hue += 360;

    onHueChanged(hue);
  }
}

class _HueRingPainter extends CustomPainter {
  final double hue;

  _HueRingPainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final ringWidth = size.width * 0.12;

    // Draw hue ring
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth;

    for (var i = 0; i < 360; i++) {
      paint.color = HSVColor.fromAHSV(1, i.toDouble(), 1, 1).toColor();
      final startAngle = (i - 90) * math.pi / 180;
      final sweepAngle = 1.5 * math.pi / 180;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - ringWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Draw selection indicator
    final indicatorRadius = radius - ringWidth / 2;
    final rad = (hue - 90) * math.pi / 180;
    final indicatorPos = Offset(
      center.dx + indicatorRadius * math.cos(rad),
      center.dy + indicatorRadius * math.sin(rad),
    );

    // White circle indicator with border
    canvas.drawCircle(
      indicatorPos,
      ringWidth / 2 + 2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      indicatorPos,
      ringWidth / 2 + 2,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(
      indicatorPos,
      ringWidth / 2 - 2,
      Paint()
        ..color = HSVColor.fromAHSV(1, hue, 1, 1).toColor()
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _HueRingPainter oldDelegate) {
    return oldDelegate.hue != hue;
  }
}

/// Saturation/Value selection box
class _SaturationValueBox extends StatelessWidget {
  final HSVColor hsvColor;
  final ValueChanged<HSVColor> onChanged;

  const _SaturationValueBox({required this.hsvColor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart:
              (details) => _handleTouch(details.localPosition, constraints),
          onPanUpdate:
              (details) => _handleTouch(details.localPosition, constraints),
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _SaturationValuePainter(hsvColor: hsvColor),
          ),
        );
      },
    );
  }

  void _handleTouch(Offset position, BoxConstraints constraints) {
    final saturation = (position.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final value = 1 - (position.dy / constraints.maxHeight).clamp(0.0, 1.0);
    onChanged(hsvColor.withSaturation(saturation).withValue(value));
  }
}

class _SaturationValuePainter extends CustomPainter {
  final HSVColor hsvColor;

  _SaturationValuePainter({required this.hsvColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw saturation gradient (white to hue color)
    final saturationGradient = LinearGradient(
      colors: [
        Colors.white,
        HSVColor.fromAHSV(1, hsvColor.hue, 1, 1).toColor(),
      ],
    );
    canvas.drawRect(
      rect,
      Paint()..shader = saturationGradient.createShader(rect),
    );

    // Draw value gradient (transparent to black)
    final valueGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Colors.black],
    );
    canvas.drawRect(rect, Paint()..shader = valueGradient.createShader(rect));

    // Draw border
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.grey.shade300
        ..strokeWidth = 1,
    );

    // Draw selection indicator
    final indicatorX = hsvColor.saturation * size.width;
    final indicatorY = (1 - hsvColor.value) * size.height;

    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      10,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _SaturationValuePainter oldDelegate) {
    return oldDelegate.hsvColor != hsvColor;
  }
}
