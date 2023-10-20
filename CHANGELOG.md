## [0.0.1] - Initial Release

### Added
- Initial implementation of the `apsl_api_call` package.
- `ApiCall` class for handling API calls and exceptions.
  - Methods for regular and multipart API calls.
  - Connectivity checks before making API calls.
  - Exception handling for various error scenarios.
- `APIRequestInfoObj` class for representing the information required for an API request.
- `UploadDocumentObj` class for representing the information required for uploading a document.
- `ApiErrorMessage` class providing a collection of predefined error messages for API calls.
  - General error messages.
  - No internet connection error messages.
  - Authorization error messages.
  - Maintenance error messages.
  - Format and server error messages.
  - Timeout error messages.

### Notes
- This is the initial release of the package, providing foundational functionality for making API calls and handling exceptions.
