# Plan: Flutter Accessories Store App (MVP Architecture)

## TL;DR

Build a complete Flutter mobile app for an accessories store with User and Admin capabilities using **MVP architecture**, **Python FastAPI backend** with MySQL, OTP authentication, Razorpay payments, and **Cloudinary** for image storage. Single app with role-based UI.

---

## Phase 1: Project Setup & Core Infrastructure

| Step | Task                                                          | Parallel            |
| ---- | ------------------------------------------------------------- | ------------------- |
| 1.1  | Initialize Flutter project, set up MVP folder structure       | —                   |
| 1.2  | Create `lib/core/` modules (network, utils, constants, theme) | _parallel with 1.1_ |
| 1.3  | Set up FastAPI backend with MySQL, JWT auth, Cloudinary       | _parallel with 1.1_ |

---

## Phase 2: Authentication System

| Step | Task                                                           | Depends On |
| ---- | -------------------------------------------------------------- | ---------- |
| 2.1  | Create `user_model.dart`                                       | —          |
| 2.2  | Create `auth_service.dart` (sendOtp, verifyOtp, signup, login) | 2.1        |
| 2.3  | Create `login_presenter.dart` with view contracts              | 2.2        |
| 2.4  | Build views: Splash (Lottie animation), Login, OTP, Signup     | 2.3        |

---

## Phase 3: Dashboard & Navigation

| Step | Task                                                                    |
| ---- | ----------------------------------------------------------------------- |
| 3.1  | Create main scaffold with 5 tabs: Home, Products, Cart, Orders, Profile |
| 3.2  | Build `banner_slider.dart` (auto-swipe, max 4 images)                   |
| 3.3  | Trending products section (vertical, max 6)                             |
| 3.4  | Discounted products section (vertical, max 6)                           |

---

## Phase 4: Product System

| Step | Task                                                                     |
| ---- | ------------------------------------------------------------------------ |
| 4.1  | Create `product_model.dart`, `category_model.dart`                       |
| 4.2  | Create `product_service.dart`                                            |
| 4.3  | Create `product_presenter.dart` with filtering/sorting logic             |
| 4.4  | Build product list (grid), detail screen (carousel), `product_card.dart` |

---

## Phase 5: Cart System

| Step | Task                                              |
| ---- | ------------------------------------------------- |
| 5.1  | Create `cart_model.dart`                          |
| 5.2  | Create `cart_service.dart`                        |
| 5.3  | Create `cart_presenter.dart`                      |
| 5.4  | Build cart screen with quantity selectors, totals |

---

## Phase 6: Address & Checkout

| Step | Task                                |
| ---- | ----------------------------------- |
| 6.1  | Create `address_model.dart`         |
| 6.2  | Build address selection/add screens |
| 6.3  | Implement checkout flow             |

---

## Phase 7: Order System

| Step | Task                                                                                  |
| ---- | ------------------------------------------------------------------------------------- |
| 7.1  | Create `order_model.dart`, `order_item_model.dart`, `order_status_history_model.dart` |
| 7.2  | Create `order_service.dart`                                                           |
| 7.3  | Build order list, detail screen with status timeline                                  |

---

## Phase 8: Payment Integration (Razorpay)

| Step | Task                                                        |
| ---- | ----------------------------------------------------------- |
| 8.1  | Integrate `razorpay_flutter` SDK                            |
| 8.2  | Create `payment_service.dart`                               |
| 8.3  | Build payment screen with UPI, GPay, PhonePe, Cards support |

---

## Phase 9: Profile System

| Step | Task                                                                 |
| ---- | -------------------------------------------------------------------- |
| 9.1  | Build profile screen (view/edit user info, manage addresses, logout) |

---

## Phase 10: Admin Module

| Step | Task                                                                  |
| ---- | --------------------------------------------------------------------- |
| 10.1 | Implement role detection and admin navigation                         |
| 10.2 | Admin Dashboard: sales stats, charts (fl_chart), low stock alerts     |
| 10.3 | Product management: CRUD, image upload (max 5), set trending/discount |
| 10.4 | Order management: search, filter, status updates                      |

---

## Phase 11: FastAPI Backend

| Step | Task                                                                           |
| ---- | ------------------------------------------------------------------------------ |
| 11.1 | Project structure with SQLAlchemy, Pydantic, Alembic                           |
| 11.2 | Auth routes: `/api/send-otp`, `/api/verify-otp`, `/api/signup`, `/api/login`   |
| 11.3 | Product routes: `/api/products`, `/api/products/trending`, `/api/product/{id}` |
| 11.4 | Cart routes: `/api/cart/add`, `/api/cart/update`, `/api/cart`                  |
| 11.5 | Order routes: `/api/order/place`, `/api/orders`, `/api/order/{id}`             |
| 11.6 | Admin routes: CRUD products, order management, dashboard stats                 |

---

## Flutter Folder Structure

