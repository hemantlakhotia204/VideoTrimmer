// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'element_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElementModel _$ElementModelFromJson(Map<String, dynamic> json) => ElementModel(
      key: json['key'] as String,
      properties:
          PropertiesModel.fromJson(json['properties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ElementModelToJson(ElementModel instance) =>
    <String, dynamic>{
      'key': instance.key,
      'properties': instance.properties.toJson(),
    };
