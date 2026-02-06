import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelebara_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:yelebara_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:yelebara_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:yelebara_mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:yelebara_mobile/features/home/presentation/pages/home_page.dart';
import 'package:yelebara_mobile/features/admin/presentation/pages/admin_home_page.dart';
import 'package:yelebara_mobile/features/presseur/presentation/pages/presseur_home_page.dart';
import 'package:yelebara_mobile/features/orders/presentation/pages/create_order_page.dart';
import 'package:yelebara_mobile/features/orders/presentation/pages/clothing_selection_page.dart';
import 'package:yelebara_mobile/features/orders/presentation/pages/location_selection_page.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:yelebara_mobile/features/beneficiaries/presentation/pages/beneficiary_directory_page.dart';
import 'package:yelebara_mobile/features/orders/presentation/pages/orders_page.dart';
import 'package:yelebara_mobile/features/profile/presentation/pages/profile_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Auth Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      
      // Home Routes (by role)
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/admin/home',
        builder: (context, state) => const AdminHomePage(),
      ),
      GoRoute(
        path: '/presseur/home',
        builder: (context, state) => const PresseurHomePage(),
      ),
      GoRoute(
        path: '/create-order',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return CreateOrderPage(
            serviceTitle: extras['serviceTitle'] as String,
            servicePrice: extras['servicePrice'] as String?,
            serviceIcon: extras['serviceIcon'] as IconData,
            serviceColor: extras['serviceColor'] as Color,
            existingOrder: extras['existingOrder'] as OrderEntity?,
          );
        },
      ),
      GoRoute(
        path: '/clothing-selection',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return ClothingSelectionPage(
            serviceTitle: extras['serviceTitle'] as String,
            serviceIcon: extras['serviceIcon'] as IconData,
            serviceColor: extras['serviceColor'] as Color,
            selectedDate: extras['selectedDate'] as DateTime,
            selectedTime: extras['selectedTime'] as TimeOfDay,
            pickupAtHome: extras['pickupAtHome'] as bool,
            instructions: extras['instructions'] as String,
          );
        },
      ),
      GoRoute(
        path: '/location-selection',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          return LocationSelectionPage(
            serviceTitle: extras['serviceTitle'] as String,
            serviceIcon: extras['serviceIcon'] as IconData,
            serviceColor: extras['serviceColor'] as Color,
            selectedDate: extras['selectedDate'] as DateTime,
            selectedTime: extras['selectedTime'] as TimeOfDay,
            pickupAtHome: extras['pickupAtHome'] as bool,
            instructions: extras['instructions'] as String,
            clothingSelection: extras['clothingSelection'] as Map<String, dynamic>,
            totalItems: extras['totalItems'] as int,
            finalPrice: extras['finalPrice'] as int,
            formattedPrice: extras['formattedPrice'] as String,
          );
        },
      ),
      GoRoute(
        path: '/pressing',
        builder: (context, state) => const BeneficiaryDirectoryPage(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const ClientOrdersPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ClientProfilePage(),
      ),
    ],
  );
});