```
lib/
  core/
    network/
      api_client.dart
      api_endpoints.dart
      interceptors.dart
    utils/
      validators.dart
      formatters.dart
      helpers.dart
    constants/
      app_constants.dart
      colors.dart
    theme/
      app_theme.dart
      typography.dart
  models/
    user_model.dart
    product_model.dart
    order_model.dart
    cart_model.dart
    category_model.dart
    address_model.dart
    order_item_model.dart
    order_status_history_model.dart
  services/
    api_service.dart
    auth_service.dart
    product_service.dart
    cart_service.dart
    order_service.dart
    payment_service.dart
  presenters/
    login_presenter.dart
    product_presenter.dart
    cart_presenter.dart
    order_presenter.dart
    admin/
      admin_product_presenter.dart
      admin_order_presenter.dart
      admin_dashboard_presenter.dart
  views/
    splash/
      splash_screen.dart
    auth/
      login_screen.dart
      otp_verification_screen.dart
      signup_screen.dart
    dashboard/
      dashboard_screen.dart
      home_screen.dart
    product/
      product_list_screen.dart
      product_detail_screen.dart
    cart/
      cart_screen.dart
    order/
      order_list_screen.dart
      order_detail_screen.dart
      order_confirmation_screen.dart
    checkout/
      address_selection_screen.dart
      add_address_screen.dart
      payment_screen.dart
    profile/
      profile_screen.dart
      edit_profile_screen.dart
    admin/
      admin_dashboard_screen.dart
      product/
        admin_product_list_screen.dart
        add_edit_product_screen.dart
      order/
        admin_order_list_screen.dart
        admin_order_detail_screen.dart
  widgets/
    product_card.dart
    banner_slider.dart
    cart_item.dart
    order_status_timeline.dart
    category_filter.dart
    price_slider.dart
    quantity_selector.dart
  main.dart
```

---

## Backend Folder Structure (FastAPI)

```
backend/
  app/
    main.py
    config.py
    database.py
    dependencies.py
    models/
      user.py
      product.py
      order.py
      cart.py
      category.py
      address.py
    schemas/
      user.py
      product.py
      order.py
      cart.py
      auth.py
    routers/
      auth.py
      products.py
      cart.py
      orders.py
      admin.py
    services/
      otp_service.py
      cloudinary_service.py
      razorpay_service.py
    utils/
      security.py
      validators.py
  requirements.txt
  alembic/
    versions/
  alembic.ini
  .env
```

---

## Database Tables

### users

| Column     | Type                                 |
| ---------- | ------------------------------------ |
| id         | INT PRIMARY KEY                      |
| name       | VARCHAR(100)                         |
| phone      | VARCHAR(15) UNIQUE                   |
| email      | VARCHAR(100)                         |
| address    | TEXT                                 |
| city       | VARCHAR(50)                          |
| pincode    | VARCHAR(10)                          |
| role       | ENUM('user', 'admin') DEFAULT 'user' |
| created_at | DATETIME                             |

### products

| Column         | Type                  |
| -------------- | --------------------- |
| id             | INT PRIMARY KEY       |
| name           | VARCHAR(200)          |
| description    | TEXT                  |
| category_id    | INT FK                |
| price          | DECIMAL(10,2)         |
| discount_price | DECIMAL(10,2) NULL    |
| qty            | INT                   |
| shades         | JSON                  |
| primary_image  | VARCHAR(500)          |
| is_trending    | BOOLEAN DEFAULT FALSE |
| created_at     | DATETIME              |

### product_images

| Column     | Type                  |
| ---------- | --------------------- |
| id         | INT PRIMARY KEY       |
| product_id | INT FK                |
| image_url  | VARCHAR(500)          |
| is_primary | BOOLEAN DEFAULT FALSE |

### categories

| Column    | Type            |
| --------- | --------------- |
| id        | INT PRIMARY KEY |
| name      | VARCHAR(100)    |
| parent_id | INT FK NULL     |

### orders

| Column         | Type                                                                    |
| -------------- | ----------------------------------------------------------------------- |
| id             | INT PRIMARY KEY                                                         |
| user_id        | INT FK                                                                  |
| order_number   | VARCHAR(20) UNIQUE                                                      |
| total_amount   | DECIMAL(10,2)                                                           |
| payment_method | VARCHAR(50)                                                             |
| payment_status | ENUM('pending', 'paid', 'failed')                                       |
| status         | ENUM('pending', 'order_placed', 'in_transit', 'delivered', 'cancelled') |
| created_at     | DATETIME                                                                |

### order_items

| Column         | Type               |
| -------------- | ------------------ |
| id             | INT PRIMARY KEY    |
| order_id       | INT FK             |
| product_id     | INT FK             |
| qty            | INT                |
| price          | DECIMAL(10,2)      |
| discount_price | DECIMAL(10,2) NULL |

### order_status_history

| Column    | Type            |
| --------- | --------------- |
| id        | INT PRIMARY KEY |
| order_id  | INT FK          |
| status    | VARCHAR(50)     |
| timestamp | DATETIME        |

### addresses

