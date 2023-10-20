part of apsl_api_call;

/// A utility class responsible for making API calls and handling exceptions.
///
/// This class provides methods to make both regular and multipart API calls.
/// It also handles various types of exceptions that can occur during the API call process.
class ApiCall {
  /// Makes an API call based on the provided request information.
  ///
  /// This method determines the type of API call (multipart or regular) based on the request information.
  /// It also handles various exceptions like no internet connectivity, HTTP errors, and request timeouts.
  static Future<http.Response> callService({
    required APIRequestInfoObj requestInfo,
  }) async {
    try {
      // Check for Internet connectivity before making the API call.
      await _checkConnectivity();

      // Print the API request details for debugging purposes.
      _printApiDetail(requestInfo);

      // Determine the type of API call (multipart or regular) and make the call.
      return requestInfo.docList.isEmpty
          ? await _callAPI(requestInfo: requestInfo)
              .timeout(Duration(seconds: requestInfo.timeSecond))
          : await _callMultipartAPI(requestInfo: requestInfo)
              .timeout(Duration(seconds: requestInfo.timeSecond));
    } on SocketException catch (e) {
      // Handle exceptions related to no internet connectivity.
      throw AppException(
        message: e.message,
        type: ExceptionType.noInternet,
      );
    } on HttpException catch (e) {
      // Handle generic HTTP exceptions.
      throw AppException(
        message: e.message,
        type: ExceptionType.httpException,
      );
    } on FormatException catch (e) {
      // Handle exceptions related to response format errors.
      throw AppException(
        message: e.source?.toString(),
        type: ExceptionType.formatException,
      );
    } on TimeoutException {
      // Handle request timeout exceptions.
      throw AppException(
        title: ApiErrorMessage.requestTimeoutTitle,
        message: ApiErrorMessage.requestTimeoutMessage,
        type: ExceptionType.timeOut,
      );
    } catch (error) {
      // Rethrow any other unhandled exceptions.
      rethrow;
    }
  }

