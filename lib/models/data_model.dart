import 'package:video_cut/models/element_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_model.g.dart';


@JsonSerializable(explicitToJson: true)
class DataModel {

final List<ElementModel> elements;

  DataModel(this.elements);

  factory DataModel.fromJson(Map<String, dynamic> json) => _$DataModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataModelToJson(this);
}

