// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'properties_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertiesModel _$PropertiesModelFromJson(Map<String, dynamic> json) =>
    PropertiesModel(
      startFrame: (json['startFrame'] as num).toDouble(),
      endFrame: (json['endFrame'] as num).toDouble(),
      startCoor: (json['startCoor'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      endCoor: (json['endCoor'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      centerCoor: (json['centerCoor'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      radius: (json['radius'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PropertiesModelToJson(PropertiesModel instance) =>
    <String, dynamic>{
      'startFrame': instance.startFrame,
      'endFrame': instance.endFrame,
      'startCoor': instance.startCoor,
      'endCoor': instance.endCoor,
      'centerCoor': instance.centerCoor,
      'radius': instance.radius,
    };
