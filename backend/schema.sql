-- FAH Retail Mobile App - MySQL Database Schema
-- Run this script to create all required tables

-- Create database
CREATE DATABASE IF NOT EXISTS fah_retail;
USE fah_retail;

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    pincode VARCHAR(10),
    role ENUM('user', 'admin') DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_phone (phone),
    INDEX idx_role (role)
);

-- =====================================================
-- OTP TABLE (for authentication)
-- =====================================================
CREATE TABLE IF NOT EXISTS otps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    phone VARCHAR(15) NOT NULL,
    otp VARCHAR(6) NOT NULL,
    expires_at DATETIME NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_phone_otp (phone, otp),
    INDEX idx_expires (expires_at)
);

-- =====================================================
-- CATEGORIES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INT DEFAULT NULL,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_parent (parent_id),
    INDEX idx_active (is_active)
);

-- =====================================================
-- PRODUCTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount_price DECIMAL(10, 2) DEFAULT NULL,
    qty INT NOT NULL DEFAULT 0,
    shades JSON DEFAULT NULL,
    primary_image VARCHAR(500),
    is_trending BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    INDEX idx_category (category_id),
    INDEX idx_trending (is_trending),
    INDEX idx_active (is_active),
    INDEX idx_price (price),
    FULLTEXT INDEX idx_search (name, description)
);

-- =====================================================
-- PRODUCT IMAGES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS product_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_product (product_id),
    INDEX idx_primary (is_primary)
);

-- =====================================================
-- ADDRESSES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS addresses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_default (is_default)
);

-- =====================================================
-- CART TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_item (user_id, product_id),
    INDEX idx_user (user_id)
);

-- =====================================================
-- ORDERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    order_number VARCHAR(20) NOT NULL UNIQUE,
    address_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    delivery_fee DECIMAL(10, 2) DEFAULT 0,
    payment_method VARCHAR(50) NOT NULL,
    payment_status ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
    razorpay_order_id VARCHAR(100),
    razorpay_payment_id VARCHAR(100),
    razorpay_signature VARCHAR(500),
    status ENUM('pending', 'order_placed', 'in_transit', 'delivered', 'cancelled') DEFAULT 'pending',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (address_id) REFERENCES addresses(id),
    INDEX idx_user (user_id),
    INDEX idx_order_number (order_number),
    INDEX idx_status (status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_created (created_at)
);

-- =====================================================
-- ORDER ITEMS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    product_image VARCHAR(500),
    qty INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount_price DECIMAL(10, 2),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_order (order_id)
);

-- =====================================================
-- ORDER STATUS HISTORY TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS order_status_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    note TEXT,
    created_by INT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_order (order_id),
    INDEX idx_timestamp (timestamp)
);

-- =====================================================
-- BANNERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS banners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200),
    image_url VARCHAR(500) NOT NULL,
    link VARCHAR(500),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_active (is_active),
    INDEX idx_order (sort_order)
);

-- =====================================================
-- INSERT DEFAULT CATEGORIES
-- =====================================================
INSERT INTO categories (name, parent_id, sort_order) VALUES
('Hair band', NULL, 1),
('Hair pins', NULL, 2),
('Saree pins', NULL, 3),
('Clips', NULL, 4),
('Necklace', NULL, 5),
('Bracelet', NULL, 6),
('Rings', NULL, 7),
('Watches', NULL, 8),
('Fancy mirror', NULL, 9),
('Earrings', NULL, 10);

-- Get Earrings category ID and insert subcategories
SET @earrings_id = (SELECT id FROM categories WHERE name = 'Earrings');

INSERT INTO categories (name, parent_id, sort_order) VALUES
('Crystal earrings', @earrings_id, 1),
('Long earrings', @earrings_id, 2),
('Short earrings', @earrings_id, 3),
('Round earrings', @earrings_id, 4),
('Rose gold earrings', @earrings_id, 5),
('Silver plated earrings', @earrings_id, 6),
('Gold plated earrings', @earrings_id, 7);

-- =====================================================
-- INSERT ADMIN USER (password: admin123)
-- =====================================================
INSERT INTO users (name, phone, email, role) VALUES
('Admin', '9999999999', 'admin@fahretail.com', 'admin');

-- =====================================================
-- INSERT SAMPLE PRODUCTS
-- =====================================================
INSERT INTO products (name, description, category_id, price, discount_price, qty, is_trending, primary_image) VALUES
('Crystal Drop Earrings', 'Beautiful crystal drop earrings perfect for any occasion', 11, 499.00, 399.00, 50, TRUE, 'https://res.cloudinary.com/demo/image/upload/v1/products/earring1.jpg'),
('Gold Plated Necklace Set', 'Elegant gold plated necklace with matching earrings', 5, 1299.00, 999.00, 30, TRUE, 'https://res.cloudinary.com/demo/image/upload/v1/products/necklace1.jpg'),
('Silver Charm Bracelet', 'Delicate silver charm bracelet with heart pendants', 6, 599.00, NULL, 45, FALSE, 'https://res.cloudinary.com/demo/image/upload/v1/products/bracelet1.jpg'),
('Floral Hair Clips Set', 'Set of 6 beautiful floral hair clips', 4, 299.00, 249.00, 100, TRUE, 'https://res.cloudinary.com/demo/image/upload/v1/products/clips1.jpg'),
('Designer Hair Band', 'Premium designer hair band with pearl accents', 1, 399.00, NULL, 60, FALSE, 'https://res.cloudinary.com/demo/image/upload/v1/products/hairband1.jpg'),
('Rose Gold Hoop Earrings', 'Trendy rose gold hoop earrings', 15, 799.00, 649.00, 40, TRUE, 'https://res.cloudinary.com/demo/image/upload/v1/products/earring2.jpg');

-- =====================================================
-- INSERT SAMPLE BANNERS
-- =====================================================
INSERT INTO banners (title, image_url, sort_order, is_active) VALUES
('New Arrivals', 'https://res.cloudinary.com/demo/image/upload/v1/banners/banner1.jpg', 1, TRUE),
('Summer Sale - Up to 50% Off', 'https://res.cloudinary.com/demo/image/upload/v1/banners/banner2.jpg', 2, TRUE),
('Trending Collection', 'https://res.cloudinary.com/demo/image/upload/v1/banners/banner3.jpg', 3, TRUE);

-- =====================================================
-- VIEWS FOR REPORTING (Optional)
-- =====================================================
CREATE OR REPLACE VIEW v_order_summary AS
SELECT 
    DATE(o.created_at) as order_date,
    COUNT(*) as total_orders,
    SUM(o.total_amount) as total_revenue,
    SUM(CASE WHEN o.status = 'delivered' THEN 1 ELSE 0 END) as delivered_orders,
    SUM(CASE WHEN o.status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_orders
FROM orders o
GROUP BY DATE(o.created_at);

CREATE OR REPLACE VIEW v_top_products AS
SELECT 
    p.id,
    p.name,
    p.primary_image,
    SUM(oi.qty) as total_sold,
    SUM(oi.qty * COALESCE(oi.discount_price, oi.price)) as total_revenue
FROM products p
JOIN order_items oi ON p.id = oi.product_id
JOIN orders o ON oi.order_id = o.id
WHERE o.status != 'cancelled'
GROUP BY p.id, p.name, p.primary_image
ORDER BY total_sold DESC;

-- Done!
SELECT 'Database setup complete!' as status;
