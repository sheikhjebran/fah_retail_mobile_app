# FAH Retail Mobile App - Copilot Instructions

## Project Overview

Flutter accessories store app with User and Admin capabilities using MVP architecture.

## Technology Stack

- **Frontend**: Flutter (latest stable)
- **Backend**: Python FastAPI with MySQL
- **Architecture**: Model-View-Presenter (MVP)
- **Image Storage**: Cloudinary
- **Payments**: Razorpay
- **Authentication**: OTP-based with JWT

## Code Style

### Flutter/Dart

- Use `camelCase` for variables and functions
- Use `PascalCase` for classes and widgets
- Use `snake_case` for file names
- Follow MVP pattern: Models → Services → Presenters → Views
- Always create view contracts (abstract classes) for presenters
- Use Dio for HTTP requests with proper error handling
- Prefer `const` constructors where possible
- Use `final` for variables that won't be reassigned
- Add documentation comments for public APIs

### Python/FastAPI

- Use `snake_case` for variables, functions, and files
- Use `PascalCase` for classes and Pydantic models
- Use async/await for database operations
- Return proper HTTP status codes
- Use Pydantic for request/response validation
- Add docstrings to all functions

## Architecture Rules

### MVP Pattern

1. **Models**: Pure data classes with `fromJson`/`toJson` methods
2. **Services**: API communication only, no business logic
3. **Presenters**: Business logic, state management, call services
4. **Views**: UI only, call presenter methods, implement view contracts

### View Contracts

Every presenter must define a view contract (abstract class):

```dart
abstract class ProductListView {
  void showLoading();
  void hideLoading();
  void showProducts(List<ProductModel> products);
  void showError(String message);
}
```

### File Organization

```
lib/
  core/
    network/        # api_client.dart, api_exceptions.dart
    utils/          # Helpers, validators
    constants/      # api_endpoints.dart, app_constants.dart
    theme/          # Colors, typography
  models/           # Data models (includes common_models.dart)
  services/         # API services (auth, product, cart, order, address, admin, banner, payment)
  presenters/       # Business logic (auth, product, cart, order, admin)
  views/            # Screens organized by feature (splash, auth, dashboard, product, cart, order, profile, admin)
  widgets/          # Reusable components (banner_slider, cart_item, category_filter, etc.)
```

## API Conventions

- Base URL: Configure in `core/constants/api_endpoints.dart`
- All endpoints prefixed with `/api/`
- Use JWT Bearer token in Authorization header
- Handle 401 responses with token refresh or logout
- Always include proper error handling with try-catch

## Error Handling

- Wrap API calls in try-catch blocks
- Create custom exception classes for different error types
- Show user-friendly error messages via view contracts
- Log errors for debugging

## Database Tables

- users, products, product_images, categories
- orders, order_items, order_status_history
- cart, addresses

## Categories

Main: Hair band, Hair pins, Saree pins, Clips, Necklace, Bracelet, Rings, Watches, Fancy mirror, Earrings

Earrings subcategories: Crystal, Long, Short, Round, Rose gold, Silver plated, Gold plated

## Order Status Flow

`pending` → `order_placed` → `in_transit` → `delivered` (or `cancelled` at any stage)

## Key Dependencies

### Flutter

- dio: HTTP client
- shared_preferences: Token storage
- hive/hive_flutter: Local data cache
- razorpay_flutter: Payment gateway
- lottie: Splash animation
- cached_network_image: Image caching
- carousel_slider: Banner slider
- fl_chart: Admin dashboard charts
- image_picker: Product image upload
- pin_code_fields: OTP input
- equatable: Value equality
- share_plus: Share functionality
- provider: Dependency injection
- shimmer: Loading placeholders
- flutter_svg: SVG support
- intl: Internationalization

### Backend

- fastapi: Web framework
- sqlalchemy: ORM
- pydantic/pydantic-settings: Validation
- python-jose: JWT handling
- cloudinary: Image storage
- razorpay: Payment processing
- httpx: HTTP client

## Testing Guidelines

- Write unit tests for all presenters
- Write unit tests for services with mocked responses
- Use `mockito` for mocking dependencies
- Test edge cases: empty states, error states, loading states

## Security

- Never hardcode API keys or secrets
- Use environment variables for sensitive data
- Validate all user inputs
- Sanitize data before database operations
- Use HTTPS for all API calls

## Performance

- Implement pagination for lists (20 items per page)
- Use lazy loading for images
- Cache API responses where appropriate
- Minimize widget rebuilds with const constructors

## Naming Conventions

### Files

- Models: `{name}_model.dart`
- Services: `{name}_service.dart`
- Presenters: `{name}_presenter.dart`
- Screens: `{name}_screen.dart`
- Widgets: `{name}.dart` or `{name}_widget.dart`

### Classes

- Models: `{Name}Model`
- Services: `{Name}Service`
- Presenters: `{Name}Presenter`
- View Contracts: `{Name}View`
- Screens: `{Name}Screen`

## Common Patterns

### API Response Handling

```dart
try {
  final response = await _apiClient.get(endpoint);
  if (response.statusCode == 200) {
    return Model.fromJson(response.data);
  }
  throw ApiException(response.statusMessage);
} on DioException catch (e) {
  throw ApiException(e.message ?? 'Network error');
}
```

### Presenter Pattern

```dart
class ProductPresenter {
  final ProductService _service;
  final ProductListView _view;

  ProductPresenter(this._service, this._view);

  Future<void> loadProducts() async {
    _view.showLoading();
    try {
      final products = await _service.getProducts();
      _view.showProducts(products);
    } catch (e) {
      _view.showError(e.toString());
    } finally {
      _view.hideLoading();
    }
  }
}
```

## Git Conventions

- Use conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
- Keep commits atomic and focused
- Write descriptive commit messages
