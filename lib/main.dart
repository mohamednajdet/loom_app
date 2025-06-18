import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// BLoC
import 'blocs/home/home_bloc.dart';
import 'blocs/home/home_event.dart';
import 'blocs/cart/cart_bloc.dart';
import 'blocs/favorite/favorite_bloc.dart';
import 'blocs/favorite/favorite_event.dart';
import 'blocs/theme_cubit.dart'; // ✅ Bloc الثيم

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
// الموديلات
import 'models/product_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  MapboxOptions.setAccessToken(
    'pk.eyJ1IjoibW9oYW1tZWRuYWpkZXQiLCJhIjoiY21ibjJ3a3dqMWlrOTJqcjFpbGtrNjNxZyJ9.b3W25F4loDoXLZC59uEoqA',
  );

  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
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
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
    GoRoute(
      path: '/product-details',
      builder: (context, state) {
        final product = state.extra as ProductModel;
        return ProductDetailsScreen(product: product);
      },
    ),
    GoRoute(path: '/confirm-order', builder: (_, __) => const CheckoutScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/saved_addresses', builder: (_, __) => const SavedAddressesScreen()),
    GoRoute(path: '/change_phone', builder: (_, __) => const ChangePhoneNumberScreen()),
    GoRoute(path: '/map-picker', builder: (_, __) => const MapPickerScreen()),
    GoRoute(path: '/feedback', builder: (_, __) => const FeedbackSuggestionsScreen()),
    GoRoute(path: '/surveys', builder: (_, __) => const SurveysScreen()),
    GoRoute(path: '/about-loom', builder: (_, __) => const AboutLoomScreen()),
    GoRoute(path: '/wishlist', builder: (_, __) => const WishlistScreen()),
    GoRoute(path: '/dark-mode-toggle', builder: (_, __) => const DarkModeToggleScreen()),
    GoRoute(path: '/delete_account', builder: (context, state) => const DeleteAccountScreen()),
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
                body: Center(child: CircularProgressIndicator(color: Colors.white)),
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
          );
        },
      ),
    );
  }
}