  /// Checks for internet connectivity.
  ///
  /// This method checks if the device has an active internet connection.
  /// If not, it throws an AppException indicating no internet connectivity.
  static Future<bool> _checkConnectivity() async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw AppException(
        title: ApiErrorMessage.noInternet,
        message: ApiErrorMessage.noInternetMessage,
        type: ExceptionType.noInternet,
      );
    }
    return true;
  }

  /// Makes a regular API call based on the provided request information.
  ///
  /// This method makes standard API calls like GET, POST, PUT, and DELETE.
  /// It constructs the request based on the provided information and sends it to the server.
  static Future<http.Response> _callAPI({
    required APIRequestInfoObj requestInfo,
  }) async {
    String url = requestInfo.url;
    http.Response response;
    Map<String, String>? apiHeader = requestInfo.headers;

    // Determine the type of HTTP request and make the call.
    switch (requestInfo.requestType) {
      case HTTPRequestType.post:
        response = await http.post(
          Uri.parse(url),
          body: requestInfo.parameter == null
              ? null
              : json.encode(requestInfo.parameter),
          headers: apiHeader,
        );
        break;
      case HTTPRequestType.get:
        response = await http.get(
          Uri.parse(url),
          headers: apiHeader,
        );
        break;
      case HTTPRequestType.delete:
        response = await http.delete(
          Uri.parse(url),
          headers: apiHeader,
        );
        break;
      case HTTPRequestType.put:
        response = await http.put(
          Uri.parse(url),
          body: requestInfo.parameter == null
              ? null
              : json.encode(requestInfo.parameter),
          headers: apiHeader,
        );
        break;
    }

    // Print the API response details for debugging purposes.
    _printResponse(response, requestInfo.serviceName);
    return response;
  }

  /// Makes a multipart API call based on the provided request information.
  ///
  /// This method is used for API calls that involve uploading files.
  /// It constructs a multipart request and sends it to the server.
  static Future<http.Response> _callMultipartAPI({
    required APIRequestInfoObj requestInfo,
  }) async {
    Uri uri = Uri.parse(requestInfo.url);
    http.MultipartRequest request = http.MultipartRequest(
      describeEnum(requestInfo.requestType),
      uri,
    );

    // Add parameters and headers to the request.
    requestInfo.parameter?.forEach((key, value) => request.fields[key] = value);
    Map<String, String>? apiHeader = requestInfo.headers;
    apiHeader?.forEach((key, value) => request.headers[key] = value);

    // Process and add files to the request.
    List<http.MultipartFile> successfulFiles = [];
    List<String> failedFiles = [];

    List<Future<void>> filesFutures = requestInfo.docList
        .map(
          (docInfo) => docInfo.docPathList.map(
            (docPath) async {
              try {
                http.MultipartFile file = await http.MultipartFile.fromPath(
                  docInfo.docKey,
                  docPath,
                  filename: basename(docPath),
                );
                successfulFiles.add(file);
              } catch (error) {
                // Handle file upload errors.
                debugPrint(
                    "Error While uploading Image: $docPath, Error: $error");
                failedFiles.add(docPath);
              }
            },
          ),
        )
        .expand((_) => _)
        .toList();

    await Future.wait(filesFutures);
    request.files.addAll(successfulFiles);

    // Send the multipart request and get the response.
    http.Response response =
        await http.Response.fromStream(await request.send());

    // Print the API response details for debugging purposes.
    _printResponse(response, requestInfo.serviceName);
    return response;
  }

  /// Prints API request details for debugging purposes.
  ///
  /// This method logs the details of the API request, including the URL, parameters, and headers.
  static void _printApiDetail(APIRequestInfoObj info) {
    if (kReleaseMode) return;
    String apiLog = """
        ${info.serviceName} Service Parameters
        |-------------------------------------------------------------------------------------------------------------------------
        | ApiType :- ${describeEnum(info.requestType)}
        | URL     :- ${info.url}
        | Params  :- ${info.parameter}
        |-------------------------------------------------------------------------------------------------------------------------
        """;
    debugPrint(apiLog);
  }

  /// Prints API response details for debugging purposes.
  ///
  /// This method logs the details of the API response, including the status code and response body.
  static void _printResponse(http.Response response, String serviceName) {
    if (kReleaseMode) return;
    if (response.statusCode < 300) return;
    String apiLog = """
        $serviceName Service Response
        |--------------------------------------------------------------------------------------------------------------------------
        | API        :- $serviceName
        | StatusCode :- ${response.statusCode}
        | Message    :- ${response.body}
        |--------------------------------------------------------------------------------------------------------------------------
       """;
    debugPrint(apiLog);
  }
}

/// Represents the information required for an API request.
///
/// This class encapsulates all the necessary details needed to make an API call.
/// It includes the type of HTTP request (GET, POST, PUT, DELETE), the request URL,
/// any parameters to be sent with the request, headers, documents for multipart requests,
/// the name of the service being called, and a timeout duration for the request.
class APIRequestInfoObj {
  /// Type of the HTTP request (e.g., POST, GET, DELETE, PUT).
  HTTPRequestType requestType;

  /// The endpoint URL for the API call.
  String url;

  /// Parameters to be sent with the API request.
  Map<String, dynamic>? parameter;

  /// Headers to be included in the API request.
  Map<String, String>? headers;

  /// List of documents to be uploaded in case of a multipart request.
  List<UploadDocumentObj> docList;

  /// Name of the service or API being called (used for debugging purposes).
  String serviceName;

  /// Timeout duration for the API call.
  int timeSecond;

  /// Constructor for the `APIRequestInfoObj` class.
  ///
  /// Initializes the class with the provided details for the API call.
  APIRequestInfoObj({
    this.requestType = HTTPRequestType.post,
    this.parameter,
    this.headers,
    this.docList = const [],
    required this.url,
    this.serviceName = "",
    this.timeSecond = 90,
  });
}

/// Represents the information required for uploading a document.
///
/// This class is used in conjunction with the `APIRequestInfoObj` class for making
/// multipart API requests. It specifies the key for the document and a list of paths
/// to the documents to be uploaded.
class UploadDocumentObj {
  /// Key for the document in the multipart request.
  String docKey;

  /// List of paths to the documents to be uploaded.
  List<String> docPathList;

  /// Constructor for the `UploadDocumentObj` class.
  ///
  /// Initializes the class with the provided key and list of document paths.
  UploadDocumentObj({
    this.docKey = "",
    this.docPathList = const [],
  });
}
