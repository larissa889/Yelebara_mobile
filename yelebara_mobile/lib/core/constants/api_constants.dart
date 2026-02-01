class ApiConstants {
  // ---------------------------------------------------------------------------
  // 🌍 API CONFIGURATION
  // ---------------------------------------------------------------------------
  // Select your environment below by uncommenting the appropriate line.
  
  // OPTION 1: Localhost (Browser / iOS Simulator)
  // static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // OPTION 2: Android Emulator (Standard)
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // OPTION 3: REAL DEVICE / NETWORK (Your detected IP)
  // This allows devices on the same WiFi to connect to this machine.
  static const String baseUrl = 'http://192.168.10.105:8000/api';

  // ---------------------------------------------------------------------------
  
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String userEndpoint = '/user';
}
