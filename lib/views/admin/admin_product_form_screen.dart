import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/admin_service.dart';
import '../../services/product_service.dart';

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
  final _productService = ProductService();
  final _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _shadeController = TextEditingController();

  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  bool _isTrending = false;
  bool _isLoading = false;
  bool _isSaving = false;

  // Images - can add up to 5, one as primary
  final List<XFile> _newImages = [];
  List<String> _existingImageUrls = [];
  int _primaryImageIndex = 0;

  // Shades/Colors
  List<String> _shades = [];

  // Predefined shade colors for selection
  final List<Map<String, dynamic>> _predefinedShades = [
    {'name': 'Gold', 'color': const Color(0xFFFFD700)},
    {'name': 'Silver', 'color': const Color(0xFFC0C0C0)},
    {'name': 'Rose Gold', 'color': const Color(0xFFB76E79)},
    {'name': 'Black', 'color': const Color(0xFF000000)},
    {'name': 'White', 'color': const Color(0xFFFFFFFF)},
    {'name': 'Red', 'color': const Color(0xFFE53935)},
    {'name': 'Blue', 'color': const Color(0xFF1E88E5)},
    {'name': 'Green', 'color': const Color(0xFF43A047)},
    {'name': 'Pink', 'color': const Color(0xFFE91E63)},
    {'name': 'Purple', 'color': const Color(0xFF8E24AA)},
    {'name': 'Orange', 'color': const Color(0xFFFF9800)},
    {'name': 'Brown', 'color': const Color(0xFF795548)},
    {'name': 'Crystal', 'color': const Color(0xFFE0F7FA)},
    {'name': 'Pearl', 'color': const Color(0xFFFAF0E6)},
    {'name': 'Bronze', 'color': const Color(0xFFCD7F32)},
    {'name': 'Copper', 'color': const Color(0xFFB87333)},
  ];

  bool get isEditing => widget.productId != null || widget.product != null;

  int get totalImages => _newImages.length + _existingImageUrls.length;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _populateFormIfEditing();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _qtyController.dispose();
    _shadeController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      _categories = await _productService.getCategories();
    } catch (e) {
      if (mounted) {
        Helpers.showError(context, 'Failed to load categories');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

      // Load shades
      if (product.shades != null) {
        _shades = List<String>.from(product.shades!);
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

  void _addShade(String shade) {
    if (shade.trim().isEmpty) return;
    if (_shades.contains(shade.trim())) {
      Helpers.showError(context, 'Shade already added');
      return;
    }
    setState(() {
      _shades.add(shade.trim());
      _shadeController.clear();
    });
  }

  void _removeShade(int index) {
    setState(() {
      _shades.removeAt(index);
    });
  }

  void _showShadeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder:
                  (_, controller) => Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Select Colors/Shades',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap colors to select/deselect. ${_shades.length} selected',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GridView.builder(
                            controller: controller,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: _predefinedShades.length,
                            itemBuilder: (context, index) {
                              final shade = _predefinedShades[index];
                              final isSelected = _shades.contains(
                                shade['name'],
                              );
                              final isDark = _isColorDark(
                                shade['color'] as Color,
                              );

                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    if (isSelected) {
                                      _shades.remove(shade['name']);
                                    } else {
                                      _shades.add(shade['name']);
                                    }
                                  });
                                  setState(() {}); // Update parent state
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: shade['color'],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : AppColors.border,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: (shade['color'] as Color)
                                                    .withValues(alpha: 0.4),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (isSelected)
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            shade['name'],
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                        const Text(
                          'Or add custom color:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _shadeController,
                                decoration: InputDecoration(
                                  hintText: 'Enter custom shade name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                textCapitalization: TextCapitalization.words,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_shadeController.text.trim().isNotEmpty) {
                                  final customShade =
                                      _shadeController.text.trim();
                                  if (!_shades.contains(customShade)) {
                                    setModalState(() {
                                      _shades.add(customShade);
                                    });
                                    setState(() {});
                                    _shadeController.clear();
                                  } else {
                                    Helpers.showError(
                                      ctx,
                                      'Shade already added',
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            );
          },
        );
      },
    );
  }

  bool _isColorDark(Color color) {
    final luminance = color.computeLuminance();
    return luminance < 0.5;
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
          shades: _shades.isNotEmpty ? _shades : null,
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
          shades: _shades.isNotEmpty ? _shades : null,
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
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
                        decoration: _inputDecoration(
                          'Enter product description',
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 20),

                      // ==================== CATEGORY ====================
                      _buildLabel('Category *'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: _inputDecoration('Select category'),
                        items: _buildCategoryItems(),
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
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
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
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
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
                                    final discountPrice = double.tryParse(
                                      value.trim(),
                                    );
                                    if (discountPrice == null ||
                                        discountPrice <= 0) {
                                      return 'Invalid';
                                    }
                                    final price =
                                        double.tryParse(
                                          _priceController.text,
                                        ) ??
                                        0;
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
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
                                    isEditing
                                        ? 'Update Product'
                                        : 'Add Product',
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
      children: [
        // Add shade button
        GestureDetector(
          onTap: _showShadeSelector,
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
                Icon(Icons.palette, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Add Shade / Color',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Selected shades
        if (_shades.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _shades.asMap().entries.map((entry) {
                  final index = entry.key;
                  final shade = entry.value;
                  final predefined = _predefinedShades.firstWhere(
                    (s) => s['name'] == shade,
                    orElse: () => {'name': shade, 'color': AppColors.primary},
                  );

                  return Chip(
                    avatar: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: predefined['color'],
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                    ),
                    label: Text(shade),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeShade(index),
                    backgroundColor: AppColors.surface,
                  );
                }).toList(),
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

  List<DropdownMenuItem<int>> _buildCategoryItems() {
    final items = <DropdownMenuItem<int>>[];

    for (final category in _categories) {
      // Add parent category
      items.add(
        DropdownMenuItem(
          value: category.id,
          child: Text(
            category.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );

      // Add subcategories
      if (category.subcategories != null) {
        for (final subcategory in category.subcategories!) {
          items.add(
            DropdownMenuItem(
              value: subcategory.id,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text('• ${subcategory.name}'),
              ),
            ),
          );
        }
      }
    }

    return items;
  }
}
