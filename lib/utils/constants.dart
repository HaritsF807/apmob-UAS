class AppConstants {
  // ============= KONFIGURASI API =============
  // PILIH SALAH SATU URL DI BAWAH INI SESUAI KEBUTUHAN:
  
  // 1. Untuk Android Emulator:
  // static const String baseUrl = "http://10.0.2.2:8000/api";
  
  // 2. Untuk Web/Chrome & iOS Simulator (AKTIF SEKARANG):
  static const String baseUrl = "http://localhost:8000/api";
  
  // 3. Untuk perangkat fisik Android/iOS (uncomment dan ganti dengan IP laptop Anda):
  //    Cari IP laptop dengan: ipconfig (Windows) atau ifconfig (Mac/Linux)
  //    Contoh: 192.168.1.5, 192.168.100.10, dll
  // static const String baseUrl = "http://192.168.1.5:8000/api";
  
  // 4. Untuk production/hosting (uncomment dan ganti dengan URL production):
  // static const String baseUrl = "https://api.yourdomain.com/api";
  
  // ============================================
  
  // Colors shared across the app
  static const int primaryColorValue = 0xFF854D0E; // Brown
}
