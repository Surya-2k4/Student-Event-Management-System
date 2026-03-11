class AppConfig {
  static const String baseUrl = "http://localhost:5000/api";

  // Endpoints
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String userDetails = "$baseUrl/auth/user";
  static const String registerEvent = "$baseUrl/events/register-event";
  static const String viewEvents = "$baseUrl/events/view-events";
}
