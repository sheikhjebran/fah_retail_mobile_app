import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/product_model.dart';
import '../../models/common_models.dart';
import '../../presenters/product_presenter.dart';
import '../../presenters/cart_presenter.dart';
import '../../services/banner_service.dart';
import '../../widgets/banner_slider.dart';
import '../../widgets/product_card.dart';
import '../product/product_detail_screen.dart';

/// Home screen with banners and product sections
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeProductsView {
  final _productPresenter = ProductPresenter();
  final _cartPresenter = CartPresenter();
  final _bannerService = BannerService();

  List<BannerModel> _banners = [];
  List<ProductModel> _trendingProducts = [];
  List<ProductModel> _discountedProducts = [];

  bool _isBannersLoading = true;
  bool _isTrendingLoading = true;
  bool _isDiscountedLoading = true;
  final Set<int> _addingToCart = {};

  @override
  void initState() {
    super.initState();
    _productPresenter.attachHomeView(this);
    _loadData();
  }

  @override
  void dispose() {
    _productPresenter.detach();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadBanners(),
      _loadTrendingProducts(),
      _loadDiscountedProducts(),
    ]);
  }

  Future<void> _loadBanners() async {
    try {
      _banners = await _bannerService.getBanners();
    } catch (e) {
      // Use placeholder banners
      _banners = [];
    } finally {
      if (mounted) {
        setState(() => _isBannersLoading = false);
      }
    }
  }

  Future<void> _loadTrendingProducts() {
    return _productPresenter.loadTrendingProducts();
  }

  Future<void> _loadDiscountedProducts() {
    return _productPresenter.loadDiscountedProducts();
  }

  void _navigateToProducts() {
    // Navigate to products tab (index 1)
    final dashboardState = context.findAncestorStateOfType<State>();
    if (dashboardState != null) {
      // TODO: Implement proper navigation to products tab
    }
  }

  void _navigateToProductDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  Future<void> _addToCart(ProductModel product) async {
    if (_addingToCart.contains(product.id)) return;

    setState(() => _addingToCart.add(product.id));

    try {
      await _cartPresenter.addToCart(product);
      if (mounted) {
        Helpers.showSuccess(context, '${product.name} added to cart');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showError(context, 'Failed to add to cart: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _addingToCart.remove(product.id));
      }
    }
  }

  // HomeProductsView implementation
  @override
  void showTrendingLoading() {
    setState(() => _isTrendingLoading = true);
  }

  @override
  void showTrendingProducts(List<ProductModel> products) {
    setState(() {
      _trendingProducts = products;
      _isTrendingLoading = false;
    });
  }

  @override
  void showDiscountedLoading() {
    setState(() => _isDiscountedLoading = true);
  }

  @override
  void showDiscountedProducts(List<ProductModel> products) {
    setState(() {
      _discountedProducts = products;
      _isDiscountedLoading = false;
    });
  }

  @override
  void showError(String message) {
    // Show error snackbar if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Center(
                child: Text(
                  'F',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('FAH Retail'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Slider
              _isBannersLoading
                  ? const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : BannerSlider(banners: _banners),

              const SizedBox(height: 24),

              // Trending Products Section
              _buildSectionHeader(
                title: '🔥 Trending Products',
                onViewAll: _navigateToProducts,
              ),
              const SizedBox(height: 12),
              _buildProductSection(
                products: _trendingProducts,
                isLoading: _isTrendingLoading,
              ),

              const SizedBox(height: 24),

              // Discounted Products Section
              _buildSectionHeader(
                title: '💰 Best Deals',
                onViewAll: _navigateToProducts,
              ),
              const SizedBox(height: 12),
              _buildProductSection(
                products: _discountedProducts,
                isLoading: _isDiscountedLoading,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onViewAll,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('View All'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection({
    required List<ProductModel> products,
    required bool isLoading,
  }) {
    if (isLoading) {
      return SizedBox(
        height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      );
    }

    if (products.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No products available')),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 160,
              child: ProductCard(
                product: product,
                onTap: () => _navigateToProductDetail(product),
                onAddToCart: () => _addToCart(product),
              ),
            ),
          );
        },
      ),
    );
  }
}
