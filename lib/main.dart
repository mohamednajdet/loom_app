import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// BLoC
import 'blocs/home/home_bloc.dart';
import 'blocs/home/home_event.dart';
import 'blocs/cart/cart_bloc.dart';

// استدعاء الشاشات
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
import 'screens/saved_addresses_screen.dart'; // ✅ شاشة العناوين المحفوظة

import 'models/product_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc()..add(LoadProducts())),
        BlocProvider(create: (_) => CartBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Loom',
        theme: ThemeData(fontFamily: 'Poppins'),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (settings.name == '/otp-register') {
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
              builder: (_) => OtpRegisterScreen(
                name: args['name']!,
                phoneNumber: args['phone']!,
                gender: args['gender']!,
              ),
            );
          }

          if (settings.name == '/otp-login') {
            final phoneNumber = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => OtpLoginScreen(phoneNumber: phoneNumber),
            );
          }

          if (settings.name == '/product-details') {
            final product = settings.arguments as ProductModel;
            return MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product),
            );
          }

          if (settings.name == '/cart') {
            return MaterialPageRoute(builder: (_) => CartScreen());
          }

          if (settings.name == '/confirm-order') {
            return MaterialPageRoute(
              builder: (_) => CheckoutScreen(),
            );
          }

          if (settings.name == '/profile') {
            return MaterialPageRoute(
              builder: (_) => const ProfileScreen(),
            );
          }

          if (settings.name == '/saved_addresses') {
            return MaterialPageRoute(
              builder: (_) => const SavedAddressesScreen(),
            );
          }

          // باقي الراوتات
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case '/login':
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case '/signup':
              return MaterialPageRoute(builder: (_) => const SignUpScreen());
            case '/home':
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            default:
              return null;
          }
        },
      ),
    );
  }
}
