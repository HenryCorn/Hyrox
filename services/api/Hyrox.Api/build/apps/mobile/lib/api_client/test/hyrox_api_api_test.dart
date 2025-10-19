import 'package:test/test.dart';
import 'package:hyrox_api_client/hyrox_api_client.dart';


/// tests for HyroxApiApi
void main() {
  final instance = HyroxApiClient().getHyroxApiApi();

  group(HyroxApiApi, () {
    //Future<BuiltList<WeatherForecast>> weatherforecastGet() async
    test('test weatherforecastGet', () async {
      // TODO
    });

  });
}
