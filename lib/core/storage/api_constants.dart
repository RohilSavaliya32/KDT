class ApiConstants {
  ApiConstants._();
  static const String baseUrl = "https://www.kdtdiamond.com/api/v1";
  // ==========================
  // Contact
  // ==========================
  static const String contact = "/contact";

  // ==========================
  // Currency
  // ==========================
  static const String currencyContext = "/currency/context";
  static const String currencyRates = "/currency/rates";

  // ==========================
  // Settings
  // ==========================
  static const String settings = "/settings/settings";

  static String settingsByType(String type) =>
      "/settings/$type";

  // ==========================
  // Coupons
  // ==========================
  static const String validateCoupon = "/coupons/validate";
  static const String availableCoupons = "/coupons/available";

  // ==========================
  // Reviews
  // ==========================
  static const String reviews = "/reviews";

  static String diamondReviews(String diamondId) =>
      "/reviews/$diamondId";

  // ==========================
  // Addresses
  // ==========================
  static const String addresses = "/addresses";

  // ==========================
  // Orders
  // ==========================
  static const String orders = "/orders";
  static const String myOrders = "/orders/myorders";

  static String uploadPaymentProof(String orderId) =>
      "/orders/$orderId/payment-proof";

  static String cancelOrder(String orderId) =>
      "/orders/$orderId/cancel";

  // ==========================
  // Diamonds
  // ==========================
  static const String diamonds = "/diamonds";


  static String diamondsPagination({
    int page = 1,
    int limit = 20,
  }) =>
      "/diamonds?page=$page&limit=$limit";

  static String trendingDiamonds({
    int limit = 6,
  }) =>
      "/diamonds?sortBy=trending&limit=$limit&pagination=true";

  // ==========================
  // Authentication
  // ==========================
  static const String register = "/auth/register";  //used
  static const String login = "/auth/login";        //used
  static const String firebaseLogin = "/auth/firebase";  //used
  static const String profile = "/auth/profile";         //used
  static const String profileImage = "/auth/profile/image"; //used
  static const String cart = "/auth/cart";                  //used
  static const String wishlist = "/auth/wishlist";          //used
  static const String wishlistAdd = "/auth/wishlist/add";   //used
  static const String checkMobile = "/auth/check-mobile";
  static const String checkUser = "/auth/check-user";   //used
  static const String fcmToken = "/auth/fcm-token";     //used
  static const String logout = "/auth/logout";          //used
  static const String Notification = "/notifications/preferences";

}