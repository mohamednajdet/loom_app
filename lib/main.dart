import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart'; // ← الجديد
import 'services/firebase_messaging_helper.dart'; // ← استدعاء الكلاس الجديد

// BLoC
import 'blocs/home/home_bloc.dart';
import 'blocs/home/home_event.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/favorite/favorite_bloc.dart';
import 'blocs/favorite/favorite_event.dart';
import 'blocs/search/search_bloc.dart';
import 'blocs/orders/orders_bloc.dart';
import 'blocs/orders/orders_event.dart';
import 'blocs/theme_cubit.dart';

// الشاشات
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/otp_register_screen.dart';
import 'screens/otp_login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/confirm_order_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/saved_addresses_screen.dart';
import 'screens/change_phone_screen.dart';
import 'screens/map_picker_screen.dart';
import 'screens/feedback_suggestions_screen.dart';
import 'screens/surveys_screen.dart';
import 'screens/about_loom_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/dark_mode_toggle_screen.dart';
import 'screens/delete_account_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/notifications_settings_screen.dart';
import 'package:loom_app/screens/categories_screen.dart';
import 'screens/products_screen.dart';
import 'screens/search_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/discounted_products_screen.dart';

// الموديلات
import 'models/product_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // ✅ تهيئة Firebase
  await Firebase.initializeApp();

  // ✅ تهيئة Firebase Messaging (إشعارات FCM)
  await FirebaseMessagingHelper.initFCM();

  MapboxOptions.setAccessToken(
    'pk.eyJ1IjoibW9oYW1tZWRuYWpkZXQiLCJhIjoiY21ibjJ3a3dqMWlrOTJqcjFpbGtrNjNxZyJ9.b3W25F4loDoXLZC59uEoqA',
  );

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, _) => const SignUpScreen()),
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
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/cart', builder: (_, _) => const CartScreen()),
    GoRoute(
      path: '/product-details',
      builder: (context, state) {
        final product = state.extra as ProductModel;
        return ProductDetailsScreen(product: product);
      },
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => BlocProvider(
        create: (_) =>
            OrdersBloc()..add(LoadOrders()), // تحميل الطلبات عند فتح الشاشة
        child: const OrdersScreen(),
      ),
    ),
    GoRoute(path: '/confirm-order', builder: (_, _) => const CheckoutScreen()),
    GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    GoRoute(
      path: '/saved_addresses',
      builder: (_, _) => const SavedAddressesScreen(),
    ),
    GoRoute(
      path: '/change_phone',
      builder: (_, _) => const ChangePhoneNumberScreen(),
    ),
    GoRoute(path: '/map-picker', builder: (_, _) => const MapPickerScreen()),
    GoRoute(
      path: '/feedback',
      builder: (_, _) => const FeedbackSuggestionsScreen(),
    ),
    GoRoute(path: '/surveys', builder: (_, _) => const SurveysScreen()),
    GoRoute(path: '/about-loom', builder: (_, _) => const AboutLoomScreen()),
    GoRoute(path: '/wishlist', builder: (_, _) => const WishlistScreen()),
    GoRoute(
      path: '/dark-mode-toggle',
      builder: (_, _) => const DarkModeToggleScreen(),
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
    GoRoute(
      path: '/search',
      builder: (context, state) => BlocProvider(
        create: (_) => SearchBloc(),
        child: const SearchScreen(),
      ),
    ),
    GoRoute(
      path: '/discounted_products',
      builder: (context, state) => const DiscountedProductsScreen(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) {
        final filters = state.extra as Map<String, dynamic>?;
        return ProductsScreen(
          gender: filters?['gender'],
          type: filters?['type'],
          categoryType: filters?['categoryType'], // ← أضف هذا السطر 👈
        );
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()), // ✅ Bloc الثيم
        BlocProvider(create: (_) => HomeBloc()..add(LoadProducts())),
        BlocProvider(create: (_) => CartBloc()),
        BlocProvider(create: (_) => FavoriteBloc()..add(LoadFavorites())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode?>(
        builder: (context, themeMode) {
          // إذا بعده يحمل الثيم من SharedPreferences
          if (themeMode == null) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: Color(0xFF546E7A),
                body: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            );
          }
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Loom',
            theme: ThemeData(
              brightness: Brightness.light,
              fontFamily: 'Poppins',
              scaffoldBackgroundColor: Colors.white,
              cardColor: Colors.white,
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF546E7A),
                secondary: Color(0xFF29434E),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'Poppins',
              scaffoldBackgroundColor: const Color(0xFF232F34),
              cardColor: const Color(0xFF29434E), // اسود داكن جداً
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF546E7A),
                secondary: Color(0xFF29434E),
                surface: Color(0xFF232F34),
              ),
            ),
            themeMode: themeMode,
            routerConfig: _router,
            // 👇 هنا أضفت الـ MediaQuery في خاصية builder
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
