import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/client_home_screen.dart';
import '../screens/driver_home_screen.dart';
import '../screens/map_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/create_ride_screen.dart';
import '../screens/ride_history_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String clientHome = '/client-home';
  static const String driverHome = '/driver-home';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String createRide = '/create-ride';
  static const String rideHistory = '/ride-history';
  static const String scheduledRides = '/scheduled-rides';
  static const String stats = '/stats';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    clientHome: (context) => const ClientHomeScreen(),
    driverHome: (context) => const DriverHomeScreen(),
    map: (context) => const MapScreen(),
    profile: (context) => const ProfileScreen(),
    createRide: (context) => const CreateRideScreen(),
    rideHistory: (context) => const RideHistoryScreen(),
  };
}