| Column     | Type                  |
| ---------- | --------------------- |
| id         | INT PRIMARY KEY       |
| user_id    | INT FK                |
| name       | VARCHAR(100)          |
| phone      | VARCHAR(15)           |
| address    | TEXT                  |
| city       | VARCHAR(50)           |
| state      | VARCHAR(50)           |
| pincode    | VARCHAR(10)           |
| is_default | BOOLEAN DEFAULT FALSE |

### cart

| Column     | Type            |
| ---------- | --------------- |
| id         | INT PRIMARY KEY |
| user_id    | INT FK          |
| product_id | INT FK          |
| quantity   | INT             |
| created_at | DATETIME        |

---

## Categories

**Main Categories:**

- Hair band
- Hair pins
- Saree pins
- Clips
- Necklace
- Bracelet
- Rings
- Watches
- Fancy mirror
- Earrings

**Earrings Subcategories:**

- Crystal earrings
- Long earrings
- Short earrings
- Round earrings
- Rose gold earrings
- Silver plated earrings
- Gold plated earrings

---

## API Endpoints

### Authentication

| Method | Endpoint          | Description            |
| ------ | ----------------- | ---------------------- |
| POST   | `/api/send-otp`   | Send OTP to phone      |
| POST   | `/api/verify-otp` | Verify OTP, return JWT |
| POST   | `/api/signup`     | Register user          |
| POST   | `/api/login`      | Login user             |

### Products

| Method | Endpoint                 | Description                    |
| ------ | ------------------------ | ------------------------------ |
| GET    | `/api/products`          | List all (pagination, filters) |
| GET    | `/api/products/trending` | Trending products              |
| GET    | `/api/products/discount` | Discounted products            |
| GET    | `/api/product/{id}`      | Product details                |
| GET    | `/api/categories`        | All categories                 |

### Cart

| Method | Endpoint           | Description     |
| ------ | ------------------ | --------------- |
| GET    | `/api/cart`        | Get user's cart |
| POST   | `/api/cart/add`    | Add item        |
| PUT    | `/api/cart/update` | Update quantity |
| DELETE | `/api/cart/{id}`   | Remove item     |

### Orders

| Method | Endpoint           | Description   |
| ------ | ------------------ | ------------- |
| POST   | `/api/order/place` | Place order   |
| GET    | `/api/orders`      | User's orders |
| GET    | `/api/order/{id}`  | Order details |

### Addresses

| Method | Endpoint              | Description      |
| ------ | --------------------- | ---------------- |
| GET    | `/api/addresses`      | User's addresses |
| POST   | `/api/addresses`      | Add address      |
| PUT    | `/api/addresses/{id}` | Update address   |
| DELETE | `/api/addresses/{id}` | Delete address   |

### Admin

| Method | Endpoint                       | Description     |
| ------ | ------------------------------ | --------------- |
| GET    | `/api/admin/dashboard`         | Dashboard stats |
| POST   | `/api/admin/product`           | Add product     |
| PUT    | `/api/admin/product/{id}`      | Edit product    |
| DELETE | `/api/admin/product/{id}`      | Delete product  |
| GET    | `/api/admin/orders`            | All orders      |
| PUT    | `/api/admin/order/{id}/status` | Update status   |

---

## Dependencies

### Flutter (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  razorpay_flutter: ^1.3.6
  lottie: ^3.1.0
  cached_network_image: ^3.3.1
  carousel_slider: ^4.2.1
  fl_chart: ^0.66.2
  image_picker: ^1.0.7
  intl: ^0.19.0
  shimmer: ^3.0.0
  flutter_svg: ^2.0.9
  pin_code_fields: ^8.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.8
  hive_generator: ^2.0.1
```

### Backend (requirements.txt)

```
fastapi==0.109.0
uvicorn==0.27.0
sqlalchemy==2.0.25
pymysql==1.1.0
pydantic==2.5.3
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
cloudinary==1.38.0
razorpay==1.4.1
alembic==1.13.1
python-dotenv==1.0.0
httpx==0.26.0
```

---

## Confirmed Decisions

| Decision         | Choice                                        |
| ---------------- | --------------------------------------------- |
| Backend          | Python + FastAPI                              |
| App Structure    | Single app with role-based UI                 |
| Image Storage    | Cloudinary (direct upload)                    |
| State Management | MVP pattern (no external library)             |
| HTTP Client      | Dio with interceptors                         |
| Local Storage    | SharedPreferences (tokens), Hive (cart cache) |
| Charts           | fl_chart                                      |
| Animations       | Lottie                                        |
| OTP Provider     | Twilio / MSG91 (configurable)                 |

---

## Verification Checklist

- [ ] Unit tests for all presenters
- [ ] Unit tests for all services
- [ ] Widget tests for key components
- [ ] Integration tests for auth flow
- [ ] Integration tests for checkout flow
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] Test all Razorpay payment methods (test mode)
- [ ] Verify OTP delivery
- [ ] Test Cloudinary image uploads
- [ ] Android APK build
- [ ] iOS build (if applicable)

---

## Future Enhancements (Out of Scope)

- Wishlist functionality
- Reviews and ratings
- Push notifications
- Coupon/discount code system
- Delivery tracking map
- Social login (Google, Apple)
- Multi-language support
- Dark mode
