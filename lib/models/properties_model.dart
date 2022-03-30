import 'package:json_annotation/json_annotation.dart';

part 'properties_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PropertiesModel {
  final double startFrame;
  final double endFrame;
  final List<double>? startCoor;
  final List<double>? endCoor;
  final List<double>? centerCoor;
  final double? radius;

  PropertiesModel(
      {required this.startFrame,required this.endFrame, this.startCoor, this.endCoor, this.centerCoor, this.radius});


  factory PropertiesModel.fromJson(Map<String, dynamic> json) => _$PropertiesModelFromJson(json);

  Map<String, dynamic> toJson() => _$PropertiesModelToJson(this);
}