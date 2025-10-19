//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:openapi/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'weather_forecast.g.dart';

/// WeatherForecast
///
/// Properties:
/// * [date] 
/// * [temperatureC] 
/// * [summary] 
/// * [temperatureF] 
@BuiltValue()
abstract class WeatherForecast implements Built<WeatherForecast, WeatherForecastBuilder> {
  @BuiltValueField(wireName: r'date')
  Date? get date;

  @BuiltValueField(wireName: r'temperatureC')
  int? get temperatureC;

  @BuiltValueField(wireName: r'summary')
  String? get summary;

  @BuiltValueField(wireName: r'temperatureF')
  int? get temperatureF;

  WeatherForecast._();

  factory WeatherForecast([void updates(WeatherForecastBuilder b)]) = _$WeatherForecast;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WeatherForecastBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WeatherForecast> get serializer => _$WeatherForecastSerializer();
}

class _$WeatherForecastSerializer implements PrimitiveSerializer<WeatherForecast> {
  @override
  final Iterable<Type> types = const [WeatherForecast, _$WeatherForecast];

  @override
  final String wireName = r'WeatherForecast';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WeatherForecast object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.date != null) {
      yield r'date';
      yield serializers.serialize(
        object.date,
        specifiedType: const FullType(Date),
      );
    }
    if (object.temperatureC != null) {
      yield r'temperatureC';
      yield serializers.serialize(
        object.temperatureC,
        specifiedType: const FullType(int),
      );
    }
    if (object.summary != null) {
      yield r'summary';
      yield serializers.serialize(
        object.summary,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.temperatureF != null) {
      yield r'temperatureF';
      yield serializers.serialize(
        object.temperatureF,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WeatherForecast object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WeatherForecastBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Date),
          ) as Date;
          result.date = valueDes;
          break;
        case r'temperatureC':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.temperatureC = valueDes;
          break;
        case r'summary':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.summary = valueDes;
          break;
        case r'temperatureF':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.temperatureF = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WeatherForecast deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WeatherForecastBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

