import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'home_screen.dart';
import '../product/product_list_screen.dart';
import '../cart/cart_screen.dart';
import '../order/order_list_screen.dart';
import '../profile/profile_screen.dart';

/// Main dashboard screen with bottom navigation
class DashboardScreen extends StatefulWidget {
  final int initialIndex;

  const DashboardScreen({super.key, this.initialIndex = 0, required user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;
  late PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProductListScreen(),
    CartScreen(),
    OrderListScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: _CartBadgeIcon(),
              activeIcon: _CartBadgeIcon(isActive: true),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

/// Cart icon with badge
class _CartBadgeIcon extends StatelessWidget {
  final bool isActive;

  const _CartBadgeIcon({this.isActive = false});

  @override
  Widget build(BuildContext context) {
    // TODO: Get cart count from presenter/provider
    const cartCount = 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined),
        if (cartCount > 0)
          Positioned(
            right: -8,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                cartCount > 99 ? '99+' : '$cartCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
