import 'package:go_router/go_router.dart';

// الشاشات
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/otp_register_screen.dart';
import 'screens/otp_login_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/confirm_order_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/saved_addresses_screen.dart';
import 'screens/change_phone_screen.dart';
import 'screens/map_picker_screen.dart'; // 🗺️ شاشة اختيار الموقع
import 'screens/feedback_suggestions_screen.dart'; // ✅ شاشة الشكاوى
import 'screens/about_loom_screen.dart'; // شاشة عن لووم
import 'screens/wishlist_screen.dart'; // ✅ شاشة المفضلات
import 'screens/dark_mode_toggle_screen.dart';
import 'screens/delete_account_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/notifications_settings_screen.dart';
import 'package:loom_app/screens/categories_screen.dart';
import 'screens/products_screen.dart';
import 'screens/search_screen.dart';

// Bloc
import 'blocs/search/search_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// الموديلات
import 'models/product_model.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),

    GoRoute(
      path: '/otp-register',
      builder: (context, state) {
        final args = state.extra as Map<String, String>;
        return OtpRegisterScreen(
          name: args['name']!,
          phoneNumber: args['phone']!,
          gender: args['gender']!,
        );
      },
    ),

    GoRoute(
      path: '/otp-login',
      builder: (context, state) {
        final phoneNumber = state.extra as String;
        return OtpLoginScreen(phoneNumber: phoneNumber);
      },
    ),

    GoRoute(
      path: '/product-details',
      builder: (context, state) {
        final product = state.extra as ProductModel;
        return ProductDetailsScreen(product: product);
      },
    ),

    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(
      path: '/confirm-order',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/saved_addresses',
      builder: (context, state) => const SavedAddressesScreen(),
    ),
    GoRoute(
      path: '/change_phone',
      builder: (context, state) => const ChangePhoneNumberScreen(),
    ),
    GoRoute(
      path: '/map-picker',
      builder: (context, state) => const MapPickerScreen(),
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) => const FeedbackSuggestionsScreen(),
    ),
    GoRoute(
      path: '/about-loom',
      builder: (context, state) => const AboutLoomScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: '/dark-mode-toggle',
      builder: (context, state) => const DarkModeToggleScreen(),
    ),
    GoRoute(
      path: '/delete_account',
      builder: (context, state) => const DeleteAccountScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/notifications_settings',
      builder: (context, state) => const NotificationsSettingsScreen(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => BlocProvider(
        create: (context) => SearchBloc(),
        child: const CategoriesScreen(),
      ),
    ),

    // ✅ حل مشكلة البحث: BlocProvider حول SearchScreen فقط
    GoRoute(
      path: '/search',
      builder: (context, state) => BlocProvider(
        create: (_) => SearchBloc(),
        child: const SearchScreen(),
      ),
    ),

    GoRoute(
      path: '/products',
      builder: (context, state) {
        final filters = state.extra as Map<String, dynamic>?;
        return ProductsScreen(
          gender: filters?['gender'],
          type: filters?['type'], // ← بدل category
        );
      },
    ),
  ],
);
