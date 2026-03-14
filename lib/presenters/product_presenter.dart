import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';
import '../core/constants/app_constants.dart';

/// View contract for product list screen
abstract class ProductListView {
  void showLoading();
  void hideLoading();
  void showProducts(List<ProductModel> products, bool hasMore);
  void showLoadMoreLoading();
  void showCategories(List<CategoryModel> categories);
  void showError(String message);
  void showEmptyState();
}

/// View contract for product detail screen
abstract class ProductDetailView {
  void showLoading();
  void hideLoading();
  void showProduct(ProductModel product);
  void showError(String message);
  void showAddedToCart();
}

/// View contract for home screen product sections
abstract class HomeProductsView {
  void showTrendingLoading();
  void showTrendingProducts(List<ProductModel> products);
  void showDiscountedLoading();
  void showDiscountedProducts(List<ProductModel> products);
  void showError(String message);
}

/// Product presenter for managing product-related operations
class ProductPresenter {
  final ProductService _productService;
  ProductListView? _listView;
  ProductDetailView? _detailView;
  HomeProductsView? _homeView;

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  ProductFilter _currentFilter = const ProductFilter();
  int _currentPage = 1;
  bool _hasMoreProducts = true;
  bool _isLoading = false;

  ProductPresenter({ProductService? productService})
    : _productService = productService ?? ProductService();

  /// Attach list view
  void attachListView(ProductListView view) {
    _listView = view;
  }

  /// Attach detail view
  void attachDetailView(ProductDetailView view) {
    _detailView = view;
  }

  /// Attach home view
  void attachHomeView(HomeProductsView view) {
    _homeView = view;
  }

  /// Detach views
  void detach() {
    _listView = null;
    _detailView = null;
    _homeView = null;
  }

  /// Get current products
  List<ProductModel> get products => _products;

  /// Get categories
  List<CategoryModel> get categories => _categories;

  /// Get current filter
  ProductFilter get currentFilter => _currentFilter;

  /// Check if more products available
  bool get hasMoreProducts => _hasMoreProducts;

  /// Load products (initial load or refresh)
  Future<void> loadProducts({
    ProductFilter? filter,
    bool refresh = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    if (refresh || filter != null) {
      _currentPage = 1;
      _products = [];
      _hasMoreProducts = true;
    }

    if (filter != null) {
      _currentFilter = filter;
    }

    _listView?.showLoading();

    try {
      final response = await _productService.getProducts(
        page: _currentPage,
        filter: _currentFilter,
      );

      _products = response.items;
      _hasMoreProducts = response.hasNextPage;
      _currentPage++;

      _listView?.hideLoading();

      if (_products.isEmpty) {
        _listView?.showEmptyState();
      } else {
        _listView?.showProducts(_products, _hasMoreProducts);
      }
    } catch (e) {
      _listView?.hideLoading();
      _listView?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (_isLoading || !_hasMoreProducts) return;
    _isLoading = true;

    _listView?.showLoadMoreLoading();

    try {
      final response = await _productService.getProducts(
        page: _currentPage,
        filter: _currentFilter,
      );

      _products.addAll(response.items);
      _hasMoreProducts = response.hasNextPage;
      _currentPage++;

      _listView?.showProducts(_products, _hasMoreProducts);
    } catch (e) {
      _listView?.showError(e.toString());
    } finally {
      _isLoading = false;
    }
  }

  /// Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await _productService.getCategories();
      _listView?.showCategories(_categories);
    } catch (e) {
      _listView?.showError(e.toString());
    }
  }

  /// Apply filter
  Future<void> applyFilter(ProductFilter filter) async {
    await loadProducts(filter: filter, refresh: true);
  }

  /// Clear filters
  Future<void> clearFilters() async {
    await loadProducts(filter: const ProductFilter(), refresh: true);
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    final filter = _currentFilter.copyWith(searchQuery: query);
    await loadProducts(filter: filter, refresh: true);
  }

  /// Filter by category
  Future<void> filterByCategory(int? categoryId) async {
    final filter = _currentFilter.copyWith(categoryId: categoryId);
    await loadProducts(filter: filter, refresh: true);
  }

  /// Sort products
  Future<void> sortProducts(ProductSortOption sortOption) async {
    final filter = _currentFilter.copyWith(sortOption: sortOption);
    await loadProducts(filter: filter, refresh: true);
  }

  /// Load product detail
  Future<void> loadProductDetail(int productId) async {
    _detailView?.showLoading();

    try {
      final product = await _productService.getProductById(productId);
      _detailView?.hideLoading();
      _detailView?.showProduct(product);
    } catch (e) {
      _detailView?.hideLoading();
      _detailView?.showError(e.toString());
    }
  }

  /// Load trending products for home
  Future<void> loadTrendingProducts() async {
    _homeView?.showTrendingLoading();

    try {
      final products = await _productService.getTrendingProducts(
        limit: AppConstants.maxTrendingProducts,
      );
      _homeView?.showTrendingProducts(products);
    } catch (e) {
      _homeView?.showError(e.toString());
    }
  }

  /// Load discounted products for home
  Future<void> loadDiscountedProducts() async {
    _homeView?.showDiscountedLoading();

    try {
      final products = await _productService.getDiscountedProducts(
        limit: AppConstants.maxDiscountedProducts,
      );
      _homeView?.showDiscountedProducts(products);
    } catch (e) {
      _homeView?.showError(e.toString());
    }
  }
}
