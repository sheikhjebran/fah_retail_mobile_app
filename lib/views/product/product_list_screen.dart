import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../presenters/product_presenter.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

/// Product listing screen with filtering and sorting
class ProductListScreen extends StatefulWidget {
  final String? categoryId;
  final String? searchQuery;

  const ProductListScreen({super.key, this.categoryId, this.searchQuery});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>
    implements ProductListView {
  final _presenter = ProductPresenter();
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;

  ProductFilter _filter = ProductFilter();
  ProductSortOption _sortOption = ProductSortOption.newest;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _presenter.attachListView(this);
    _selectedCategoryId = widget.categoryId;
    _searchController.text = widget.searchQuery ?? '';

    _scrollController.addListener(_onScroll);
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _presenter.detach();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreProducts();
      }
    }
  }

  Future<void> _loadCategories() async {
    // TODO: Load categories from service
    _categories = [];
  }

  Future<void> _loadProducts() async {
    _currentPage = 1;
    _hasMore = true;
    _filter = _filter.copyWith(
      categoryId: _selectedCategoryId,
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
      sortOption: _sortOption,
    );
    await _presenter.loadProducts(filter: _filter, page: _currentPage);
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore) return;
    _currentPage++;
    await _presenter.loadProducts(
      filter: _filter,
      page: _currentPage,
      refresh: false,
    );
  }

  void _onSearch(String query) {
    _loadProducts();
  }

  void _navigateToDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => _FilterBottomSheet(
            categories: _categories,
            selectedCategoryId: _selectedCategoryId,
            sortOption: _sortOption,
            onApply: (categoryId, sort) {
              setState(() {
                _selectedCategoryId = categoryId;
                _sortOption = sort;
              });
              Navigator.pop(context);
              _loadProducts();
            },
          ),
    );
  }

  // ProductListView implementation
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  @override
  void showProducts(List<ProductModel> products) {
    setState(() {
      if (_currentPage == 1) {
        _products = products;
      } else {
        _products.addAll(products);
      }
      _hasMore = products.length >= 20;
    });
  }

  @override
  void showLoadingMore() {
    setState(() => _isLoadingMore = true);
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() {
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _loadProducts();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onSubmitted: _onSearch,
            ),
          ),

          // Sort option row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_products.length} items',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                DropdownButton<ProductSortOption>(
                  value: _sortOption,
                  underline: const SizedBox(),
                  items:
                      ProductSortOption.values.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Text(_getSortLabel(option)),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _sortOption = value);
                      _loadProducts();
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Product grid
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _products.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: _products.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _products.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final product = _products[index];
                          return ProductCard(
                            product: product,
                            onTap: () => _navigateToDetail(product),
                            onAddToCart: () {
                              // TODO: Add to cart
                            },
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(ProductSortOption option) {
    switch (option) {
      case ProductSortOption.newest:
        return 'Newest';
      case ProductSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case ProductSortOption.priceHighToLow:
        return 'Price: High to Low';
      case ProductSortOption.popularity:
        return 'Popularity';
    }
  }
}

/// Filter bottom sheet
class _FilterBottomSheet extends StatefulWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final ProductSortOption sortOption;
  final Function(String?, ProductSortOption) onApply;

  const _FilterBottomSheet({
    required this.categories,
    this.selectedCategoryId,
    required this.sortOption,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _selectedCategoryId;
  late ProductSortOption _sortOption;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _sortOption = widget.sortOption;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter & Sort',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Categories
          if (widget.categories.isNotEmpty) ...[
            Text('Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedCategoryId == null,
                  onSelected: (selected) {
                    setState(() => _selectedCategoryId = null);
                  },
                ),
                ...widget.categories.map((category) {
                  return ChoiceChip(
                    label: Text(category.name),
                    selected: _selectedCategoryId == category.id,
                    onSelected: (selected) {
                      setState(() => _selectedCategoryId = category.id);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),
          ],

          // Sort options
          Text('Sort By', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                ProductSortOption.values.map((option) {
                  return ChoiceChip(
                    label: Text(_getSortLabel(option)),
                    selected: _sortOption == option,
                    onSelected: (selected) {
                      setState(() => _sortOption = option);
                    },
                  );
                }).toList(),
          ),

          const SizedBox(height: 32),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_selectedCategoryId, _sortOption),
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _getSortLabel(ProductSortOption option) {
    switch (option) {
      case ProductSortOption.newest:
        return 'Newest';
      case ProductSortOption.priceLowToHigh:
        return 'Price: Low to High';
      case ProductSortOption.priceHighToLow:
        return 'Price: High to Low';
      case ProductSortOption.popularity:
        return 'Popularity';
    }
  }
}
