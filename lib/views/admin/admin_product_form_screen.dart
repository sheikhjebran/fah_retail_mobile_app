import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _qtyController = TextEditingController();

  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  bool _isTrending = false;
  bool _isLoading = false;
  bool _isSaving = false;

  bool get isEditing => widget.productId != null || widget.product != null;

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
    }
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

      if (isEditing) {
        await _adminService.updateProduct(
          widget.productId ?? widget.product!.id,
          name: name,
          description: description,
          categoryId: _selectedCategoryId,
          price: price,
          discountPrice: discountPrice,
          qty: qty,
          isTrending: _isTrending,
        );
        if (mounted) {
          Helpers.showSuccess(context, 'Product updated successfully');
          Navigator.pop(context, true);
        }
      } else {
        await _adminService.addProduct(
          name: name,
          description: description,
          categoryId: _selectedCategoryId!,
          price: price,
          discountPrice: discountPrice,
          qty: qty,
          isTrending: _isTrending,
        );
        if (mounted) {
          Helpers.showSuccess(context, 'Product added successfully');
          Navigator.pop(context, true);
        }
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
                      // Product Name
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

                      // Description
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

                      // Category
                      _buildLabel('Category *'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedCategoryId,
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

                      // Price Row
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
                                      return 'Price is required';
                                    }
                                    final price = double.tryParse(value.trim());
                                    if (price == null || price <= 0) {
                                      return 'Enter valid price';
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
                                      return 'Enter valid price';
                                    }
                                    final price =
                                        double.tryParse(
                                          _priceController.text,
                                        ) ??
                                        0;
                                    if (discountPrice >= price) {
                                      return 'Must be less than price';
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

                      // Quantity
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
                      const SizedBox(height: 20),

                      // Trending Switch
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

                      // Save Button
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
