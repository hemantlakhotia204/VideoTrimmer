import 'package:video_cut/models/properties_model.dart';
import 'package:json_annotation/json_annotation.dart';


part 'element_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ElementModel {
  final String key;
  final PropertiesModel  properties;

  ElementModel({required this.key, required this.properties});

  factory ElementModel.fromJson(Map<String, dynamic> json) => _$ElementModelFromJson(json);

  Map<String, dynamic> toJson() => _$ElementModelToJson(this);
}