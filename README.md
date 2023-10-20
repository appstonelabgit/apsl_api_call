# APSL API Call Package

A Dart package designed to simplify the process of making API calls and handling exceptions.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Making an API Call](#making-an-api-call)
  - [Handling Exceptions](#handling-exceptions)
- [Classes & Methods](#classes--methods)
- [Contributing](#contributing)
- [License](#license)

## Features

- **API Calls**: Provides methods for making both regular and multipart API calls.
- **Exception Handling**: Handles common exceptions such as no internet, server errors, timeouts, and more.
- **Connectivity Checks**: Automatically checks for internet connectivity before making an API call.
- **Predefined Error Messages**: Includes a collection of predefined error messages for various API call scenarios.

## Installation

To use the `apsl_api_call` package, add it as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  apsl_api_call: ^1.0.0
```


## Usage

**Making an API Call**

```
import 'package:apsl_api_call/apsl_api_call.dart';

// Define your API request information
APIRequestInfoObj requestInfo = APIRequestInfoObj(
    requestType: HTTPRequestType.get,
    url: "https://api.example.com/data",
    headers: {
        "Authorization": "Bearer YOUR_TOKEN"
    },
    serviceName: "GetData"
);

// Make the API call
http.Response response = await ApiCall.callService(requestInfo: requestInfo);
```


## Contributing
Contributions are welcome! Please read our contributing guidelines to get started.

