import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../models/common_models.dart';
import '../../presenters/admin_presenter.dart';

/// Admin banner form screen for creating/editing banners
class AdminBannerFormScreen extends StatefulWidget {
  final BannerModel? banner;

  const AdminBannerFormScreen({super.key, this.banner});

  @override
  State<AdminBannerFormScreen> createState() => _AdminBannerFormScreenState();
}

class _AdminBannerFormScreenState extends State<AdminBannerFormScreen>
    implements AdminBannerFormView {
  final _presenter = AdminPresenter();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _discountTextController = TextEditingController();
  final _discountPercentController = TextEditingController();
  final _buttonTextController = TextEditingController();
  final _sortOrderController = TextEditingController();

  String? _imageUrl;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isUploading = false;

  bool get _isEditing => widget.banner != null;

  @override
  void initState() {
    super.initState();
    _presenter.attachBannerFormView(this);
    if (_isEditing) {
      _populateForm(widget.banner!);
    } else {
      _sortOrderController.text = '0';
      _buttonTextController.text = 'Shop Now';
    }
  }

  @override
  void dispose() {
    _presenter.detach();
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _discountTextController.dispose();
    _discountPercentController.dispose();
    _buttonTextController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  void _populateForm(BannerModel banner) {
    _titleController.text = banner.title ?? '';
    _descriptionController.text = banner.description ?? '';
    _linkController.text = banner.link ?? '';
    _discountTextController.text = banner.discountText ?? '';
    _discountPercentController.text =
        banner.discountPercent?.toString() ?? '';
    _buttonTextController.text = banner.buttonText ?? 'Shop Now';
    _sortOrderController.text = banner.sortOrder.toString();
    _imageUrl = banner.imageUrl;
    _isActive = banner.isActive;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      await _presenter.uploadBannerImage(
        pickedFile.path,
        bannerId: _isEditing ? widget.banner!.id : null,
      );
    }
  }

  void _saveBanner() {
    if (!_formKey.currentState!.validate()) return;

    if (_imageUrl == null || _imageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a banner image')),
      );
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final link = _linkController.text.trim();
    final discountText = _discountTextController.text.trim();
    final discountPercent = int.tryParse(_discountPercentController.text);
    final buttonText = _buttonTextController.text.trim();
    final sortOrder = int.tryParse(_sortOrderController.text) ?? 0;

    if (_isEditing) {
      _presenter.updateBanner(
        widget.banner!.id,
        imageUrl: _imageUrl,
        title: title.isNotEmpty ? title : null,
        description: description.isNotEmpty ? description : null,
        link: link.isNotEmpty ? link : null,
        discountText: discountText.isNotEmpty ? discountText : null,
        discountPercent: discountPercent,
        buttonText: buttonText.isNotEmpty ? buttonText : 'Shop Now',
        sortOrder: sortOrder,
        isActive: _isActive,
      );
    } else {
      _presenter.createBanner(
        imageUrl: _imageUrl!,
        title: title.isNotEmpty ? title : null,
        description: description.isNotEmpty ? description : null,
        link: link.isNotEmpty ? link : null,
        discountText: discountText.isNotEmpty ? discountText : null,
        discountPercent: discountPercent,
        buttonText: buttonText.isNotEmpty ? buttonText : 'Shop Now',
        sortOrder: sortOrder,
        isActive: _isActive,
      );
    }
  }

  // AdminBannerFormView implementation
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() => _isLoading = false);
  }

  @override
  void showBanner(BannerModel banner) {
    _populateForm(banner);
    setState(() {});
  }

  @override
  void showBannerSaved(BannerModel banner) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? 'Banner updated successfully' : 'Banner created successfully',
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  void showImageUploading() {
    setState(() => _isUploading = true);
  }

  @override
  void showImageUploaded(String imageUrl) {
    setState(() {
      _imageUrl = imageUrl;
      _isUploading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image uploaded successfully')),
    );
  }

  @override
  void showError(String message) {
    setState(() {
      _isLoading = false;
      _isUploading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void showValidationError(String field, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$field: $message')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Banner' : 'Add Banner'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveBanner,
              child: const Text('Save'),
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
              // Image picker
              _buildImagePicker(),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter banner title',
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter banner description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Discount section
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _discountTextController,
                      decoration: const InputDecoration(
                        labelText: 'Discount Text',
                        hintText: 'e.g., Up to 50% Off',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountPercentController,
                      decoration: const InputDecoration(
                        labelText: 'Discount %',
                        hintText: 'e.g., 50',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Button text
              TextFormField(
                controller: _buttonTextController,
                decoration: const InputDecoration(
                  labelText: 'Button Text',
                  hintText: 'e.g., Shop Now',
                ),
              ),
              const SizedBox(height: 16),

              // Link
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Link (optional)',
                  hintText: '/products?filter=sale',
                ),
              ),
              const SizedBox(height: 16),

              // Sort order
              TextFormField(
                controller: _sortOrderController,
                decoration: const InputDecoration(
                  labelText: 'Sort Order',
                  hintText: 'Lower number shows first',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Active toggle
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text('Show this banner on the home screen'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // Preview section
              if (_imageUrl != null) ...[
                const Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPreview(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Banner Image *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isUploading ? null : _pickImage,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: _isUploading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Uploading...'),
                      ],
                    ),
                  )
                : _imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: _imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error_outline,
                                size: 48,
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Change',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap to select image',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Recommended: 800x400 pixels',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 2,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              CachedNetworkImage(
                imageUrl: _imageUrl!,
                fit: BoxFit.cover,
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_discountTextController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _discountTextController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (_discountTextController.text.isNotEmpty)
                      const SizedBox(height: 8),
                    if (_titleController.text.isNotEmpty)
                      Text(
                        _titleController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (_descriptionController.text.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _descriptionController.text,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (_buttonTextController.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _buttonTextController.text,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
