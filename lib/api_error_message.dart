part of apsl_api_call;

/// A collection of predefined error messages that can be used throughout the application
/// to provide consistent and descriptive error messages to the user during API calls.
class ApiErrorMessage {
  // General Errors

  /// A generic error message for unexpected issues.
  static const String socketException = 'Please try again later';

  /// Default title for error messages.
  static const String defaultErrorTitle = "Error";

  /// A generic message indicating something went wrong.
  static const String somethingWentWrong =
      "Something went wrong, please try again later...";

  // No Internet Connection Errors

  /// Title indicating no internet connection.
  static const String noInternet = "No Internet";

  /// Message suggesting the user to check their internet connection.
  static const String noInternetMessage =
      "Please check your internet connection";

  // Authorization Errors

  /// Title indicating an unauthorized access or expired session.
  static const String unauthorisedTitle = "Unauthorised";

  /// Message indicating the session has expired and suggesting the user to log in again.
  static const String unauthorisedMessage =
      "The session is expired due to security reasons, please login again to continue.";

  // Maintenance Errors

  /// Title indicating the system is under maintenance.
  static const String underMaintenanceTitle =
      "Under Maintenance"; // Fixed typo in "Maintainance"

  /// Message indicating the system is down for scheduled maintenance.
  static const String underMaintenanceMessage =
      "Sorry, we're down for scheduled maintenance right now, please try after some time.";

  // Format and Server Errors

  /// Message indicating an invalid format error.
  static const String invalidFormat = "Invalid format";

  /// Message indicating the server is currently unavailable.
  static const String httpErrorMessage = "The server is currently unavailable.";

  // Timeout Errors

  /// Title indicating a request timeout.
  static const String requestTimeoutTitle =
      "Request Timeout"; // Fixed typo in "TimeOut"

  /// Message indicating the server took too long to respond, suggesting potential connectivity issues or server problems.
  static const String requestTimeoutMessage =
      "Looks like the server is taking too long to respond. This can be caused by poor connectivity or an issue with our servers. Please try again in a moment.";
}
