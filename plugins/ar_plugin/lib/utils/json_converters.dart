// The code in this file is adapted from Oleksandr Leuschenko' ARKit Flutter Plugin (https://github.com/olexale/arkit_flutter_plugin)
import 'package:json_annotation/json_annotation.dart';
import 'package:vector_math/vector_math_64.dart';

class MatrixConverter implements JsonConverter<Matrix4, List<dynamic>> {
  const MatrixConverter();

  @override
  Matrix4 fromJson(List<dynamic> json) {
    try {
      return Matrix4.fromList(json.cast<double>());
    } catch (e) {
      return Matrix4.identity();
    }
  }

  @override
  List<dynamic> toJson(Matrix4 matrix) {
    final list = List<double>.filled(16, 0.0);
    matrix.copyIntoArray(list);
    return list;
  }
}

class VectorConverter implements JsonConverter<Vector3, List<dynamic>> {
  @override
  Vector3 fromJson(List json) {
    try {
      return Vector3.array(json.cast<double>());
    } catch (e) {
      return Vector3.all(1);
    }
  }

  @override
  List toJson(Vector3 vector3) {
    return [vector3.x, vector3.y, vector3.z];
  }
}
