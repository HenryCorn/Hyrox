# hyrox_api_client.api.HyroxApiApi

## Load the API package
```dart
import 'package:hyrox_api_client/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**weatherforecastGet**](HyroxApiApi.md#weatherforecastget) | **GET** /weatherforecast | 


# **weatherforecastGet**
> BuiltList<WeatherForecast> weatherforecastGet()



### Example
```dart
import 'package:hyrox_api_client/api.dart';

final api = HyroxApiClient().getHyroxApiApi();

try {
    final response = api.weatherforecastGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling HyroxApiApi->weatherforecastGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**BuiltList&lt;WeatherForecast&gt;**](WeatherForecast.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

